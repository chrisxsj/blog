# pg_lock

**作者**

Chrisx

**日期**

2021-12-06

**内容**

显示锁定

数据库提供了多种锁模式用于控制对表中数据的并发访问。锁与mvcc一起构成了并发控制。

---

[toc]

## 表级锁

表可以被并发读取，如果在表上同时存在读写呢，并发会冲突吗？

表级锁，就是它的字面意思，在表级进行锁定。表级锁共有8中，对并发进行细粒度控制。不同的表锁之间可能并存也可能冲突。详细表锁介绍如下

* ACCESS SHARE
与ACCESS EXCLUSIVE锁模式冲突。表上的查询都会获得这种锁模式。

* ROW SHARE
与EXCLUSIVE和ACCESS EXCLUSIVE锁模式冲突。SELECT FOR UPDATE和SELECT FOR SHARE命令在目标表上取得一个这种模式的锁。

* ROW EXCLUSIVE
与SHARE、SHARE ROW EXCLUSIVE、EXCLUSIVE和ACCESS EXCLUSIVE锁模式冲突。DML命令UPDATE、DELETE和INSERT在目标表上取得这种锁模式

* SHARE UPDATE EXCLUSIVE
与SHARE UPDATE EXCLUSIVE、SHARE、SHARE ROW EXCLUSIVE、EXCLUSIVE和ACCESS EXCLUSIVE锁模式冲突。这种模式保护一个表不受并发模式改变和VACUUM运行的影响。

* SHARE
与ROW EXCLUSIVE、SHARE UPDATE EXCLUSIVE、SHARE ROW EXCLUSIVE、EXCLUSIVE和ACCESS EXCLUSIVE锁模式冲突。这种模式保护一个表不受并发数据改变的影响。由CREATE INDEX（不带CONCURRENTLY）取得。

* SHARE ROW EXCLUSIVE
与ROW EXCLUSIVE、SHARE UPDATE EXCLUSIVE、SHARE、SHARE ROW EXCLUSIVE、EXCLUSIVE和ACCESS EXCLUSIVE锁模式冲突。这种模式保护一个表不受并发数据修改所影响，并且是自排他的，这样在一个时刻只能有一个会话持有它。由CREATE COLLATION、CREATE TRIGGER和很多 ALTER TABLE语句获得。

* EXCLUSIVE
与ROW SHARE、ROW EXCLUSIVE、SHARE UPDATE EXCLUSIVE、SHARE、SHARE ROW EXCLUSIVE、EXCLUSIVE和ACCESS EXCLUSIVE锁模式冲突。这种模式只允许并发的ACCESS SHARE锁，即只有来自于表的读操作可以与一个持有该锁模式的事务并行处理。由REFRESH MATERIALIZED VIEW CONCURRENTLY获得。

* ACCESS EXCLUSIVE
与所有模式的锁冲突（ACCESS SHARE、ROW SHARE、ROW EXCLUSIVE、SHARE UPDATE EXCLUSIVE、SHARE、SHARE ROW EXCLUSIVE、EXCLUSIVE和ACCESS EXCLUSIVE）。这种模式保证持有者是访问该表的唯一事务。由ALTER TABLE、DROP TABLE、TRUNCATE、REINDEX、CLUSTER、VACUUM FULL和REFRESH MATERIALIZED VIEW（不带CONCURRENTLY）命令获取。ALTER TABLE的很多形式也在这个层面上获得锁（见ALTER TABLE）。这也是未显式指定模式的LOCK TABLE命令的默认锁模式。

一旦被获取，一个锁通常将被持有直到事务结束。ROLLBACK取消事务后，锁资源会被释放。

具体的锁冲突参考如下

