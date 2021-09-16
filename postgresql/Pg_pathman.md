https://github.com/postgrespro/pg_pathman/releases
 
https://yq.aliyun.com/articles/62314
 
pg_pathman 支持 range ， hash
 
安装配置！

$ git clone https://github.com/postgrespro/pg_pathman
$ export PATH=/home/digoal/pgsql9.6:$PATH

$ cd pg_pathman
$ make USE_PGXS=1
$ make USE_PGXS=1 install

$ cd $PGDATA
$ vi postgresql.conf
shared_preload_libraries = 'pg_pathman,pg_stat_statements'
$ pg_ctl restart -m fast

$ psql
postgres=# create extension pg_pathman;
CREATE EXTENSION

postgres=# \dx
                   List of installed extensions
    Name    | Version |   Schema   |         Description         
------------+---------+------------+------------------------------
 pg_pathman | 1.1     | public     | Partitioning tool ver. 1.1
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
 
Hgdb561 自带pg _pathman
直接配置使用
# alter system set shared_preload_libraries = 'pg_pathman' ;
$ pg_ctl restart -m fast

$ psql
postgres=# create extension pg_pathman;
CREATE EXTENSION

postgres=# \dx
                   List of installed extensions
    Name    | Version |   Schema   |         Description         
------------+---------+------------+------------------------------
 pg_pathman | 1.1     | public     | Partitioning tool ver. 1.1
 
 
hash 分区
建立测试表
CREATE TABLE items (
    id       SERIAL PRIMARY KEY,
    name     TEXT,
    code     BIGINT);
插入测试数据
INSERT INTO items (id, name, code)
SELECT g, md5(g::text), random() * 100000
FROM generate_series(1, 10000) as g;
分区并迁移
SELECT create_hash_partitions('items', 'id', 10);
查询
 SELECT * FROM items WHERE id = 1234;
  id  |               name               | code 
------+----------------------------------+-------
 1234 | 81dc9bdb52d04dc20036dbd8313ed055 | 87938
(1 row)
 
EXPLAIN SELECT * FROM items WHERE id = 1234;
                                     QUERY PLAN                                     
-------------------------------------------------------------------------------------
 Append  (cost=0.28..2.50 rows=1 width=44)
   ->  Index Scan using items_11_pkey on items_11  (cost=0.28..2.50 rows=1 width=44)
         Index Cond: (id = 1234)
(3 rows)
 
范围分区
建立测试表：
CREATE TABLE test _range_pathman (
    id      SERIAL,
    dt      TIMESTAMP NOT NULL,
    level   INTEGER,
    msg     TEXT);
CREATE INDEX ON test_range_pathman (dt);
插入测试数据：
INSERT INTO test_range_pathman (dt, level, msg) SELECT g, random() * 6,
md5(g::text) FROM generate_series('2019-01-01'::date, '2019-12-31'::date, '1 minute') as g;
 
INSERT INTO test_range_pathman (dt, level, msg) SELECT g, random() * 6,
md5(g::text) FROM generate_series('2019-01-01'::date, '2019-12-31'::date, '60 minute') as g;
 
创建分区表：
SELECT create_range_partitions(
        ' test_range_pathman ',-- 主表名
        'dt',   -- 分区字段
        '2019-01-01'::date, -- 分区起始日期
        '1 month'::interval, -- 分区间隔
        null,     -- 不指定分区数量，根据时间与间隔会自动计算出数量
        false -- 默认 tue 立即迁移数据， false 是不迁移数据
);
查看数据：
只统计主表数据量（分区，但数据未迁移）
select count(*) from only test_range_pathman ;
 count 
--------
 524161
(1 row)
 
非堵塞式数据迁移，并查看数据：

使用非堵塞式的迁移接口  
partition_table_concurrently(relation   REGCLASS,              -- 主表 OID
                             batch_size INTEGER DEFAULT 1000,  -- 一个事务批量迁移多少记录
                             sleep_time FLOAT8 DEFAULT 1.0)    -- 获得行锁失败时，休眠多久再次获取，重试 60 次退出任务。
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
select partition_table_concurrently(' test_range_pathman ',10000,1.0);
select count(*) from only test_range_pathman ;
 count
