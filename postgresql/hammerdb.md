# HammerDB

---

### 作者
chris
### 日期
2020-01-15
### 标签
HammerDB

---

# Installation Guide

## 1. intrueduction
HammerDB is the leading benchmarking and load testing software for the worlds most popular databases supporting Oracle Database, SQL Server, IBM Db2, MySQL, MariaDB, PostgreSQL and Redis.

## 2.Test Matrix
OS Test Matrix

Operating System | Release
---------------- | -------------
Linux | Ubuntu 17.X 18.X / RHEL 7.X RHEL 8.X
Windows | Windows 10

**On Linux HammerDB requires the Xft FreeType-based font drawing library for X installed as follows:**
```
// An highlighted block
Ubuntu:
$ sudo apt-get install libxft-dev
Red Hat:
$ yum install libXft
```
Database Test Matrix

Database (Compatible)|Release
---------------------|-------
Oracle (TimesTen)|12c / 18c / 19c
SQL Server|2017
Db2|11.1
MySQL(MariaDB) (Amazon Aurora)|5.7 / 8.0 / 10.2 / 10.3 / 10.4
PostgreSQL (EnterpriseDB) (Amazon Redshift) (Greenplum)|10.2 / 10.3 /11 / 12
Redis|4.0.6 / 5.0.5

# Installing and Starting HammerDB on Linux

## 5.1. Self Extracting Installer
To install from the self-extracting installer using a graphical environment
```
#./HammerDB-3.3-Linux-x86-64-Install 
This will install HammerDB on your computer. Continue? [n/Y] Y
Where do you want to install HammerDB? [/usr/local/HammerDB-3.3] 
Installing HammerDB...
Installing Program Files...                                                   
Installation complete.
```
## 5.2. Tar.gz File
To install from the tar.gz run the command
```
tar -zxvf HammerDB-3.0.tar.gz 
```
Starting HammerDB

To start HammerDB change to the HammerDB directory and run locally as follows.
```
./hammerdb
```
## 5.4. Uninstalling HammerDB

To uninstall HammerDB on Linux run the uninstall executable for the self-extracting installer or remove the directory for the tar.gz install.

## 6. Verifying Client Libraries
For all of the databases that HammerDB supports it is necessary to have a 3rd party client library installed that HammerDB can use to connect and interact with the database.

To run this utility run the following command
```
./hammerdbcli
and type librarycheck.
HammerDB CLI v3.0
Copyright (C) 2003-2018 Steve Shaw
Type "help" for a list of commands
The xml is well-formed, applying configuration
hammerdb>librarycheck
Checking database library for Oracle
Error: failed to load Oratcl - can't read "env(ORACLE_HOME)": no such variable
Ensure that Oracle client libraries are installed and the location in the LD_LIBRARY_PATH environment variable
Checking database library for MSSQLServer
Success ... loaded library tclodbc for MSSQLServer
Checking database library for Db2
Success ... loaded library db2tcl for Db2
Checking database library for MySQL
Success ... loaded library mysqltcl for MySQL
Checking database library for PostgreSQL
Success ... loaded library Pgtcl for PostgreSQL
Checking database library for Redis
Success ... loaded library redis for Redis
hammerdb
in the example it can be seen that the environment is not set for Oracle however all of the other libraries were found and correctly loaded. 
```

# eg

## Installation and Configuration
### 需要安装pg，并配置网络访问控制。如：
```
listen_addresses = "*"
pg_hba.conf
```
### 安装hammerdb

### Configuring Schema Build Options
1. Benchmark Options

选择要基于 TPC-C 规范创建 OLTP 测试架构，需要通过在"option"菜单（或benchmark树状视图）中来选择要使用的基准测试和数据库。
```
option>benchmarksql>postgresql and tpcc
```
2. Schema Build Options

配置tpcc模式
```
benchmark tree-view>schema build>option

Number of Warehouses：仓库的数量
Virtual Users to Build Schema：用于生成仓库的虚拟用户数量。可设置多个虚拟用户并发创建仓库，虚拟用户数不能低于仓库数量。
```
### Creating the Schema

```
benchmark tree-view>schema build>build

When the schema build is complete Virtual User 1 will display the message SCHEMA COMPLETE and all virtual users will show that they completed their action successfully.
```
1. Deleting or Verifying the PostgreSQL Schema

if you have made a mistake simply close the application and run the following SQL to undo the user you have created.
```
postgres=# drop database tpcc;
postgres=# drop role tpcc;
```
You can browse the created schema, for example:
```

[postgres@db ~]$ psql -d tpcc -U tpcc
psql (12.1)
Type "help" for help.

tpcc=> select relname, n_tup_ins - n_tup_del as rowcount from pg_stat_user_tables;
  relname   | rowcount 
------------+----------
 new_order  |    17900
 orders     |    60000
 order_line |   599599
 item       |   100000
 district   |       20
 customer   |    60000
 history    |    60000
 stock      |   200000
 warehouse  |        2
(9 rows)

```
### Configuring Driver Script options

```
benchmark tree-view>driver script>option

This displays the Driver Script Options dialog. The connection options are common to the Schema Build Dialog in addition to new Driver Options.
```
+ TPC-C Driver Script:Test Driver Script仅用于用于验证和测试配置。执行测试时应选择Timed Driver Script
+ Total Transactions per User：应确保事务数设置为适当的高值，以确保虚拟用户在计时测试完成之前未完成测试，这样做将意味着您将为空闲虚拟用户计时，并且结果将无效。
+ Exit on Error	:设置为 TRUE，用户将报告错误到 HammerDB 控制台，然后终止执行。如果设置为 FALSE，虚拟用户将忽略错误并继续执行下一个事务。
+ Keying and Thinking Time:设置为 TRUE，则每个用户都将模拟此实际用户类型工作负载，测试将更接近实际生产环境的工作负载方案。设置为 TRUE 时，每个用户每分钟可能执行 2 或 3 个事务，设置为 FALSE，现在每个用户每分钟将执行数万个事务。默认模式是在设置为 FALSE 时运行，这是驱动最高事务速率的方法。
+ Minutes of Rampup Time:在数据库中提前缓存数据的时间

### Loading the Driver Script
选择驱动程序脚本选项后，将加载驱动程序脚本。配置的选项可以在"驱动程序脚本"窗口中看到，也可以直接修改。
```
benchmark tree-view>driver script>load  
```


![Fig. 6.1. Loading the Driver Script.](imgs/ch4-16.png)

### Configure Virtual Users

```
benchmark tree-view>virtual user>option
```
+ Virtual Users:要创建的虚拟用户数。请注意，在运行时点工作负载 HammerDB 将自动创建一个额外的虚拟用户来监视工作负载。
+ Iterations:是驱动程序脚本完整运行的次数。
+ Show Output:显示输出,将报告虚拟用户输出到虚拟用户输出窗口，对于 TPC-C 测试应启用此功能。
+ Log Output to Temp:启用后，此将所有虚拟用户输出追加到名为 hammerdb.log 的可用临时目录中的文本文件。

### Create and Run Virtual Users
双击树视图中的"创建"。虚拟用户将创建并处于空闲状态，准备在脚本编辑器窗口中运行驱动程序脚本。
```
benchmark tree-view>virtual user>create
```
双击"运行"，虚拟用户将登录到目标数据库并开始运行其工作负荷。
```
benchmark tree-view>virtual user>run
```

> Reference

+ https://www.hammerdb.com/document.html
+ https://www.hammerdb.com/blog/uncategorized/hammerdb-best-practice-for-postgresql-performance-and-scalability/