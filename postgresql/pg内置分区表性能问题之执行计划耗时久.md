# pg内置分区表性能问题之执行计划耗时久

## 问题现象

客户反馈，执行以下sql，执行计划时间耗时长，查询的表为分区表（内置分区表）。

explain analyze
with aa as (select min(rectime)as rectime from statisticdata_1 where wfid ='630012' and wtid ='630012901')
select rectime from aa;

示例

explain with aa as (select min(rectime)as rectime from p_raw.statisticdata_1 where wfid ='630012' and wtid ='630012901')
 select date_to_str(rectime , 'yyyy-mm-dd') recdate from aa;
                                                                       QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------

--------------------
 CTE Scan on aa  (cost=65.10..65.37 rows=1 width=8)
   CTE aa
     ->  Result  (cost=65.09..65.10 rows=1 width=0)
           InitPlan 1 (returns $0)
             ->  Limit  (cost=0.85..65.09 rows=1 width=8)
                   ->  Merge Append  (cost=0.85..322.08 rows=5 width=8)
                         Sort Key: statisticdata_1.rectime
                         ->  Index Scan using pk__statisticdata_1 on statisticdata_1  (cost=0.29..289.30 rows=1 width=8)
                               Index Cond: ((wtid = 630012901) AND (rectime IS NOT NULL))
                               Filter: (wfid = 630012)
                         ->  Index Scan using pk_p_raw_statisticdata_1_630012_202004 on statisticdata_1_630012_202004  (cost=0.12..8
.15 rows=1 width=8)
                               Index Cond: ((wtid = 630012901) AND (rectime IS NOT NULL))
                               Filter: (wfid = 630012)
                         ->  Index Scan using pk_p_raw_statisticdata_1_630012_202005 on statisticdata_1_630012_202005  (cost=0.12..8
.15 rows=1 width=8)
                               Index Cond: ((wtid = 630012901) AND (rectime IS NOT NULL))
                               Filter: (wfid = 630012)
                         ->  Index Scan using pk_p_raw_statisticdata_1_630012_202006 on statisticdata_1_630012_202006  (cost=0.12..8
.15 rows=1 width=8)
                               Index Cond: ((wtid = 630012901) AND (rectime IS NOT NULL))
                               Filter: (wfid = 630012)
                         ->  Index Scan using pk_p_raw_statisticdata_1_630012_202007 on statisticdata_1_630012_202007  (cost=0.12..8
.15 rows=1 width=8)
                               Index Cond: ((wtid = 630012901) AND (rectime IS NOT NULL))
                               Filter: (wfid = 630012)
(22 行记录)

时间：14396.753 ms

此执行计划返回的时间约14s

## 问题处理

1. vacuum收集统计信息

猜测执行计划不合理，查询相关表，没有统计信息分析。

soam=# select relname,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_all_tables where relname in ('statisticdata_1','statisticdata_1_630012_202004','statisticdata_1_630012_202005','statisticdata_1_630012_202006','statisticdata_1_630012_202007');
            relname            | last_vacuum | last_autovacuum | last_analyze | last_autoanalyze 
-------------------------------+-------------+-----------------+--------------+------------------
 statisticdata_1_630012_202005 |             |                 |              | 
 statisticdata_1_630012_202004 |             |                 |              | 
 statisticdata_1               |             |                 |              | 
 statisticdata_1_630012_202006 |             |                 |              | 
 statisticdata_1               |             |                 |              | 
 statisticdata_1_630012_202007 |             |                 |              | 
(6 行记录)


执行vacuum操作，执行统计信息收集

vacuum p_raw.statisticdata_1;
vacuum p_raw.statisticdata_1_630012_202005;
vacuum p_raw.statisticdata_1_630012_202004;
vacuum p_raw.statisticdata_1_630012_202006;
vacuum p_raw.statisticdata_1_630012_202007;

无明显改善。执行计划返回时间依然很长。

2 进一步分析