-------
     0
(1 row)
# 父表中数据已经为 0 ，迁移全部完毕
 

数据迁移完成后，建议禁用主表，这样执行计划就不会出现主表了
postgres=# select set_enable_parent('part_test'::regclass, false);
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
 
# 查看子表数据
postgres=> select * from test_range_pathman_10 limit 10;
  id  |         dt          | level |               msg               
------+---------------------+-------+----------------------------------
 6553 | 2019-10-01 00:00:00 |     5 | eee5c09b0e683d62ce1fbfb591963341
 6554 | 2019-10-01 01:00:00 |     5 | d65d91ca0d52f1b8b79a7621498030cf
 6555 | 2019-10-01 02:00:00 |     4 | 3f5c4e0bb66847e219f5943b7fdd8a02
 6556 | 2019-10-01 03:00:00 |     0 | 389176c45d5e9bcdd37db5ec441d9542
 6557 | 2019-10-01 04:00:00 |     3 | 174240f01991d66ccf38a2322d0e01e2
 6558 | 2019-10-01 05:00:00 |     3 | d0b1194e3ed234759d83913809a2bb3c
 6559 | 2019-10-01 06:00:00 |     3 | 64e716bd201ff17e2f9edb597f2bb005
 6560 | 2019-10-01 07:00:00 |     5 | d588ec8ca1f9c894cffd2beea0de9734
 6561 | 2019-10-01 08:00:00 |     5 | d8f5b8b84bba3b05466ffb6526d3378a
 6562 | 2019-10-01 09:00:00 |     1 | 64f81817c1b7d620a98c3ca95d90700f
(10 rows)
 
查看分区表执行计划：
 explain select * from journal where dt between '2019-03-29 06:00:00' and '2019-03-29 10:00:00' ;
                                                                   QUERY PLAN                                                                   
-------------------------------------------------------------------------------------------------------------------------------------------------
 Append  (cost=0.00..11.61 rows=242 width=49)
   ->  Seq Scan on journal  (cost=0.00..0.00 rows=1 width=49)
         Filter: ((dt >= '2019-03-29 06:00:00'::timestamp without time zone) AND (dt <= '2019-03-29 10:00:00'::timestamp without time zone))
   ->  Index Scan using journal_88_dt_idx on journal_88  (cost=0.28..10.40 rows=241 width=49)
         Index Cond: ((dt >= '2019-03-29 06:00:00'::timestamp without time zone) AND (dt <= '2019-03-29 10:00:00'::timestamp without time zone))
(5 rows)
注意 :
	1. 
分区列必须有 not null 约束
	2. 
分区个数必须能覆盖已有的所有记录


 
 
4. 分裂范围分区
例如某个分区太大了，想分裂为两个分区，可以使用这种方法
仅支持范围分区表
 
postgres=> \d+ test_range_pathman;
                                                           Table "test.test_range_pathman"
 Column |            Type             | Collation | Nullable |                    Default                     | Storage  | Stats target |
Description
--------+-----------------------------+-----------+----------+------------------------------------------------+----------+--------------+-
------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass) | plain    |              |
 dt     | timestamp without time zone |           | not null |                                                | plain    |              |
 level  | integer                     |           |          |                                                | plain    |              |
 msg    | text                        |           |          |                                                | extended |              |
Indexes:
    "test_range_pathman_dt_idx" btree (dt)
Child tables: test_range_pathman_1,
              test_range_pathman_10,
              test_range_pathman_11,
              test_range_pathman_12,
              test_range_pathman_2,
              test_range_pathman_3,
              test_range_pathman_4,
              test_range_pathman_5,
              test_range_pathman_6,
              test_range_pathman_7,
              test_range_pathman_8,
              test_range_pathman_9
 
 
postgres=> \d test_range_pathman_12
                                      Table "test.test_range_pathman_12"
 Column |            Type             | Collation | Nullable |                    Default                    
--------+-----------------------------+-----------+----------+------------------------------------------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass)
 dt     | timestamp without time zone |           | not null |
 level  | integer                     |           |          |
 msg    | text                        |           |          |
