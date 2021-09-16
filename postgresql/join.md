# join

创建环境

```sql
create table t1(id int,info text);
create table t2(id int,info text);
insert into t2 select generate_series(1,100000),'bill'||generate_series(1,100000);  
insert into t1 select generate_series(1,100000),'bill'||generate_series(1,100000);  
```

## Nested Loop Join

* Nested Loop是扫描一个表（外表），每读到一条记录，就根据Join字段上的索引去另一张表（内表）里面查找，
* 内表在Join字段上建有索引
* 外表也叫“驱动表”，一般为小表，不仅相对其它表为小表，而且记录数的绝对值也较小，不要求有索引；
* 外表返回的每一行都要在内表中检索找到与它匹配的行，因此整个查询返回的结果集不能太大（大于1 万不适合）
* 若Join字段上没有索引查询优化器一般就不会选择 Nested Loop
* 被连接的数据子集较小的情况，Nested Loop是个较好的选择

Nested Loop Join测试

```sql
create index t1_id_idx on t1(id);
create index t2_id_idx on t2(id);

explain analyze select * from t2 join t1 on (t1.id=t2.id) where t2.info='bill';

                                               QUERY PLAN
--------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.29..1994.32 rows=1 width=26) (actual time=29.304..29.304 rows=0 loops=1)
   ->  Seq Scan on t2  (cost=0.00..1986.00 rows=1 width=13) (actual time=29.303..29.304 rows=0 loops=1)
         Filter: (info = 'bill'::text)
         Rows Removed by Filter: 100000
   ->  Index Scan using t1_id_idx on t1  (cost=0.29..8.31 rows=1 width=13) (never executed)
         Index Cond: (id = t2.id)
 Planning Time: 0.231 ms
 Execution Time: 29.341 ms
(8 rows)

```

nl连接大致过程为：
1、t2表进行扫描, 过滤条件info = ‘bill’；
2、t2表根据过滤条件输出的中间结果, 每一条中间结果, t1表都根据索引idx_t1_id扫一遍, 过滤条件id= t2.id。

## Merge Join

* Merge join的操作通常分三步

1. 对连接的每个表做table access full;
2. 对table access full的结果进行排序；
3. 进行merge join对排序结果进行合并；

* 在全表扫描比索引范围扫描再进行表访问更可取的情况下，Merge Join会比Nested Loop性能更佳
* 当表特别小或特别巨大的时候，实行全表访问可能会比索引范围扫描更有效
* Merge Join的性能开销几乎都在前两步
* Merge Join可适用于非等值Join（>，<，>=，<=，但是不包含!=，也即<>）
* 通常情况下Hash Join的效果都比排序合并连接要好，如果两表已经被排过序，在执行排序合并连接时不需要再排序了，这时Merge Join的性能会更优


Merge Join测试

```sql
create index t1_id_idx on t1(id);
create index t2_id_idx on t2(id);
explain analyze select * from t2 join t1 on (t1.id=t2.id) ;

                                                            QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------
 Merge Join  (cost=0.73..8186.55 rows=100000 width=26) (actual time=0.023..159.118 rows=100000 loops=1)
   Merge Cond: (t2.id = t1.id)
   ->  Index Scan using t2_id_idx on t2  (cost=0.29..3343.29 rows=100000 width=13) (actual time=0.010..33.418 rows=100000 loops=1)
   ->  Index Scan using t1_id_idx on t1  (cost=0.29..3343.29 rows=100000 width=13) (actual time=0.008..35.913 rows=100000 loops=1)
 Planning Time: 0.220 ms
 Execution Time: 168.692 ms
(6 rows)

```

merge join的两张表需要按照连接列排序，因为这里用到了索引，所以没有排序过程；
相较于nl连接，merge join不需要多次扫描，两个表都只扫描一次。

## Hash Join

* 优化器使用两个比较的表，并利用连接键在内存中建立散列表，然后扫描较大的表并探测散列表，找出与散列表匹配的行，适用于较小的表完全可以放于内存中的情况，这样总成本就是访问两个表的成本之和；
* 但如果表很大，不能完全放入内存，优化器会将它分割成若干不同的分区，把不能放入内存的部分写入磁盘的临时段，此时要有较大的临时段以便提高I/O的性能。 
* 只能应用于等值连接(如WHERE A.COL3 = B.COL4)，这是由Hash的特点决定的。
* 哈希连接是归并连接的主要替代方案，哈希连接并不会对输入进行排序；
* 能够很好的工作于没有索引的大表和并行查询的环境中，并提供最好的性能。
* 是否比其他连接方式高效，取决于输入的内容是否经过排序。

Hash Join测试

```sql
create index t1_id_idx on t1(id);
create index t2_id_idx on t2(id);
explain analyze select * from t1 join t2 on (t1.info=t2.info) where t2.id between 1 and 1000;

                                                            QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=56.15..2177.26 rows=1011 width=26) (actual time=0.774..52.093 rows=1000 loops=1)
   Hash Cond: (t1.info = t2.info)
   ->  Seq Scan on t1  (cost=0.00..1736.00 rows=100000 width=13) (actual time=0.014..21.429 rows=100000 loops=1)
   ->  Hash  (cost=43.51..43.51 rows=1011 width=13) (actual time=0.752..0.752 rows=1000 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 67kB
         ->  Index Scan using t2_id_idx on t2  (cost=0.29..43.51 rows=1011 width=13) (actual time=0.033..0.377 rows=1000 loops=1)
               Index Cond: ((id >= 1) AND (id <= 1000))
 Planning Time: 0.379 ms
 Execution Time: 52.242 ms
(9 rows)

```

hash join过程：
1、首先扫描t2表, 过滤条件是t2.id between 1 and 1000, 这里由于t2上id有索引, 所以是走的index scan, 扫描后的结果放到一个Hash表中. Hash key就是两个表关联的列, 这里也就是id列；
2、然后扫描t1表, 扫描到的ID列的值用于去匹配Hash表的KEY值, 匹配到则输出。

## 各种Join的对比

| 类别     | Nested Loop                                                                  | Hash Join                                                                                                                  | Merge Join                                                                                           |
| -------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| 使用条件 | 任何条件                                                                     | 任何条件                                                                                                                   | 等值或非等值连接(>，<，=，>=，<=)，‘<>’除外                                                          |
| 相关资源 | CPU、磁盘I/O                                                                 | 内存、临时空间                                                                                                             | 内存、临时空间                                                                                       |
| 特点     | 当有高选择性索引或进行限制性搜索时效率比较高，能够快速返回第一次的搜索结果。 | 当缺乏索引或者索引条件模糊时，Hash Join比Nested Loop有效。通常比Merge Join快。在数据仓库环境下，如果表的记录数多，效率高。 | 当缺乏索引或者索引条件模糊时，Merge Join比Nested Loop有效。非等值连接时，Merge Join比Hash Join更有效 |
| 缺点     | 当索引丢失或者查询条件限制不够时，效率很低；当表的纪录数多时，效率低。       | 为建立哈希表，需要大量内存。第一次的结果返回较慢。                                                                         | 所有的表都需要排序。它为最优化的吞吐量而设计，并且在结果没有全部找到前不返回数据                     |
