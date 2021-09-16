# hg_job

**作者**

chrisx

**日期**

2021-03-11

**内容**

HGDB hg_job功能，定时任务功能可以减轻数据库操作人员的手工重复工作，提高工作的效率，对于数据定时处理工作带来了极大的便利。

----

[toc]

参考**管理手册**

## hg_job配置(功能逻辑)

### 参数

cat $PGDATA/postgresql.conf

```bash
shared_preload_libraries #后台进程hg_job_scheduler需要预先加载库文件
#------------------------------------------------------------------------------
# HGDB JOB
#------------------------------------------------------------------------------

hg.job_database = 'highgo' #后台进程（hg_job_scheduler）要连接的数据库，默认highgo
hg.job_queue_processes = 0 #作业进程并发数，默认为0，0表示不启动。需要配置大于0
hg.job_queue_interval = 3 #后台工作进程 hg_job_scheduler 扫描 job 的频率,单位为秒，
#取值范围为 1..3600，默认为 3 秒，建议与时间间隔成倍数关系。
hg.job_log_path = 'hg_job' #日志保存路径，默认路径为：$PGDATA/hg_job/，需要先在$PGDATA 目录下创建 hg_job 目录。

```

启用

```sql
alter system set shared_preload_libraries='hg_job'; --默认已经添加

alter system set hg.job_database = 'highgo';
alter system set hg.job_queue_processes = 4;
alter system set hg.job_queue_interval = 9;
alter system set hg.job_log_path = 'hg_job';

```

> 注意默认有hg_job扩展（\dx）

### 监控进程

1. 后台工作进程
配置参数 hg.job_queue_processes=0，默认不启用定时任务功能，也就没有后台工作者进程。hg.job_queue_processes>0 就会启用定时任务。后台会产生hg_job_scheduler工作进程。

```shell
[hgdb565@db data]$ ps -ef |grep hg_job
hgdb565   2406  2394  0 15:35 ?        00:00:00 postgres: bgworker: hg_job_scheduler

```

2. 作业队列进程
后台工作进程轮询 job 创建作业队列进程，执行 job，执行完释放作业队列进程。定时任务支持并发，作业队列进程以 libpq 方式创建连接，hg.job_queue_processes 应设置合理的取值范围（0..max_connectios/2）。

### hg_job元数据表

为了实现对 HighGo Database 定时任务更好的管理，HG_JOB 定义两张元数据表，记录任务内容，运行情况等信息。

:warning: 注意 hg_job 元数据所在的模式必须是hg_job 定时任务管理的数据库上，否则定时任务管理不能正常进行。

```sql
highgo=# \d hgjob.job; --Hgjob.job 元数据表是记录定时任务属性的表
highgo=# \d hgjob.jobrunning; --hgjob.jobrunning 元数据表是记录正在执行的定时任务的表
```

## HG_JOB启用

有两种方式启用定时任务功能：

1. 配置文件中，修改参数 hg.job_queue_processes>0，重启数据库，自动启动后台工作进程，并创建 hg_job 扩展，启用定时任务。

2. 使用 ALTER SYSTEM 命令，修改 hg.job_queue_processes>0，重新 reload 或重启数据库，手动创建 hg_job 扩展，调用 job_launch()函数启动后台工作进程，启用定时任务。

## HG_JOB 操作函数

hg_job 中对定时任务的管理都是通过函数来实现，包括创建，修改等操作。这些函数也都是在 hg_job 模式下。

```sql
highgo=# select p.proname,n.nspname from pg_proc p,pg_namespace n where proname like 'job_%' and p.pronamespace=n.oid;
   proname    | nspname
--------------+---------
 job_change   | hgjob    --更改用户设定的任务参数
 job_create   | hgjob    --提交一个新任务，系统指定一个任务号
 job_delete   | hgjob    --从队列中删除一个已存在的任务
 job_interval | hgjob    --更改任务运行的时间间隔
 job_launch   | hgjob    --启动后台工作者进程
 job_nextrun  | hgjob    --更改任务下一次运行时间
 job_run      | hgjob    --立即执行任务
 job_start    | hgjob    --将停止的 job 重新启用
 job_stop     | hgjob    --将任务停止，不让其重复运行
 job_what     | hgjob    --更改 PSQL 任务定义
(10 rows)

```

### 创建定时任务（job_create）

1. 间隔时间若不定义，即为空，则本次 job 仅执行一次然后停止。 
2. job 执行前，通过间隔时间预先计算下一次执行时间，再用计算结果代替下次执行时间的值，然后去执行 job。 
3. job 创建时应检查创建语句是否有效，若无效（表不存在、语法错误、job 运行时间为错误时间等）则不插入数据（即创建失败），并根据相应的错误内容进行输出提示。 
4. 创建定时任务时可指定 job 的运行开始时间，若不指定则默认当前时间立即执行。 

```sql
create table test_t (info varchar,time timestamp);


highgo=# select hgjob.job_create($$insert into public.test_t (info, time) values ('jobid:1',now());$$, $$now() + interval '5 m'$$, now());
     job_create
--------------------
 Job create success
(1 row)

```

### 修改定时任务（job_change）

```sql
select hgjob.job_change(1, $$insert into public.test_t (info, time) values ('1111',now());$$,$$now() + interval '1 m'$$ );

```

### 停止定时任务（job_stop）

```sql
select hgjob.job_stop(1);

```

### 启动定时任务（job_start）

```sql
select hgjob.job_start(3, '2018-05-30 00:00:00'); --指定任务 id、下次执行时间，启动任务

```

### 删除定时任务（job_delete）

## HG_JOB 任务监控

```sql
select jobid,jobenabled,jobnextrun,jobstartrun,jobuser,jobcount from hgjob.job;
select * from hgjob.jobrunning;

select hgjob.job_stop(1);
```