Indexes:
    "test_range_pathman_12_dt_idx" btree (dt)
Check constraints:
    "pathman_test_range_pathman_12_check" CHECK (dt >= '2019-12-01 00:00:00'::timestamp without time zone AND dt < '2020-01-01 00:00:00'::timestamp without time zone)
Inherits: test_range_pathman
 
postgres=>
 
来自 < https://yq.aliyun.com/articles/62314 >
 

split_range_partition(partition      REGCLASS,            -- 分区 oid
                      split_value    ANYELEMENT,          -- 分裂值
                      partition_name TEXT DEFAULT NULL)   -- 分裂后新增的分区表名
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
 

postgres=# select split_range_partition(' test_range_pathman_12 '::regclass,    -- 分区 oid
                      '201 9 -1 2 -1 5 00:00:00'::timestamp,     -- 分裂值
                      ' test_range_pathman_12 _2');                     -- 分区表名
 
来自 < https://yq.aliyun.com/articles/62314 >
 
postgres=> \d+ test_range_pathman;
                                                           Table "test.test_range_pathman"
 Column |            Type             | Collation | Nullable |                    Default                     | Storage  | Stats target |
Description
--------+-----------------------------+-----------+----------+------------------------------------------------+----------+--------------+-
------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass) | plain    |              |
 dt     | timestamp without time zone |           | not null |                                                | plain    |              |
 level  | integer                     |           |          |                                                | plain    |              |
 msg    | text                        |           |          |                                                | extended |              |
Indexes:
    "test_range_pathman_dt_idx" btree (dt)
Child tables: test_range_pathman_1,
              test_range_pathman_10,
              test_range_pathman_11,
              test_range_pathman_12,
              test_range_pathman_12_2,
              test_range_pathman_2,
              test_range_pathman_3,
              test_range_pathman_4,
              test_range_pathman_5,
              test_range_pathman_6,
              test_range_pathman_7,
              test_range_pathman_8,
              test_range_pathman_9
 
 
postgres=> \d test_range_pathman_12_2
                                     Table "test.test_range_pathman_12_2"
 Column |            Type             | Collation | Nullable |                    Default                    
--------+-----------------------------+-----------+----------+------------------------------------------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass)
 dt     | timestamp without time zone |           | not null |
 level  | integer                     |           |          |
 msg    | text                        |           |          |
Indexes:
    "test_range_pathman_12_2_dt_idx" btree (dt)
Check constraints:
    "pathman_test_range_pathman_12_2_check" CHECK (dt >= '2019-12-15 00:00:00'::timestamp without time zone AND dt < '2020-01-01 00:00:00'::timestamp without time zone)
Inherits: test_range_pathman
 
数据会自动迁移到另一个分区
 
 
5. 合并范围分区
目前仅支持范围分区
调用如下接口

指定两个需要合并分区，必须为相邻分区  
merge_range_partitions(partition1 REGCLASS, partition2 REGCLASS)   
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
 

postgres=# select merge_range_partitions(' test_range_pathman_12 '::regclass, ' test_range_pathman_12_2 '::regclass) ;
 merge_range_partitions
------------------------
(1 row)
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
postgres=> \d+ test_range_pathman;
                                                           Table "test.test_range_pathman"
 Column |            Type             | Collation | Nullable |                    Default                     | Storage  | Stats target |
Description
--------+-----------------------------+-----------+----------+------------------------------------------------+----------+--------------+-
------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass) | plain    |              |
 dt     | timestamp without time zone |           | not null |                                                | plain    |              |
 level  | integer                     |           |          |                                                | plain    |              |
 msg    | text                        |           |          |                                                | extended |              |
Indexes:
    "test_range_pathman_dt_idx" btree (dt)
Child tables: test_range_pathman_1,
              test_range_pathman_10,
              test_range_pathman_11,
              test_range_pathman_12,
              test_range_pathman_2,
              test_range_pathman_3,
              test_range_pathman_4,
              test_range_pathman_5,
              test_range_pathman_6,
              test_range_pathman_7,
              test_range_pathman_8,
              test_range_pathman_9
 
合并后，会删掉其中一个分区表
 
