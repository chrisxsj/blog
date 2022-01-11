# performance_turning_poctest

性能优化方案（瀚高安全版数据库/企业版）

## 操作系统

参考[performance_turning_os](./performance_turning_os.md)

## 2 数据库

### 数据库参数

ref[performance_turning_pg](./performance_turning_pg.md)

对数据安全性有影响的参数，纯测试环境可以设置，以加快速度

```sql
alter system set logging_collector = 'off'; --关闭日志
alter system set wal_level = minimal; --最小化wal日志
alter system set full_page_writes = off; # 全页写对性能影响约20%-30%，测试关闭全页写

alter system set synchronous_commit = off;
alter system set fsync = off;
alter system set wal_sync_method = 'open_sync'; --根据测试定义

```

> 注意，可以调大wal segment size

### 关闭三权

关闭三权开关，重启生效

```sql
\c highgo syssso

v45x之前

select set_secure_level ('off');
SELECT show_secure_param();

v45x之后
select set_secure_param('hg_sepofpowers','off');  --关闭三权
select set_secure_param('hg_macontrol','min');  --最小化强制访问控制
select set_secure_param('hg_rowsecure','off');  --关闭行级强制访问控制
SELECT set_secure_param('hg_ShowLoginInfo', 'off'); --关闭登录信息提示
SELECT show_secure_param();

```

### 关闭audit

```sql
\c highgo syssao

v45x之后

select set_audit_param('hg_audit','off');
select show_audit_param();

```

### 关闭插件

```sql
show shared_preload_libraries;
alter system reset shared_preload_libraries; 
```

### pg_prewarm

pg_prewarm 预加载扩展，

```sql
create extension pg_prewarm; --创建
select pg_prewarm('tableName', 'buffer', 'main'); --加载表
select pg_prewarm('indexName', 'buffer', 'main'); --加载索引

```

关于预加载，可以结合另一个有效的方法：
先开启日志，跑一轮测试，将执行的 SQL 抓出来，然后关了日志，开启大页，最后在正式执行前，执行一遍这些 SQL

### 手动 vacuum

```sql
vacuum edoc_base;
vacuum edoc_base_workflow;
vacuum edoc_todoworklist;
vacuum form_opinion;
vacuum instance_joinactor;
vacuum jiyaojufawenbiaodan;
vacuum wf_activity;
vacuum wf_assignment;
vacuum wf_dai_ban_task;
vacuum wf_process;
vacuum wf_transition;
vacuum wf_yi_ban_task;

```

### 手动 analyze

```sql
analyze verbose;

```

## 最后的方式，还没用到！

### unloggd  table

```sql
alter table edoc_base SET UNLOGGED;
alter table edoc_base_workflow SET UNLOGGED;
alter table edoc_todoworklist SET UNLOGGED;
alter table form_opinion SET UNLOGGED;
alter table instance_joinactor SET UNLOGGED;
alter table jiyaojufawenbiaodan SET UNLOGGED;
alter table wf_activity SET UNLOGGED;
alter table wf_assignment SET UNLOGGED;
alter table wf_dai_ban_task SET UNLOGGED;
alter table wf_process SET UNLOGGED;
alter table wf_transition SET UNLOGGED;
alter table wf_yi_ban_task SET UNLOGGED;

```

### 开启并行查询

```sql
alter system set force_parallel_mode=on;
alter system set max_parallel_workers_per_gather=4;
alter system set max_parallel_workers=50;

```

## vacuum
参数名称    默认值 Azure DB for PG推荐值  Citusdata   HGDB推荐
autovacuum_max_workers  3   3   5或者6    6
autovacuum_naptime  1min    15s    15s
autovacuum_vacuum_threshold     50  50  Could be larger for small tables    25
autovacuum_analyze_threshold    50        10
autovacuum_vacuum_scale_factor  0.2 0.05    Smaller for big tables, try 0.01    0.01
autovacuum_analyze_scale_factor 0.1       0.05
autovacuum_vacuum_cost_delay    20ms    20ms    Can turn it down if OK with more vacuum I/O load    100ms
autovacuum_vacuum_cost_limit    -1  -1  Probably leave it alone 10000
maintenance_work_mem    64MB       system ram * 3/(8*autovacuum max workers)   1024MB