soam=# explain (analyze,buffers,verbose) with aa as (select rectime as rectime from p_raw.statisticdata_1 where wfid ='630012' and wtid ='630012901')
soam-#  select public.date_to_str(max(rectime), 'yyyy-mm-dd') recdate from aa;
                                                                                        QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------
 Aggregate  (cost=311.49..311.75 rows=1 width=8) (actual time=0.410..0.410 rows=1 loops=1)
   Output: public.date_to_str(max(aa.rectime), 'yyyy-mm-dd'::character varying)
   Buffers: shared hit=6
   CTE aa
     ->  Append  (cost=4.87..311.37 rows=5 width=8) (actual time=0.033..0.033 rows=0 loops=1)
           Buffers: shared hit=6
           ->  Bitmap Heap Scan on p_raw.statisticdata_1  (cost=4.87..278.79 rows=1 width=8) (actual time=0.019..0.019 rows=0 loops=
1)
                 Output: statisticdata_1.rectime
                 Recheck Cond: (statisticdata_1.wtid = 630012901)
                 Filter: (statisticdata_1.wfid = 630012)
                 Buffers: shared hit=2
                 ->  Bitmap Index Scan on pk__statisticdata_1  (cost=0.00..4.86 rows=77 width=0) (actual time=0.012..0.012 rows=0 lo
ops=1)
                       Index Cond: (statisticdata_1.wtid = 630012901)
                       Buffers: shared hit=2
           ->  Index Scan using pk_p_raw_statisticdata_1_630012_202004 on p_raw.statisticdata_1_630012_202004  (cost=0.12..8.14 rows
=1 width=8) (actual time=0.005..0.005 rows=0 loops=1)
                 Output: statisticdata_1_630012_202004.rectime
                 Index Cond: (statisticdata_1_630012_202004.wtid = 630012901)
                 Filter: (statisticdata_1_630012_202004.wfid = 630012)
                 Buffers: shared hit=1
           ->  Index Scan using pk_p_raw_statisticdata_1_630012_202005 on p_raw.statisticdata_1_630012_202005  (cost=0.12..8.14 rows
=1 width=8) (actual time=0.003..0.003 rows=0 loops=1)
                 Output: statisticdata_1_630012_202005.rectime
                 Index Cond: (statisticdata_1_630012_202005.wtid = 630012901)
                 Filter: (statisticdata_1_630012_202005.wfid = 630012)
                 Buffers: shared hit=1
           ->  Index Scan using pk_p_raw_statisticdata_1_630012_202006 on p_raw.statisticdata_1_630012_202006  (cost=0.12..8.14 rows
=1 width=8) (actual time=0.002..0.002 rows=0 loops=1)
                 Output: statisticdata_1_630012_202006.rectime
                 Index Cond: (statisticdata_1_630012_202006.wtid = 630012901)
                 Filter: (statisticdata_1_630012_202006.wfid = 630012)
                 Buffers: shared hit=1
           ->  Index Scan using pk_p_raw_statisticdata_1_630012_202007 on p_raw.statisticdata_1_630012_202007  (cost=0.12..8.14 rows
=1 width=8) (actual time=0.004..0.004 rows=0 loops=1)
                 Output: statisticdata_1_630012_202007.rectime
                 Index Cond: (statisticdata_1_630012_202007.wtid = 630012901)
                 Filter: (statisticdata_1_630012_202007.wfid = 630012)
                 Buffers: shared hit=1
   ->  CTE Scan on aa  (cost=0.00..0.10 rows=5 width=8) (actual time=0.035..0.035 rows=0 loops=1)
         Output: aa.rectime
         Buffers: shared hit=6
 Planning time: 1526.132 ms
 Execution time: 0.658 ms
(39 行记录)

时间：6339.969 ms

通过以上可以看出，sql计划时间和执行时间都很短。但是执行计划返回时间较长，约6s。执行计划中扫描了4个分区表

查询当前会话的进程ID
select pg_backend_pid();

追踪进程操作
strace -fr -o /tmp/3364 -p 3364