来自 < https://yq.aliyun.com/articles/62314 >
 
6. 向后添加范围分区
如果已经对主表进行了分区，将来需要增加分区的话，有几种方法，一种是向后新增分区（即在末尾追加分区）。
新增分区时，会使用初次创建该分区表时的interval作为间隔。
 
来自 < https://yq.aliyun.com/articles/62314 >
 
可以在这个表中查询每个分区表初次创建时的 interval

postgres=# select * from pathman_config;
  partrel  | attname  | parttype | range_interval
-----------+----------+----------+----------------
 part_test | crt_time |        2 | 1 mon
 
 
 
添加分区接口，支持指定表空间

append_range_partition(parent         REGCLASS,            -- 主表 OID
                       partition_name TEXT DEFAULT NULL,   -- 新增的分区表名 , 默认不需要输入
                       tablespace     TEXT DEFAULT NULL)   -- 新增的分区表放到哪个表空间 , 默认不需要输入
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
 
postgres=> select append_range_partition('test_range_pathman'::regclass);
 append_range_partition
------------------------
 test_range_pathman_13
(1 row)
 
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
7. 向前添加范围分区
在头部追加分区。
接口

prepend_range_partition(parent         REGCLASS,
                        partition_name TEXT DEFAULT NULL,
                        tablespace     TEXT DEFAULT NULL)
例子
postgres=# select prepend_range_partition('part_test'::regclass);
 
来自 < https://yq.aliyun.com/articles/62314 >
 
8. 添加分区
指定分区起始值的方式添加分区，只要创建的分区和已有分区不会存在数据交叉就可以创建成功。
也就是说使用这种方法，不要求强制创建连续的分区，例如已有分区覆盖了2010-2015的范围，你可以直接创建一个2020年的分区表，不需要覆盖2015到2020的范围。
接口如下

add_range_partition(relation       REGCLASS,    -- 主表 OID
                    start_value    ANYELEMENT,  -- 起始值
                    end_value      ANYELEMENT,  -- 结束值
                    partition_name TEXT DEFAULT NULL,  -- 分区名
                    tablespace     TEXT DEFAULT NULL)  -- 分区创建在哪个表空间下  
例子

postgres=# select add_range_partition('part_test'::regclass,    -- 主表 OID
                    '2020-01-01 00:00:00'::timestamp,  -- 起始值
                    '2020-02-01 00:00:00'::timestamp); -- 结束值
 add_range_partition
---------------------
 public.part_test_27
(1 row)
 
来自 < https://yq.aliyun.com/articles/62314 >
 
9. 删除分区
1. 删除单个范围分区
接口如下

drop_range_partition(partition TEXT,   -- 分区名称
                    delete_data BOOLEAN DEFAULT TRUE)  -- 是否删除分区数据，如果 false ，表示分区数据迁移到主表。  
Drop RANGE partition and all of its data if delete_data is true.
例子

删除分区， 数据迁移到主表  
postgres=# select drop_range_partition('part_test_1',false);
 
来自 < https://yq.aliyun.com/articles/62314 >
 
2. 删除所有分区，并且指定是否要将数据迁移到主表
接口如下

drop_partitions(parent      REGCLASS,
                delete_data BOOLEAN DEFAULT FALSE)

Drop partitions of the parent table (both foreign and local relations).
If delete_data is false, the data is copied to the parent table first.
Default is false.
例子
postgres=# select drop_partitions('part_test'::regclass, false);  -- 删除所有分区表，并将数据迁移到主表
 
来自 < https://yq.aliyun.com/articles/62314 >
 
10. 绑定分区(已有的表加入分区表)
将已有的表，绑定到已有的某个分区主表。
已有的表与主表要保持一致的结构，包括dropped columns。 (查看pg_attribute的一致性)
如果设置了回调函数，会触发。
接口如下

attach_range_partition(relation    REGCLASS,    -- 主表 OID
                       partition   REGCLASS,    -- 分区表 OID
                       start_value ANYELEMENT,  -- 起始值
                       end_value   ANYELEMENT)  -- 结束值
例子

