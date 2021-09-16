
Pgbench
在数据库服务器硬件、软件环境中建立已知的性能基准线成为基准测试。pg内置了pgbench基准测试工具
 
软件系统运行在一定的环境中，收环境影响，如：
硬件
网络
负载
软件，操作系统内核
现在硬件水平扩展很容易，但oltp数据库扩展能力有限，只能通过分库分表，读写分离减轻压力。
 
基准测试主要用于测试不同硬件和应用场景下，数据库系统配置是否合理。
 
基准测试衡量指标
吞吐量（throughput）：TPS(每秒事务数)作为单位
响应时间（RT reponce time）：分钟、秒、毫秒、微妙作为单位。根据最大值、最小值、平均值做分组统计
延迟（latency）：分钟、秒、毫秒、微妙作为单位
 
测试的原则：
一次测试不可能将系统各个方面测得很清楚。测试目标尽量单一，测试方法简单，测试过程尽量接近真实环境。尽可能多的收集系统状态
 
使用pgbench测试
TPC（事务处理性能委员会：transaction Processing Performance Council www.tpc.org ）已经退出TPC-A、TPC-B、TPC-C、TPC-D、TPC-E、TPC-W等基准测试标准。其中TPC-C是经典的衡量在线事务处理（OLTP）系统性能和可伸缩性的基准测试规范，还有比较新的OLTP测试规范TPC-E。常见的基准测试工具 benchmarksql，hammerDB等。postgresql自带运行基准测试的简单程序pgbench。pgbench是一个类TPC-B的基准测试工具
 
pgbench内嵌4张表：pgbench_branches、pgbench_tellers、pgbench_accounts、pgbench_history。
初始化时自动创建并初始化测试数据。数据库中存在同名表时，pgbench会删除这些表重新初始化。
 
初始化数据
pgbench --help
 
-i进入初始化模式
-F数据块的填充因子，取值10-100，可设置为小数。默认值100。小于100对update性能有一定提高（物理存储占用数据块的比例）
-n初始化后不执行vacuum
-q静默模式，默认每100000打印一条消息，切换静默模式后，每5s打印一条消息。可避免大量打印消息。
-s缩放因子，生成数据的比例因子，默认为1。当它为1时只生产1份数据，为k时，生产k份数据。
 
pgbench_branches--1
pgbench_tellers--10
Pgbench_accounts--100000
Pgbench_history--0
 
[postgres@post ~]$ pgbench -i -s 1 -F 100 -h 127.0.0.1 -p 5433 -d test -U test
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
creating tables...
100000 of 100000 tuples (100%) done (elapsed 0.12 s, remaining 0.00 s)
vacuum...
set primary keys...
done.
[postgres@post ~]$
 
test=> select count(*) from pgbench_accounts ;
 count 
--------
 100000
(1 row)
 
test=> select count(*) from pgbench_branches ;
 count
-------
     1
(1 row)
 
test=> select count(*) from pgbench_history ;
 count
-------
     0
(1 row)
 
test=> select count(*) from pgbench_tellers ;
 count
-------
    10
(1 row)
 
[postgres@post ~]$ pgbench -i -s 10 -F 80 -h 127.0.0.1 -p 5433 -d test -U test
creating tables...
100000 of 1000000 tuples (10%) done (elapsed 0.14 s, remaining 1.27 s)
200000 of 1000000 tuples (20%) done (elapsed 0.31 s, remaining 1.24 s)
300000 of 1000000 tuples (30%) done (elapsed 0.42 s, remaining 0.97 s)
400000 of 1000000 tuples (40%) done (elapsed 0.47 s, remaining 0.70 s)
500000 of 1000000 tuples (50%) done (elapsed 0.54 s, remaining 0.54 s)
600000 of 1000000 tuples (60%) done (elapsed 0.62 s, remaining 0.41 s)
700000 of 1000000 tuples (70%) done (elapsed 0.76 s, remaining 0.33 s)
800000 of 1000000 tuples (80%) done (elapsed 0.85 s, remaining 0.21 s)
900000 of 1000000 tuples (90%) done (elapsed 0.97 s, remaining 0.11 s)
1000000 of 1000000 tuples (100%) done (elapsed 1.13 s, remaining 0.00 s)
vacuum...
set primary keys...
done.
[postgres@post ~]$
 
使用内置脚本测试
[postgres@post data]$ pgbench -b list
Available builtin scripts:
tpcb-like
simple-update
select-only
 
tpcb-like--包含select，update，insert事务，默认使用这种测试脚本
simple-update--update操作
select-only--select操作
 
[postgres@post data]$ pgbench -b tpcb-like@8 -b select-only@2 -h 127.0.0.1 -p 5433 -d test -U test
pghost: 127.0.0.1 pgport: 5433 nclients: 1 nxacts: 10 dbName: test
starting vacuum...end.
client 0 executing script "<builtin: TPC-B (sort of)>"
client 0 executing \set aid
client 0 executing \set bid
……
transaction type: multiple scripts
scaling factor: 10
query mode: simple
number of clients: 1
number of threads: 1
number of transactions per client: 10
number of transactions actually processed: 10/10
latency average = 8.030 ms
tps = 124.532421 (including connections establishing)
tps = 142.279122 (excluding connections establishing)
SQL script 1: <builtin: TPC-B (sort of)>
 - weight: 8 (targets 80.0% of total)
 - 7 transactions (70.0% of total, tps = 87.172695)
 - latency average = 9.516 ms
 - latency stddev = 1.993 ms
SQL script 2: <builtin: select only>
 - weight: 2 (targets 20.0% of total)
 - 3 transactions (30.0% of total, tps = 37.359726)
 - latency average = 1.185 ms
 - latency stddev = 0.034 ms
[postgres@post data]$
 
以上命令使用了内置脚本tpcb-like占比80%和select-only占比20%进行的基准测试。
 
transaction type: multiple scripts--测试类型
scaling factor: 10--初始化时的比例因子
query mode: simple--查询类型
number of clients: 1--客户端数量
number of threads: 1--测试时指定的每个客户端的线程数
number of transactions per client: 10--测试时指定的每个客户端运行的事务数
number of transactions actually processed: 10/10--测试完成时实际完成的事务数和计划完成的事务数
latency average = 8.030 ms--测试过程中的平均响应时间
tps = 124.532421 (including connections establishing)--包含建立连接开销的tps值
tps = 142.279122 (excluding connections establishing)
SQL script 1: <builtin: TPC-B (sort of)>
 - weight: 8 (targets 80.0% of total)
 - 7 transactions (70.0% of total, tps = 87.172695)
 - latency average = 9.516 ms
 - latency stddev = 1.993 ms
SQL script 2: <builtin: select only>
 - weight: 2 (targets 20.0% of total)
 - 3 transactions (30.0% of total, tps = 37.359726)
 - latency average = 1.185 ms
 - latency stddev = 0.034 ms
 
 
使用自定以脚本
pgbench -f bench_script.sql -h 127.0.0.1 -p 5433 -d test -U test
 
其他选项
-c指定客户端的数量，即并发连接数，默认为1
-j多线程cpu时，可以模拟将客户端平均分配在个线程上
-T单次测试运行的时间，如3600s
-t每个客户端运行的事务数，默认10个
T和t二选一，要么指定时间结束，要么指定事务数结束
 
没有指定时间的话，默认使用事务数。如-c指定10，则会运行10*10个事务结束