3364       0.000039 lseek(252, 0, SEEK_END) = 0
3364       0.001726 close(253)          = 0
3364       0.000049 open("base/22081/204017", O_RDWR) = 253
3364       0.000049 lseek(253, 8192, SEEK_SET) = 8192
3364       0.000036 lseek(253, 0, SEEK_END) = 8192
3364      10.896350 semop(121864204, {{8, 1, 0}}, 1) = 0
3364       0.000763 semop(121962511, {{9, 1, 0}}, 1) = 0
3364       0.000280 sendto(9, "\2\0\0\0\250\3\0\0AV\0\0\10\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 936, 0, NULL, 0) = 936
3364       0.000137 sendto(9, "\2\0\0\0\250\3\0\0AV\0\0\10\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 936, 0, NULL, 0) = 936
3364       0.000052 sendto(9, "\2\0\0\0\250\3\0\0AV\0\0\10\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 936, 0, NULL, 0) = 936
3364       0.000051 sendto(9, "\2\0\0\0\250\3\0\0AV\0\0\10\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 936, 0, NULL, 0) = 936


3364       0.000033 lseek(784, 0, SEEK_END) = 8192
3364      10.009023 semop(121962511, {{4, 1, 0}}, 1) = 0
3364       0.000610 sendto(9, "\2\0\0\0\250\3\0\0AV\0\0\10\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 936, 0, NULL, 0) = 936
3364       0.000062 sendto(9, "\2\0\0\0\250\3\0\0AV\0\0\10\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 936, 0, NULL, 0) = 936

semop耗时时间最长。

[root@soamtestserver26 ~]# ps aux |grep post |grep BIND
highgo   14983 75.7  1.2 27643572 790232 ?     Rs   15:31  11:02 postgres: highgo soam 10.80.5.69(45078) BIND
highgo   16499 28.2  2.2 27580912 1482032 ?    Ss   15:35   3:06 postgres: highgo soam 10.80.5.69(49304) BIND
highgo   18554 34.6  0.5 27309648 333400 ?     Rs   15:40   2:09 postgres: highgo soam 10.80.5.69(37930) BIND
highgo   19150 42.3  3.1 28124392 2078616 ?    Rs   15:41   2:02 postgres: highgo soam 10.80.5.69(51058) BIND
highgo   19152 26.8  1.6 27508840 1114748 ?    Ss   15:41   1:17 postgres: highgo soam 10.80.5.69(51060) BIND
highgo   19413 26.1  1.7 28117060 1128484 ?    Rs   15:42   1:07 postgres: highgo soam 10.80.5.57(45586) BIND
highgo   19499 37.7  0.5 27317960 351316 ?     Rs   15:42   1:32 postgres: highgo soam 10.80.5.69(57962) BIND
highgo   19986 19.7  0.4 27313496 326552 ?     Rs   15:43   0:34 postgres: highgo soam 10.80.5.69(40370) BIND
highgo   19988 41.9  0.4 27309684 323152 ?     Rs   15:43   1:12 postgres: highgo soam 10.80.5.69(40378) BIND
highgo   20084 35.9  1.4 27423656 928852 ?     Rs   15:43   0:57 postgres: highgo soam 10.80.5.69(42590) BIND
highgo   20090 40.8  1.4 27445856 949780 ?     Ss   15:43   1:05 postgres: highgo soam 10.80.5.69(42645) BIND
highgo   20663 39.5  1.3 27434524 917860 ?     Rs   15:45   0:29 postgres: highgo soam 10.80.5.69(55104) BIND
highgo   20714 58.2  4.3 29836788 2880076 ?    Rs   15:45   0:39 postgres: highgo soam 10.80.5.69(56086) BIND
highgo   20715 53.6  0.5 27317464 341092 ?     Rs   15:45   0:36 postgres: highgo soam 10.80.5.69(56088) BIND
highgo   21047 12.0  0.6 27381708 444592 ?     Rs   15:46   0:02 postgres: highgo soam 10.80.5.69(35064) BIND
highgo   21048 39.2  1.1 27361296 768308 ?     Ss   15:46   0:08 postgres: highgo soam 10.80.5.69(35066) BIND
highgo   21050 20.5  1.0 27371680 701732 ?     Ss   15:46   0:04 postgres: highgo soam 10.80.5.69(35084) BIND
highgo   21051 17.0  1.0 27387044 686768 ?     Ss   15:46   0:03 postgres: highgo soam 10.80.5.69(35090) BIND
highgo   21054 11.3  0.6 27374336 441028 ?     Rs   15:46   0:02 postgres: highgo soam 10.80.5.69(35114) BIND
highgo   21055 17.6  1.0 27391564 712512 ?     Ss   15:46   0:03 postgres: highgo soam 10.80.5.69(35128) BIND
[root@soamtestserver26 ~]#

有很多BIND，SLEEP状态的进程。


依据以上，判断是分区表的问题。PostgreSQL 内置分区性能较差。子表越多，性能越差。主要与优化器有关，分区表过多的时候，执行计划需要耗时很久。

原因是，内置分区表，plan\bind时需要分析所有子表，对子表加SPINLOCK（自旋锁）。自旋锁最多只能被一个内核任务持有，如果一个内核任务试图请求一个已被争用(已经被持有)的自旋锁，那么这个任务就会一直进行忙循环——旋转——等待锁重新可用。因此并发高时执行计划会产生等待，同时会导致CPU很高，并有大量的进程处于BIND，SLEEP的状态，也就是CPU空转。因分区表过多引发的问题通常出现在OLTP系统（主要是OLTP系统的并发高，更容易把这种小问题放大），本来一次请求只需要1毫秒的，但是执行计划可能需要上百毫秒，也就是说执行耗时变成了小头，而执行计划（SPIN LOCK）变成了大头。


此外，内置分区表还会造成分区表锁粒度高。只要操作主表，就需要对所有子表加锁。降低并发和数据库性能。

建议，
1，减少分区表的使用。必须使用时，减少分区个数。从而减少SPINLOCK次数
2，使用扩展插件pg_pathman创建分区表。pg_pathman对分区的支持更全面，性能更高。对sql语句会过滤目标分区，从而使不需要的分区不进入执行计划的环节。

PostgreSQL 社区正在改进这块的代码，PATCH如下(PostgreSQL 11可能会包含这部分优化)：
https://www.postgresql.org/message-id/flat/098b9c71-1915-1a2a-8d52-1a7a50ce79e8@lab.ntt.co.jp#098b9c71-1915-1a2a-8d52-1a7a50ce79e8@lab.ntt.co.jp
https://commitfest.postgresql.org/17/1272/

参考
https://yq.aliyun.com/articles/405176?spm=a2c4e.11153959.teamhomeleft.44.8WKxt7
https://yq.aliyun.com/articles/501428?spm=a2c4e.11153940.0.0.77dc4aa2ttIpka
https://github.com/digoal/blog/blob/master/201801/20180122_03.md?spm=a2c4e.10696291.0.0.69b519a4Hcvsph&file=20180122_03.md


启用分区查询参数：设置 constraint_exclusion 参数

show constraint_exclusion;

SET constraint_exclusion = off;         ##所有表都不通过约束优化查询
SET constraint_exclusion = on;          ##所有表都通过约束优化查询
SET constraint_exclusion = partition;    ##只对继承表和UNION ALL 子查询通过检索约束来优化查询