postgres=# create table part_test_1 (like part_test including all);
CREATE TABLE
postgres=# \d+ part_test
                                  Table "public.part_test"
  Column  |            Type             | Modifiers | Storage  | Stats target | Description
----------+-----------------------------+-----------+----------+--------------+-------------
 id       | integer                     |           | plain    |              |
 info     | text                        |           | extended |              |
 crt_time | timestamp without time zone | not null  | plain    |              |

postgres=# \d+ part_test_1
                                 Table "public.part_test_1"
  Column  |            Type             | Modifiers | Storage  | Stats target | Description
----------+-----------------------------+-----------+----------+--------------+-------------
 id       | integer                     |           | plain    |              |
 info     | text                        |           | extended |              |
 crt_time | timestamp without time zone | not null  | plain    |              |

postgres=# select attach_range_partition('part_test'::regclass, 'part_test_1'::regclass, '2019-01-01 00:00:00'::timestamp, '2019-02-01 00:00:00'::timestamp);
 attach_range_partition
------------------------
 part_test_1
(1 row)

绑定分区时，
自动创建继承关系，自动创建约束  
postgres=# \d+ part_test_1
                                 Table "public.part_test_1"
  Column  |            Type             | Modifiers | Storage  | Stats target | Description
----------+-----------------------------+-----------+----------+--------------+-------------
 id       | integer                     |           | plain    |              |
 info     | text                        |           | extended |              |
 crt_time | timestamp without time zone | not null  | plain    |              |
Check constraints:
    "pathman_part_test_1_3_check" CHECK (crt_time >= '2019-01-01 00:00:00'::timestamp without time zone AND crt_time < '2019-02-01 00:00:00'::timestamp without time zone)
Inherits: part_test
11. 解绑分区(将分区变成普通表)
将分区从主表的继承关系中删除, 不删数据，删除继承关系，删除约束
接口如下
detach_range_partition(partition REGCLASS)  -- 指定分区名，转换为普通表  
例子
postgres=# select count(*) from part_test;
 
来自 < https://yq.aliyun.com/articles/62314 >
 
四.5 分区表高级管理
 
来自 < https://yq.aliyun.com/articles/62314 >
 
2. 自动扩展分区
范围分区表，允许自动扩展分区。
如果新插入的数据不在已有的分区范围内，会自动创建分区。
set_auto(relation REGCLASS, value BOOLEAN)
Enable/disable auto partition propagation (only for RANGE partitioning).
It is enabled by default.
例子
 
来自 < https://yq.aliyun.com/articles/62314 >
 
postgres=> \d+ test_range_pathman;
                                                           Table "test.test_range_pathman"
 Column |            Type             | Collation | Nullable |                    Default                     | Storage  | Stats target |
Description
--------+-----------------------------+-----------+----------+------------------------------------------------+----------+--------------+-
------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass) | plain    |              |
 dt     | timestamp without time zone |           | not null |                                                | plain    |              |
 level  | integer                     |           |          |                                                | plain    |              |
 msg    | text                        |           |          |                                                | extended |              |
Indexes:
    "test_range_pathman_dt_idx" btree (dt)
Child tables: test_range_pathman_1,
              test_range_pathman_10,
              test_range_pathman_11,
              test_range_pathman_12,
              test_range_pathman_13,
              test_range_pathman_2,
              test_range_pathman_3,
              test_range_pathman_4,
              test_range_pathman_5,
              test_range_pathman_6,
              test_range_pathman_7,
              test_range_pathman_8,
              test_range_pathman_9
 
postgres=> \d+ test_range_pathman_13;
                                                          Table "test.test_range_pathman_13"
 Column |            Type             | Collation | Nullable |                    Default                     | Storage  | Stats target |
Description
--------+-----------------------------+-----------+----------+------------------------------------------------+----------+--------------+-
------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass) | plain    |              |
 dt     | timestamp without time zone |           | not null |                                                | plain    |              |
 level  | integer                     |           |          |                                                | plain    |              |
 msg    | text                        |           |          |                                                | extended |              |
Indexes:
    "test_range_pathman_13_dt_idx" btree (dt)