## loadrunner

run-time setting 里：
1 ） general --> logging ：不勾选
2 ） general --> think time ：选择 ignore

# 3 ） browser --> browser emulation ：不勾选 download non-html resources

更多参考[瀚高数据库性能测试方案](./script/瀚高数据库性能测试方案.docx)


## 客户端

benchmarksql4 
1、jdbc连接串
conn=jdbc:postgresql://localhost:9696/tpcc?
reWriteBatchedInserts=1&assumeMinServerVersion=10.5&tcpKeepAlive=1&loggerLevel=off&preparedStatementCacheSizeMiB=8&preferQueryMode=extended&defaultRowFetchSize=1&disableColumnSanitiser=1&stringtype=unspecified
 
2、run目录下log4.xml文件，关掉benchmark日志打印
在文件最后面
<root>
<priority value="trace"/>
<appender-ref ref="console"/>
<appender-ref ref="R"/>
<appender-ref ref="E"/>
</root>
把trace 改成 info
 
3、jdbc替换成pg官方的
 
服务端
 
1、启动数据库之前root清缓存
sync
sync
sync
echo 3 > /proc/sys/vm/drop_caches
 
2、启动数据库
numactl --interleave=all pg_ctl start
 
3、修改表为unlogged
 
3、缓存数据
create extension pg_prewarm;
 
select pg_prewarm('benchmarksql.stock','buffer','main');
select pg_prewarm('benchmarksql.pk_stock','buffer','main');
 
select pg_prewarm('benchmarksql.district','buffer','main');
select pg_prewarm('benchmarksql.pk_district','buffer','main');
 
select pg_prewarm('benchmarksql.order_line','buffer','main');
select pg_prewarm('benchmarksql.pk_order_line','buffer','main');
 
select pg_prewarm('benchmarksql.warehouse','buffer','main');
select pg_prewarm('benchmarksql.pk_warehouse','buffer','main');
 
select pg_prewarm('benchmarksql.customer','buffer','main');
select pg_prewarm('benchmarksql.pk_customer','buffer','main');
select pg_prewarm('benchmarksql.ndx_customer_name','buffer','main');
 
select pg_prewarm('benchmarksql.oorder','buffer','main');
select pg_prewarm('benchmarksql.pk_oorder','buffer','main');
select pg_prewarm('benchmarksql.ndx_oorder_carrier','buffer','main');
 
select pg_prewarm('benchmarksql.new_order','buffer','main');
select pg_prewarm('benchmarksql.pk_new_order','buffer','main');
 
select pg_prewarm('benchmarksql.item','buffer','main');
select pg_prewarm('benchmarksql.pk_item','buffer','main');
 
 
client_min_messages = panic
log_min_messages = panic
log_min_error_statement = panic
 
 
4、开始测试


====================
下面默认以HGDB为例：
 
一、排序:
1. 尽量避免
2. 排序的数据量尽量少，并保证在内存里完成排序。
（至于具体什么数据量能在内存中完成排序，不同数据库有不同的配置：
    HGDB是work_mem (integer)，单位是KB，默认值是4MB。
 
二、索引：
1. 过滤的数据量比较少，一般来说<20%,应该走索引。20%-40% 可能走索引也可能不走索引。> 40% ，基本不走索引(会全表扫描)
2. 保证值的数据类型和字段数据类型要一直。
3. 对索引的字段进行计算时，必须在运算符右侧进行计算。也就是 to_char(oc.create_date, 'yyyyMMdd')是没用的
4. 表字段之间关联，尽量给相关字段上添加索引。
5. 复合索引，遵从最左前缀的原则,即最左优先。（单独右侧字段查询没有索引的）
 
 
三、连接查询方式：
1、hash join
放内存里进行关联。
适用于结果集比较大的情况。
比如都是200000数据
2、nest loop
从结果1 逐行取出，然后与结果集2进行匹配。
适用于两个结果集，其中一个数据量远大于另外一个时。
结果集一：1000
结果集二：1000000
 
