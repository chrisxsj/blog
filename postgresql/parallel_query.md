# parallel_query

PostgreSQL 可以设计查询计划，利用多个 CPU 更快地回答查询。此功能称为并行查询。

## 并行查询如何工作

* 计划树的顶部是gather merge或gather时，所有的子工作进程并行执行。当gather或gather merge是计划的一部分，只有此部分的子工作进程并行执行
* 规划器将考虑使用的后台工作者的数量被限制为最多max_parallel_workers_per_gather个
* 任何时候能够存在的后台工作者进程的总数由max_worker_processes和max_parallel_workers限制。
* 当计划的并行部分的顶层节点是Gather Merge而不是Gather时，它表示每个执行计划并行部分的进程会排序，并且领导者执行一种保持顺序的合并。相反，Gather会以任何方便的顺序从工作者读取元组，这会破坏可能已经存在的排序顺序。

ref[How Parallel Query Works](https://www.postgresql.org/docs/13/how-parallel-query-works.html)

## 何时使用并行查询

有几种设置会导致查询规划器在任何情况下都不生成并行查询计划。为了让并行查询计划能够被生成，必须配置好下列设置。

* max_parallel_workers_per_gather必须被设置为大于零的值。这是一种特殊情况，更加普遍的原则是所用的工作者数量不能超过max_parallel_workers_per_gather所配置的数量。
* dynamic_shared_memory_type必须被设置为除none之外的值。并行查询要求动态共享内存以便在合作的进程之间传递数据。
* 此外，系统一定不能运行在单用户模式下。因为在单用户模式下，整个数据库系统运行在单个进程中，没有后台工作者进程可用。

也有一些条件，即便对一个给定查询通常可以产生并行查询计划，规划器都不会为它产生并行查询计划
详细参考[When Can Parallel Query Be Used?](https://www.postgresql.org/docs/13/when-can-parallel-query-be-used.html) 

## eg

1. 创建测试表并插入测试数据

```sql
 CREATE TABLE test_big(
id int4,
name character varying(32),
create_time timestamp without time zone DEFAULT clock_timestamp());

INSERT INTO test_big(id,name) SELECT n, n||'_test' FROM generate_series(1,5000000) n;

CREATE INDEX idx_test_big_id ON test_big USING btree(id);

 CREATE TABLE test_small(
id int4,
name character varying(32));

INSERT INTO test_small(id,name)SELECT n, n || '_small' FROM generate_series(1,800000) n;

CREATE INDEX idx_test_small_id ON test_small USING btree(id);
```

2. 查看并行是否开启,并开启并行

```sql
show max_parallel_workers_per_gather;
set max_parallel_workers_per_gather = 2;

```

3. 索引扫描

```sql
-- 查看执行计划
highgo=# EXPLAIN ANALYSE SELECT count(name) FROM test_big WHERE id < 1000000;
                                                                              QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=33879.25..33879.26 rows=1 width=8) (actual time=3094.504..3094.505 rows=1 loops=1)
   ->  Gather  (cost=33879.04..33879.25 rows=2 width=8) (actual time=3091.537..3094.724 rows=3 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Partial Aggregate  (cost=32879.04..32879.05 rows=1 width=8) (actual time=3067.548..3067.549 rows=1 loops=3)
               ->  Parallel Index Scan using idx_test_big_id on test_big  (cost=0.43..31835.63 rows=417364 width=12) (actual time=0.493..2767.347 rows=333333 loops=3)
                     Index Cond: (id < 1000000)
 Planning Time: 0.638 ms
 Execution Time: 3094.854 ms
(9 rows)

--关闭并行
highgo=# set max_parallel_workers_per_gather = 0;
SET

-- 查看执行计划
highgo=# EXPLAIN ANALYSE SELECT count(name) FROM test_big WHERE id < 1000000;
                                                                    QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=40182.91..40182.92 rows=1 width=8) (actual time=589.703..589.703 rows=1 loops=1)
   ->  Index Scan using idx_test_big_id on test_big  (cost=0.43..37678.73 rows=1001674 width=12) (actual time=0.048..357.773 rows=999999 loops=1)
         Index Cond: (id < 1000000)
 Planning Time: 0.098 ms
 Execution Time: 589.759 ms
(5 rows)


```

2. 并行bitmap heap扫描

```sql
--开启并行
highgo=# set max_parallel_workers_per_gather = 2;
SET
--查看执行计划（能够看到Bitmap Index索引扫描，没有并行执行）
highgo=# EXPLAIN ANALYSE SELECT * FROM test_big WHERE id = 1 OR id = 2;
                                                          QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on test_big  (cost=8.88..16.87 rows=2 width=24) (actual time=0.020..0.021 rows=2 loops=1)
   Recheck Cond: ((id = 1) OR (id = 2))
   Heap Blocks: exact=1
   ->  BitmapOr  (cost=8.88..8.88 rows=2 width=0) (actual time=0.016..0.016 rows=0 loops=1)
         ->  Bitmap Index Scan on idx_test_big_id  (cost=0.00..4.44 rows=1 width=0) (actual time=0.012..0.012 rows=1 loops=1)
               Index Cond: (id = 1)
         ->  Bitmap Index Scan on idx_test_big_id  (cost=0.00..4.44 rows=1 width=0) (actual time=0.003..0.003 rows=1 loops=1)
               Index Cond: (id = 2)
 Planning Time: 0.075 ms
 Execution Time: 0.060 ms
(10 rows)

--扩大ID选择范围及工作进程参数
highgo=# SET max_parallel_workers_per_gather = 4;
SET
highgo=# EXPLAIN ANALYSE SELECT count(*) FROM test_big WHERE id < 100000 OR id > 4900000;
                                                                          QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=51443.53..51443.54 rows=1 width=8) (actual time=345.518..345.519 rows=1 loops=1)
   ->  Gather  (cost=51443.11..51443.52 rows=4 width=8) (actual time=343.445..346.812 rows=5 loops=1)
         Workers Planned: 4
         Workers Launched: 4
         ->  Partial Aggregate  (cost=50443.11..50443.12 rows=1 width=8) (actual time=315.838..315.839 rows=1 loops=5)
               ->  Parallel Bitmap Heap Scan on test_big  (cost=3842.30..50317.95 rows=50066 width=0) (actual time=88.147..290.028 rows=40000 loops=5)
                     Recheck Cond: ((id < 100000) OR (id > 4900000))
                     Heap Blocks: exact=487
                     ->  BitmapOr  (cost=3842.30..3842.30 rows=202306 width=0) (actual time=86.867..86.867 rows=0 loops=1)
                           ->  Bitmap Index Scan on idx_test_big_id  (cost=0.00..1930.97 rows=104339 width=0) (actual time=6.984..6.984 rows=99999 loops=1)
                                 Index Cond: (id < 100000)
                           ->  Bitmap Index Scan on idx_test_big_id  (cost=0.00..1811.19 rows=97968 width=0) (actual time=79.881..79.881 rows=100000 loops=1)
                                 Index Cond: (id > 4900000)
 Planning Time: 0.694 ms
 Execution Time: 346.925 ms
(15 rows)

```

3. 多表关联

```sql
highgo=# EXPLAIN ANALYSE SELECT test_small.name FROM test_big,test_small WHERE test_big.id = test_small.id AND test_small.id < 10000;
                                                                            QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.90..25309.97 rows=9831 width=12) (actual time=1.442..183.294 rows=9999 loops=1)
   Workers Planned: 4
   Workers Launched: 4
   ->  Merge Join  (cost=0.90..23326.87 rows=2458 width=12) (actual time=46.952..118.476 rows=2000 loops=5)
         Merge Cond: (test_big.id = test_small.id)
         ->  Parallel Index Only Scan using idx_test_big_id on test_big  (cost=0.43..138077.26 rows=1250161 width=4) (actual time=0.047..1.312 rows=2001 loops=5)
               Heap Fetches: 10004
         ->  Index Scan using idx_test_small_id on test_small  (cost=0.42..364.47 rows=9831 width=16) (actual time=0.062..112.905 rows=9999 loops=5)
               Index Cond: (id < 10000)
 Planning Time: 1.984 ms
 Execution Time: 184.457 ms
(11 rows)

```

## 其他示例

PostgreSQL优化器计算并行度及如何决定使用并行

1、确定整个系统能开多少worker进程（max_worker_processes）
2、计算并行计算的成本，优化器根据CBO原则选择是否开启并行（parallel_setup_cost、parallel_tuple_cost）。
3、强制开启并行（force_parallel_mode）。
4、根据表级parallel_workers参数决定每个查询的并行度取最小值(parallel_workers, max_parallel_workers_per_gather)
5、当表没有设置parallel_workers参数，并且表的大小大于min_parallel_relation_size时，由算法决定每个查询的并行度。
并行顺序扫描测试
什么是顺序操作
顺序操作（同oracle中的全表扫描），意味着数据库会按顺序读取整张表，逐行确认是否符合查询条件。一般来说，当你关注给定查询语句的执行时间时，需要关注顺序操作。由以上可知，对于一个单表查询来说，顺序操作的时间复杂度为O(n)。对于时间敏感的查询，走索引是更好的选择，索引(默认的二叉树索引)有更好的时间复杂度O(log(n))。但使用索引是有代价的：在进行插入和更新操作时，需要花费额外的时间更新索引，并占用额外的内存和磁盘空间。因此，在一些情况下不使用索引，走顺序操作可能是更好的选择。以上这些需要根据实际情况取舍。
首先创建一个people表，只有id(主键)和age列:
postgres=# CREATETABLE people (id int PRIMARY KEY NOT NULL, age int NOT NULL);
CREATE TABLE
postgres=# \d people
   Table "public.people"
Column |Type   | Modifiers
-------+---------+-----------
id     | integer | not null
age    | integer | not null
Indexes:
   "people_pkey" PRIMARY KEY, btree (id)
插入一些数据。一千万行应该足以看到并行计算的用处。表中每个人的年龄取0~100的随机数。
postgres=# INSERTINTO people SELECT id, (random()*100)::integer AS age FROM generate_series(1,10000000) AS id;
INSERT 0 10000000
现在尝试获取所有年龄为6岁的人，预计获取约百分之一的行。
postgres=# EXPLAINANALYZE SELECT * FROM people WHERE age =6;
QUERY PLAN
------------------------------------------------------------------------------------------------------------------
 Seq Scan on people  (cost=0.00..169247.71 rows=104000 width=8) (actual time=0.052..1572.701 rows=100310 loops=1)
   Filter: (age = 6)
   Rows Removed by Filter: 9899690
 Planning time: 0.061 ms
 Execution time: 1579.476 ms
(5 rows)
上面查询花了1579.476 ms。并行查询默认是禁用的。现在启用并行查询，允许PostgreSQL最多使用两个并行，然后再次运行该查询。
postgres=# SET max_parallel_workers_per_gather = 2;
SET
postgres=# EXPLAINANALYZE SELECT * FROM people WHERE age =6;
 QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------
 Gather(cost=1000.00..107731.21 rows=104000 width=8) (actual time=0.431..892.823 rows=100310 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->Parallel Seq Scan on people(cost=0.00..96331.21 rows=43333 width=8) (actual time=0.109..862.562 rows=33437 loops=3)
         Filter: (age = 6)
         Rows Removed by Filter: 3299897
 Planning time: 0.133 ms
 Execution time: 906.548 ms
(8 rows)
 
使用并行查询后，同样语句查询事件缩减到906.548 ms，还不到原来时间的一半。启用并行查询收集数据并将“收集”的数据进行聚合会带来额外的开销。每增加一个并行，开销也随之增大。有时更多的并行并不能改善查询性能。但为了验证并行的性能，你需要在数据库服务器上进行试验，因为服务器拥有更多的CPU核心。
不是所有的查询都会使用并行。例如尝试获取年龄低于50的数据（这将返回一半数据）
postgres=# EXPLAINANALYZE SELECT * FROM people WHERE age <50;
QUERY PLAN
--------------------------------------------------------------------------------------------------------------------
 Seq Scan on people  (cost=0.00..169247.71 rows=4955739 width=8) (actual time=0.079..1957.076 rows=4949330 loops=1)
   Filter: (age < 50)
   Rows Removed by Filter: 5050670
 Planning time: 0.097 ms
 Execution time: 2233.848 ms
(5 rows)
上面的查询返回表中的绝大多数数据，没有使用并行，为什么会这样呢? 当查询只返回表的一小部分时，并行计算进程启动、运行（匹配查询条件）及合并结果集的开销小于串行计算的开销。当返回表中大部分数据时，并行计算的开销可能会高于其所带来的好处。
如果要强制使用并行，可以强制设置并行计算的开销为0，如下所示：
postgres=# SET parallel_tuple_cost TO 0;
SET
postgres=# EXPLAINANALYZE SELECT * FROM people WHERE age <50;
QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------
 Gather(cost=1000.00..97331.21 rows=4955739 width=8) (actual time=0.424..3147.678 rows=4949330 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->Parallel Seq Scan on people(cost=0.00..96331.21 rows=2064891 width=8) (actual time=0.082..1325.310 rows=1649777 loops=3)
         Filter: (age < 50)
         Rows Removed by Filter: 1683557
 Planning time: 0.104 ms
 Execution time: 3454.690 ms
(8 rows)
从上面结果中可以看到，强制并行后，查询语句执行时间由2233.848 ms增加到3454.690 ms，说明并行计算的开销是真实存在的。
聚合函数的并行计算测试
测试之前，现重置一下现有环境
postgres=# SET parallel_tuple_cost TO DEFAULT;
SET
postgres=# SET max_parallel_workers_per_gather TO 0;
SET
下面语句在未开启并行时，计算所有人的平均年龄
postgres=# EXPLAINANALYZE SELECT avg(age) FROM people;
                                                        QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=169247.72..169247.73 rows=1 width=32) (actual time=2751.862..2751.862 rows=1 loops=1)
   ->Seq Scan on people  (cost=0.00..144247.77 rows=9999977 width=4) (actual time=0.054..1250.670 rows=10000000 loops=1)
 Planning time: 0.054 ms
 Execution time: 2751.905 ms
(4 rows)
开启并行后，再次计算平均年龄
postgres=# SET max_parallel_workers_per_gather TO 2;
SET
 
postgres=# EXPLAINANALYZE SELECT avg(age) FROM people;
QUERY PLAN    
---------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=97331.43..97331.44 rows=1 width=32) (actual time=1616.346..1616.346 rows=1 loops=1)
   ->Gather  (cost=97331.21..97331.42 rows=2 width=32) (actual time=1616.143..1616.316 rows=3 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Partial Aggregate  (cost=96331.21..96331.22 rows=1 width=32) (actual time=1610.785..1610.785 rows=1 loops=3)
               ->  Parallel Seq Scan on people  (cost=0.00..85914.57 rows=4166657 width=4) (actual time=0.067..957.355 rows=3333333 loops=3)
 Planning time: 0.248 ms
 Execution time: 1619.181 ms
(8 rows)
从上面两次查询中可以看到，并行计算将查询时间由2751.905 ms降低到了1619.181ms。
join并行测试
创建测试环境。创建一个1000万行的pets表。
postgres=# CREATETABLE pets (owner_id int NOT NULL, species character(3) NOTNULL);
postgres=# CREATEINDEX pets_owner_id ON pets (owner_id);
postgres=# INSERTINTO pets SELECT (random()*10000000)::integer AS owner_id, ('{cat,dog}'::text[])[ceil(random()*2)] as species FROM generate_series(1,10000000);
不启用并行计算，执行join语句
postgres=# SET max_parallel_workers_per_gather TO 0;
SET
postgres=# EXPLAINANALYZE SELECT * FROM pets JOIN people ON pets.owner_id = people.id WHERE pets.species = 'cat' AND people.age = 18;
QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=171025.88..310311.99 rows=407 width=28) (actual time=1627.973..5963.378 rows=49943 loops=1)
   Hash Cond: (pets.owner_id = people.id)
   ->Seq Scan on pets  (cost=0.00..138275.00 rows=37611 width=20) (actual time=0.050..2784.238 rows=4997112 loops=1)
         Filter: (species = 'cat'::bpchar)
         Rows Removed by Filter: 5002888
   ->Hash  (cost=169247.71..169247.71 rows=108333 width=8) (actual time=1626.987..1626.987 rows=100094 loops=1)
         Buckets: 131072  Batches: 2  Memory Usage: 2974kB
         ->  Seq Scan on people  (cost=0.00..169247.71 rows=108333 width=8) (actual time=0.045..1596.765 rows=100094 loops=1)
               Filter: (age = 18)
               Rows Removed by Filter: 9899906
 Planning time: 0.466 ms
 Execution time: 5967.223 ms
(12 rows)
以上查询花费这几乎是5967.223 ms，下面启用并行计算
postgres=# SET max_parallel_workers_per_gather TO 2;
SET
postgres=# EXPLAINANALYZE SELECT * FROM pets JOIN people ON pets.owner_id = people.id WHERE pets.species = 'cat' AND people.age = 18;
QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------
 Gather(cost=1000.43..244061.39 rows=53871 width=16) (actual time=0.304..1295.285 rows=49943 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->Nested Loop  (cost=0.43..237674.29 rows=22446 width=16) (actual time=0.347..1274.578 rows=16648 loops=3)
         ->  Parallel Seq Scan on people  (cost=0.00..96331.21 rows=45139 width=8) (actual time=0.147..882.415 rows=33365 loops=3)
               Filter: (age = 18)
               Rows Removed by Filter: 3299969
         ->  Index Scan using pets_owner_id on pets  (cost=0.43..3.12 rows=1 width=8) (actual time=0.010..0.011 rows=0 loops=100094)
               Index Cond: (owner_id = people.id)
               Filter: (species = 'cat'::bpchar)
               Rows Removed by Filter: 1
 Planning time: 0.274 ms
 Execution time: 1306.590 ms
(13 rows)
由以上可知，查询语句的执行时间从5967.223 ms降低到1306.590 ms。
 
来自 <https://www.cnblogs.com/baisha/p/8309852.html>


