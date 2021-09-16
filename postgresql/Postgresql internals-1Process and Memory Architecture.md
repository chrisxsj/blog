# 1Process and Memory Architecture
# 1数据库体系结构-进程和内存结构（Process and Memory Architecture）
[TOC]
**PostgreSQL是一个client/server架构rdbms，一个服务器上运行多个进程。**
## 1、进程结构
- `Postgres Server Process（postmaster）`--pg的主进程，也是父进程，后端进程和后台工作进程都是由server process fork派生出来；同时具有监听的功能
- `Background Processes`--后台工作进程，实现数据库的功能及管理
> `logger process`--日志收集进程，将日志信息输出到日志文件
`checkpointer process`--检查点进程，执行检查点
`writer process`--后台写进程，将shared buffer中的数据写入磁盘
`wal writer process`--后台wal日志写进程，将walbuffer中的日志流写入磁盘
`autovacuum launcher process`--自动清理进程，清理版本数据，向postmaster主进程申请调用autovacuum进程.（mvcc实现方式的不同）
`archiver process`--归档进程，归档wal日志
`stats collector process`--统计信息收集进（pg_stat_database、pg_stat_activity）
`logical replication，wal sender process等其他进程`
- `backed process`--后端进程求，用来处理客户端连接请服务
>`pg postgres [local] idle`--本地登陆进程
`pg postgres 192.168.6.1(53171) idle`--远程登陆进程
`pg postgres 192.168.6.1(51846) idle intransaction`--远程登陆进程，进程中事务未完成
```
eg
[root@pg ~]# pstree -ap |grep post |grep -v grep
|-postmaster,889 -D /opt/postgres/data
| |-postmaster,906
| |-postmaster,990
| |-postmaster,991
| |-postmaster,992
| |-postmaster,993
| |-postmaster,994
| |-postmaster,995
| |-postmaster,996
| |-postmaster,1249
| |-postmaster,1301
| `-postmaster,1428`
[root@pg ~]# ps -ef |grep postgres |grep -v grep
pg 889 1 0 09:44 ? 00:00:00 /opt/postgres//bin/postmaster -D /opt/postgres/data
pg 906 889 0 09:44 ? 00:00:00 postgres: logger process
pg 990 889 0 09:44 ? 00:00:00 postgres: checkpointer process
pg 991 889 0 09:44 ? 00:00:00 postgres: writer process
pg 992 889 0 09:44 ? 00:00:00 postgres: wal writer process
pg 993 889 0 09:44 ? 00:00:00 postgres: autovacuum launcher process
pg 994 889 0 09:44 ? 00:00:00 postgres: archiver process
pg 995 889 0 09:44 ? 00:00:00 postgres: stats collector process
pg 996 889 0 09:44 ? 00:00:00 postgres: bgworker: logical replication launcher
pg 1249 889 0 09:51 ? 00:00:00 postgres: pg postgres [local] idle
pg 1301 889 0 10:18 ? 00:00:00 postgres: pg postgres 192.168.6.1(51846) idle in transaction
pg 1428 889 0 11:03 ? 00:00:00 postgres: pg postgres 192.168.6.1(53171) idle
[root@pg ~]#
以上以看出，postmaster fork出其他的进程，其中包括必可须的后台服务进程和后端进程。
注意：
由于所有进程都是由postmster进程派生出来的，不能对进程进行kill操作，否则会造成postmaster重启，也就是数据库重启
杀死后端进程需要使用函数pg_terminate_backend(apid int)
如：
postgres=# select pg_terminate_backend(1301);
pg_terminate_backend
----------------------
t
(1 row)
postgres=#

查询当前会话的PID
```sql
select pg_backend_pid();
```

## 2、内存结构

* `Local memory area`--每个后端进程自己使用，主要用于查询
> `work_mem`--用于存放排序和hash结果
`maintenance_work_mem`--管理工作使用的内存，如VACUUM
`temp_buffers`--存储临时表，创建索引
* `Shared memory area`--所有进程共同使用，启动数据库后分配的内存
> `shared buffer pool`--存放page，数据库所有操作都在此内存完成
`WAL buffer`--存放wal日志流
`commit log(buffer)`--存放事务状态
```
内存大小有参数控制
postgres=# select name,setting,source from pg_settings where name like '%work_mem%';
name | setting | source
----------------------+---------+---------
autovacuum_work_mem | -1 | default
maintenance_work_mem | 65536 | default
work_mem | 4096 | default
(3 rows)
postgres=# select name,setting,source from pg_settings where name like '%buffer%';
name | setting | source
----------------+---------+--------------------
shared_buffers | 16384 | configuration file
temp_buffers | 1024 | default
wal_buffers | 512 | override
(3 rows)
知道以上内存的作用，进行参数调优
```
## 3、数据库启动过程
+ start读取参数文件，启动数据库，
+ 首先启动Postgres Server Process（postmaster）
+ 然后分配共享内存
+ 分配内存后启动必须的后台工作进程
+ postmaster监听一个端口，等待客户端连接请求
## 4、客户端连接过程
客户端进程申请连接数据库，postmaster监听连接，通过连接认证后，fork出后台进程backend process代替客户端进程操作数据库