四、多表联查时：
在多表联查时，需要考虑连接顺序问题。
1、当在HGDB中进行查询时，如果多表是通过逗号，而不是join连接，那么连接顺序是多表的笛卡尔积中取最优的。如果有太多输入的表， HGDB规划器将从穷举搜索切换为基因概率搜索，以减少可能性数目(样本空间)。基因搜索花的时间少， 但是并不一定能找到最好的规划。
   
2、对于JOIN，
  LEFT JOIN / RIGHT JOIN 会一定程度上指定连接顺序，但是还是会在某种程度上重新排列：
 FULL JOIN 完全强制连接顺序。
 如果要强制规划器遵循准确的JOIN连接顺序，我们可以把运行时参数join_collapse_limit设置为 1。


五、HGDB提供了一些性能调优的功能：

优化思路：
1、为每个表执行 ANALYZE <table>。然后分析 EXPLAIN (ANALYZE，BUFFERS) sql。
2、对于多表查询，查看每张表数据，然后改进连接顺序。
3、先查找那部分是重点语句，比如上面SQL，外面的嵌套层对于优化来说没有意义，可以去掉。
4、查看语句中，where等条件子句，每个字段能过滤的效率。找出可优化处。比如oc.order_id = oo.order_id是关联条件，需要加索引。oc.op_type = 3 能过滤出1/20的数据，oo.event_type IN (...) 能过滤出1/10的数据，这两个是优化的重点，也就是实现确保op_type与event_type已经加了索引，其次确保索引用到了。

六、优化方案：

a) 整体优化：
1、使用EXPLAIN
  EXPLAIN命令可以查看执行计划，这个方法是我们最主要的调试工具。
2、及时更新执行计划中使用的统计信息
 由于统计信息不是每次操作数据库都进行更新的，一般是在 VACUUM 、 ANALYZE 、 CREATE INDEX等DDL执行的时候会更新统计信息，因此执行计划所用的统计信息很有可能比较旧。 这样执行计划的分析结果可能误差会变大。
以下是表tenk1的相关的一部分统计信息。
SELECT relname, relkind, reltuples, relpages
FROM pg_class
WHERE relname LIKE 'tenk1%';
 
      relname                  | relkind | reltuples | relpages
----------------------+---------+-----------+----------
  tenk1                            | r      |    10000 |      358
  tenk1_hundred              | i      |    10000 |      30
  tenk1_thous_tenthous    | i      |    10000 |      30
  tenk1_unique1              | i      |    10000 |      30
  tenk1_unique2              | i        |    10000 |      30
(5 rows)
 
其中 relkind是类型，r是自身表，i是索引index；reltuples是项目数；relpages是所占硬盘的块数。
估计成本通过（磁盘页面读取【relpages】*seq_page_cost）+（行扫描【reltuples】*cpu_tuple_cost）计算。默认情况下， seq_page_cost是1.0，cpu_tuple_cost是0.01。
名字
类型
描述
relpages
int4
以页(大小为BLCKSZ)的此表在磁盘上的形式的大小。 它只是规划器用的一个近似值，是由VACUUM,ANALYZE 和几个 DDL 命令，比如CREATE INDEX更新。
reltuples
float4
表中行的数目。只是规划器使用的一个估计值，由VACUUM,ANALYZE 和几个 DDL 命令，比如CREATE INDEX更新。
3、使用临时表（with）
对于数据量大，且无法有效优化时，可以使用临时表来过滤数据，降低数据数量级。
4、对于会影响结果的分析，可以使用 begin;...rollback;来回滚。
 
 
b) 查询优化：
1、明确用join来关联表，确保连接顺序
  一般写法：SELECT * FROM a, b, c WHERE a.id = b.id AND b.ref = c.id;
  如果明确用join的话，执行时候执行计划相对容易控制一些。