| 锁冲突                 | ACCESS SHARE | ROW SHARE | ROW EXCLUSIVE | SHARE UPDATE EXCLUSIVE | SHARE | SHARE ROW EXCLUSIVE | EXCLUSIVE | ACCESS EXCLUSIVE |
| ---------------------- | ------------ | --------- | ------------- | ---------------------- | ----- | ------------------- | --------- | ---------------- |
| ACCESS SHARE           |              |           |               |                        |       |                     |           | X                |
| ROW SHARE              |              |           |               |                        |       |                     | X         | X                |
| ROW EXCLUSIVE          |              |           |               |                        | X     | X                   | X         | X                |
| SHARE UPDATE EXCLUSIVE |              |           |               | X                      | X     | X                   | X         | X                |
| SHARE                  |              |           | X             | X                      |       | X                   | X         | X                |
| SHARE ROW EXCLUSIVE    |              |           | X             | X                      | X     | X                   | X         | X                |
| EXCLUSIVE              |              | X         | X             | X                      | X     | X                   | X         | X                |
| ACCESS EXCLUSIVE       | X            | X         | X             | X                      | X     | X                   | X         | X                |

示例

```sql
create table t_lock(id integer primary key);
insert into t_lock values(1),(2);

session 1:

begin;
alter table t_lock add column name text;

session 2
begin;
insert into t_lock values (3);  

session 3

postgres=# select pc.relname,pl.pid,pl.mode,pl.granted,psa.usename,psa.wait_event_type,psa.wait_event,psa.state,psa.query from pg_locks pl inner join pg_stat_activity psa on pl.pid = psa.pid inner join pg_class pc on pl.relation=pc.oid and pc.relname not like 'pg_%';
 relname | pid |        mode         | granted | usename  | wait_event_type | wait_event |        state        |                  query
---------+-----+---------------------+---------+----------+-----------------+------------+---------------------+------------------------------------------
 t_lock  | 373 | RowExclusiveLock    | f       | postgres | Lock            | relation   | active              | insert into t_lock values (3);
 t_lock  | 326 | AccessExclusiveLock | t       | postgres | Client          | ClientRead | idle in transaction | alter table t_lock add column name text;
(2 rows)

```

## 行锁模式

同一个表上操作会有冲突，在同一行上操作呢？

多个事务在相同的行上操作也可能会形成锁冲突。但是行级锁不影响数据查询操作。

* FOR UPDATE
FOR UPDATE会导致由SELECT语句检索到的行被锁定，就好像它们要被更新。任何在一行上的DELETE命令也会获得FOR UPDATE锁模式，在某些列上修改值的UPDATE也会获得该锁模式。

* FOR NO KEY UPDATE
行为与FOR UPDATE类似，不过获得的锁较弱：这种锁将不会阻塞尝试在相同行上获得锁的SELECT FOR KEY SHARE命令。任何不获取FOR UPDATE锁的UPDATE也会获得这种锁模式。

* FOR SHARE
行为与FOR NO KEY UPDATE类似，不过它在每个检索到的行上获得一个共享锁而不是排他锁。一个共享锁会阻塞其他事务在这些行上执行UPDATE、DELETE、SELECT FOR UPDATE或者SELECT FOR NO KEY UPDATE，但是它不会阻止它们执行SELECT FOR SHARE或者SELECT FOR KEY SHARE。

* FOR KEY SHARE
行为与FOR SHARE类似，不过锁较弱：SELECT FOR UPDATE会被阻塞，但是SELECT FOR NO KEY UPDATE不会被阻塞。一个键共享锁会阻塞其他事务执行修改键值的DELETE或者UPDATE，但不会阻塞其他UPDATE，也不会阻止SELECT FOR NO KEY UPDATE、SELECT FOR SHARE或者SELECT FOR KEY SHARE。

具体行锁冲突模式如下

| 锁冲突            | FOR KEY SHARE | FOR SHARE | FOR NO KEY UPDATE | FOR UPDATE |
| ----------------- | ------------- | --------- | ----------------- | ---------- |
| FOR KEY SHARE     |               |           |                   | X          |
| FOR SHARE         |               |           | X                 | X          |
| FOR NO KEY UPDATE |               | X         | X                 | X          |
| FOR UPDATE        | X             | X         | X                 | X          |

