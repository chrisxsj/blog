PostgreSQL数据加载工具之pg_bulkload
1. 介绍
PostgreSQL提供了一个copy命令的便利数据加载工具，copy命令源于PostgreSQL数据库，copy命令支持文件与表之间的数据加载和表对文件的数据卸载。pg_bulkload是一种用于PostgreSQL的高速数据加载工具，相比copy命令。最大的优势就是速度。优势在让我们跳过shared buffer,wal buffer。直接写文件。pg_bulkload的direct模式就是这种思路来实现的，它还包含了数据恢复功能，即导入失败的话，需要恢复。
2. pg_bulkload架构图
pg_bulkload主要包括两个模块：reader和writer。reader负责读取文件、解析tuple，writer负责把解析出的tuple写入输出源中。pg_bulkload最初的版本功能很简单，只是加载数据。3.1版本增加了数据过滤的功能。

3. pg_bulkload安装

[root@Postgres201 ~]# unzip pg_bulkload-VERSION3_1_10.zip
[root@Postgres201 ~]# cd pg_bulkload-VERSION3_1_10
[root@Postgres201 pg_bulkload-VERSION3_1_10]# make
[root@Postgres201 pg_bulkload-VERSION3_1_10]# make install
安装完成；要使用它需要建extension

[postgres@Postgres201 ~]$ psql lottu lottu
psql (9.6.0)
Type "help" for help.
lottu=# create extension pg_bulkload;
CREATE EXTENSION
4. pg_bulkload参数

[postgres@Postgres201 ~]$ pg_bulkload --help
pg_bulkload is a bulk data loading tool for PostgreSQL
Usage:
  Dataload: pg_bulkload [dataload options] control_file_path
  Recovery: pg_bulkload -r [-D DATADIR]
Dataload options:
  -i, --input=INPUT         INPUT path or function
  -O, --output=OUTPUT       OUTPUT path or table
  -l, --logfile=LOGFILE     LOGFILE path
  -P, --parse-badfile=*     PARSE_BADFILE path
  -u, --duplicate-badfile=* DUPLICATE_BADFILE path
  -o, --option="key=val"    additional option
Recovery options:
  -r, --recovery            execute recovery
  -D, --pgdata=DATADIR      database directory
Connection options:
  -d, --dbname=DBNAME       database to connect
  -h, --host=HOSTNAME       database server host or socket directory
  -p, --port=PORT           database server port
  -U, --username=USERNAME   user name to connect as
  -w, --no-password         never prompt for password
  -W, --password            force password prompt
Generic options:
  -e, --echo                echo queries
  -E, --elevel=LEVEL        set output message level
  --help                    show this help, then exit
  --version                 output version information, then exit
5. pg_bulkload的使用
创建测试表tbl_lottu和测试文件tbl_lottu_output.txt

[postgres@Postgres201 ~]$ psql lottu lottu
psql (9.6.0)
Type "help" for help.
lottu=# create table tbl_lottu(id int,name text);
CREATE TABLE
[postgres@Postgres201 ~]$  seq 100000| awk '{print $0"|lottu"}' > tbl_lottu_output.txt
	1. 
不使用控制文件使用参数



[postgres@Postgres201 ~]$ pg_bulkload -i /home/postgres/tbl_lottu_output.txt -O tbl_lottu -l /home/postgres/tbl_lottu_output.log -P /home/postgres/tbl_lottu_bad.txt  -o "TYPE=CSV" -o "DELIMITER=|" -d lottu -U lottu
NOTICE: BULK LOAD START
NOTICE: BULK LOAD END
 0 Rows skipped.
 100000 Rows successfully loaded.
 0 Rows not loaded due to parse errors.
 0 Rows not loaded due to duplicate errors.
 0 Rows replaced with new rows.
[postgres@Postgres201 ~]$ cat tbl_lottu_output.log
pg_bulkload 3.1.9 on 2018-07-12 13:37:18.326685+08
INPUT = /home/postgres/tbl_lottu_output.txt
PARSE_BADFILE = /home/postgres/tbl_lottu_bad.txt
LOGFILE = /home/postgres/tbl_lottu_output.log
LIMIT = INFINITE
PARSE_ERRORS = 0
CHECK_CONSTRAINTS = NO
TYPE = CSV
SKIP = 0
DELIMITER = |
QUOTE = "\""
ESCAPE = "\""
NULL =
OUTPUT = lottu.tbl_lottu
MULTI_PROCESS = NO
VERBOSE = NO
WRITER = DIRECT
DUPLICATE_BADFILE = /data/postgres/data/pg_bulkload/20180712133718_lottu_lottu_tbl_lottu.dup.csv
DUPLICATE_ERRORS = 0
ON_DUPLICATE_KEEP = NEW
TRUNCATE = NO
  0 Rows skipped.
  100000 Rows successfully loaded.
  0 Rows not loaded due to parse errors.
  0 Rows not loaded due to duplicate errors.
  0 Rows replaced with new rows.
Run began on 2018-07-12 13:37:18.326685+08
Run ended on 2018-07-12 13:37:18.594494+08
CPU 0.14s/0.07u sec elapsed 0.27 sec
2. 导入之前先清理表数据

[postgres@Postgres201 ~]$ pg_bulkload -i /home/postgres/tbl_lottu_output.txt -O tbl_lottu -l /home/postgres/tbl_lottu_output.log -P /home/postgres/tbl_lottu_bad.txt  -o "TYPE=CSV" -o "DELIMITER=|" -o "TRUNCATE=YES" -d lottu -U lottu
NOTICE: BULK LOAD START
NOTICE: BULK LOAD END
 0 Rows skipped.
 100000 Rows successfully loaded.
 0 Rows not loaded due to parse errors.
 0 Rows not loaded due to duplicate errors.
 0 Rows replaced with new rows.
 
[postgres@Postgres201 ~]$ psql lottu lottu -c "select count(1) from tbl_lottu;"
 count 
--------
 100000
(1 row)
3. 使用控制文件
新建控制文件lottu.ctl

INPUT = /home/postgres/lotu01
PARSE_BADFILE = /home/postgres/tbl_lottu_bad.txt
LOGFILE = /home/postgres/tbl_lottu_output.log
LIMIT = INFINITE
PARSE_ERRORS = 0
CHECK_CONSTRAINTS = NO
TYPE = CSV
SKIP = 5
DELIMITER = |
QUOTE = "\""
ESCAPE = "\""
OUTPUT = lottu.tbl_lottu
MULTI_PROCESS = NO
WRITER = DIRECT
DUPLICATE_BADFILE = /home/postgres/tbl_lottu.dup.csv
DUPLICATE_ERRORS = 0
ON_DUPLICATE_KEEP = NEW
TRUNCATE = YES
使用控制文件进行加载操作

pg_bulkload  /home/postgres/lottu.ctl -d lottu -U lottu
[postgres@Postgres201 ~]$ pg_bulkload  /home/postgres/lottu.ctl -d lottu -U lottu
NOTICE: BULK LOAD START
NOTICE: BULK LOAD END
 5 Rows skipped.
 95 Rows successfully loaded.
 0 Rows not loaded due to parse errors.
 0 Rows not loaded due to duplicate errors.
 0 Rows replaced with new rows.
6. 总结
pg_bulkload是一种用于PostgreSQL的高速数据加载工具，相比copy命令。最大的优势就是速度。优势在让我们跳过shared buffer,wal buffer。直接写文件。pg_bulkload的direct模式就是这种思路来实现的。不足的是;表字段的顺序要跟导入的文件报错一致。希望后续版本能开发。
 
来自 <https://www.cnblogs.com/lottu/p/9319016.html>