例子：
    SELECT * FROM a CROSS JOIN b CROSS JOIN c WHERE a.id = b.id AND b.ref = c.id;
    SELECT * FROM a JOIN (b JOIN c ON (b.ref = c.id)) ON (a.id = b.id);
 
c) 插入更新优化
1、关闭自动提交（autocommit=false）
如果有多条数据库插入或更新等，最好关闭自动提交，这样能提高效率
 
2、多次插入数据用copy命令更高效
  我们有的处理中要对同一张表执行很多次insert操作。这个时候我们用copy命令更有效率。因为insert一次，其相关的index都要做一次，比较花费时间。
 
3、临时删除index【具体可以查看Navicat表数据生成sql的语句，就是先删再建的】
  有时候我们在备份和重新导入数据的时候，如果数据量很大的话，要好几个小时才能完成。这个时候可以先把index删除掉。导入后再建index。
 
4、外键关联的删除
  如果表的有外键的话，每次操作都没去check外键整合性。因此比较慢。数据导入后再建立外键也是一种选择。
 
 
d) 修改参数：
选项
默认值
说明
优化
原因
max_connections
100
允许客户端连接的最大数目
否
因为在测试的过程中，100个连接已经足够
fsync
on
强制把数据同步更新到磁盘
是
因为系统的IO压力很大，为了更好的测试其他配置的影响，把改参数改为off
shared_buffers
24MB
决定有多少内存可以被PostgreSQL用于缓存数据（推荐内存的1/4)
是
在IO压力很大的情况下，提高该值可以减少IO
work_mem
1MB
使内部排序和一些复杂的查询都在这个buffer中完成
是
有助提高排序等操作的速度，并且减低IO
effective_cache_size
128MB
优化器假设一个查询可以用的最大内存，和shared_buffers无关（推荐内存的1/2)
是
设置稍大，优化器更倾向使用索引扫描而不是顺序扫描
maintenance_work_mem
16MB
这里定义的内存只是被VACUUM等耗费资源较多的命令调用时使用
是
把该值调大，能加快命令的执行
wal_buffer
768kB
日志缓存区的大小
是
可以降低IO，如果遇上比较多的并发短事务，应该和commit_delay一起用
checkpoint_segments
3
设置wal log的最大数量数（一个log的大小为16M）
是
默认的48M的缓存是一个严重的瓶颈，基本上都要设置为10以上
checkpoint_completion_target
0.5
表示checkpoint的完成时间要在两个checkpoint间隔时间的N%内完成
是
能降低平均写入的开销
commit_delay
0
事务提交后，日志写到wal log上到wal_buffer写入到磁盘的时间间隔。需要配合commit_sibling
是
能够一次写入多个事务，减少IO，提高性能
commit_siblings
5
设置触发commit_delay的并发事务数，根据并发事务多少来配置
是
减少IO，提高性能
autovacuum_naptime
1min
下一次vacuum任务的时间
是
提高这个间隔时间，使他不是太频繁
autovacuum_analyze_threshold
50
与autovacuum_analyze_scale_factor配合使用，来决定是否analyze
是
使analyze的频率符合实际
autovacuum_analyze_scale_factor
0.1
当update,insert,delete的tuples数量超过autovacuum_analyze_scale_factor*table_size+autovacuum_analyze_threshold时，进行analyze。
是
使analyze的频率符合实际
 
 
其他重要的参数：
1、增加maintenance_work_mem参数大小
  增加这个参数可以提升CREATE INDEX和ALTER TABLE ADD FOREIGN KEY的执行效率。
 
2、增加checkpoint_segments参数的大小
  增加这个参数可以提升大量数据导入时候的速度。
 
