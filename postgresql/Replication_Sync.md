# Replication_sync

**作者**

Chrisx

**日期**

2021-07-07

**内容**

同步流复制

流复制同步异步转换

ref [Synchronous Replication](https://www.postgresql.org/docs/13/warm-standby.html#SYNCHRONOUS-REPLICATION)

----

[toc]

## 同步流复制介绍

PostgreSQL流复制默认是异步的。如果主服务器崩溃，则某些已被提交的事务可能还没有被复制到后备服务器，这会导致数据丢失。数据的丢失量与故障转移时的复制延迟成比例。同步流复制则保证了数据库不丢失情况。
在请求同步复制时，一个写事务的每次提交将一直等待，直到收到一个确认表明该提交在主服务器和后备服务器上都已经被写入到磁盘上的预写式日志中。数据会被丢失的唯一可能性是主服务器和后备服务器在同一时间都崩溃。
同步流复制 “ 陷阱 ” ，在同步流复制中由于主库提交事务时需等待至少一个备库接收 WAL 并返回确认信息后主库才返回成功。基于以上前提，若备库宕机，则主库所有 写操作将被阻塞。所以若生产环境为一主一备，不应使用同步流复制。 一主多从的情况下可以选择一主多从。

## 基本配置

主库额外配置以下参数

```sql
alter system set synchronous_standby_names='pg_rep1'; --指定哪些备用服务器启用同步复制策略
alter system set synchronous_commit=on;  --指定同步策略的级别
```

:warning: synchronous_standby_names 指定的是同步备库 recovery.conf 文件的 primary_conninfo 参数的 application_name

## 多个同步后备

同步复制支持一个或者更多个同步后备服务器，事务将会等待，直到所有同步后备服务器都确认收到了它们的数据为止。
事务必须等待其回复的同步后备的数量由synchronous_standby_names指定。这个参数还指定一个后备服务器名称及方法（FIRST和ANY）的列表来从列出的后备中选取同步后备。

1. 方法FIRST指定一种基于优先的同步复制并且让事务提交等待，直到它们的WAL记录被复制到基于优先级选中的所要求数量的同步后备上为止

```sql
synchronous_standby_names='FIRST 2(s1,s2,s3)'
```

在这个例子中，如果有四个后备服务器s1、s2、s3和s4在运行，两个后备服务器s1和s2将被选中为同步后备，因为它们出现在后备服务器名称列表的前部。s3是一个潜在的同步后备（potential），当s1或s2中的任何一个失效， 它就会取而代之。s4则是一个异步后备因为它的名字不在列表中。

2. 方法ANY指定一种基于规定数量的同步复制并且让事务提交等待，直到它们的WAL记录至少被复制到列表中所要求数量的同步后备上为止。

```sql
synchronous_standby_names = 'ANY 2 (s1, s2, s3)'
```

在这个例子中，如果有四台后备服务器s1、s2、s3以及s4正在运行，事务提交将会等待来自至少其中任意两台后备服务器（quorum）的回复。s4是一台异步后备，因为它的名字不在该列表中。s3是一个

后备服务器的同步状态可以使用pg_stat_replication视图查看。

```sql
postgres=# select pid,usename,application_name,client_addr,state,sync_state from pg_stat_replication;
 pid  | usename | application_name | client_addr  |   state   | sync_state
------+---------+------------------+--------------+-----------+------------
 3740 | repuser | pg_rep1          | 192.168.6.17 | streaming | sync
(1 row)

```

sync_state字段的可选项包括

* async：表示备库为异步同步方式
* sync： 当前备库为同步方式
* potential：表示备库当前为异步同步方式，如果当前的同步备库宕机后，异步备库可升级成为同步备库。
* quorum：表示备库为quorum standbys的候选

<!--
PG9.6 时只支持基于优先级的同步备库方式， PG10 的 synchronous_standby_names 参数新增 ANY 选项，可以设置任意一个或多个备库为同步备 库，这种基于 Quorum 的同步备库方式是 PG10 版本的新特性
-->

## 监控

pg_stat_replication 中以下列能监控延迟情况

write_lag < flush_lag < replay_lag

* write_lag         等待备库返回确认信息，此时日志流没有写入备库的 wal 文件，还在操作系统缓存中
* flush_lag         等待备库返回确认信息，此时日志流写入备库的 wal 文件，还没有应用
* replay_lag         等待备库返回确认信息，此时日志流写入备库的 wal 文件，并且已应用

## 高可用性规划

高可用的最佳方案是确保有所要求数量的同步后备。这可以通过使用synchronous_standby_names指定多个潜在后备服务器来实现。

如果实在无法保持所要求数量的同步后备，那么应该减少synchronous_standby_names中指定的事务提交应该等待其回应的同步后备的数量（或者禁用），并且在主服务器上重载配置文件。

即便当同步复制被启用时，个体事务也可以被配置为不等待复制，做法是将synchronous_commit参数设置为local或off。

基于以上说法，可以实现流复制同步异步转换

数据库流复制支持同步和异步方式，同步方式能提供最大保护，异步方式能提供最大可用。同步方式在网络异常或备库宕机情况下，主库操作也会受影响，事务操作会出现等待状态。当出现以上场景时，我们总是希望进行降级，将同步转为异步，避免主库hang住。

### 同步异步转换

修改synchronous_standby_names，然后reload生效。也就是说转换过程不需要重启服务器，这一点非常方便的。

* 同步流复制，synchronous_standby_names指定需要启用同步复制策略的备用服务器
* 异步流复制，synchronous_standby_names为空

示例

```sql
alter system set synchronous_standby_names='standby12';
select pg_reload_conf();

此时关闭备库，主库执行insert，主库hang住

alter system set synchronous_standby_names='';
select pg_reload_conf();

此时insert就执行成功了
```

### 同步复制不等待

修改synchronous_commit参数设置为local或off，reload生效。即使为同步复制，主库事务也无需等待。此种情况也可以看做是另一种“同步转异步”

示例

```sql
alter system set synchronous_standby_names='standby12';
alter system set synchronous_commit=local;
select pg_reload_conf();

此时关闭备库，主库执行insert，主库不受影响。但是注意

DETAIL:  The transaction has already committed locally, but might not have been replicated to the standby.
```

synchronous_commit参考[pg_reliability](./pg_reliability.md)