示例

```sql
create table t_lock(id integer primary key);
insert into t_lock values(1),(2);

session 1:

begin;
select * from t_lock where id=1 for update;

session 2
begin;
update t_lock set id=100 where id=1;

session 3

postgres=# select pc.relname,pl.pid,pl.mode,pl.granted,psa.usename,psa.wait_event_type,psa.wait_event,psa.state,psa.query from pg_locks pl inner join pg_stat_activity psa on pl.pid = psa.pid inner join pg_class pc on pl.relation=pc.oid and pc.relname not like 'pg_%';
   relname   | pid |        mode         | granted | usename  | wait_event_type |  wait_event   |        state        |                    query

-------------+-----+---------------------+---------+----------+-----------------+---------------+---------------------+-------------------------------------
--------
 t_lock_pkey | 373 | RowExclusiveLock    | t       | postgres | Lock            | transactionid | active              | update t_lock set id=100 where id=1;
 t_lock      | 373 | RowExclusiveLock    | t       | postgres | Lock            | transactionid | active              | update t_lock set id=100 where id=1;
 t_lock_pkey | 467 | RowShareLock        | t       | postgres | Client          | ClientRead    | idle in transaction | select * from t_lock where id=1 for
update;
 t_lock      | 467 | RowShareLock        | t       | postgres | Client          | ClientRead    | idle in transaction | select * from t_lock where id=1 for
update;
 t_lock      | 373 | AccessExclusiveLock | t       | postgres | Lock            | transactionid | active              | update t_lock set id=100 where id=1;
(5 rows)

```

## 死锁(deadlock)

锁的使用过程中，可能会造成死锁，死锁是指两个（或多个）事务相互持有对方想要的锁。PostgreSQL能够自动检测到死锁情况并且会通过中断其中一个事务从而允许其它事务完成来解决这个问题

示例

```sql
create table t_deadlock(id integer primary key,name varchar);
insert into t_deadlock values(1,'aaa'),(2,'bbb');

session 1:
begin;
update t_deadlock set name='Peter' where id=1;

session 2
begin;
update t_deadlock set name='Jason' where id=2;
update t_deadlock set name='xiaoming' where id=1;

session 1
update t_deadlock set name='xiaohong' where id=2;

```

错误日志：

```bash
ERROR:  deadlock detected
DETAIL:  Process 558 waits for ShareLock on transaction 532; blocked by process 560.
Process 560 waits for ShareLock on transaction 530; blocked by process 558.
HINT:  See server log for query details.
CONTEXT:  while updating tuple (0,1) in relation "t_deadlock"
```

防止死锁的最好方法通常是保证所有使用一个数据库的应用在逻辑上以一致的顺序在多个对象上获得锁。避免死锁的产生。