3、设置archive_mode无效
  这个参数设置为无效的时候，能够提升以下的操作的速度
  ・CREATE TABLE AS SELECT
  ・CREATE INDEX
  ・ALTER TABLE SET TABLESPACE
  ・CLUSTER等。
 
4、autovacuum相关参数
autovacuum：默认为on，表示是否开起autovacuum。默认开起。特别的，当需要冻结xid时，尽管此值为off，PG也会进行vacuum。 
autovacuum_naptime：下一次vacuum的时间，默认1min。 这个naptime会被vacuum launcher分配到每个DB上。autovacuum_naptime/num of db。 
log_autovacuum_min_duration：记录autovacuum动作到日志文件，当vacuum动作超过此值时。 “-1”表示不记录。“0”表示每次都记录。 
autovacuum_max_workers：最大同时运行的worker数量，不包含launcher本身。 
autovacuum_work_mem    ：每个worker可使用的最大内存数。
autovacuum_vacuum_threshold    ：默认50。与autovacuum_vacuum_scale_factor配合使用， autovacuum_vacuum_scale_factor默认值为20%。当update,delete的tuples数量超过autovacuum_vacuum_scale_factor*table_size+autovacuum_vacuum_threshold时，进行vacuum。如果要使vacuum工作勤奋点，则将此值改小。 
autovacuum_analyze_threshold        ：默认50。与autovacuum_analyze_scale_factor配合使用。
autovacuum_analyze_scale_factor    ：默认10%。当update,insert,delete的tuples数量超过autovacuum_analyze_scale_factor*table_size+autovacuum_analyze_threshold时，进行analyze。 
autovacuum_freeze_max_age：200 million。离下一次进行xid冻结的最大事务数。 
autovacuum_multixact_freeze_max_age：400 million。离下一次进行xid冻结的最大事务数。 
autovacuum_vacuum_cost_delay    ：如果为-1，取vacuum_cost_delay值。 
autovacuum_vacuum_cost_limit       ：如果为-1，到vacuum_cost_limit的值，这个值是所有worker的累加值。


========================================
参考

