# tuple_and_deadtuple

**作者**

Chrisx

**日期**

2021-06-01

**内容**

从并发控制（MVCC）角度看deadtuple死数据的产生

---

[TOC]

## tuple结构

数据结构 HeapTupleHeaderData 是多版本并发控制的核心数据结构

|        |        |       |        |             |            |        |             |           |
| ------ | ------ | ----- | ------ | ----------- | ---------- | ------ | ----------- | --------- |
| t_xmin | t_xmax | t_cid | t_ctid | t_infomask2 | t_infomask | t_hoff | null_bitmap | user_data |

虽然 [HeapTupleHeaderData]结构包含7个元素，但本文中只涉及其中4个元素。

* t_xmin 记录插入此元组的事务ID（txid）。
* t_xmax 记录删除或更新此元组的事务ID（txid）。如果这个元组没有被删除或更新，t_xmax被设置为0，这意味着INVALID。
* t_cid 记录命令ID(command id，cid)，从0开始递增，表示当前事务中执行此命令之前执行了多少个SQL命令。例如，假定我们在单个事务中执行三个INSERT命令：BEGIN; INSERT; INSERT; INSER;COMMIT;。如果第一个命令插入这个元组，则t_cid被设置为0，如果第二个命令插入该元组，则t_cid被设置为1，依此类推。
* t_ctid 记录指向自身或新元组的元组标识符(tuple identifier，tid)。tid用于标识表中的元组。当这个元组更新时，这个元组的t_ctid指向新的元组; 否则，t_ctid指向自己。

## tuple增删改及dead tuple产生

### 1. Insert

插入操作中，新元组将直接插入目标表页面中。其 xmin 字段被存储为本事务的 XID，xmax 为 0,当事 务提交后，所有的事务的 XID 大于等于 xmin 中存储的 XID 的事务，都可以看到这条记录。 这完全符合 read commit 事务隔离级别的要求。

```sql
begin;
insert into test_con values (1,'A');
commit;
```

**PostgreSQL提供了一个扩展pageinspect，用于显示page页的内容**

```sql
CREATE EXTENSION pageinspect;
create table test_con(id int,name text);
insert into test_con values (1,'A');
test=# SELECT lp as tuple, t_xmin, t_xmax, t_field3 as t_cid, t_ctid FROM heap_page_items(get_raw_page('test.test_con', 0));
tuple | t_xmin | t_xmax | t_cid | t_ctid
-------+--------+--------+-------+--------
1 | 594 | 0 | 0 | (0,1)
(1 row)
```

* t_xmin设置为594，表示这条数据是由事务594插入的
* t_xmax设置为0，保留事务id，无效的。表示这行数据没有被update或delete
* t_cid设置为0，表示这行数据是事务594插入的第一行数据
* t_ctid设置为（0，1），指向自己，没有新版本产生

:warning: 注：page结构不在本文讨论，参考体系结构-物理结构

### 2. delete

如果该记录被删除，在 PostgreSQL 中，暂时不会删除这条记录，而是会在这条记录上 做一个标识。PostgreSQL 的做法是将该记录的 xmax 设置为删除这条记录的事务的 XID。 这样，所有的该记录删除后的事务的 XID 都大于 xmax 的值，因此删除后发起的查询都无 法读取到这条记录；而对于删除这条记录之前的启动的查询，由于 XID 小于 xmax，因此仍
然可以读取到这条记录。这样就解决了 MVCC 的事务隔离和一致性读的问题。

```sql
begin;
delete from test_con where id=1;
commit;
```

可以通过扩展 pageinspect ，查看page的内容

```sql
test=# SELECT lp as tuple, t_xmin, t_xmax, t_field3 as t_cid, t_ctid FROM heap_page_items(get_raw_page('test.test_con', 0));
tuple | t_xmin | t_xmax | t_cid | t_ctid
-------+--------+--------+-------+--------
1 | 594 | 595 | 0 | (0,1)
(1 row)
```

* t_xmax设置为595，表示这行数据被事务595update或delete
* 如果事务操作commited，那么这行数据tuple_1就不再需要了，会被标记为 `dead tuple`。

### 3. update

如果该记录被修改（update）了，那么 PostgreSQL 不会直接修改原有的记录，而是会 生成一条新的记录，新记录的 xmin 为 update 操作的 XID，xmax 为 0，同时会将老记录的 xmax 设置为当前操作的 XID，也就是说新记录的 xmin 和老记录的 xmax 相同。这样在同 一张表中，同一条记录就会有存在多个副本。

```sql
test=> insert into test_con values (1,'A');
INSERT 0 1
test=> update test_con set name='B' where id=1; UPDATE 1
test=> update test_con set name='C' where id=1; UPDATE 1
test=>
```

可以通过扩展 pageinspect ，查看page的内容

```sql
test=# SELECT lp as tuple, t_xmin, t_xmax, t_field3 as t_cid, t_ctid FROM heap_page_items(get_raw_page('test.test_con', 0));
tuple | t_xmin | t_xmax | t_cid | t_ctid
-------+--------+--------+-------+--------
1 | 599 | 600 | 0 | (0,2)
2 | 600 | 601 | 0 | (0,3)
3 | 601 | 0 | 0 | (0,3)
(3 rows)
```

* tuple_1
t_xmax设置为600，被事务600修改
t_ctid设置为（0，2），不再指向自己，指向第二个版本tuple_2

* tuple_2
t_xmax设置为601，被事务601修改
t_ctid设置为（0，3），不再指向自己，指向第三个版本tuple_3

* tuple_3
t_xmax设置为0，没有被修改过
t_ctid设置为（0，3），指向自己

如果事务操作committed，那么数据tuple_1和tuple_2就不再需要了，会被标记为`dead tuple`。

<!--
思考
产生这么多的dead tuple怎么办？死数据导致表膨胀，不断占用磁盘空间
-->

从MVCC 机制工作原理来看，INSERT 操作并没有太多的问题， PostgreSQL 的 INSERT 操作和其他数据库的工作原理十分类似，只是 PostgreSQL 的行头 大小为 20 字节，远远大于 Oracle 的 3 字节，因此 PostgreSQL 的存储额外开销要略大于 Oracle。从 UPDATE 操作来看，无论 UPDATE 多少个字段，PostgreSQL 都需要插入一条 新的记录，这样会造成 SEGMENT 高水位的增长，如果某张表的数据插入后，需要多次 UPDATE，那么这张表的高水位会出现暴涨。为了解决这个问题，PostgreSQL 使用了一个 版本回收机制----VACUUM。通过 VACUUM，PostgreSQL 可以回收旧版本，从而避免多版本带 来的性能问题。
