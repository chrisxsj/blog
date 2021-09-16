# pg_rewind

作者：瀚高PG实验室（Highgo PG Lab）-Chrisx

reference [pg_rewind](https://www.postgresql.org/docs/13/app-pgrewind.html)

[toc]

pg_rewind是一个工具，用于在群集的时间线出现分歧后，将 PostgreSQL 群集与同一群集的另一个副本进行同步。
> 典型的案例是旧主服务器在故障转移后重新联机，将其作为新主机之后的备用服务器。

## 1. 优势

**pg_rewind**成功后，目标数据目录的状态类似于源数据目录的基本备份（`作者注，数据一致的状态`）。与base backup或使用 rsync 等工具不同，pg_rewind不需要比较或复制群集中未更改的关系块。仅复制现有关系文件中更改的块和所有其他文件（包括new relation files, configuration files, and WAL segments）将完整复制。因此，当数据库很大且群集之间只有一小部分块不同时，pg_rewind操作比其他方法快得多。（`作者注，实现增量恢复比全量恢复快的多`）

> 使用 pg_rewind 不限于故障转移，可以promote备用服务器，运行一些写入事务，然后重新回卷，再次成为备用服务器。（`作者注，类似Oracle snapshot standby`）

## 2. 使用要求

* 需要目标服务器设置wal_log_hints为on或者initdb时启用了data checksums
* 此外需要将full_page_writes设置为on（默认值就是on）

```sql
alter system set wal_log_hints = on;
alter system set full_page_writes = on; --默认就是on
```

> 注意，使用pg_rewind需要提前配置参数

## 3. 工作原理

基本思想是将所有文件系统级别的更改从源群集复制到目标群集

1. 从源集群和目标集群时间线分叉点之前的最近一个checkpoint开始，扫描目标集群的wal日志。生成目标群集中更改的所有数据块的列表。
2. 将所有这些更改的块复制到目标群集。关系文件现在处于相当于上次完成检查点之前的状态，也就是时间线分叉点加上源集群所有块更改。
3. 从源集群拷贝所有其他文件，包括new relation files, WAL segments, pg_xact, and configuration files
4. 创建一个backup_lable文件，从failover的checkpoint开始，重放wal日志并更改pg_control文件的LSN信息。
5. 应用所有需要的wal日志，是数据库恢复到一致状态。

## 4. 使用示例

1. 故障转移后，重新启动旧主机作为新的备用服务器。

启动报错，出现了时间线分叉

```shell
2020-12-16 14:59:20.749 CST,,,9350,,5fd9b048.2486,1,,2020-12-16 14:59:20 CST,,0,FATAL,XX000,"could not start WAL streaming: ERROR:  requested starting point 0/A0000000 on timeline 1 is not in this server's history
DETAIL:  This server's history forked from timeline 1 at 0/9F000060.",,,,,,,,,""
2020-12-16 14:59:20.750 CST,,,9342,,5fd9b039.247e,9,,2020-12-16 14:59:05 CST,1/0,0,LOG,00000,"new timeline 2 forked off current database system timeline 1 before current recovery point 0/A0000098",,,,,,,,,""
2020-12-16 14:59:25.756 CST,,,9351,,5fd9b04d.2487,1,,2020-12-16 14:59:25 CST,,0,FATAL,XX000,"could not start WAL streaming: ERROR:  requested starting point 0/A0000000 on timeline 1 is not in this server's history
DETAIL:  This server's history forked from timeline 1 at 0/9F000060.",,,,,,,,,""
2020-12-16 14:59:25.758 CST,,,9342,,5fd9b039.247e,10,,2020-12-16 14:59:05 CST,1/0,0,LOG,00000,"new timeline 2 forked off current database system timeline 1 before current recovery point 0/A0000098",,,,,,,,,""

```

pg_rewind增量追加数据

```shell
pg_ctl stop

pg_rewind --target-pgdata /opt/pg106/data --source-server='host=192.168.6.142 port=5970 user=pg106 dbname=postgres' -P

connected to server
servers diverged at WAL location 0/9F000060 on timeline 1
rewinding from last common checkpoint at 0/9E000060 on timeline 1
reading source file list
reading target file list
reading WAL in target
need to copy 73 MB (total source directory size is 102 MB)
75441/75441 kB (100%) copied
creating backup label and updating control file
syncing target data directory
Done!

pg_ctl start

```

> 注意，pg_rewind 会将 recovery.conf 会被 recovery.done。复制过程会，如果主库有的recovery.done文件，则会复制到备库并覆盖文件。此时重新修改recovery.done并重命名为recovery.conf

2. 此外，数据库同步出现日志断档,无法使用pg_rewind增量追加数据

断档报错

```shell
2020-12-16 15:25:19.622 CST,,,9372,,5fd9b65f.249c,1,,2020-12-16 15:25:19 CST,,0,LOG,00000,"started streaming WAL from primary at 0/A2000000 on timeline 3",,,,,,,,,""
2020-12-16 15:25:19.622 CST,,,9372,,5fd9b65f.249c,2,,2020-12-16 15:25:19 CST,,0,FATAL,XX000,"could not receive data from WAL stream: ERROR:  requested WAL segment 0000000300000000000000A2 has already been removed",,,,,,,,,""
2020-12-16 15:25:24.637 CST,,,9373,,5fd9b664.249d,1,,2020-12-16 15:25:24 CST,,0,LOG,00000,"started streaming WAL from primary at 0/A2000000 on timeline 3",,,,,,,,,""
2020-12-16 15:25:24.638 CST,,,9373,,5fd9b664.249d,2,,2020-12-16 15:25:24 CST,,0,FATAL,XX000,"could not receive data from WAL stream: ERROR:  requested WAL segment 0000000300000000000000A2 has already been removed",,,,,,,,,""
2020-12-16 15:25:29.631 CST,,,9374,,5fd9b669.249e,1,,2020-12-16 15:25:29 CST,,0,LOG,00000,"started streaming WAL from primary at 0/A2000000 on timeline 3",,,,,,,,,""
2020-12-16 15:25:29.631 CST,,,9374,,5fd9b669.249e,2,,2020-12-16 15:25:29 CST,,0,FATAL,XX000,"could not receive data from WAL stream: ERROR:  requested WAL segment 0000000300000000000000A2 has already been removed",,,,,,,,,""

```

pg_rewind操作不支持

```shell
[pg106@db2 data]$ pg_rewind --target-pgdata /opt/pg106/data --source-server='host=192.168.6.141 port=5970 user=pg106 dbname=postgres' -P
connected to server
source and target cluster are on the same timeline
no rewind required
[pg106@db2 data]$

```
