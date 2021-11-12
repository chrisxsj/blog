# FDW

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

## fdw使用

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

fdw机制支持一种特性，将user_remote_estimate设置为on，查询会获取外部表上的统计信息，用于估计查询代价。目前仅postgres_fdw支持比较好。

```sql
alter server remote_server_name options(user_remote_estimate 'on');
```

3. 发送sql并接收结果。

* executor将sql语句发送到远程服务器并接受结果。
* 不同的fdw扩展决定了sql语句发送到远程服务器的具体方法
* postgres_fdw的sql执行顺序

> 1启动远程事务，默认隔离级别repeatable read
2声明一个游标，sql以游标的方式运行
3fetch获取结果，默认fetch命令一次获取100行
4从远程服务器接收结果
5关闭游标
6提交远程事务

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

## file_fdw

file_fdw模块提供外部数据包装器file_fdw， 它能被用来访问服务器的文件系统中的数据文件

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

## postgres_fdw

postgres_fdw模块提供了外部数据包装器postgres_fdw，它可以被用来访问存储在外部PostgreSQL服务器中的数据。

本地数据库配置！

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

CREATE FOREIGN TABLE test_postgres_fdw (product_id      CHAR(4)      NOT NULL,
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

## oracle_fdw

oracle_fdw是PostgreSQL扩展，它提供了一个第三方外部数据包装器，方便和高效地访问存储在外部数据库oracle中的数据

### 安装配置oracle客户端

下载[instant client](https://www.oracle.com/database/technologies/instant-client/downloads.html)

1. 下载三个文件即可
Basic Package (ZIP)
SQL*Plus Package (ZIP)
SDK Package (ZIP)

```shell
instantclient-basic-linux.x64-11.2.0.4.0.zip
instantclient-sdk-linux.x64-11.2.0.4.0.zip
instantclient-sqlplus-linux.x64-11.2.0.4.0.zip

```

2. 创建用户和目录

```shell
groupadd oinstall
useradd -G oinstall oracle
passwd oracle
mkdir /opt/oracle
chown oracle:oinstall /opt/oracle

```
3. 解压3个文件,会将内容解压到一个目录中instantclient_11_2。将文件夹中的内容复制到/opt/oracle

4. 设置环境变量

```shell
su - oracle
vi ~/.bash_profile

export ORACLE_HOME=/opt/oracle
export SQLPATH=/opt/oracle
export TNS_ADMIN=/opt/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH;
export PATH=$ORACLE_HOME:$PATH

```

5. 配置tns

配置网络访问

```shell
vi /opt/oracle/tnsnames.ora

FDW =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.6.11)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )


```

测试tns是否正常

```shell
sqlplus system/oracle@fdw 

```

### 安装oracle_fdw

下载 [oracle_fdw](https://github.com/laurenz/oracle_fdw/)
:warning: windows下载对应版本，linux可使用源码包编译

1. 设置环境变量

将环境变量添加到pg数据库用户下

```shell
export ORACLE_HOME=/opt/oracle
export SQLPATH=/opt/oracle
export TNS_ADMIN=/opt/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH;
export PATH=$ORACLE_HOME:$PATH

```

```shell
export HG_BASE=/opt/HighGo5.6.5
export PGHOME=/opt/HighGo5.6.5
export HGDB_HOME=/opt/HighGo5.6.5
export PGDATA=/opt/HighGo5.6.5/data
export LD_LIBRARY_PATH=/opt/HighGo5.6.5/lib:$LD_LIBRARY_PATH
export PGPORT=5966
export PGDATABASE=highgo
export PGUSER=highgo
export PATH=$PATH:/opt/HighGo5.6.5/bin

export ORACLE_HOME=/opt/oracle
export SQLPATH=/opt/oracle
export TNS_ADMIN=/opt/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH;
export PATH=$ORACLE_HOME:$PATH


```

测试tns

```shell
sqlplus system/oracle@fdw 

```

2. 解压

3. 安装

```shell
make PG_CONFIG=/opt/HighGo5.6.5/bin/pg_config

```

<!--
报错
oracle_utils.c:22:17: fatal error: oci.h: No such file or directory
 #include <oci.h>
                 ^
compilation terminated.
make: *** [oracle_utils.o] Error 1

解决方案

需在pg数据库用户下设置ORACLE_HOME环境变量
export ORACLE_HOME=/opt/oracle
-->

<!--
报错
/bin/ld: cannot find -lclntsh
collect2: error: ld returned 1 exit status
make: *** [oracle_fdw.so] Error 1

解决方案
执行make若出现“/usr/bin/ld: cannot find -lclntsh”；原因是找不到库liblclntsh文件
$ORACLE_HOME下有库文件libclntsh.so.11.1，而需要的库文件是libclntsh.so，创建一个软连接即可
ln -s libclntsh.so.11.1 libclntsh.so
-->

<!--
[hgdb565@db oracle_fdw-ORACLE_FDW_2_3_0]$ make PG_CONFIG=/opt/HighGo5.6.5/bin/pg_config
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -shared -o oracle_fdw.so oracle_fdw.o oracle_utils.o oracle_gis.o -L/opt/HighGo5.6.5/lib  -llber  -Wl,--as-needed -Wl,-rpath,'/opt/HighGo5.6.5/lib',--enable-new-dtags  -L/opt/oracle -L/opt/oracle/bin -L/opt/oracle/lib -L/opt/oracle/lib/amd64 -lclntsh -L/usr/lib/oracle/19.8/client/lib -L/usr/lib/oracle/19.8/client64/lib -L/usr/lib/oracle/19.6/client/lib -L/usr/lib/oracle/19.6/client64/lib -L/usr/lib/oracle/19.3/client/lib -L/usr/lib/oracle/19.3/client64/lib -L/usr/lib/oracle/18.5/client/lib -L/usr/lib/oracle/18.5/client64/lib -L/usr/lib/oracle/18.3/client/lib -L/usr/lib/oracle/18.3/client64/lib -L/usr/lib/oracle/12.2/client/lib -L/usr/lib/oracle/12.2/client64/lib -L/usr/lib/oracle/12.1/client/lib -L/usr/lib/oracle/12.1/client64/lib -L/usr/lib/oracle/11.2/client/lib -L/usr/lib/oracle/11.2/client64/lib -L/usr/lib/oracle/11.1/client/lib -L/usr/lib/oracle/11.1/client64/lib -L/usr/lib/oracle/10.2.0.5/client/lib -L/usr/lib/oracle/10.2.0.5/client64/lib -L/usr/lib/oracle/10.2.0.4/client/lib -L/usr/lib/oracle/10.2.0.4/client64/lib -L/usr/lib/oracle/10.2.0.3/client/lib -L/usr/lib/oracle/10.2.0.3/client64/lib
[hgdb565@db oracle_fdw-ORACLE_FDW_2_3_0]$
-->

```shell
make install PG_CONFIG=/opt/HighGo5.6.5/bin/pg_config

```

<!--
[hgdb565@db oracle_fdw-ORACLE_FDW_2_3_0]$ make install PG_CONFIG=/opt/HighGo5.6.5/bin/pg_config
/usr/bin/mkdir -p '/opt/HighGo5.6.5/lib/postgresql'
/usr/bin/mkdir -p '/opt/HighGo5.6.5/share/postgresql/extension'
/usr/bin/mkdir -p '/opt/HighGo5.6.5/share/postgresql/extension'
/usr/bin/mkdir -p '/opt/HighGo5.6.5/share/doc/postgresql/extension'
/usr/bin/install -c -m 755  oracle_fdw.so '/opt/HighGo5.6.5/lib/postgresql/oracle_fdw.so'
/usr/bin/install -c -m 644 .//oracle_fdw.control '/opt/HighGo5.6.5/share/postgresql/extension/'
/usr/bin/install -c -m 644 .//oracle_fdw--1.2.sql .//oracle_fdw--1.0--1.1.sql .//oracle_fdw--1.1--1.2.sql  '/opt/HighGo5.6.5/share/postgresql/extension/'
/usr/bin/install -c -m 644 .//README.oracle_fdw '/opt/HighGo5.6.5/share/doc/postgresql/extension/'
[hgdb565@db oracle_fdw-ORACLE_FDW_2_3_0]$
-->

4. 配置

```sql
CREATE EXTENSION oracle_fdw;      --创建fdw扩展

CREATE SERVER ser_oracle_fdw  
        FOREIGN DATA WRAPPER oracle_fdw  
        OPTIONS (dbserver '192.168.6.11:1521/orcl'); --创建远程服务

create role ora_fdw with login password 'ora_fdw';

CREATE USER MAPPING FOR highgo  
        SERVER ser_oracle_fdw  
        OPTIONS (user 'hr', password 'hr');      --配置远程访问用户密码-mapping
--ora_fdw，要映射到外部服务器的一个现有用户的名称。也就是本地用户名
--OPTIONS (user 'system', password 'oracle')，定义该映射实际的用户名和 口令，也就是远程连接使用的用户名口令，也就是远程服务器上存在的用户名口令

CREATE FOREIGN TABLE test_oracle_fdw (product_id      CHAR(4)  options(key 'true')    NOT NULL,
 product_name    VARCHAR(100) NOT NULL,
 product_type    VARCHAR(32)  NOT NULL,
 sale_price      INTEGER ,
 purchase_price  INTEGER ,
 regist_date     DATE) SERVER ser_oracle_fdw
OPTIONS (schema 'HR',table 'PRODUCT' );     --创建外部表

--注意，Oracle table names are case sensitive，因此这里的用户名及表名必须为大写

alter FOREIGN TABLE test_oracle_fdw
```

5. 查询外部表

```sql
highgo=# select * from test_oracle_fdw ;
 product_id | product_name | product_type | sale_price | purchase_price |  regist_date
------------+--------------+--------------+------------+----------------+---------------
 0001       | T恤          | 衣服         |       1000 |            500 | 0001-01-01 BC
(1 row)


```

<!--
报错
highgo=# select * from test_oracle_fdw ;
2021-02-19 15:55:30.925 CST [6157] ERROR:  HV00R: Oracle table "hr"."product" for foreign table "test_oracle_fdw" does not exist or does not allow read access
2021-02-19 15:55:30.925 CST [6157] DETAIL:  ORA-00942: table or view does not exist
2021-02-19 15:55:30.925 CST [6157] HINT:  Oracle table names are case sensitive (normally all uppercase).
2021-02-19 15:55:30.925 CST [6157] STATEMENT:  select * from test_oracle_fdw ;
ERROR:  HV00R: Oracle table "hr"."product" for foreign table "test_oracle_fdw" does not exist or does not allow read access
DETAIL:  ORA-00942: table or view does not exist
HINT:  Oracle table names are case sensitive (normally all uppercase).
highgo=#

解决方案
创建外部表时，oracle的用户名及表名必须为大写

CREATE FOREIGN TABLE test_oracle_fdw (product_id      CHAR(4)      NOT NULL,
 product_name    VARCHAR(100) NOT NULL,
 product_type    VARCHAR(32)  NOT NULL,
 sale_price      INTEGER ,
 purchase_price  INTEGER ,
 regist_date     DATE) SERVER ser_oracle_fdw
OPTIONS (schema 'HR',table 'PRODUCT' );     --创建外部表
-->

6. 修改外部表

```sql

highgo=# INSERT INTO test_oracle_fdw VALUES ('0002', '打孔器', '办公用品', 500, 320, to_date('yyyy-mm-dd','2009-09-11'));
INSERT 0 1

highgo=# update test_oracle_fdw set sale_price=1111 where product_id='0001';
UPDATE 1

highgo=# select * from test_oracle_fdw ;
 product_id | product_name | product_type | sale_price | purchase_price |  regist_date
------------+--------------+--------------+------------+----------------+---------------
 0001       | T恤          | 衣服         |       1111 |            500 | 0001-01-01 BC
 0002       | 打孔器       | 办公用品     |        500 |            320 | 0001-01-01 BC
(2 rows)

```

<!--
报错
highgo=# INSERT INTO test_oracle_fdw VALUES ('0001', 'T恤' ,'衣服', 1000, 500, '2009-09-20');
2021-02-19 16:02:11.040 CST [6157] ERROR:  40001: error executing query: OCIStmtExecute failed to execute remote query
2021-02-19 16:02:11.040 CST [6157] DETAIL:  ORA-08177: can't serialize access for this transaction
2021-02-19 16:02:11.040 CST [6157] STATEMENT:  INSERT INTO test_oracle_fdw VALUES ('0001', 'T恤' ,'衣服', 1000, 500, '2009-09-20');
ERROR:  40001: error executing query: OCIStmtExecute failed to execute remote query
DETAIL:  ORA-08177: can't serialize access for this transaction

解决方案

数据类型不匹配，日期数据类型需改为兼容oracle

INSERT INTO test_oracle_fdw VALUES ('0001', 'T恤' ,'衣服', 1000, 500, to_date('yyyy-mm-dd','2009-09-20'));
-->

<!--
报错

highgo=# delete from test_oracle_fdw where product_id='0001';
2021-02-19 16:09:02.499 CST [6157] ERROR:  HV00L: no primary key column specified for foreign Oracle table
2021-02-19 16:09:02.499 CST [6157] DETAIL:  For UPDATE or DELETE, at least one foreign table column must be marked as primary key column.
2021-02-19 16:09:02.499 CST [6157] HINT:  Set the option "key" on the columns that belong to the primary key.
2021-02-19 16:09:02.499 CST [6157] STATEMENT:  delete from test_oracle_fdw where product_id='0001';
ERROR:  HV00L: no primary key column specified for foreign Oracle table
DETAIL:  For UPDATE or DELETE, at least one foreign table column must be marked as primary key column.
HINT:  Set the option "key" on the columns that belong to the primary key.

解决方案
update或delete一定要设置options(key ‘true’)，就是设置外部表的主键，否则会报错。
CREATE FOREIGN TABLE test_oracle_fdw 
......
OPTIONS (schema 'HR',table 'PRODUCT' );     --创建外部表
-->

7. 相关错误参考本文注释