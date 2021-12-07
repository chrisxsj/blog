## performance_turning_way

**作者**

chrisx

**日期**

2021-12-07

**内容**

性能分析与诊断

----

[toc]

## pdr

ref[hg_pdr](./hg_pdr.md)

## 统计信息

统计信息是优化器运行的基础，代价估算的过程严重依赖于数据库的统计信息，统计信息是否能准确地描述表中的数据分布情况是决定代价准确性的重要条件之一
还可以通过查询统计信息数据监控数据库运行状态

在表数据大量变动后，如批量导入，需要手动收集统计信息。

 Better Execution Plan
 Cost based Plan
 --
 Statistics collection overhead
 More data to analyze for arriving at execution plan

### 统计收集配置

统计信息常用参数

* track_activities允许监控当前被任意服务器进程执行的命令。
* track_activity_query_size (integer) -- 指定统计信息中允许存储的SQL长度, 超出长度的SQL被截断。默认1024。pg_stat_activity.query。
* track_counts控制是否收集关于表和索引访问的统计信息。
* track_functions启用对用户定义函数使用的跟踪。
* track_io_timing启用对块读写次数的监控。

统计收集器通过临时文件将收集到的信息传送给其他PostgreSQL进程。这些文件被存储在名字由stats_temp_directory参数指定的目录中，默认是pg_stat_tmp。为了得到更好的性能，stats_temp_directory可以被指向一个基于 RAM 的文件系统来降低物理 I/O 需求。当服务器被干净地关闭时，一份统计数据的永久拷贝被存储在pg_stat子目录中，这样在服务器重启后统计信息能被保持。当在服务器启动时执行恢复时（例如立即关闭、服务器崩溃以及时间点恢复之后），所有统计计数器会被重置。

<!--

### 动态统计视图

视图名称  描述
pg_stat_activity  每个服务器进程一行，显示与那个进程的当前活动相关的信息，例如状态和当前查询。详见pg_stat_activity。
pg_stat_replication 每一个 WAL 发送进程一行，显示有关到该发送进程 连接的后备服务器的复制的统计信息。详见 pg_stat_replication。
pg_stat_wal_receiver  只有一行，显示来自 WAL 接收器所连接服务器的有关该接收器的统计信息。详见pg_stat_wal_receiver。
pg_stat_subscription  每个订阅至少一行，显示有关该订阅的工作者的信息。详见pg_stat_subscription。
pg_stat_ssl 每个连接（常规的或者复制）一行，显示在这个连接上使用的SSL的信息。详见pg_stat_ssl。
pg_stat_progress_vacuum 每个运行着VACUUM的后端（包括autovacuum工作者进程）一行，显示当前的进度。

### 已收集统计信息的视图

视图名称  描述
pg_stat_archiver  只有一行，显示有关 WAL 归档进程活动的统计信息。详见pg_stat_archiver。
pg_stat_bgwriter  只有一行，显示有关后台写进程的活动的统计信息。详见pg_stat_bgwriter。
pg_stat_database  每个数据库一行，显示数据库范围的统计信息。详见pg_stat_database。
pg_stat_database_conflicts  每个数据库一行，显示数据库范围的统计信息， 这些信息的内容是关于由于与后备服务器的恢复过程 发生冲突而被取消的查询。详见 pg_stat_database_conflicts。
pg_stat_all_tables  当前数据库中每个表一行，显示有关访问指定表的统计信息。详见pg_stat_all_tables。
pg_stat_sys_tables  和pg_stat_all_tables一样，但只显示系统表。
pg_stat_user_tables 和pg_stat_all_tables一样，但只显示用户表。

pg_stat_all_indexes 当前数据库中的每个索引一行，显示：表OID、索引OID、模式名、表名、索引名、 使用了该索引的索引扫描总数、索引扫描返回的索引记录数、使用该索引的简 单索引扫描抓取的活表(livetable)中数据行数。 当前数据库中的每个索引一行，显示与访问指定索引有关的统计信息。详见pg_stat_all_indexes。
pg_stat_sys_indexes 和pg_stat_all_indexes一样，但只显示系统表上的索引。
pg_stat_user_indexes  和pg_stat_all_indexes一样，但只显示用户表上的索引。
pg_statio_all_tables  当前数据库中每个表一行(包括TOAST表)，显示：表OID、模式名、表名、 从该表中读取的磁盘块总数、缓冲区命中次数、该表上所有索引的磁盘块读取总数、 该表上所有索引的缓冲区命中总数、在该表的辅助TOAST表(如果存在)上的磁盘块读取总数、 在该表的辅助TOAST表(如果存在)上的缓冲区命中总数、TOAST表的索引的磁盘块读 取总数、TOAST表的索引的缓冲区命中总数。 当前数据库中的每个表一行，显示有关在指定表上 I/O 的统计信息。详见pg_statio*。

