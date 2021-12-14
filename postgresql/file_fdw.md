# file_fdw

**作者**

Chrisx

**日期**

2021-12-14

**内容**


file_fdw模块提供外部数据包装器file_fdw， 它能被用来访问服务器的文件系统中的数据文件

----

[toc]

## 配置

```sql
CREATE EXTENSION file_fdw;      --创建fdw扩展

CREATE SERVER ser_file_fdw FOREIGN DATA WRAPPER file_fdw;       --创建服务

CREATE FOREIGN TABLE test_file_fdw (product_id      CHAR(4)      NOT NULL,
 product_name    VARCHAR(100) NOT NULL,
 product_type    VARCHAR(32)  NOT NULL,
 sale_price      INTEGER ,
 purchase_price  INTEGER ,
 regist_date     DATE) SERVER ser_file_fdw
OPTIONS ( filename '/tmp/test_file_fdw.csv', format 'csv',header 'true',null 'null' );     --创建外部表，表结构与外部文件一致

```

:warning: ERROR:  0A000: primary key constraints are not supported on foreign tables

生成一个外部文件

```sql
copy (select * from product limit 5) to '/tmp/test_file_fdw.csv' with (FORMAT csv,header true,null 'null');    --生成外部文件csv
```

查询外部表

```sql
highgo=#  select * from test_file_fdw;
 product_id | product_name | product_type | sale_price | purchase_price | regist_date
------------+--------------+--------------+------------+----------------+-------------
 0001       | T恤          | 衣服         |       1000 |            500 | 2009-09-20
 0002       | 打孔器       | 办公用品     |        500 |            320 | 2009-09-11
 0003       | 运动T恤      | 衣服         |       4000 |           2800 |
 0004       | 菜刀         | 厨房用具     |       3000 |           2800 | 2009-09-20
 0005       | 高压锅       | 厨房用具     |       6800 |           5000 | 2009-01-15
(5 rows)

```

:warning: file_fdw不支持增删改 ERROR:  0A000: cannot update foreign table "test_file_fdw"

<!--
查询过程可能存在如下错误

```sql
highgo=# select * from test_file_fdw;
2021-02-18 15:54:23.389 CST [3462] ERROR:  22007: invalid input syntax for type date: "null"
2021-02-18 15:54:23.389 CST [3462] CONTEXT:  COPY test_file_fdw, line 4, column regist_date: "null"
2021-02-18 15:54:23.389 CST [3462] STATEMENT:  select * from test_file_fdw;
ERROR:  22007: invalid input syntax for type date: "null"
CONTEXT:  COPY test_file_fdw, line 4, column regist_date: "null"
highgo=#
```
解决方法

创建外部表是需指定识别空的符号。外部表，表结构与需外部文件一致，外部文件中使用null表示空。因此外部表需要指定null为空

```sql
CREATE FOREIGN TABLE
......
OPTIONS ( null 'null' ); 
```
-->

[为 PostgreSQL CSV 日志创建一个外部表](https://www.postgresql.org/docs/13/file-fdw.html)

外部表相关视图

* pg_foreign_server
* pg_user_mapping
* pg_foreign_table
