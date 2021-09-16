
# TOAST

**作者**

chrisx

**日期**

2021-05-13

**内容**

pg toast

`TOAST` (The Oversized-Attribute Storage Technique) 超尺寸字段存储技术。就是说超长字段在Postgres的一个存储方式。

----

[toc]

## WHY？

PostgreSQL page大小是固定的（通常为8KB），且不允许tuples跨多个page存储。因此不能存储非常大的字段值。为了克服这个限制，大字段值需要压缩甚至分割成多个物理行进行存储，这就是TOAST技术。TOAST对用户来说是透明的。

[comment]:( Postgres的部分类型数据不支持toast，这是因为有些字段类型是不会产生大字段数据的，完全没必要用到Toast技术(比如date,time,boolean等) )

## 存储方式

Out-of-line, on-disk TOAST storage 行外磁盘存储
+ 当表中字段任何一个有Toast，那这个表都会有这一个相关联的Toast表，OID被存储在pg_class.reltoastrelid里面。Out-of-line values（可能是压缩后的，如果使用了压缩）将会被分割成chunks，每个chunk大小为toast_max_chunk_size(缺省是2Kb)，每个chunk作为单独的一行存储在TOAST表中。
+ 相比较普通表(MAIN TABLE),TOAST有额外的三个字段（chunk_id,chunk_seq,chunk_data），有唯一索引在chunk_id和hunk_seq上提供快速查询。

```
chunk_id :标识TOASTed值的OID字段
chunk_seq :chunk的序列号，与chunk_id的组合唯一索引可以加速访问
chunk_data :存储TOAST的实际数据
```

+ 当存储的行数据超过toast_tuple_threshold值(通常是2kB)，就会触发toast存储，这时toast将会压缩或者移动超出的字段值直到行数据比toast_tuple_targer值小(这个值通常也是2KB)。所以基础表上可能只存了20%的数据
[//]: # 与更直接的方法 (如允许行值跨页) 相比, 此方案具有许多优点。
[//]: # Out-of-line, in-memory TOAST storage 行外内存存储

Toast有识别4种不同可存储toast的策略：

```bash
# plain避免压缩或行外存储
PLAIN prevents either compression or out-of-line storage; furthermore it disables use of single-byte headers for varlena types. This is the only possible strategy for columns of non-TOAST-able data types
# extended允许压缩和行外存储(默认toast存储)
EXTENDED allows both compression and out-of-line storage. This is the default for most TOASTable data types. Compression will be attempted first, then out-of-line storage if the row is still too big
# external允许行外但不允许压缩
EXTERNAL allows out-of-line storage but not compression. Use of EXTERNAL will make substring operations on wide text and bytea columns faster(at the penalty of increased storage space) because these operations are optimized to fetch only the required parts of the out-of-line value when it is not compressed
# main允许压缩但不允许行外存储
MAIN allows compression but not out-of-line storage. (Actually, out-of-line storage will still be performed for such columns, but only as a last resort when there is no other way to make the row small enough to fit on a page
```

上述压缩采用的是LZ compression技术。

可以通过以下语句更改字段的存储策略

```sql
ALTER TABLE ... SET STORAGE;

```

## 查看TOAST存储

查看TOAST存储

```sql
CREATE TABLE test_toast(
    id int,
    name text,
    age int,
    create_time timestamp without time zone);

--更改toast策略

alter table test_toast alter name set storage external;

INSERT INTO test_toast SELECT generate_series(1,10000),md5(random()::text),
((random()*100)::integer),clock_timestamp();
   
\d+ test_toast;
Table "test.test_toast"
Column | Type | Collation | Nullable | Default | Storage | Stats target | Description
-------------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
id | integer | | | | plain | |
name | text | | | | extended | |
age | integer | | | | plain | |
create_time | timestamp without time zone | | | | plain | |

 select relname,relfilenode,reltoastrelid from pg_class where relname='test_toast';
relname | relfilenode | reltoastrelid
------------+-------------+---------------
test_toast | 102417 | 102420
(1 row)

注意：TOAST表名，可通过以下方式查看

 \! oid2name -d postgres -f 102420
From database "postgres":
Filenode Table Name
---------------------------
102420 pg_toast_102417

or

查询toast表
select 'pg_toast.pg_toast_'||(select relfilenode  from pg_class where relname='test') as toast_tablename ;
```

含有TOAST表的空间大小计算！

```sql
如果表中有某些字段使用TOAST进行存储，那么，通过普通的pg_relation_size('表名')查询不到TOAST字段所占用的空间。如果要查询TOAST字段所占用的空间，可以先查询出TOAST字段对应的OID，再通过pg_relation_size(OID)的方式查询出TOAST字段所占用的空间。


select pg_size_pretty(pg_relation_size('test_toast','main'));
select pg_size_pretty(pg_relation_size(102420));

增加字段大小，产生TOAST存储
update test_toast set name=name||name where id=1;

postgres=> select pg_size_pretty(pg_relation_size(102417));
pg_size_pretty
----------------
832 kB
(1 row)
postgres=> select pg_size_pretty(pg_relation_size(102420));
pg_size_pretty
----------------
3072 kB
(1 row)
postgres=> select pg_size_pretty(pg_table_size('test_toast'));
pg_size_pretty
----------------
4016 kB
(1 row)
使用pg_table_size查出的结果是包括TOAST字段所占用的空间的。
注意：物理文件空间大小查询参考《Cluster database and table》
```

## TOAST的优缺点

Toast的优点
- 可以存储超长超大字段，避免之前不能直接存储的限制
- 物理上与普通表是分离的，检索查询时不检索到该字段会极大地加快速度
- 更新普通表时，该表的Toast数据没有被更新时，不用去更新Toast表

Toast的劣势：
- 对大字段的索引创建是一个问题，有可能会失败，其实通常也不建议在大字段上创建，全文检索倒是一个解决方案。
- 大字段的更新会有点慢，其它DB也存在，通病

<!--
why？？ relpages总是0

highgo=# select pg_size_pretty(pg_relation_size(12725));
 pg_size_pretty
----------------

(1 row)

highgo=#  select * from pg_class where relfilenode = 17275;
  oid  |    relname     | relnamespace | reltype | reloftype | relowner | relam | relfilenode | reltablespace | relpages | reltuples | relallvisible | relto
astrelid | relhasindex | relisshared | relpersistence | relkind | relnatts | relchecks | relhasrules | relhastriggers | relhassubclass | relrowsecurity | re
lforcerowsecurity | relispopulated | relreplident | relispartition | relrewrite | relfrozenxid | relminmxid | relacl | reloptions | relpartbound
-------+----------------+--------------+---------+-----------+----------+-------+-------------+---------------+----------+-----------+---------------+------
---------+-------------+-------------+----------------+---------+----------+-----------+-------------+----------------+----------------+----------------+---
------------------+----------------+--------------+----------------+------------+--------------+------------+--------+------------+--------------
 17275 | pg_toast_17272 |           99 |   17276 |         0 |     9999 |     2 |       17275 |             0 |        0 |         0 |             0 |
       0 | t           | f           | p              | t       |        3 |         0 | f           | f              | f              | f              | f
                  | t              | n            | f              |          0 |          619 |          1 |        |            |
(1 row)

highgo=#
-->
