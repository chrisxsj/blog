# oracle_fdw

**作者**

Chrisx

**日期**

2021-12-14

**内容**

oracle_fdw是PostgreSQL扩展，它提供了一个第三方外部数据包装器，方便和高效地访问存储在外部数据库oracle中的数据

----

[toc]

## 安装配置oracle客户端

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

## 安装oracle_fdw

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

1. 解压

2. 安装

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

## 配置

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

## 管理

查询外部表

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

修改外部表

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