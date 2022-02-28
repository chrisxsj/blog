# upgrading

**作者**

chrisx

**日期**

2021-05-27

**内容**

数据库升级

ref [Upgrading a PostgreSQL Cluster](https://www.postgresql.org/docs/13/upgrading.html)

----

[toc]

## 升级概述

当前PostgreSQL版本号由主要版本号和次要版本号组成。 例如，在版本号10.1中，10是主要版本号，1是次要版本号，这意味着这将是主版本10的第一个次要版本。 对于PostgreSQL版本10.0之前的版本，版本号由三个数字组成，例如9.5.3。 在这些情况下，主要版本由版本号的前两个数字组（例如9.5）组成，次要版本是第三个数字， 例如3，这意味着这将是主要版本9.5的第三次要版本。

次要发行从来不改变内部存储格式并且总是向前并向后兼容同一主版本号中的次要发行。 例如版本10.1与版本10.0和版本10.6兼容。类似的，例如9.5.3与9.5.0、9.5.1和9.5.6兼容。 要在兼容的版本间升级，你只需要简单地在服务器关闭时替换可执行文件并重启服务器。 数据目录则保持不变 — 次要升级就这么简单。

对于PostgreSQL的主发行， 内部数据存储格式常被改变，这使升级复杂化。传统的把数据移动到 新主版本的方法是先转储然后重新载入到数据库，不过这可能会很慢。 一种更快的方式是pg_upgrade。如下文所讨论的， 复制方法也能被用于升级。
主版本通常会引入一些不兼容的更改，依次主版本升级前，应用程序需要进行测试。因此，建立一个新旧版本的并存安装通常是一个好主意。

升级建议

**主板本不再受支持情况下建议升级主板本**
**始终建议您使用可用的最新次要版本**

虽然升级总是会包含一定程度的风险，但PostgreSQL次要版本只修复了经常遇到的bug、安全问题和数据损坏问题，以降低与升级相关的风险。对于小版本，社区认为不升级比升级风险更大。

## 次要版本升级

次要版本升级。次要版本通常不需要转储和恢复，安装更新的二进制文件，然后重新启动数据库。

1. 安装新版本软件（软件目录位于新的位置，与其旧的软件目录区别开）
2. 停止数据库
3. 修改环境变量，（环境变量指向新版本软件目录）
4. 启动数据库，使用新版本软件加载原来的data
5. 数据验证

:warning: 升级前做好备份
:warning: 非内核扩展插件需要重新安装。

<!--

编译安装插件，扩展无需删除

postgres=# \dx
                                        List of installed extensions
        Name        | Version |   Schema   |                           Description
--------------------+---------+------------+-----------------------------------------------------------------
 pg_bulkload        | 1.0     | public     | pg_bulkload is a high speed data loading utility for PostgreSQL
 pg_hint_plan       | 1.3.7   | hint_plan  |
 pg_stat_statements | 1.7     | public     | track execution statistics of all SQL statements executed
 plpgsql            | 1.0     | pg_catalog | PL/pgSQL procedural language
(4 rows)

[postgres@db ~]$ pg_ctl start
waiting for server to start....2022-02-28 10:39:50.848 CST [12668] FATAL:  could not access file "pg_hint_plan": No such file or directory
2022-02-28 10:39:50.848 CST [12668] LOG:  database system is shut down
 stopped waiting
pg_ctl: could not start server
Examine the log output.
[postgres@db ~]$ ls

[postgres@db pg_hint_plan-PG12]$ make install
/bin/mkdir -p '/opt/pg129/share/postgresql/extension'
/bin/mkdir -p '/opt/pg129/share/postgresql/extension'
/bin/mkdir -p '/opt/pg129/lib/postgresql'
/bin/install -c -m 644 .//pg_hint_plan.control '/opt/pg129/share/postgresql/extension/'
/bin/install -c -m 644 .//pg_hint_plan--*.sql  '/opt/pg129/share/postgresql/extension/'
/bin/install -c -m 755  pg_hint_plan.so '/opt/pg129/lib/postgresql/'
[postgres@db pg_hint_plan-PG12]$

pg_ctl start
-->

## 主版本升级

### pg_dumpall升级

使用转储数据的方式升级，使用pg_dump或者pg_dumpall工具。建议使用较新版本的工具。

1. 备份

```
pg_dumpall -p 5434 -v -f /tmp/pg126_data

```

2. 安装新版本

* 初始化data
* 恢复pg_hba.conf和postgresql.conf、postgresql.auto.conf修改（可从旧版本数据库拷贝）
* 启动数据库

:warning: 建议新旧版本并行运行，如需要将新版本安装在旧版本位置，需要停止旧数据库，并重命名或删除旧的安装目录

3. 恢复数据

```sh
psql -d postgres -p 5435 -f /tmp/pg126_data

```

:warning: 插件需要重新安装，建议提前安装好插件。
:warning: 新旧版本并行运行时，为达到最低的停机时间。可以这样用

```sh
pg_dumpall -v -p 5434 | psql -v -d postgres -p 5435

```

### pg_upgrade升级

pg_upgrade模块允许一个安装从一个 PostgreSQL主版本“就地”升级成另一个主版本。 升级可以在数分钟内被执行，特别是使用--link模式时

ref [pg_upgrade](./pg_upgrade.md)

### Replication升级

逻辑复制支持在不同主版本的PostgreSQL之间的复制。后备服务器可以在同一台计算机或者不同的计算机上。一旦它和主服务器（运行旧版本的PostgreSQL）同步好，你可以切换主机并且将后备服务器作为主机，然后关闭旧的数据库实例。这样一种切换使得一次升级的停机时间只有数秒。

ref [logical_replication](./logical_replication.md)