# Continuous_archiving_in_standby

**作者**

chrisx

**日期**

2021-07-07

**内容**

在后备机上连续归档

ref [Continuous Archiving in Standby](https://www.postgresql.org/docs/13/warm-standby.html#CONTINUOUS-ARCHIVING-IN-STANDBY)

----

[toc]

## 连续归档应用 Continuous archiving in standby

当在一个后备机上使用连续归档时，有两种不同的情景：WAL 归档在主服务器 和后备机之间共享，或者后备机有自己的 WAL 归档。当后备机拥有其自身的 WAL 归档时，将archive_mode设置为 always(备机设置此参数)，后备机将在收到每个 WAL 段时调用归档命令， 不管它是从归档恢复还是使用流复制恢复。

备机修改参数(备机居然可以修改参数)

```sql
alter system set archive_mode = always;

```

还有一种方式，就是主库产生两份归档，其中一份存放到备库

1.设置ssh互信
2.archive_commandshe设置额外的命令scp

```sql
alter system set archive_command='cp %p /db/arch/%f;scp /db/arch/%f 10.247.32.163:/db/arch';
```