echo ""
listen_addresses = '0.0.0.0'            # 监听所有IPV4地址
port = 1921                             # 监听非默认端口
max_connections = 4000                  # 最大允许连接数
superuser_reserved_connections = 20     # 为超级用户保留的连接
unix_socket_directories = '.'           # unix socket文件目录最好放在$PGDATA中, 确保安全
unix_socket_permissions = 0700          # 确保权限安全
tcp_keepalives_idle = 30                # 间歇性发送TCP心跳包, 防止连接被网络设备中断.
tcp_keepalives_interval = 10
tcp_keepalives_count = 10
shared_buffers = 16GB                   # 数据库自己管理的共享内存大小, 如果用大页, 建议设置为: 内存 - 100*work_mem - autovacuum_max_workers*(autovacuum_work_mem or autovacuum_work_mem) - max_connections*1MB
huge_pages = try                        # 尽量使用大页, 需要操作系统支持, 配置vm.nr_hugepages*2MB大于shared_buffers.
maintenance_work_mem = 512MB            # 可以加速创建索引, 回收垃圾(假设没有设置autovacuum_work_mem)
autovacuum_work_mem = 512MB             # 可以加速回收垃圾
shared_preload_libraries = 'auth_delay,passwordcheck,pg_stat_statements,auto_explain'           # 建议防止暴力破解, 密码复杂度检测, 开启pg_stat_statements, 开启auto_explain, 参考 http://blog.163.com/digoal@126/blog/static/16387704020149852941586  
bgwriter_delay = 10ms                   # bgwriter process间隔多久调用write接口(注意不是fsync)将shared buffer中的dirty page写到文件系统.
bgwriter_lru_maxpages = 1000            # 一个周期最多写多少脏页
max_worker_processes = 20               # 如果要使用worker process, 最多可以允许fork 多少个worker进程.
wal_level = logical                     # 如果将来打算使用logical复制, 最后先配置好, 不需要停机再改.
synchronous_commit = off                # 如果磁盘的IOPS能力一般, 建议使用异步提交来提高性能, 但是数据库crash或操作系统crash时, 最多可能丢失2*wal_writer_delay时间段产生的事务日志(在wal buffer中). 
wal_sync_method = open_datasync         # 使用pg_test_fsync测试wal所在磁盘的fsync接口, 使用性能好的.
wal_buffers = 16MB
wal_writer_delay = 10ms
checkpoint_segments = 1024              # 等于shared_buffers除以单个wal segment的大小.
checkpoint_timeout = 50min
checkpoint_completion_target = 0.8
archive_mode = on                       # 最好先开启, 否则需要重启数据库来修改
archive_command = '/bin/date'           # 最好先开启, 否则需要重启数据库来修改, 将来修改为正确的命令例如, test ! -f /home/postgres/archivedir/pg_root/%f && cp %p /home/postgres/archivedir/pg_root/%f
max_wal_senders = 32                    # 最多允许多少个wal sender进程.
wal_keep_segments = 2048                # 在pg_xlog目录中保留的WAL文件数, 根据流复制业务的延迟情况和pg_xlog目录大小来预估.
max_replication_slots = 32              # 最多允许多少个复制插槽
hot_standby = on
max_standby_archive_delay = 300s        # 如果备库要被用于只读, 有大的查询的情况下, 如果遇到conflicts, 可以考虑调整这个值来避免conflict造成cancel query.
max_standby_streaming_delay = 300s      # 如果备库要被用于只读, 有大的查询的情况下, 如果遇到conflicts, 可以考虑调整这个值来避免conflict造成cancel query.
wal_receiver_status_interval = 1s
hot_standby_feedback = off               # 建议关闭, 如果备库出现long query，可能导致主库频繁的autovacuum(比如出现无法回收被需要的垃圾时)
vacuum_defer_cleanup_age = 0             # 建议设置为0，避免主库出现频繁的autovacuum无用功，也许新版本会改进。
random_page_cost = 1.3                    # 根据IO能力调整(企业级SSD为例 1.3是个经验值)
effective_cache_size = 100GB            # 调整为与内存一样大, 或者略小(减去shared_buffer). 用来评估OS PAGE CACHE可以用到的内存大小.
log_destination = 'csvlog'
logging_collector = on
log_truncate_on_rotation = on
log_rotation_size = 10MB
log_min_duration_statement = 1s
log_checkpoints = on
log_connections = on
log_disconnections = on
log_error_verbosity = verbose           # 在日志中输出代码位置
log_lock_waits = on
log_statement = 'ddl'
autovacuum = on
log_autovacuum_min_duration = 0
autovacuum_max_workers = 10              # 根据实际频繁变更或删除记录的对象数决定
autovacuum_naptime = 30s                  # 快速唤醒, 防止膨胀
autovacuum_vacuum_scale_factor = 0.1    # 当垃圾超过比例时, 启动垃圾回收工作进程
autovacuum_analyze_scale_factor = 0.2  
autovacuum_freeze_max_age = 1600000000
autovacuum_multixact_freeze_max_age = 1600000000
vacuum_freeze_table_age = 1500000000
vacuum_multixact_freeze_table_age = 1500000000
auth_delay.milliseconds = 5000          # 认证失败, 延迟多少毫秒反馈
auto_explain.log_min_duration = 5000    # 记录超过多少毫秒的SQL当时的执行计划
auto_explain.log_analyze = true
auto_explain.log_verbose = true
auto_explain.log_buffers = true
auto_explain.log_nested_statements = true
pg_stat_statements.track_utility=off

    建议的操作系统配置(根据实际情况修改) : 
