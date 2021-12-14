## postgres_fdw

**作者**

Chrisx

**日期**

2021-12-14

**内容**

postgres_fdw的使用

postgres_fdw模块提供了外部数据包装器postgres_fdw，它可以被用来访问存储在外部PostgreSQL服务器中的数据。

----

[toc]

## 远程数据库

需要知道远程数据库信息，如
服务器ip、端口、用户、schema、对象

## 本地数据库配置

```sql
CREATE EXTENSION postgres_fdw;      --创建fdw扩展

CREATE SERVER ser_postgres_fdw  
        FOREIGN DATA WRAPPER postgres_fdw  
        OPTIONS (host '192.168.6.142', port '5966', dbname 'test'); --创建远程服务

--OPTIONS (host '192.168.6.142', port '5966', dbname 'test') 是远程数据库连接信息

CREATE USER MAPPING FOR highgo  
        SERVER ser_postgres_fdw  
        OPTIONS (user 'test', password 'test');      --配置远程访问用户密码-mapping
--highgo，要映射到外部服务器的一个现有用户的名称。也就是本地用户名
--OPTIONS (user 'test', password 'test')，定义该映射实际的用户名和 口令，也就是远程连接使用的用户名口令，也就是远程服务器上存在的用户名口令

CREATE FOREIGN TABLE public.test_postgres_fdw (product_id      CHAR(4)      NOT NULL,
 product_name    VARCHAR(100) NOT NULL,
 product_type    VARCHAR(32)  NOT NULL,
 sale_price      INTEGER ,
 purchase_price  INTEGER ,
 regist_date     DATE) SERVER ser_postgres_fdw
OPTIONS (schema_name 'public',table_name 'product' );     --创建外部表

-- test_postgres_fdw，本地表名称。通常来说，推荐创建外部表时使用和远程表一致的数据类型以及可能的排序规则。虽然目前 postgres_fdw 支持各种类型转换，远程服务器和本地服务器解析 WHERE 子句的细微差别可能会导致意外的语义异常。另外，外部表的字段个数可以少于远程表，字段顺序也可以不同；因为字段的映射是通过名称而不是字段位置实现。
--OPTIONS (schema_name 'public',table_name 'product' )是远程表的信息

ALTER TABLE test_postgres_fdw OWNER TO highgo;  --将表授予普通用户

```

## 外部表管理

查询外部表

```sql
highgo=# select * from test_postgres_fdw ;
 product_id | product_name | product_type | sale_price | purchase_price | regist_date
------------+--------------+--------------+------------+----------------+-------------
 0001       | T恤          | 衣服         |       1000 |            500 | 2009-09-20
 0002       | 打孔器       | 办公用品     |        500 |            320 | 2009-09-11
 0003       | 运动T恤      | 衣服         |       4000 |           2800 |
 0004       | 菜刀         | 厨房用具     |       3000 |           2800 | 2009-09-20
 0005       | 高压锅       | 厨房用具     |       6800 |           5000 | 2009-01-15
 0006       | 叉子         | 厨房用具     |        500 |                | 2009-09-20
 0007       | 擦菜板       | 厨房用具     |        880 |            790 | 2008-04-28
 0008       | 圆珠笔       | 办公用品     |        100 |                | 2009-11-11
(8 rows)

```

修改外部表

```sql
highgo=# update test_postgres_fdw set sale_price=1111 where product_id='0001';
UPDATE 1

```

:warning: 如需大量创建外部表，可进行批量导入，ref [fdw_import](./fdw_import.md)

<!--

查询可能会遇到如下错误

highgo=# select * from test_postgres_fdw ;
2021-02-18 16:57:40.969 CST [4432] ERROR:  08001: could not connect to server "ser_postgres_fdw"
2021-02-18 16:57:40.969 CST [4432] DETAIL:  could not connect to server: No route to host
                Is the server running on host "192.168.6.142" and accepting
                TCP/IP connections on port 5966?
2021-02-18 16:57:40.969 CST [4432] STATEMENT:  select * from test_postgres_fdw ;
ERROR:  08001: could not connect to server "ser_postgres_fdw"
DETAIL:  could not connect to server: No route to host
        Is the server running on host "192.168.6.142" and accepting
        TCP/IP connections on port 5966?
highgo=#

解决方案

此问题是远程网络访问控制没有允许连接，没有放开权限。在远程端放开连接权限（pg_hba.conf,listen_addresses）
-->