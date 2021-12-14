# fdw

**作者**

Chrisx

**日期**

2021-11-17

**内容**

FDW的使用

----

[toc]

FWD(foreign data wrapper)外部数据包装器,允许我们使用普通SQL查询来访问位于PostgreSQL之外的数据。

## fdw相关概念

* `外部数据`,数据库支持将数据存储在外部，外部可以是一个远程的pg数据库或者其他数据库（mysql, oracle等）,又或者是文件等。可以在一个`外部数据包装器`的帮助下被访问
* `FWD(foreign data wrapper)外部数据包装器`,fdw是一种外部访问接口，可以在PG数据库中创建外部表，用户访问的时候与访问本地表的方法一样，支持增删改查。
* `SERVER外部服务器`,包装了fdw用来访问一个外部数据源所需的连接信息
* `USER MAPPING用户映射`,定义一个用户到一个外部服务器的新映射,提供访问数据源需要的用户名和密码
* `FOREIGN TABLE外部表`，它们定义了外部数据的结构。一个外部表可以在查询中像一个普通表一样地使用，但是外部表没有存储数据。只是一张表结构

* 一个外部数据包装器是一个库，它可以与一个外部数据源通讯，并隐藏连接到数据源和从它获取数据的细节。
* FDW使用server和USER MAPPING包含的信息,访问FOREIGN TABLE
* 有很多fdw扩展，但只有postgres_fdw与file_fdw是由官方维护的。（citus也是fdw的一种）

假设远程服务器分别装有pg和oracle，数据库中存放表分别为pg_foreigntab和ora_foreigntab。在HGDB中分别创建外部表test_pg_foreigntab和test_ora_foreigntab，可对外部数据进行访问

```sql
--可以在本地服务器上执行
Select count(*) from test_pg_foreigntab;
Select count(*) from test_ora_foreigntab;
--还可以进行连接操作
Select count(*) from test_pg_foreigntab as p,test_ora_foreigntab as o where m.id=o.id;
```

## fdw使用简介

使用fdw需要先创建扩展、并设置相关配置（create foreign table、create server、create user mapping）

```sql
create extension postgres_fdw ;

CREATE SERVER foreign_server
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host '192.168.6.12', port '5432', dbname 'postgres');
        
CREATE USER MAPPING FOR highgo
        SERVER foreign_server
        OPTIONS (user 'pg', password 'pg');
       
create FOREIGN TABLE foreign_table (
        id integer NOT NULL,
        info text
)
        SERVER foreign_server
        OPTIONS (schema_name 'public', table_name 'pitr_test',fetch_size '10000');

```

## fdw执行过程

1. 本地服务器

$\downarrow$ `parser`
$\downarrow$ `analyzer`--解析器根据sql创建查询树，使用外部表定义。外部表定义存储在系统目录pg_catalog.pg_class和pg_catalog.pg_foreign_table
$\downarrow$ `rewriter`
$\downarrow$ `planner`--连接至远程服务器，连接信息参数存储在系统目录pg_catalog.pg_user_mapping和pg_catalog.pg_foreign_server
$\downarrow$ `executor`--生成执行计划树时，会为外部表创建对应的纯文本sql语句，称为`逆解析`。使用mysql_fdw时，会创建mysql对应的select语句，使用oracle_fdw时会创建oracle对应的select语句。

2. 远程服务器

fdw机制支持一种特性，将use_remote_estimate设置为on，查询会获取外部表上的统计信息，用于估计查询代价。目前仅postgres_fdw支持比较好。

```sql
alter server remote_server_name options(use_remote_estimate 'on');
```

3. 发送sql并接收结果。

* executor将sql语句发送到远程服务器并接受结果。
* 不同的fdw扩展决定了sql语句发送到远程服务器的具体方法
* postgres_fdw的sql执行顺序

1）启动远程事务，默认隔离级别repeatable read
2）声明一个游标，sql以游标的方式运行
3）fetch获取结果，默认fetch命令一次获取100行
4）从远程服务器接收结果
5）关闭游标
6）提交远程事务

## fdw工作原理

fdw会下推操作

| 版本 | 描述                                                                                                                                    |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 9.3  | postgres_fdw正式发布                                                                                                                    |
| 9.6  | 在远程服务器上执行排序；在远程服务器上执行连接；如果可行，在远程服务器上执行update与delete；允许在服务器与表的选项中设置fetch结果集大小 |
| 10   | 如果可行，将聚合函数下推值远程服务器                                                                                                    |

:warning: fdw不会检测死锁

```sql
EXPLAIN (analyze,costs,buffers,timing,verbose) select * from foreign_table where id=1;
```

[fdw支持的数据源](https://wiki.postgresql.org/wiki/Foreign_data_wrappers)

## 使用

具体使用参考如下

* ref [file_fdw](./file_fdw.md)
* ref [postgresql_fdw](./postgresql_fdw.md)
* ref [oracle_fdw](./oracle_fdw.md)

:warning: 如需大量创建外部表，可进行批量导入，ref [fdw_import](./fdw_import.md)