Check constraints:
    "pathman_test_range_pathman_13_check" CHECK (dt >= '2020-01-01 00:00:00'::timestamp without time zone AND dt < '2020-02-01 00:00:00'::
timestamp without time zone)
Inherits: test_range_pathman
 
postgres=>
 
postgres=> select * from test_range_pathman limit 10;
 id |         dt          | level |               msg               
----+---------------------+-------+----------------------------------
  1 | 2019-01-01 00:00:00 |     2 | e79ef3f3199f43435b8b002edf493c06
  2 | 2019-01-01 01:00:00 |     3 | 6fe4e5108fae8be678353f4eb91926f3
  3 | 2019-01-01 02:00:00 |     4 | 5df5f73b9ec0e9639a4fabf1162ca25f
  4 | 2019-01-01 03:00:00 |     2 | ec19a5e22418e26492adaf1e52abb213
  5 | 2019-01-01 04:00:00 |     4 | daef3e76471068995b49ef559a5363ad
  6 | 2019-01-01 05:00:00 |     2 | cb2188eb040b27b0e9318c138d26f882
  7 | 2019-01-01 06:00:00 |     3 | 6ef7f60f6104d17488ccdd72d3f77061
  8 | 2019-01-01 07:00:00 |     0 | b89bddb8988fc0ff36800677852fdc61
  9 | 2019-01-01 08:00:00 |     5 | 2e6c897cd130377fffc24c1989803894
 10 | 2019-01-01 09:00:00 |     4 | 26a82826be29d79c4bc1bf9892524798
(10 rows)
 

插入一个不在已有分区范围的值，会根据创建分区时的 interval 自动扩展若干个分区，这个操作可能很久很久。  
postgres=> insert into test_range_pathman (dt,level,msg) values ('2020-03-01'::timestamp,2,'test');
INSERT 0 1
postgres=>
 
postgres=> \d+ test_range_pathman;
                                                           Table "test.test_range_pathman"
 Column |            Type             | Collation | Nullable |                    Default                     | Storage  | Stats target |
Description
--------+-----------------------------+-----------+----------+------------------------------------------------+----------+--------------+-
------------
 id     | integer                     |           | not null | nextval('test_range_pathman_id_seq'::regclass) | plain    |              |
 dt     | timestamp without time zone |           | not null |                                                | plain    |              |
 level  | integer                     |           |          |                                                | plain    |              |
 msg    | text                        |           |          |                                                | extended |              |
Indexes:
    "test_range_pathman_dt_idx" btree (dt)
Child tables: test_range_pathman_1,
              test_range_pathman_10,
              test_range_pathman_11,
              test_range_pathman_12,
              test_range_pathman_13,
              test_range_pathman_14,
              test_range_pathman_15,
              test_range_pathman_2,
              test_range_pathman_3,
              test_range_pathman_4,
              test_range_pathman_5,
              test_range_pathman_6,
              test_range_pathman_7,
              test_range_pathman_8,
              test_range_pathman_9
 
postgres=>
 
来自 < https://yq.aliyun.com/articles/62314 >
 
 
引用分区(reference partitioning)是Oracle Database 11g Release 1及以上版本的一个新特性。它处理的是父/子对等分区的问题。也就是说，要以某种方式对子表分区，使得各个子表分区分别与一个你表分区存在一对一的关系。在某些情况下这很重要，例如假设有一个数据仓库，你希望保证一定数量的数据在线(例如最近5年的ORDER信息)，而且要确保相关联的子表数据(ORDER_LINE_ITEMS数据)也在线。在这个经典的例子中，ORDERS表通常有一个ORDER_DATE列，所以可以很容易地按月分区，这也有利于保证最近5年的数据在线。随着时间推移，只需加载下一个朋的分区，并删除最老的分区。不过，考虑ORDER_LINE_ITEMS表时会看到存在一个问题。它没有ORDER_DATE列，而且ORDER_LINE_ITEMS表中根本没法有可以据以分区的列，因此无法帮助清除老信息或加载新信息。
 
From <http://124.133.18.218:8089/social/im/SocialIMMain.jsp?frommain=yes&from=pc&isAero=false&pcOS=Windows&sessionkey=abcwnBhA1DKt2dUzFpe7w&language=7>