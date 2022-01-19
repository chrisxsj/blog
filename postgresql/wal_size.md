# wal_size

**作者**

Chrisx

**日期**

2021-04-29

**内容**

WAL大小
WAL日志数量

ref [参数max_wal_size与min_wal_size的计算与影响](https://www.postgresql.org/message-id/e0990ee6-6efa-8ca0-4bdc-9052add439e7@postgresdata.com)
ref [WAL配置](http://postgres.cn/docs/13/wal-configuration.html)
ref [WAL Configuration](https://www.postgresql.org/docs/13/wal-configuration.html)

---

[toc]

## wal写放大

原因

1. 全页写
2. 频繁CTID变更
3. 大量DML操作

解决

1. 增加checkpoint间隔，减少全页写次数
2. 减少dml操作
3. wal压缩

## WAL空间大小

参数

通常情况下，pg_wal目录中的 WAL 段文件数量取决于min_wal_size、max_wal_size以及在之前的检查点周期中产生的 WAL 数量。

* max_wal_size，两个检查点之间，wal可增长的最大大小，这是一个软限制。
* min_wal_size，检查点后用来保留的，用于未来循环使用的wal文件。可以被用来确保有足够的 WAL 空间被保留来应付 WAL 使用的高峰

WAL空间使用情况如下

1. 如果日志量大于max_wal_size，则WAL日志空间尽量保持在max_wal_size。因为会触发检查点，不需要的段文件将被移除直到系统回到这个限制以下。
2. 如果日志量小于max_wal_size，则WAL日志空间至少保持min_wal_size。
3. 通常情况下，WAL日志空间大小在min_wal_size和max_wal_size之间动态评估。该估计基于在以前的检查点周期中使用的WAL文件数的动态平均值。如果实际使用量超过估计值，动态平均数会立即增加。

<!--
通常情况下，pg_wal目录中的 WAL 段文件数量取决于min_wal_size、max_wal_size以及在之前的检查点周期中产生的 WAL 数量。当旧的日志段文件不再被需要时，它们将被移除或者被再利用（也就是被重命名变成数列中未来的段）。如果由于日志输出率的短期峰值导致超过max_wal_size，会触发检查点，不需要的段文件将被移除直到系统回到这个限制以下。低于该限制时，系统会再利用足够的 WAL 文件来覆盖直到下一个检查点之前的需要。这种需要是基于之前的检查点周期中使用的 WAL 文件数量的移动平均数估算出来的。如果实际用量超过估计值，移动平均数会立即增加，因此它能在一定程度上适应峰值用量而不是平均用量。min_wal_size对回收给未来使用的 WAL 文件的量设置了一个最小值，这个参数指定数量的 WAL 将总是被回收给未来使用，即便系统很闲并且 WAL 用量估计建议只需要一点点 WAL 时也是如此。

如果WAL文件的总大小超过max_wal_size，则将启动checkpoint。通过checkpoint，将创建一个新的REDO点，然后不必要的旧文件将被回收。通过这种方式，PostgreSQL将始终保存数据库恢复所需的WAL段文件。
-->

如：

```sql
postgres=# select name,setting,unit from pg_settings where name like '%wal_size%';
     name     | setting | unit
--------------+---------+------
 max_wal_size | 1024    | MB
 min_wal_size | 80      | MB
(2 rows)
```

```sh
$ ll
total 81936
drwx------  3 pg126 pg126     4096 Apr 28 10:09 ./
drwx------ 20 pg126 pg126     4096 Apr 29 15:18 ../
-rw-------  1 pg126 pg126      337 Apr 14 14:02 000000010000000000000009.00000028.backup
-rw-------  1 pg126 pg126 16777216 Apr 28 16:09 00000001000000000000000A
-rw-------  1 pg126 pg126 16777216 Apr 14 13:52 00000001000000000000000B
-rw-------  1 pg126 pg126 16777216 Apr 14 13:52 00000001000000000000000C
-rw-------  1 pg126 pg126 16777216 Apr 14 14:02 00000001000000000000000D
-rw-------  1 pg126 pg126 16777216 Apr 14 14:02 00000001000000000000000E
drwx------  2 pg126 pg126     4096 Apr 28 10:09 archive_status/

```

pg_wal大小至少保留80MB的文件，也就是00000001000000000000000A-E 5个文件

执行一个大型操作，查看pg_wal大小超过了1GB

```sh
$ du -sm pg_wal
1329    pg_wal

```

执行检查点后，查看pg_wal大小为801MB，低于1GB

```sh
$ du -sm pg_wal/
801     pg_wal/

```

再次执行检查点后，查看pg_wal大小依然为801MB，与上一个检查点周期WAL大小一致

```sh
$ du -sm pg_wal/
801     pg_wal/

```

## 影响WAL大小的因素

不管怎样，max_wal_size从来不是一个硬限制，因此你应该总是应该留出充足的净空来避免耗尽磁盘空间，会有以下因素影响WAL大小。

WAL异常增长，或WAL一直膨胀且超过max_wal_size，执行检查点后，WAL使用量未见降低，需要排查以下因素。

* 独立于max_wal_size之外，wal_keep_size（MB）+ 1 个最近的 WAL 文件将总是被保留。（pg13之前的版本是wal_keep_segments）
* 启用了WAL 归档，旧的段在被归档之前不能被移除或者再利用。
* 启用了复制槽功能，一个使用了复制槽的较慢或者失败的后备服务器也会导致WAL不能被删除或重用。
* checkpoing未完成，
* 长事务未提交。

## standby也遵循这一规则

在归档恢复模式或后备模式，服务器周期性地执行重启点。和正常操作时的检查点相似：服务器强制它所有的状态到磁盘，更新pg_control来指示已被处理的WAL数据不需要被再次扫描，并且接着回收pg_wal中的任何旧日志段文件。
