# pg_reliability

**作者**

Chrisx

**日期**

2021-04-26

**内容**

可靠性配置

* fsync
* synchronous_commit
* wal_sync_method
* full_page_writes

参数详解

ref [Write Ahead Log](https://www.postgresql.org/docs/13/runtime-config-wal.html#GUC-WAL-SYNC-METHOD)

---

[toc]

## 介绍

与数据库的可靠性有关。

* fsync
确保更新被物理地写入到磁盘，这保证了数据库集簇在一次操作系统或者硬件崩溃后能恢复到一个一致的状态。 虽然关闭fsync常常可以得到性能上的收益，但当发生断电或系统崩溃时可能造成不可恢复的数据损坏。某些测试环境可以关闭此参数提高性能。
以在多个时机来完成：在集簇被关闭时或在 fsync 因为运行initdb --sync-only而打开时、运行sync时、卸载文件系统时或者重启服务器时。
多数情况下可以考虑关闭synchronous_commit，来达到关闭fsync的带来的收益，而没有数据损坏的风险

* synchronous_commit
指定数据库服务器返回“success”指示给客户端之前，必须要完成多少WAL处理。 off模式，无需等待，可提高性能。不同于fsync，将这个参数设置为off不会产生数据库不一致性的风险。因此，当性能比完全确保事务的持久性更重要时，关闭synchronous_commit可以作为一个有效的代替手段。

如果synchronous_standby_names为空，则唯一有意义的设置为on 和 off ； remote_apply，remote_write 和 local都提供与on相同的本地同步级别。
如果synchronous_standby_names为非空，synchronous_commit也控制是否事务提交将等待它们的 WAL 记录在后备服务器上被处理。

当设置为 remote_apply 时，提交将等待，直到来自当前同步备用服务器的答复显示他们已收到事务的提交记录并应用了它，以便它变得对备用服务器上的查询可见，并写入备用服务器上的持久存储。但会有更大延迟
当设置为on时，提交将等待，直到来自于当前同步的后备服务器的回复显示它们已经收到了事务的提交记录并将其刷入了磁盘。 这保证事务将不会被丢失，除非主服务器和所有同步后备都遭受到了数据库存储损坏的问题。
当这个参数被设置为remote_write时，提交将等待，直到来自当前的同步后备的回复指示它们已经收到了该事务的提交记录并且已经把该记录写到它们的文件系统，这种设置保证数据得以保存，在PostgreSQL的后备服务器实例崩溃时，但是不能保证后备服务器遭受操作系统级别崩溃时数据能被保持，因为数据不一定必须要在后备机上达到持久存储。
设置local会导致提交等待本地刷写到磁盘，而不是复制。在使用同步复制时这通常是不可取的

| synchronous_commit setting | local durable commit | standby durable commit after PG crash | standby durable commit after OS crash | standby query consistency |
| -------------------------- | -------------------- | ------------------------------------- | ------------------------------------- | ------------------------- |
| remote_apply               | •                    | •                                     | •                                     | •                         |
| on                         | •                    | •                                     | •                                     |
| remote_write               | •                    | •                                     |                                       |
| local                      | •                    |                                       |                                       |
| off                        |                      |                                       |                                       |

* wal_sync_method
用来向强制 WAL 更新到磁盘的方法。pg没有O_DIRECT方式

* full_page_writes

当这个参数为打开时，PostgreSQL服务器在一个检查点之后的页面的第一次修改期间将每个页面的全部内容写到 WAL 中。这么做是因为在操作系统崩溃期间正在处理的一次页写入可能只有部分完成，从而导致在一个磁盘页面中混合有新旧数据。在崩溃后的恢复期间，通常存储在 WAL 中的行级改变数据不足以完全恢复这样一个页面。存储完整的页面映像可以保证页面被正确存储，但代价是增加了必须被写入 WAL 的数据量（因为 WAL 重放总是从一个检查点开始，所以在检查点后每个页面的第一次改变时这样做就够了。因此，一种减小全页面写开销的方法是增加检查点间隔参数值）。