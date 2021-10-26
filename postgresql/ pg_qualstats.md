# pg_qualstats

**作者**

Chrisx

**日期**

2021-10-25

**内容**

pg_qualstats是一个PostgreSQL扩展，它保留WHERE语句和JOIN子句中谓词的统计信息。

如果您希望能够分析数据库中最常执行的QUAL（谓词）是什么，这将非常有用。powa项目利用这一点提供建议。如索引优化建议，查找那些列需要添加索引。

ref [pg_qualstats](https://github.com/powa-team/pg_qualstats)

----

[toc]

## 安装

下载源码包,编译安装

```sh
tar -zxvf pg_qualstats-2.0.3.tar.gz
cd pg_qualstats-2.0.3
make
make install

```

<!--
[root@db pg_qualstats-2.0.3]# make install
/usr/bin/mkdir -p '/opt/HighGo4.5.5-see/share/postgresql/extension'
/usr/bin/mkdir -p '/opt/HighGo4.5.5-see/share/postgresql/extension'
/usr/bin/mkdir -p '/opt/HighGo4.5.5-see/lib/postgresql'
/usr/bin/install -c -m 644 .//pg_qualstats.control '/opt/HighGo4.5.5-see/share/postgresql/extension/'
/usr/bin/install -c -m 644 .//pg_qualstats--2.0.3.sql  '/opt/HighGo4.5.5-see/share/postgresql/extension/'
/usr/bin/install -c -m 755  pg_qualstats.so '/opt/HighGo4.5.5-see/lib/postgresql/'
[root@db pg_qualstats-2.0.3]#
-->

## 配置使用

```sql
psql
alter system set shared_preload_libraries=pg_qualstats;
pg_ctl restart
CREATE EXTENSION pg_qualstats;
select * from pg_qualstats;
```

配置参数

* pg_qualstats.enabled
* pg_qualstats.track_constants
* pg_qualstats.max
* pg_qualstats.resolve_oids
* pg_qualstats.track_pg_catalog
* pg_qualstats.sample_rate

参考手册[Configuration](https://github.com/powa-team/pg_qualstats)

```sql
alter system set pg_qualstats.sample_rate=1;
```

## pg_qualstats_index_advisor

pg_qualstats_index_advisor（最小过滤器、最小选择性、禁止am）：执行全局索引建议。默认情况下，只考虑过滤至少1000行和平均30%行的谓词，但这可以作为参数传递。如果希望避免某些错误，还可以提供索引访问方法数组。例如，在PostgreSQL 9.6和更早版本上，哈希索引将被忽略，因为这些索引还不是崩溃安全的。

```sql
SELECT v
  FROM json_array_elements(
    pg_qualstats_index_advisor(min_filter => 50)->'indexes') v
  ORDER BY v::text COLLATE "C";

```

case

```sql
3.创建测试表并插入数据
Drop table t1;
create table t1(id int, name text);
INSERT INTO t1 SELECT (random() * 1000000)::int, md5(g::text) FROM generate_series(1, 1000000) g;
4.执行带过滤条件的 SELECT 语句
select * from t1 limit 10;
Select * from t1 where id = 第一个值;
5.查询 sql 优化建议
highgo=# SELECT v
highgo-#   FROM json_array_elements(
highgo(#     pg_qualstats_index_advisor(min_filter => 50)->'indexes') v
highgo-#   ORDER BY v::text COLLATE "C";
                      v
---------------------------------------------
 "CREATE INDEX ON public.t1 USING brin (id)"
(1 row)

highgo=#

```