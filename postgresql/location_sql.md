# location_sql

分析定位sql语句

## 定位pid

使用TOP命令查看占用CPU高的postgresql进程，并获取该进程的ID号，如图该id号为3640

## 定位sql

在知道pid的情况下，可定位到sql语句。

``` sql
SELECT procpid, START, now() - START AS lap, current_query  FROM ( SELECT backendid, pg_stat_get_backend_pid (S.backendid) AS procpid,
pg_stat_get_backend_activity_start (S.backendid) AS START,pg_stat_get_backend_activity (S.backendid) AS current_query  FROM (SELECT
pg_stat_get_backend_idset () AS backendid) AS S) AS S WHERE current_query <> '<IDLE>' and procpid=25400  ORDER BY lap DESC;

```

* procpid：进程id 如果不确认进程ID，将上面的条件去掉，可以逐条分析
* start：进程开始时间
* lap：经过时间
* current_query：执行中的sql
* 怎样停止正在执行的sql ：SELECT pg_cancel_backend(进程id); 或者用系统函数 

## 定位执行计划

使用explain analyze + sql语句的格式

## 分析执行计划