vi /etc/sysctl.conf
# add by digoal.zhou
fs.aio-max-nr = 1048576
fs.file-max = 76724600
kernel.core_pattern= /data01/corefiles/core_%e_%u_%t_%s.%p         
# /data01/corefiles事先建好，权限777
kernel.sem = 4096 2147483647 2147483646 512000    
# 信号量, ipcs -l 或 -u 查看，每16个进程一组，每组信号量需要17个信号量。
kernel.shmall = 107374182      
# 所有共享内存段相加大小限制(建议内存的80%)
kernel.shmmax = 274877906944   
# 最大单个共享内存段大小(建议为内存一半), >9.2的版本已大幅降低共享内存的使用
kernel.shmmni = 819200         
# 一共能生成多少共享内存段，每个PG数据库集群至少2个共享内存段
net.core.netdev_max_backlog = 10000
net.core.rmem_default = 262144       
# The default setting of the socket receive buffer in bytes.
net.core.rmem_max = 4194304          
# The maximum receive socket buffer size in bytes
net.core.wmem_default = 262144       
# The default setting (in bytes) of the socket send buffer.
net.core.wmem_max = 4194304          
# The maximum send socket buffer size in bytes.
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_keepalive_intvl = 20
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_mem = 8388608 12582912 16777216
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1    
# 开启SYN Cookies。当出现SYN等待队列溢出时，启用cookie来处理，可防范少量的SYN攻击
net.ipv4.tcp_timestamps = 1    
# 减少time_wait
net.ipv4.tcp_tw_recycle = 0    
# 如果=1则开启TCP连接中TIME-WAIT套接字的快速回收，但是NAT环境可能导致连接失败，建议服务端关闭它
net.ipv4.tcp_tw_reuse = 1      
# 开启重用。允许将TIME-WAIT套接字重新用于新的TCP连接
net.ipv4.tcp_max_tw_buckets = 262144
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.tcp_wmem = 8192 65536 16777216
net.nf_conntrack_max = 1200000
net.netfilter.nf_conntrack_max = 1200000
vm.dirty_background_bytes = 409600000       
#  系统脏页到达这个值，系统后台刷脏页调度进程 pdflush（或其他） 自动将(dirty_expire_centisecs/100）秒前的脏页刷到磁盘
vm.dirty_expire_centisecs = 3000             
#  比这个值老的脏页，将被刷到磁盘。3000表示30秒。
vm.dirty_ratio = 95                          
#  如果系统进程刷脏页太慢，使得系统脏页超过内存 95 % 时，则用户进程如果有写磁盘的操作（如fsync, fdatasync等调用），则需要主动把系统脏页刷出。
#  有效防止用户进程刷脏页，在单机多实例，并且使用CGROUP限制单实例IOPS的情况下非常有效。  
vm.dirty_writeback_centisecs = 100            
#  pdflush（或其他）后台刷脏页进程的唤醒间隔， 100表示1秒。
vm.extra_free_kbytes = 4096000
vm.min_free_kbytes = 2097152
vm.mmap_min_addr = 65536
vm.overcommit_memory = 0     
#  在分配内存时，允许少量over malloc, 如果设置为 1, 则认为总是有足够的内存，内存较少的测试环境可以使用 1 .  
vm.overcommit_ratio = 90     
#  当overcommit_memory = 2 时，用于参与计算允许指派的内存大小。
vm.swappiness = 0            
#  关闭交换分区
vm.zone_reclaim_mode = 0     
# 禁用 numa, 或者在vmlinux中禁止. 
net.ipv4.ip_local_port_range = 40000 65535    
# 本地自动分配的TCP, UDP端口号范围
#  vm.nr_hugepages = 102352    
#  建议shared buffer设置超过64GB时 使用大页，页大小 /proc/meminfo Hugepagesize

vi /etc/security/limits.conf
* soft    nofile  1024000
* hard    nofile  1024000
* soft    nproc   unlimited
* hard    nproc   unlimited
* soft    core    unlimited
* hard    core    unlimited
* soft    memlock unlimited
* hard    memlock unlimited

rm -f /etc/security/limits.d/90-nproc.conf
\n "
