
# pgbench

**作者**

Chrisx

**日期**

2022-01-17

**内容**

pgbench — 在PostgreSQL上运行一个基准测试

ref [pgbench](https://www.postgresql.org/docs/14/pgbench.html)

----

[toc]

## 介绍

pgbench是一种在PostgreSQL上运行基准测试的简单程序。它可能在并发的数据库会话中一遍一遍地运行相同序列的 SQL 命令，并且计算平均事务率（每秒的事务数）。默认情况下，pgbench会测试一种基于 TPC-B 但是要更宽松的场景，其中在每个事务中涉及五个SELECT、UPDATE以及INSERT命令。但是，通过编写自己的事务脚本文件很容易用来测试其他情况。

<!--
使用pgbench测试
TPC（事务处理性能委员会：transaction Processing Performance Council www.tpc.org ）已经退出TPC-A、TPC-B、TPC-C、TPC-D、TPC-E、TPC-W等基准测试标准。其中TPC-C是经典的衡量在线事务处理（OLTP）系统性能和可伸缩性的基准测试规范，还有比较新的OLTP测试规范TPC-E。常见的基准测试工具 benchmarksql，hammerDB等。postgresql自带运行基准测试的简单程序pgbench。pgbench是一个类TPC-B的基准测试工具
-->

## 初始化

pgbench -i会创建四个表pgbench_accounts、 pgbench_branches、pgbench_history以及pgbench_tellers，如果同名表已经存在会被先删除。如果你已经有同名表，一定注意要使用另一个数据库！

初始化数据

```sh
pgbench --help

-i进入初始化模式
-F用给定的填充因子创建表pgbench_accounts、pgbench_tellers以及pgbench_branches。默认是100。
-n初始化后不执行vacuum
-q静默模式，只是每 5 秒产生一个进度消息。默认的记录会每 100,000 行打印一个消息，这经常会在每秒钟输出很多行
-s缩放因子，将生成的行数乘以比例因子。例如，-s 100将在pgbench_accounts表中创建 10,000,000 行。默认为 1。

$ pgbench -i -s 1 -F 100 -h 127.0.0.1 -p 5433 -d test -U test
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


pgbench -i -s 100 -h localhost -p 5866 -d benchmarksql -U sysdba

```

## 测试

使用内置脚本测试

```sh
$ pgbench -b list
Available builtin scripts:
tpcb-like --包含select，update，insert事务，默认使用这种测试脚本
simple-update  --update操作
select-only    --select操作

$ pgbench -b tpcb-like@8 -b select-only@2 -c 100 -j 10 -T 1800 -h localhost -p 5866 -d benchmarksql -U sysdba -l

nohup pgbench -b tpcb-like -c 400 -T 600 -h localhost -p 5866 -d benchmarksql -U sysdba -l &

:warning: 以上命令使用了内置脚本tpcb-like占比80%和select-only占比20%进行的基准测试。

transaction type: <builtin: TPC-B (sort of)>
scaling factor: 100
query mode: simple
number of clients: 200   --客户端数量
number of threads: 16    --每个客户端的线程数
duration: 600 s     --测试运行时间
number of transactions actually processed: 2267080
latency average = 52.953 ms   --平均响应时间
tps = 3776.921516 (including connections establishing) --每秒事务数（包括建立连接的开销）
tps = 3776.969732 (excluding connections establishing)


transaction type: <builtin: TPC-B (sort of)>
scaling factor: 100
query mode: simple
number of clients: 100   --客户端数量
number of threads: 10    --每个客户端的线程数
duration: 600 s     --测试运行时间
number of transactions actually processed: 484561
latency average = 36.455 ms   --平均响应时间
tps = 2743.093334 (including connections establishing) --每秒事务数（包括建立连接的开销）
tps = 2743.211398 (excluding connections establishing)


```

## 使用自定以脚本

```sh
pgbench -f bench_script.sql -h 127.0.0.1 -p 5433 -d test -U test

其他选项
-c指定客户端的数量，即并发连接数，默认为1
-j多线程cpu时，可以模拟将客户端平均分配在个线程上
-T单次测试运行的时间，如3600s
-t每个客户端运行的事务数，默认10个
T和t二选一，要么指定时间结束，要么指定事务数结束
 
没有指定时间的话，默认使用事务数。如-c指定10，则会运行10*10个事务结束

```
