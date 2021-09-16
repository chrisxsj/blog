
timescaledb

Hgdb561自带功能，无需单独安装
 
https://github.com/digoal/blog/blob/master/201704/20170409_05.md#timescaledb%E6%9E%B6%E6%9E%84
https://yq.aliyun.com/articles/424710
 
安装略
 
1、配置postgresql.conf，在数据库启动时自动加载timescale lib库
 
alter system set shared_preload_libraries = pg_pathman,timescaledb;
pg_ctl restart -m fast
2、对需要使用timescaledb的数据库，创建插件.
create extension timescaledb;
 
highgo=# create extension timescaledb;
2019-05-05 12:00:35.079 CST [4445] 警告: 
WELCOME TO
 _____ _                               _     ____________ 
|_   _(_)                             | |    |  _  \ ___ \
  | |  _ _ __ ___   ___  ___  ___ __ _| | ___| | | | |_/ /
  | | | |  _ ` _ \ / _ \/ __|/ __/ _` | |/ _ \ | | | ___ \
  | | | | | | | | |  __/\__ \ (_| (_| | |  __/ |/ /| |_/ /
  |_| |_|_| |_| |_|\___||___/\___\__,_|_|\___|___/ \____/
               Running version 1.2.2
For more information on TimescaleDB, please visit the following links:
 
 1. Getting started: https://docs.timescale.com/getting-started
 2. API reference documentation: https://docs.timescale.com/api
 3. How TimescaleDB is designed: https://docs.timescale.com/introduction/architecture
 
Note: TimescaleDB collects anonymous reports to better understand and assist our users.
For more information and how to disable, please see our docs https://docs.timescaledb.com/using-timescaledb/telemetry.
 
2019-05-05 12:00:35.079 CST [4445] 上下文:  在RAISE的第15行的PL/pgSQL函数inline_code_block
警告: 
WELCOME TO
 _____ _                               _     ____________ 
|_   _(_)                             | |    |  _  \ ___ \
  | |  _ _ __ ___   ___  ___  ___ __ _| | ___| | | | |_/ /
  | | | |  _ ` _ \ / _ \/ __|/ __/ _` | |/ _ \ | | | ___ \
  | | | | | | | | |  __/\__ \ (_| (_| | |  __/ |/ /| |_/ /
  |_| |_|_| |_| |_|\___||___/\___\__,_|_|\___|___/ \____/
               Running version 1.2.2
For more information on TimescaleDB, please visit the following links:
 
 1. Getting started: https://docs.timescale.com/getting-started
 2. API reference documentation: https://docs.timescale.com/api
 3. How TimescaleDB is designed: https://docs.timescale.com/introduction/architecture
 
Note: TimescaleDB collects anonymous reports to better understand and assist our users.
For more information and how to disable, please see our docs https://docs.timescaledb.com/using-timescaledb/telemetry.
 
CREATE EXTENSION
highgo=#
highgo=# \dx
                                        List of installed extensions
    Name     | Version |     Schema     |                            Description                           
-------------+---------+----------------+-------------------------------------------------------------------
 oraftops    | 1.0     | oracle_catalog | Functions that are compatible with the Oracle
 pg_bulkload | 1.0     | public         | pg_bulkload is a high speed data loading utility for PostgreSQL
 pg_pathman  | 1.5     | public         | Partitioning tool for PostgreSQL
 plpgsql     | 1.0     | pg_catalog     | PL/pgSQL procedural language
 timescaledb | 1.2.2   | public         | Enables scalable inserts and complex queries for time-series data
(5 rows)
 
 
3、相关参数
highgo=# show timescaledb.constraint_aware_append ;
 timescaledb.constraint_aware_append
-------------------------------------
 on
(1 row)
 
highgo=# show timescaledb.disable_optimizations ;
 timescaledb.disable_optimizations
-----------------------------------
 off
(1 row)
 
highgo=# show timescaledb.optimize_non_hypertables ;
 timescaledb.optimize_non_hypertables
--------------------------------------
 off
(1 row)
 
highgo=# show timescaledb.restoring ;
 timescaledb.restoring
-----------------------
 off
(1 row)
 
highgo=#
 
 
数据来源及说明
https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page
 