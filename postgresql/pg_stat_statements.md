# pg_stat_statements

**作者**

Chrisx

**日期**

2021-07-30

**内容**

pg_stat_statements扩展插件使用

---

[toc]

## 介绍

PostgreSQL提供了pg_stat_statements来存储SQL的运行次数，总运行时间，shared_buffer命中次数，shared_buffer read次数等统计信息。常用于监控pg的sql性能。

### 创建插件

``` sql
create extension pg_stat_statements;
alter system set shared_preload_libraries='pg_stat_statements';
#alter system set pg_stat_statements.track='all';
```

### 插件配置

参考[pgstatstatements](https://www.postgresql.org/docs/current/pgstatstatements.html)

``` bash
# postgresql.conf
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.max = 10000
pg_stat_statements.track = top

```

在postgresql.conf中定义参数
shared_preload_libraries='pg_stat_statements'   --需要重启
Pg_stat_statements.max =10000   --记录最大sql数，默认5000
Pg_stat_statements.track=all    --设置那类sql被记录，top指只记录外层sql，all包含函数中涉及的sql
Pg_stat_statements.track_utility    --设置是否记录select，update，delete，insert以外的sql。默认为on
Pg_stat_statements.save --设置当数据库关闭时是否将sql信息记录到文件。默认为on

### 插件使用

查询执行最慢的10条SQL

``` sql
SELECT  query, calls, total_time, (total_time/calls) as average ,rows, 
        100.0 * shared_blks_hit /nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent 
FROM    pg_stat_statements 
ORDER   BY average DESC LIMIT 10;

```

平均执行时间最长的3条语句

``` sql
select call,total_time/calls as avg_time,left(query,80) from pg_stat_statements order by 2 desc limit 3;

```

监控调用次数排名前两位

```sql
select userid,dbid,queryid,query,calls,total_time,min_time,max_time,mean_time,rows from pg_stat_statements  order by calls desc limit 2;
```

监控慢sql

```sql
select userid,dbid,queryid,query,calls,total_time,min_time,max_time,mean_time,rows from pg_stat_statements  order by mean_time desc limit 2;
```

统计结果一直都在，重启也不会清零，那么统计结果如何清零重新统计呢？执行下面SQL即可

``` sql
select pg_stat_statements_reset() ;

```

<!--
常用sql参考
查询读取Buffer次数最多的SQL，这些SQL可能由于所查询的数据没有索引，而导致了过多的Buffer读，也同时大量消耗了CPU。

select * from pg_stat_statements order by shared_blks_hit+shared_blks_read desc limit 5;

查询最耗IO SQL语句，单次调用最耗IO SQL TOP 5：
select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time)/calls desc limit 5;  
查询总最耗IO SQL TOP 5
select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time) desc limit 5;  
查询最耗时 SQL，单次调用最耗时 SQL TOP 5
select userid::regrole, dbid, mean_time ,query from pg_stat_statements order by mean_time desc limit 5; 
查询总最耗时 SQL TOP 5
select userid::regrole, dbid, total_time, query from pg_stat_statements order by total_time desc limit 5;
查询响应时间抖动最严重 SQL
select userid::regrole, dbid, query from pg_stat_statements order by stddev_time desc limit 5; 
查询最耗共享内存 SQL
select userid::regrole, dbid, query from pg_stat_statements order by (shared_blks_hit+shared_blks_dirtied) desc limit 5;  
查询最耗临时空间 SQL
select userid::regrole, dbid, query from pg_stat_statements order by temp_blks_written desc limit 5; 
-->
