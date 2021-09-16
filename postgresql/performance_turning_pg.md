# performance_turning_pg

**作者**

chrisx

**日期**

2021-05-12

**内容**

性能调优-PostgreSQL

Out of the box, the default PostgreSQL configuration is not tuned for any particular workload. Default values are set to ensure that PostgreSQL runs everywhere, with the least resources it can consume and so that it doesn’t cause any vulnerabilities. It has default settings for all of the database parameters. It is primarily the responsibility of the database administrator or developer to tune PostgreSQL according to their system’s workload. In this blog, we will establish basic guidelines for setting PostgreSQL database parameters to improve database performance according to workload.

let’s take a look at the eight that have the greatest potential to improve performance

ref [tuning postgresql database parameters to optimize performance](https://www.percona.com/blog/2018/08/31/tuning-postgresql-database-parameters-to-optimize-performance/)

----

[toc]

## 实例参数

### shared_buffers

• PostgreSQL buffer is called shared_buffer.
• SHOW shared_buffers;
• The proper size for the POSTGRESQL shared buffer cache is the largest useful size that does not adversely affect other activity.
PostgreSQL既使用自身的缓冲区，也使用内核缓冲IO。这意味着数据会在内存中存储两次，首先是存入PostgreSQL缓冲区，然后是内核缓冲区。这被称为双重缓冲区处理。对大多数操作系统来说，这个参数是最有效的用于调优的参数。此参数的作用是设置PostgreSQL中用于缓存的专用内存量。
shared_buffers的默认值设置得非常低（默认值128MB。），因为某些机器和操作系统不支持使用更高的值。但在大多数现代设备中，通常需要增大此参数的值才能获得最佳性能。
建议的设置值为机器总内存大小的25％，但是也可以根据实际情况尝试设置更低和更高的值。最高不超过40%。实际值取决于机器的具体配置和工作的数据量大小。举个例子，如果工作数据集可以很容易地放入内存中，那么可以增加shared_buffers的值来包含整个数据库，以便整个工作数据集可以保留在缓存中。
在生产环境中，将shared_buffers设置为较大的值通常可以提供非常好的性能，但应当时刻注意找到平衡点。

### wal_buffers

• PostgreSQL writes its WAL (write ahead log) record into the buffers and then these buffers are flushed to disk.
• Bigger value for wal_buffer in case of lot of concurrent connection gives better performance.
PostgreSQL将其WAL（预写日志）记录写入缓冲区，然后将这些缓冲区刷新到磁盘。由wal_buffers定义的缓冲区的默认大小为16MB，但如果有大量并发连接的话，则设置为一个较高的值可以提供更好的性能。多数情况下，设置为-1的数据库会选择自动调整应给予合理的结果。-1的默认设置选择大小等于 shared_buffers的1/32 (大约3%)， 但不小于64kB也不超过一个WAL段大小， 通常16MB。如果自动选择过大或过小，则可以手动设置这个值。 但任何小于32kB的值将当作32kB处理。这个参数只能在服务器启动时设置。

### effective_cache_size(Query Planning)

• The effective_cache_size provides an estimate of the memory available for disk caching.
• It is just a guideline, not the exact allocated memory or cache size. 
• It should be large enough to hold most accessed tables, but at the same time small enough to avoid swap.
effective_cache_size提供可用于磁盘高速缓存的内存量的估计值。它只是一个建议值，而不是确切分配的内存或缓存大小。它不会实际分配内存，而是会告知优化器内核中可用的缓存量。在一个索引的代价估计中，更高的数值会使得索引扫描更可能被使用，更低的数值会使得顺序扫描更可能被使用。在设置这个参数时，还应该考虑PostgreSQL的共享缓冲区以及将被用于PostgreSQL数据文件的内核磁盘缓冲区。默认值是4GB。
该参数可以在会话级别设置，在 SQL 执行过程中，如果规划器没有按预想的走索引的，可以暂时在会话级别提高该值，在会话级别影响优化器的选择。

### work_mem

• This configuration is used for complex sorting.
此配置用于复合排序。内存中的排序比溢出到磁盘的排序快得多，设置非常高的值可能会导致部署环境出现内存瓶颈，因为此参数是按用户排序操作。如果有多个用户尝试执行排序操作，则系统将为所有用户分配大小为work_mem *总排序操作数的空间。全局设置此参数可能会导致内存使用率过高，因此强烈建议在会话级别修改此参数值。默认值为4MB。(物理内存的2%-4%)

### maintenance_work_mem

• maintenance_work_mem is a memory setting used for maintenance tasks. 
• The default value is 64MB. 
• Setting a large value helps in tasks like VACUUM, RESTORE, CREATE INDEX, ADD FOREIGN KEY and ALTER TABLE.
maintenance_work_mem是用于维护任务的内存设置。默认值为64MB。设置较大的值对于VACUUM，RESTORE，CREATE INDEX，ADD FOREIGN KEY和ALTER TABLE等操作的性能提升效果显著。建议值1G。
注意：
1、该参数设置要高于work_mem参数值。
2、当autovacuum执行时，可能会分配最大内存是该参数的 autovacuum_max_workers倍数。 因此该默认值不要设置得太高。 也可以通过独立地设置autovacuum_work_mem 可能会对控制这种情况有所帮助。

### synchronous_commit

• This is used to enforce that commit will wait for WAL to be written on disk before returning a success status to the client.
• This is a trade-off between performance and reliability. 
• Increasing reliability decreases performance and vice versa.
此参数的作用为在向客户端返回成功状态之前，强制提交等待WAL被写入磁盘。这是性能和可靠性之间的权衡。如果应用程序被设计为性能比可靠性更重要，那么关闭synchronous_commit。这意味着成功状态与保证写入磁盘之间会存在时间差。在服务器崩溃的情况下，即使客户端在提交时收到成功消息，数据也可能丢失。
该参数可选项on、remote_apply、remote_write、local和off，默认的并且安全的设置是on

### checkpoint_timeout and checkpoint_completion_target

• PostgreSQL writes changes into WAL. The checkpoint process flushes the data into the data files.
• More checkpoints have a negative impact on performance.
PostgreSQL将更改写入WAL。检查点进程将数据刷新到数据文件中。发生CHECKPOINT时完成此操作。这是一项开销很大的操作，整个过程涉及大量的磁盘读/写操作。用户可以在需要时随时发出CHECKPOINT指令，或者通过PostgreSQL的参数checkpoint_timeout和checkpoint_completion_target来自动完成。
checkpoint_timeout参数用于设置WAL检查点之间的时间。将此设置得太低会减少崩溃恢复时间，因为更多数据会写入磁盘，但由于每个检查点都会占用系统资源，因此也会损害性能。此参数只能在postgresql.conf文件中或在服务器命令行上设置。
checkpoint_completion_target指定检查点完成的目标，作为检查点之间总时间的一部分。默认值是 0.5。 这个参数只能在postgresql.conf文件中或在服务器命令行上设置。高频率的检查点可能会影响性能。

### temp_buffers

设置每个数据库会话使用的临时缓冲区的最大内存。这些是会话的本地缓冲区，只用于访问临时表。默认是 8MB。这个参数可以在独立的会话内部被改变，但是只有在会话第一次使用临时表之前才能改变。
一个会话将按照temp_buffers给出的限制根据需要分配临时缓冲区。如果在一个并不需要大量临时缓冲区的会话里设置一个大的数值， 其开销只是一个缓冲区描述符，或者说temp_buffers每增加一内存占用增加大概 64 字节。不过，如果一个缓冲区被实际使用，那么它就会额外消耗 8192 字节（或者BLCKSZ字节）。

### autovacuum_work_mem 

指定每个自动清理工作者进程能使用的最大内存量。默认值为 -1，表示使用 maintenance_work_mem的值。
例如：设置maintenance_work_mem为1GB，表示用于记录一次vacuum时，一次性可存储的垃圾tuple的tupleid。 tupleid为6字节长度。 1G可存储1.7亿（1024 *1024* 1024/6）条dead tuple的tupleid。
自动垃圾回收的触发条件由autovacuum_vacuum_threshold（默认50）和autovacuum_vacuum_scale_factor（默认0.2）决定，表示当垃圾记录数达到50+表大小乘以0.2时，会触发垃圾回收。那么1G能用于约8.9亿（1024 *1024* 1024/6/0.2）条记录的表。

### random_page_cost

本参数用于衡量SQL语句从磁盘进行随机存取的代价，默认值是4。这个默认值是针对机械硬盘的设置。若是$PGDATA位于固态盘(SSD)上，建议修改成1.1，因为固态盘(SSD)的随机存取和顺序存取的代价几乎是一样的。

### connections

MAX_CONNECTIONS
确定与数据库同时连接的最大数量。
每个客户端都可以配置内存资源，因此，客户机的最大数量表明使用的内存的最大数量。
superuser_reserved_connections
在达到max_connection限制的情况下，这些连接保留给超级用户。

```sql
--for connect
alter system set listen_addresses = '*';
alter system set port='5867';
alter system set max_connections=2000;
-- for Resource Consumption
alter system set shared_buffers = '32GB'; --建议物理内存的25%，测试改为40%
alter system set effective_cache_size = '24GB'; --effective_cache_size = 60GB不小于shared buffer
alter system set maintenance_work_mem = '1GB';
alter system set work_mem = '50MB'; --测试改为128MB，可在session级别修改

--for wal
alter system set wal_level=replica; --测试改为mimimal

alter system set wal_buffers='32MB'; --测试改为wal段大小的2倍
alter system set max_wal_size = '50GB';
alter system set min_wal_size = '5GB';
alter system set wal_keep_segments = 100;
alter system set checkpoint_timeout = '30min';
alter system set checkpoint_completion_target = 0.8; --测试改为0.9
alter system set full_page_writes = on; --测试改为off
alter system set max_wal_senders = 40;
alter system set max_replication_slots=40;
alter system set archive_mode = on; --测试改为off
alter system set archive_command = 'test ! -f /arch/%f;cp -i %p /arch/%f;scp -i %p 192.168.6.13:/arch'; --测试去掉
--alter system set archive_command = 'DIR=/home/postgres/`date +%F`;test ! -d $DIR && mkdir $DIR;test ! -f $DIR/%f && cp %p $DIR/%f';
-- for error reporting and logging
alter system set logging_collector = 'on'; --测试改为off
alter system set log_destination = 'csvlog';
alter system set log_directory = 'hgdb_log';
alter system set log_filename = 'highgodb_%d.log';
alter system set log_rotation_age = '1d';
alter system set log_rotation_size = 0;
alter system set log_truncate_on_rotation = 'on';
alter system set log_line_prefix='%m %p %u %d'; --%m是带毫秒的时间戳，%u是用户名，%d是数据库名，%p是进程ID。
alter system set log_min_duration_statement = '5000'; --测试改为-1
alter system set log_statement = 'ddl'; --测试改为none
alter system set log_checkpoints=on; --测试改为 off
alter system set log_connections = 'on'; --测试改为off
alter system set log_disconnections = 'on'; --测试改为off
alter system set log_hostname=off;
alter system set log_lock_waits=on; --测试改为off
--alter system set cluster_name=pgdb;

###########################################################
#以下内容非常规配置，可在优化时调整
alter system set client_min_messages = 'notice'; --测试改为panic
alter system set log_min_messages = 'warning'; --测试改为panic
alter system set log_min_error_statement = 'error'; --测试改为panic
-- for Automatic Vacuuming
alter system set autovacuum_max_workers = 6;
--autovacuum_freeze_max_age = 1500000000
--autovacuum_multixact_freeze_max_age = 1600000000
--alter system set autovacuum_vacuum_cost_delay = '10ms';
alter system set autovacuum_vacuum_cost_limit = -1;
--alter system set maintenance_work_mem='1GB';
alter system set autovacuum_naptime='2min';  --酌情增加或减小

-- for ssd
alter system set random_page_cost=1.1;

-- for Client Connection Defaults
--alter system set idle_in_transaction_session_timeout = '15min';
alter system set timezone = 'PRC';

-- other
alter system set temp_buffers='1GB';
alter system set log_temp_files='5GB';

alter system set commit_delay = 10; --insert
alter system set commit_siblings = 60; --insert

alter system set enable_bitmapscan = on; --index

alter system set bgwriter_delay = '500ms';
alter system set bgwriter_lru_multiplier = 10.0;
alter system set bgwriter_lru_maxpages = 1000;
alter system set bgwriter_flush_after = 0;
alter system set backend_flush_after = 0;
alter system set wal_writer_delay = '500ms';
alter system set wal_writer_flush_after = 0;

alter system set max_prepared_transactions=1200; --concurrent!
alter system set max_worker_processes = 400; --concurrent!

alter system set dynamic_shared_memory_type = posix;
alter system set max_parallel_workers_per_gather = 4;

alter system set log_timezone = 'PRC';
alter system set datestyle = 'iso, ymd';
alter system set ssl = off;
alter system set lc_messages = 'zh_CN. UTF-8';

--alter system set tcp_keepalives_idle = 60
--alter system set tcp_keepalives_interval = 10
--alter system set tcp_keepalives_count = 10

-- 安全版，测试情况下，可修改以下参数提高性能
select set_secure_param('hg_macontrol','min') --syssso，强制访问控制功能开关
select set_secure_param('hg_rowsecure','off') --syssso，行级强制访问功能开关
```

## 统计信息

统计信息是优化器运行的基础，代价估算的过程严重依赖于数据库的统计信息，统计信息是否能准确地描述表中的数据分布情况是决定代价准确性的重要条件之一
还可以通过查询统计信息数据监控数据库运行状态

### 统计收集配置

统计信息常用参数

* track_activities允许监控当前被任意服务器进程执行的命令。
* track_activity_query_size (integer) -- 指定统计信息中允许存储的SQL长度, 超出长度的SQL被截断。默认1024。pg_stat_activity.query。
* track_counts控制是否收集关于表和索引访问的统计信息。
* track_functions启用对用户定义函数使用的跟踪。
* track_io_timing启用对块读写次数的监控。

统计收集器通过临时文件将收集到的信息传送给其他PostgreSQL进程。这些文件被存储在名字由stats_temp_directory参数指定的目录中，默认是pg_stat_tmp。为了得到更好的性能，stats_temp_directory可以被指向一个基于 RAM 的文件系统来降低物理 I/O 需求。当服务器被干净地关闭时，一份统计数据的永久拷贝被存储在pg_stat子目录中，这样在服务器重启后统计信息能被保持。当在服务器启动时执行恢复时（例如立即关闭、服务器崩溃以及时间点恢复之后），所有统计计数器会被重置。

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

### pg_stat_statements

The pg_stat_statements module provides a means for tracking execution statistics of all SQL statements executed by a server.

The module must be loaded by adding pg_stat_statements to shared_preload_libraries in postgresql.conf, because it requires additional shared memory. This means that a server restart is needed to add or remove the module.

alter system set shared_preload_libraries=passwordcheck, pgaudit,pg_stat_statements;

pg_ctl restart

create extension pg_stat_statements;

pg_stat_statements.max           | 5000
pg_stat_statements.save          | on
pg_stat_statements.track         | top
pg_stat_statements.track_utility | on
statement_timeout                | 0

参考官方文档[pg_stat_statements](https://www.postgresql.org/docs/12/pgstatstatements.html)

### pg_stat_database

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

## 索引

带来更快的速度

好处

* 利用索引进行排序减少CPU开销（索引是有序的）
* 加速带条件的查询, 删除, 更新（扫描的page更少）
* 加速JOIN操作
* 加速外键约束更新和删除操作
* 加速唯一值约束, 排他约束

弊端

* 占用磁盘空间（索引过多会大量占用磁盘空间）
* 会对这类操作带来一定的性能影响。（当有批量甚至大量插入时，索引过多会造成插入缓慢。Btree索引是有序的，插入时，需要重新排序）
* 增加数据库系统的日常管理负担。

注意事项

* 正常创建索引时, 会阻断除查询以外的其他操作。
* 使用并行CONCURRENTLY 选项后, 可以允许同时对表的DML操作, 但是对于频繁DML的表, 这种创建索引的时间非常长。
* 某些索引不记录WAL, 所以如果有使用WAL进行数据恢复的情况(如crash recovery, 流复制, warm standby等)，这类索引在使用前需要重建。(HASH 索引)

### 索引类型使用

索引是提高数据库性能的常用途径。使用索引可以让数据库服务器更快找到并获取特定行。但是索引同时也会增加数据库系统的日常管理负担。
HGDB 提供了多种索引类型： Btree、Hash、GiST、SPGiST、GIN 和 BRIN 。

查询数据库支持的索引类型

```sql
highgo=# select amname from pg_am;
 amname
--------
 btree
 hash
 gist
 gin
 spgist
 brin
(6 rows)

```

* B_tree索引常用于等值和范围查询
* HASH索引只能处理简单等值查询
* GIN索引是适用于包含多个组件值的数据值（如数组）的“反向索引”
* BRIN块级索引
* GiST、SPGiST索引不是一种单一的索引，而是可以实现许多不同索引策略的基础设施。如通过GiST索引接口实现B_tree, R_tree以及特殊运算符的索引查询（<<，&<，&>，>>，<<|，&<|）

### 索引操作

**PG支持唯一、表达式、部分、多列索引。**

可以使用concurrently参数并行创建索引，使用concurrently参数不会锁表，不会阻塞表的DML
由于MVCC，大量更新后，索引会膨胀，可以使用concurrently创建新索引，删除旧索引，减小索引尺寸，提高查询速度
主键也可以使用以上的方式 
创建新主键索引
create unique index concurrently on MYTAB USING btree (id); 
查看索引
select schemaname, relname, indexrelname, pg_relation_size(indexrelid) as index_size, idx_scan, idx_tup_read, idx_tup_fetch from pg_stat_user_indexes where indexrelname in (select indexname from pg_indexes where schemaname='public' and tablename='test_rep'); 
删除旧主键索引
begin;
alter table test_rep drop constraint test_pk; 
alter table test_rep add constraint test_pk_new primary key using index test_idx; 
end;

## vacuum和膨胀

### dead tuple

### 膨胀

什么时候可能膨胀？（库级）
1、standby 开启了 feedback (且standby有慢事务, LONG SQL, 慢/dead slot),
2、慢/dead slot(catalog_xmin, 影响catalog垃圾回收),
3、vacuum_defer_cleanup_age 设置太大
4、整个实例中的 : 长事务, 慢SQL, 慢2pc

ref [vacuum2](./vacuum2.md)

## 长事务

什么是长事务？
运行时间比较长，操作的数据比较多的事务。

长事务的风险
1、锁定太多的数据，造成大量的阻塞和锁超时，回滚所需要的时间比较长。
2、影响vacuum、analyze运行

如何避免长事务
1、避免一次处理太多大数据。
2、移出不必要在事务中的select操作

查看事务最长执行时间

```sql
SELECT max(now() -xact_start) FROM pg_stat_activity WHERE state IN ('idle in transaction','active');

```

查询执行时间超过10分钟的事务

```sql
select datname,usename,application_name,client_addr,xact_start,backend_type,wait_event,wait_event_type from pg_stat_activity where state=‘active’ and now()-xact_start > interval '10 minute';

```

查询处于空闲时间超过10分钟的事务

```sql
select datname,usename,application_name,client_addr,xact_start,backend_type,wait_event,wait_event_type,state_change from pg_stat_activity where state='idle in transaction' and now()-state_change > interval '10 minute’;

```

按事务起始时间排序

```sql
SELECT pid, client_addr,xact_start, query FROM pg_stat_activity ORDER BY xact_start ASC;

```

确认为可以杀掉的会话，使用如下命令

```sql
SELECT pg_cancel_backend(pid);
SELECT pg_terminate_backend(pid);
或
kill -15 pid

```