pg_statio_系列视图主要用于判断缓冲区的效果。主要显示缓冲区和磁盘IO相关的信息。
-->

## 抓取sql语句

### 错误日志记录方式

ref [error_log](./error_log.md)

### pg_stat_database

ref [pg_stat_statements](./pg_stat_statements.md)

```sql
postgres=# select datid,datname,numbackends,blks_read,blks_hit,xact_commit,xact_rollback,deadlocks,stats_reset from pg_stat_database;
 datid |  datname  | numbackends | blks_read | blks_hit | xact_commit | xact_rollback | deadlocks |          stats_reset          
-------+-----------+-------------+-----------+----------+-------------+---------------+-----------+-------------------------------
 13212 | postgres  |           1 |      1287 |   793158 |       22377 |            18 |         0 | 2018-12-20 10:07:43.994325+08
     1 | template1 |           0 |         0 |        0 |           0 |             0 |         0 | 
 13211 | template0 |           0 |         0 |        0 |           0 |             0 |         0 | 
(3 rows)

除numbackends和stats_reset字段外，其他字段都是pg_stat_reset()以来的统计信息，优化和调整参数后可reset来前后对比


postgres=# select pg_stat_reset();
 pg_stat_reset
---------------

(1 row)
postgres=# select datid,datname,numbackends,blks_read,blks_hit,xact_commit,xact_rollback,deadlocks,stats_reset from pg_stat_database;
 datid |  datname  | numbackends | blks_read | blks_hit | xact_commit | xact_rollback | deadlocks |          stats_reset          
-------+-----------+-------------+-----------+----------+-------------+---------------+-----------+-------------------------------
 13212 | postgres  |           1 |         1 |        7 |           1 |             0 |         0 | 2018-12-29 19:18:32.339775+08
     1 | template1 |           0 |         0 |        0 |           0 |             0 |         0 | 
 13211 | template0 |           0 |         0 |        0 |           0 |             0 |         0 | 
(3 rows)
```

### shared_buffers

计算缓存命中率

```sql
postgres=# select blks_hit::float/(blks_read + blks_hit) as cache_hit_ratio from pg_stat_database where datname=current_database();
  cache_hit_ratio  
-------------------
 0.998381536671104
(1 row)
```

计算事务提交率》死锁/超时

```sql
postgres=# select xact_commit::float/(xact_commit + xact_rollback) as successful_xact_ratio from pg_stat_database where datname=current_database();
 successful_xact_ratio
-----------------------
     0.999195997855994
(1 row)
```

### pg_stat_user_tables

```sql
postgres=# select schemaname,relname,seq_scan,seq_tup_read,idx_scan,idx_tup_fetch,n_tup_ins,n_tup_upd,n_tup_del,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_user_tables;
 schemaname  |  relname   | seq_scan | seq_tup_read | idx_scan | idx_tup_fetch | n_tup_ins | n_tup_upd | n_tup_del | last_vacuum | last_autovacuum | last_analyze | las
t_autoanalyze 
-------------+------------+----------+--------------+----------+---------------+-----------+-----------+-----------+-------------+-----------------+--------------+----
--------------
 prod_1209   | test_dump  |        0 |            0 |          |               |         0 |         0 |         0 |             |                 |              | 
 public      | pitr_test  |        0 |            0 |          |               |         0 |         0 |         0 |             |                 |              | 
 prod_1209_2 | test_dump  |        0 |            0 |          |               |         0 |         0 |         0 |             |                 |              | 
 public      | pitr_test2 |        0 |            0 |          |               |         0 |         0 |         0 |             |                 |              | 
 public      | test_rep   |        0 |            0 |          |               |         0 |         0 |         0 |             |                 |              | 
(5 rows)
```

索引扫描占整个数据扫描比率

```sql
postgres=# select sum(idx_scan)/(sum(idx_scan)+sum(seq_scan)) as idx_scan_ratio from pg_stat_all_tables where schemaname='prod_1209';
 idx_scan_ratio

```

表的索引使用率ASC

```sql
postgres=# select relname,idx_scan::float/(idx_scan+seq_scan) as idx_scan_ratio from pg_stat_all_tables where schemaname='prod_1209' order by idx_scan_ratio asc;
  relname  | idx_scan_ratio
-----------+----------------
 test_dump |               
(1 row)
```

## 执行计划

ref [explain](./explain.md)

## 并行查询
