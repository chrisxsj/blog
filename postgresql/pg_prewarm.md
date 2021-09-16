# pg_prewarm

## 配置

数据库重启后，数据库缓冲区将被清空。如果是生产系统，需要在重启后的开始一段时间内读取硬盘数据，这对数据库性能有一定影响，特别是应用系统业务高峰期时。pg9.4之后支持pg_warm扩展，可预先建在到操作系统缓存中。

```sql
create extension pg_prewarm;

```

创建pg_prewarm扩展后会生成pg_prewarm函数，函数语法如下
Pg_prewarm(regclass,mode text default 'buffer',fork text default 'main',first_block int8 default null,last_block int8 default null) returns int8
函数返回成功缓存的数据块数，输入的参数5个，如下
regclass--需要缓存的数据库对象，可以是表或索引
mode--缓存模式，有3种

## 语法

highgo=# \df+ pg_prewarm
pg_prewarm(
      regclass, 
      mode text default 'buffer', 
      fork text default 'main',
      first_block int8 default null,
      last_block int8 default null) RETURNS int8

参数说明：

- regclass：需要缓存的数据库对象，可以是表和索引。 
- mode：缓存的模式，支持三种缓存模式，prefetch模式表示将数据异步读入操作系统缓存，read模式表示将数据同步读入操作系统缓存，但效率要慢些，buffer模式将数据读入数据库缓存。 
- fork：此参数默认为main，通常不需要设置。 
- first_block：需要预热的第一个数据块编号，null表示数据库对象的第0个块。
- last_block：需要预热的最后一个数据块，null表示预热的数据库对象的最后一个数据块。

我们找一个测试表，里面有10万条数据：
postgres=# select count(*) from test_prewarm;
 count 
--------
 100000
(1 row)
 
把表加入到缓存：
postgres=#   select pg_prewarm('test_prewarm','buffer');
 pg_prewarm
------------
        637
(1 row)
 
查看缓存内的信息：
postgres=#  select * from pg_buffercache where relfilenode=pg_relation_filenode('test_prewarm');
 bufferid | relfilenode | reltablespace | reldatabase | relforknumber | relblocknumber | isdirty | usagecount
----------+-------------+---------------+-------------+---------------+----------------+---------+------------
      193 |       17771 |          1663 |       13003 |             0 |            636 | f       |          5
      194 |       17771 |          1663 |       13003 |             0 |            635 | f       |          5
      195 |       17771 |          1663 |       13003 |             0 |            634 | f       |          5
      196 |       17771 |          1663 |       13003 |             0 |            633 | f       |          5
      197 |       17771 |          1663 |       13003 |             0 |            632 | f       |          5
      198 |       17771 |          1663 |       13003 |             0 |            631 | f       |          5
      199 |       17771 |          1663 |       13003 |             0 |            630 | f       |          5
省略多行...
      831 |       17771 |          1663 |       13003 |             0 |              0 | f       |          5
(639 rows)
 
接下来删除表，重建，不使用pg_prewarm将其加载到缓存中，再看一下缓存信息：
postgres=# drop table test_prewarm;
DROP TABLE
postgres=#  create table test_prewarm (id int4,name character varying(64),creat_time timestamp(6) without time zone);
CREATE TABLE
postgres=#  insert into test_prewarm select generate_series(1,100000),generate_series(1,100000)|| '_pre',clock_timestamp();
INSERT 0 100000
postgres=#  select * from pg_buffercache where relfilenode=pg_relation_filenode('test_prewarm');
 bufferid | relfilenode | reltablespace | reldatabase | relforknumber | relblocknumber | isdirty | usagecount
----------+-------------+---------------+-------------+---------------+----------------+---------+------------
(0 rows)


## 设置同步读入操作系统缓存

select pg_prewarm('big_table', 'buffer', 'main');     #同步读入操作系统缓存
--select pg_prewarm('big_table', 'read', 'main');       #异步读入操作系统缓存
--select pg_prewarm('big_table', 'prefetch', 'main');   #读入数据库缓存