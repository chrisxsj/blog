# pg_bulkload

**作者**

Chrisx

**日期**

2021-10-25

**内容**

pg高速数据加载工具pg_bulkload

ref [pg_bulkload](https://github.com/ossc-db/pg_bulkload)
ref [pg_bulkload 3.1](http://ossc-db.github.io/pg_bulkload/pg_bulkload.html#restrictions)

----

[toc]

## 介绍

IMPORTANT NOTE: Under streaming replication environment, pg_bulkload does not work properly. See [here](http://ossc-db.github.io/pg_bulkload/pg_bulkload.html#restrictions) for details.

pg_bulkload对比copy，更快速一些. ref [Performance Results](http://ossc-db.github.io/pg_bulkload/index.html)
Pg_bulkload(PARALLEL) >Pg_bulkload(directory)~copy without indexes > copy with indexes

pg_bulkload的最初目标是在PostgreSQL中更快地替代COPY命令，但3.0版或更高版本具有一些ETL功能，如输入数据验证和带有过滤函数的数据转换。

<!--
最大的优势就是速度。优势在让我们跳过shared buffer,wal buffer。直接写文件。
-->

## 使用方式

pg_bulkload支持服务器和客户端使用

1. 使用选项

pg_bulkload Load Options

WRITER选项

WRITER | LOADER = DIRECT | BUFFERED | BINARY | PARALLEL
The method to load data. The default is DIRECT.
DIRECT : Load data directly to table. Bypass the shared buffers and skip WAL logging, but need the own recovery procedure. This is the default, and original older version's mode.
BUFFERED : Load data to table via shared buffers. Use shared buffers, write WALs, and use the original PostgreSQL WAL recovery.
BINARY : Convert data into the binary file which can be used as an input file to load from. Create a sample of the control file necessary to load the output binary file. This sample file is created in the same directory as the binary file, and its name is <binary-file-name>.ctl.
PARALLEL : Same as "WRITER=DIRECT" and "MULTI_PROCESS=YES". If PARALLEL is specified, MULTI_PROCESS is ignored. If password authentication is configured to the database to load, you have to set up the password file. See Restrictions for details.

其他选项参考[pg_bulkload](http://ossc-db.github.io/pg_bulkload/pg_bulkload.html)

2. 使用控制文件

pg_bulkload sample_csv.ctl

load选项可以写到控制文件中。参考[pg_bulkload](http://ossc-db.github.io/pg_bulkload/pg_bulkload.html)

## 直接加载模式注意事项

* PostgreSQL startup sequence
当pg_bulkload崩溃并且一些.loadstatus文件仍保留在$PGDATA/pg_bulkload中时，在调用pg_ctl start之前，必须通过pg_bulkload自身恢复和“pg_bulkload-r”命令来恢复数据库。必须使用PostgreSQL脚本启动和停止PostgreSQL，该脚本正确调用“pg_bulkload-r”和“pg_ctl start”。我们建议不要直接使用pg_ctl。如果在Windows操作系统中使用pg_bulkload，则pg_bulkload包中不包含postgresql脚本。因此，您必须手动调用“pg_bulkload-r”。

* PITR/Replication
由于绕过WAL，无法使用PITR进行归档恢复。如果您想使用PITR，请在加载后通过pg_bulkload对数据库进行完整备份。如果您使用的是流式复制，则需要根据加载pg_后获取的备份集重新创建备份。

* 以$PGDATA/pgu bulkload格式加载状态文件
不能删除$PGDATA/pg_bulkload目录中的加载状态文件（*.loadstatus）。pg_批量加载崩溃恢复需要此文件。

* 不要使用kill-9
尽可能不要使用“kill-9”终止pg_bulkload命令。如果您这样做了，您必须调用postgresql脚本来执行pg_批量加载恢复，并重新启动postgresql以继续。

* Authentication can fail when MULTI_PROCESS=YES
解决方式
使用trust认证方式
or
使用密码文件
or
Don't use "WRITER=PARALLE"

* 数据库约束
默认情况下，在数据加载期间仅强制执行唯一约束和非空约束。您可以通过设置“CHECK_CONSTRAINTS=YES”来检查约束。无法检查外键约束。用户有责任提供有效的数据集。

## pg_bulkload内部结构

![pg_bulkload](http://ossc-db.github.io/pg_bulkload/img/internal.png)

## pg_bulkload安装

* 与标准contrib模块安装相同。
* 需要安装pg软件及initdb数据库
* 可使用源码安装或rpm包安装

以源码安装为例

[There are some requirement libraries. Please install them before build pg_bulkload](http://ossc-db.github.io/pg_bulkload/pg_bulkload.html#restrictions)

```sh
rpm -q postgresqlxx-devel pam-devel make gcc gzip readline readline-devel zlib zlib-devel

yum install postgresqlxx-devel pam-devel make gcc gzip readline readline-devel zlib zlib-devel openssl openssl-devel

tar -zxvf pg_bulkload-3.1.19.tar.gz
cd pg_bulkload-3.1.19/
make
make install 

```

<!--
/bin/install -c -m 755  pg_bulkload.so '/opt/pg126/lib/postgresql/pg_bulkload.so'
/bin/install -c -m 644 .//pg_bulkload.control '/opt/pg126/share/postgresql/extension/'
...
/bin/mkdir -p '/opt/pg126/lib/postgresql'
/bin/mkdir -p '/opt/pg126/share/postgresql/contrib'
/bin/install -c -m 755  pg_timestamp.so '/opt/pg126/lib/postgresql/pg_timestamp.so'
/bin/install -c -m 644 .//uninstall_pg_timestamp.sql pg_timestamp.sql '/opt/pg126/share/postgresql/contrib/'
make[1]: Leaving directory `/opt/software/pg_bulkload-3.1.19/util'

-->

安装完成；要使用它需要建extension

```sql
postgres=# create extension pg_bulkload;
CREATE EXTENSION

```

## pg_bulkload的使用

使用参数

```sh
1.准备文件，上传至/home/user/temp 目录，创建文件 test.csv 文件，
内容如下
1,a,2020-09-16 17:34:59.160127
2,b,2020-09-16 17:35:04.361309
3,c,2020-09-16 17:35:09.193185
4,d,2020-09-16 17:35:13.632514
5,e,2020-09-16 17:35:20.816410
6,f,2020-09-16 17:35:32.768525

2.以管理员身份登录，连接测试数据库
3.数据库中创建对应表结构：
CREATE TABLE test_bulkload(id int, info varchar(32), crt_time timestamp);
4.执行命令导入数据：

pg_bulkload -d 库名 -U 用户名 -i /home/user/temp/test.csv - O TEST_BULKLOAD -l /home/user/temp/test_bulkload1.log -o "TYPE=CSV" -o "DELIMITER=," -o "WRITER=BUFFERED"

[postgres@db ~]$ pg_bulkload -d postgres -U postgres -i /home/postgres/temp/test.csv -O test_bulkload -l /home/postgres/temp/test_bulkload1.log -o "TYPE=CSV" -o "DELIMITER=," -o "WRITER=BUFFERED"
NOTICE: BULK LOAD START
NOTICE: BULK LOAD END
        0 Rows skipped.
        6 Rows successfully loaded.
        0 Rows not loaded due to parse errors.
        0 Rows not loaded due to duplicate errors.
        0 Rows replaced with new rows.
[postgres@db ~]$

5.在客户端准备文件，并执行导入命令
pg_bulkload -hIP 地址 -d 库名 -U 用户名 -i/home/user/temp/test.csv -O TEST_BULKLOAD -l /home/user/temp/test_bulkload2.log -o "TYPE=CSV" -o "DELIMITER=," -o "WRITER=BUFFERED"

[postgres@db2 ~]$ pg_bulkload -h 192.168.80.151 -d postgres -U postgres -i /home/postgres/temp/test.csv -O test_bulkload -l /home/postgres/temp/test_bulkload1.log -o "TYPE=CSV" -o "DELIMITER=," -o "WRITER=BUFFERED"
Password:
NOTICE: BULK LOAD START
NOTICE: BULK LOAD END
        0 Rows skipped.
        6 Rows successfully loaded.
        0 Rows not loaded due to parse errors.
        0 Rows not loaded due to duplicate errors.
        0 Rows replaced with new rows.
[postgres@db2 ~]$


6.查看导入的数据：
SELECT * FROM test_bulkload;

```

使用控制文件

```sh
[postgres@db2 temp]$ pg_bulkload  /home/postgres/temp/test.ctl -h 192.168.80.151 -d postgres -U postgres
Password:
NOTICE: BULK LOAD START
NOTICE: BULK LOAD END
        0 Rows skipped.
        6 Rows successfully loaded.
        0 Rows not loaded due to parse errors.
        0 Rows not loaded due to duplicate errors.
        0 Rows replaced with new rows.
[postgres@db2 temp]$


cat test.ctl

INPUT = /home/postgres/temp/test.csv
PARSE_BADFILE =/home/postgres/temp/test_bad.txt
LOGFILE = /home/postgres/temp/test_bulkload1.log
LIMIT = INFINITE
PARSE_ERRORS = 0
CHECK_CONSTRAINTS = NO
TYPE = CSV
DELIMITER = ,
OUTPUT = public.test_bulkload
MULTI_PROCESS = NO
WRITER = DIRECT
DUPLICATE_BADFILE = /home/postgres/temp/test_dup.txt
DUPLICATE_ERRORS = 0
ON_DUPLICATE_KEEP = NEW

```