ref[deadlocks-in-postgresql](https://shiroyasha.io/deadlocks-in-postgresql.html)

## 如何检查或监控锁等待呢？

PostgreSQL提供了几个视图

1. pg_locks展示锁信息，每一个被锁或者等待锁的对象一条记录。
<!--
granted is true in a row representing a lock held by the indicated process. False indicates that this process is currently waiting to acquire this lock, which implies that at least one other process is holding or waiting for a conflicting lock mode on the same lockable object. The waiting process will sleep until the other lock is released (or a deadlock situation is detected). A single process can be waiting to acquire at most one lock at a time.
-->
2. pg_stat_activity，每个会话一条记录，显示会话状态信息。
3. pg_class显示对象信息。

我们通过这两个视图可以查看锁，锁等待情况。同时可以了解发生锁冲突的情况。

```sql
postgres=# select pc.relname,pl.pid,pl.mode,pl.granted,psa.usename,psa.wait_event_type,psa.wait_event,psa.state,psa.query from pg_locks pl inner join pg_stat_activity psa on pl.pid = psa.pid inner join pg_class pc on pl.relation=pc.oid and pc.relname not like 'pg_%';
 relname | pid  |       mode       | granted | usename | wait_event_type |  wait_event   |        state        |               query
---------+------+------------------+---------+---------+-----------------+---------------+---------------------+------------------------------------
 a_pkey  | 2614 | RowExclusiveLock | t       | pg106   | Lock            | transactionid | active              | update a set col1=666 where aid=1;
 a       | 2614 | RowExclusiveLock | t       | pg106   | Lock            | transactionid | active              | update a set col1=666 where aid=1;
 a_pkey  | 2176 | RowExclusiveLock | t       | pg106   | Client          | ClientRead    | idle in transaction | update a set col1=555 where aid=1;
 a       | 2176 | RowExclusiveLock | t       | pg106   | Client          | ClientRead    | idle in transaction | update a set col1=555 where aid=1;
 a       | 2614 | ExclusiveLock    | t       | pg106   | Lock            | transactionid | active              | update a set col1=666 where aid=1;
(5 rows)

```

> 注意：pg_stat_activity.query反映的是当前正在执行或请求的SQL，而同一个事务中以前已经执行的SQL不能在pg_stat_activity中显示出来。所以如果你发现两个会话发生了冲突，但是他们的pg_stat_activity.query没有冲突的话，那就有可能是他们之间的某个事务之前的SQL获取的锁与另一个事务当前请求的QUERY发生了锁冲突。

## 通常锁的排查方法如下

1. 开启审计日志log_statement = 'all'
2. psql 挂一个打印锁等待的窗口（sql语句参考如下）
3. tail 挂一个日志观测窗口

## 查看锁等待

### 方法一

```sql
SELECT
lock2.pid as locking_pid,
lock1.pid as locked_pid,
stat1.usename as locked_user,
stat1.query as locked_statement,
stat1.state as state,
stat2.query as locking_statement,
stat2.state as state,
now() - stat1.query_start as locking_duration,
stat2.usename as locking_user
FROM pg_catalog.pg_locks lock1
JOIN pg_catalog.pg_stat_activity stat1 on lock1.pid = stat1.pid
JOIN pg_catalog.pg_locks lock2 on
(lock1.locktype,lock1.database,lock1.relation,
lock1.page,lock1.tuple,lock1.virtualxid,
lock1.transactionid,lock1.classid,lock1.objid,
lock1.objsubid) IS NOT DISTINCT FROM
(lock2.locktype,lock2.DATABASE,
lock2.relation,lock2.page,
lock2.tuple,lock2.virtualxid,
lock2.transactionid,lock2.classid,
lock2.objid,lock2.objsubid)
JOIN pg_catalog.pg_stat_activity stat2 on lock2.pid
= stat2.pid
WHERE NOT lock1.granted AND lock2.granted;

```

```sql
 locking_pid | locked_pid | locked_user |          locked_statement          | state  |         locking_statement          |        state        | locking_d
uration | locking_user
-------------+------------+-------------+------------------------------------+--------+------------------------------------+---------------------+----------
--------+--------------
        2176 |       2614 | pg106       | update a set col1=666 where aid=1; | active | update a set col1=555 where aid=1; | idle in transaction | 00:52:54.
146781  | pg106
(1 row)

```

显示
locking，锁持有者相关信息
locked，被阻塞者相关信息

### 方法二

```sql
with
t_wait as
(
select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,
a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,
b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name
from pg_locks a,pg_stat_activity b where a.pid=b.pid and not a.granted
),
t_run as
(
select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,
a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,
b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name
from pg_locks a,pg_stat_activity b where a.pid=b.pid and a.granted
),
t_overlap as
(
select r.* from t_wait w join t_run r on
(
r.locktype is not distinct from w.locktype and
r.database is not distinct from w.database and
r.relation is not distinct from w.relation and
r.page is not distinct from w.page and
r.tuple is not distinct from w.tuple and
r.virtualxid is not distinct from w.virtualxid and
r.transactionid is not distinct from w.transactionid and
r.classid is not distinct from w.classid and
r.objid is not distinct from w.objid and
r.objsubid is not distinct from w.objsubid and
r.pid <> w.pid
)
),
t_unionall as
(
select r.* from t_overlap r
union all
select w.* from t_wait w
)
select locktype,datname,relation::regclass,page,tuple,virtualxid,transactionid::text,classid::regclass,objid,objsubid,
string_agg(
'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||
'Lock_Granted: '||case when granted is null then 'NULL' else granted::text end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , FastPath: '||case when fastpath is null then 'NULL' else fastpath::text end||' , VirtualTransaction: '||case when virtualtransaction is null then 'NULL' else virtualtransaction::text end||' , Session_State: '||case when state is null then 'NULL' else state::text end||chr(10)||
'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||
'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||
'SQL (Current SQL in Transaction): '||chr(10)||
case when query is null then 'NULL' else query::text end,
chr(10)||'--------'||chr(10)
order by
( case mode
when 'INVALID' then 0
when 'AccessShareLock' then 1
when 'RowShareLock' then 2
when 'RowExclusiveLock' then 3
when 'ShareUpdateExclusiveLock' then 4
when 'ShareLock' then 5
when 'ShareRowExclusiveLock' then 6
when 'ExclusiveLock' then 7
when 'AccessExclusiveLock' then 8
else 0
end ) desc,
(case when granted then 0 else 1 end)
) as lock_conflict
from t_unionall
group by
locktype,datname,relation,page,tuple,virtualxid,transactionid::text,classid,objid,objsubid;
```

如果觉得写SQL麻烦，可以将它创建为视图

``` sql
create view v_locks_monitor as
with
......
```

eg

``` sql
Pid: 1980
Lock_Granted: false , Mode: AccessExclusiveLock , FastPath: false , VirtualTransaction: 9/4 , Session_State: active
Username: test , Database: postgres , Client_Addr: NULL , Client_Port: -1 , Application_Name: psql
Xact_Start: 2019-02-11 15:35:33.054468+08 , Query_Start: 2019-02-11 15:35:34.283192+08 , Xact_Elapse: 00:01:18.422846 , Query_Elapse: 00:01:17.194122
SQL (Current SQL in Transaction):
truncate table_lock;
--------
Pid: 1894
Lock_Granted: true , Mode: RowExclusiveLock , FastPath: false , VirtualTransaction: 5/128 , Session_State: idle in transaction
Username: test , Database: postgres , Client_Addr: NULL , Client_Port: -1 , Application_Name: psql
Xact_Start: 2019-02-11 15:17:48.342793+08 , Query_Start: 2019-02-11 15:17:48.344543+08 , Xact_Elapse: 00:19:03.134521 , Query_Elapse: 00:19:03.132771
SQL (Current SQL in Transaction):
insert into table_lock values (2,'b');
--------
```

1. 前面的锁查询SQL，已经清晰的显示了每一个发生了锁等待的对象，Lock_Granted: true阻塞了Lock_Granted: false
2. 同时按锁的大小排序，第一行的锁最大（Mode: AccessExclusiveLock级别最高）

### 方法三

```sql
SELECT
    l1.*,
    l2.virtualtransaction,
    l2.pid,
    l2.mode,
    l2.granted
FROM
    pg_locks l1
JOIN
    pg_locks l2 on (
        (
            l1.locktype,
            l1.database,
            l1.relation,
            l1.page,
            l1.tuple,
            l1.virtualxid,
            l1.transactionid,
            l1.classid,
            l1.objid,
            l1.objsubid
        )
    IS NOT DISTINCT FROM
        (
            l2.locktype,
            l2.database,
            l2.relation,
            l2.page,
            l2.tuple,
            l2.virtualxid,
            l2.transactionid,
            l2.classid,
            l2.objid,
            l2.objsubid
        )
    )
WHERE
    NOT l1.granted
AND
    l2.granted;


   locktype    | database | relation | page | tuple | virtualxid | transactionid | classid | objid | objsubid | virtualtransaction | pid  |   mode    | gran
ted | fastpath | virtualtransaction | pid  |     mode      | granted
---------------+----------+----------+------+-------+------------+---------------+---------+-------+----------+--------------------+------+-----------+-----
----+----------+--------------------+------+---------------+---------
 transactionid |          |          |      |       |            |           614 |         |       |          | 4/49               | 2614 | ShareLock | f
    | f        | 3/14               | 2176 | ExclusiveLock | t


```

### 方法4

```sql
select pid,pg_blocking_pids(pid),wait_event_type,wait_event,query from pg_stat_activity ;

```

显示阻塞者相关信息

ref[Find Locks](https://wiki.postgresql.org/wiki/Find_Locks?d=1594624951637)

## 处理方法

确认会话状态为idle状态。会话的类型state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')

``` sql
select pid, state from pg_stat_activity where state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') and pid=10036;
```

> state
text
Current overall state of this backend. Possible values are:
active: The backend is executing a query.
idle: The backend is waiting for a new client command.
idle in transaction: The backend is in a transaction, but is not currently executing a query.
idle in transaction (aborted): This state is similar to idle in transaction, except one of the statements in the transaction caused an error.
fastpath function call: The backend is executing a fast-path function.
disabled: This state is reported if track_activities is disabled in this backend.

找到会话信息，通知前台用户结束事务操作，或者手动杀死会话

```sql
SELECT pg_terminate_backend(pid)

```

> 注意：此处不要使用操作系统命令kill -9, 其会造成所有活动进程被终止，数据库重启。
<!--
2019-01-09 15:08:05.399 CST,,,1887,,5c35885f.75f,5,,2019-01-09 13:36:31 CST,,0,LOG,00000,"server process (PID 2118) was terminated by signal 9: Killed","Failed process was running: update test_rep set id=3 where id=4",,,,,,,,""
2019-01-09 15:08:05.399 CST,,,1887,,5c35885f.75f,6,,2019-01-09 13:36:31 CST,,0,LOG,00000,"terminating any other active server processes",,,,,,,,,""
2019-01-09 15:08:05.399 CST,"pg","postgres",2113,"192.168.6.1:53228",5c359cd9.841,1,"idle",2019-01-09 15:03:53 CST,7/0,0,WARNING,57P02,"terminating connection because of crash of another server process","The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.","In a moment you should be able to reconnect to the database and repeat your command.",,,,,,,"Navicat"
2019-01-09 15:08:05.400 CST,"pg","postgres",2096,"192.168.6.1:53218",5c359c1c.830,1,"idle",2019-01-09 15:00:44 CST,6/0,0,WARNING,57P02,"terminating connection because of crash of another server process","The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.","In a moment you should be able to reconnect to the database and repeat your command.",,,,,,,"Navicat"
2019-01-09 15:08:05.401 CST,"pg","postgres",1953,"[local]",5c3589ad.7a1,1,"UPDATE waiting",2019-01-09 13:42:05 CST,3/53,669,WARNING,57P02,"terminating connection because of crash of another server process","The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.","In a moment you should be able to reconnect to the database and repeat your command.",,,"while updating tuple (0,4) in relation ""test_rep""",,,,"psql"
2019-01-09 15:08:05.402 CST,,,1897,,5c3588b0.769,1,,2019-01-09 13:37:52 CST,1/0,0,WARNING,57P02,"terminating connection because of crash of another server process","The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.","In a moment you should be able to reconnect to the database and repeat your command.",,,,,,,""
2019-01-09 15:08:05.403 CST,,,1887,,5c35885f.75f,7,,2019-01-09 13:36:31 CST,,0,LOG,00000,"archiver process (PID 1898) exited with exit code 1",,,,,,,,,""
2019-01-09 15:08:05.403 CST,"repuser","",1959,"192.168.6.12:53868",5c3589ca.7a7,1,"streaming 0/76007118",2019-01-09 13:42:34 CST,4/0,0,WARNING,57P02,"terminating connection because of crash of another server process","The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.","In a moment you should be able to reconnect to the database and repeat your command.",,,,,,,"pg_rep1"
2019-01-09 15:08:05.405 CST,"pg","postgres",2164,"[local]",5c359dd5.874,1,"",2019-01-09 15:08:05 CST,,0,FATAL,57P03,"the database system is in recovery mode",,,,,,,,,""
2019-01-09 15:08:05.406 CST,,,1887,,5c35885f.75f,8,,2019-01-09 13:36:31 CST,,0,LOG,00000,"all server processes terminated; reinitializing",,,,,,,,,""
2019-01-09 15:08:05.422 CST,"repuser","",2166,"192.168.6.12:53870",5c359dd5.876,1,"",2019-01-09 15:08:05 CST,,0,FATAL,57P03,"the database system is in recovery mode",,,,,,,,,""
2019-01-09 15:08:05.423 CST,,,2165,,5c359dd5.875,1,,2019-01-09 15:08:05 CST,,0,LOG,00000,"database system was interrupted; last known up at 2019-01-09 15:07:52 CST",,,,,,,,,""
2019-01-09 15:08:05.780 CST,,,2165,,5c359dd5.875,2,,2019-01-09 15:08:05 CST,,0,LOG,00000,"database system was not properly shut down; automatic recovery in progress",,,,,,,,,""
2019-01-09 15:08:05.782 CST,,,2165,,5c359dd5.875,3,,2019-01-09 15:08:05 CST,,0,LOG,00000,"redo starts at 0/76007028",,,,,,,,,""
2019-01-09 15:08:05.782 CST,,,2165,,5c359dd5.875,4,,2019-01-09 15:08:05 CST,,0,LOG,00000,"invalid record length at 0/76007118: wanted 24, got 0",,,,,,,,,""
2019-01-09 15:08:05.782 CST,,,2165,,5c359dd5.875,5,,2019-01-09 15:08:05 CST,,0,LOG,00000,"redo done at 0/760070D8",,,,,,,,,""
2019-01-09 15:08:05.792 CST,,,1887,,5c35885f.75f,9,,2019-01-09 13:36:31 CST,,0,LOG,00000,"database system is ready to accept connections",,,,,,,,,""
-->

杀15分钟以前的状态为idle的会话，可以用这个语句

``` sql
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE
pid <> pg_backend_pid()
AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled')
AND state_change < current_timestamp - INTERVAL '15' MINUTE;
```

<!--

segment级锁问题排查
由于Greenplum是分布式架构，所以有些异常的情况下，在master可能看不到锁等待的罪魁祸首，只能看到等待者，那么需要查询segment才能分析出到底是等待什么，以及如何处理，请参考：
《Greenplum segment级锁问题排查方法 - 阿里云HybridDB for PostgreSQL最佳实践》

https://github.com/digoal/blog/blob/master/201708/20170822_01.md

https://yq.aliyun.com/articles/647435
PostgreSQL 锁等待排查实践 - 珍藏级 - process xxx1 acquired RowExclusiveLock on relation xxx2 of database xxx3 after xxx4 ms at xxx
https://github.com/digoal/blog/blob/master/201705/20170521_01.md?spm=a2c4e.11153940.blogcont647435.15.7d867aacNWrnlw&file=20170521_01.md
PostgreSQL 锁等待监控 珍藏级SQL - 谁堵塞了谁
reference doc
https://www.postgresql.org/docs/10/explicit-locking.html
-->
