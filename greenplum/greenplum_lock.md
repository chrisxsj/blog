# greenplum_lock

## 锁查看

### 方法1

```sql
with    
t_wait as    
(    
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.transactionid,a.mppsessionid,a.mppiswriter,a.gp_segment_id,     
  b.pid procpid,b.sess_id,b.waiting_reason,b.query current_query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name   
    from pg_locks a,pg_stat_activity b where a.mppsessionid=b.sess_id and not a.granted   
),   
t_run as   
(   
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.transactionid,a.mppsessionid,a.mppiswriter,a.gp_segment_id,     
  b.pid procpid,b.sess_id,b.waiting_reason,b.query current_query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name   
    from pg_locks a,pg_stat_activity b where a.mppsessionid=b.sess_id and a.granted   
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
    r.transactionid is not distinct from w.transactionid and   
    r.classid is not distinct from w.classid and   
    r.objid is not distinct from w.objid and   
    r.objsubid is not distinct from w.objsubid and   
    r.mppsessionid <> w.mppsessionid   
  )    
),    
t_unionall as    
(    
  select r.* from t_overlap r    
  union all    
  select w.* from t_wait w    
)    
select locktype,datname,relation::regclass,page,tuple,textin(xidout(transactionid)),classid::regclass,objid,objsubid,   
string_agg(   
'Gp_Segment_Id: '||case when gp_segment_id is null then 'NULL' else gp_segment_id::text end||chr(10)|| 
'MppIsWriter: '||case when mppiswriter is null then 'NULL' when mppiswriter is true then 'TRUE' else 'FALSE' end||chr(10)|| 
'MppSessionId: '||case when mppsessionid is null then 'NULL' else mppsessionid::text end||chr(10)|| 
'ProcPid: '||case when procpid is null then 'NULL' else procpid::text end||chr(10)|| 
'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||   
'Lock_Granted: '||case when granted is null then 'NULL' when granted is true then 'TRUE' else 'FALSE' end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , Waiting_Reason: '||case when waiting_reason is null then 'NULL' else waiting_reason::text end||chr(10)||   
'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||    
'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||    
'SQL (Current SQL in Transaction): '||chr(10)||  
case when current_query is null then 'NULL' else current_query::text end,    
chr(10)||'--------'||chr(10)    
order by    
  (  case mode    
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
  end  ) desc,   
  (case when granted then 0 else 1 end)  
) as lock_conflict  
from t_unionall   
group by   
locktype,datname,relation::regclass,page,tuple,textin(xidout(transactionid)),classid::regclass,objid,objsubid;

```

result:

Gp_Segment_Id: 1
MppIsWriter: TRUE
MppSessionId: 49
ProcPid: 20990
Pid: 16020
Lock_Granted: TRUE , Mode: ExclusiveLock , Waiting_Reason: NULL
Username: hgadmin , Database: hgdw , Client_Addr: NULL , Client_Port: -1 , Application_Name: psql
Xact_Start: 2021-01-26 09:28:10.744882+08 , Query_Start: 2021-01-26 09:28:13.789063+08 , Xact_Elapse: 00:07:44.035711 , Query_Elapse: 00:07:40.99153
SQL (Current SQL in Transaction): 
update test_select set name='aaa' where id=1;
--------
Gp_Segment_Id: 1
MppIsWriter: TRUE
MppSessionId: 50
ProcPid: 21330
Pid: 16031
Lock_Granted: FALSE , Mode: ShareLock , Waiting_Reason: NULL
Username: hgadmin , Database: hgdw , Client_Addr: NULL , Client_Port: -1 , Application_Name: psql
Xact_Start: 2021-01-26 09:30:00.514704+08 , Query_Start: 2021-01-26 09:30:00.514704+08 , Xact_Elapse: 00:05:54.265889 , Query_Elapse: 00:05:54.265889
SQL (Current SQL in Transaction): 
update test_select set name='bbb' where id=1;

Lock_Granted: TRUE  --持有锁的会话

### 方法2

```sql
select pc.relname,pl.pid,pl.mode,pl.granted,psa.usename,psa.waiting,psa.waiting_reason,psa.state,psa.query from pg_locks pl inner join pg_stat_activity psa on pl.pid = psa.pid inner join pg_class pc on pl.relation=pc.oid and pc.relname not like 'pg_%';

```

result:

hgdw=# select pc.relname,pl.pid,pl.mode,pl.granted,psa.usename,psa.waiting,psa.waiting_reason,psa.state,psa.query from pg_locks pl inner join pg_stat_activity psa on pl.pid = psa.pid inner join pg_class pc on pl.relation=pc.oid and pc.relname not like 'pg_%';
        relname         |  pid  |       mode       | granted | usename | waiting | waiting_reason |        state        |                     query
------------------------+-------+------------------+---------+---------+---------+----------------+---------------------+-----------------------------------------------
 test_select_id_idx     | 20990 | RowExclusiveLock | t       | hgadmin | f       |                | idle in transaction | update test_select set name='aaa' where id=1;
 test_select_id_idx     | 21330 | RowExclusiveLock | t       | hgadmin | f       |                | active              | update test_select set name='bbb' where id=1;
 test_select_insert_idx | 20990 | RowExclusiveLock | t       | hgadmin | f       |                | idle in transaction | update test_select set name='aaa' where id=1;
 test_select_insert_idx | 21330 | RowExclusiveLock | t       | hgadmin | f       |                | active              | update test_select set name='bbb' where id=1;
 test_select            | 20990 | RowExclusiveLock | t       | hgadmin | f       |                | idle in transaction | update test_select set name='aaa' where id=1;
 test_select            | 21330 | RowExclusiveLock | t       | hgadmin | f       |                | active              | update test_select set name='bbb' where id=1;
 test_select_time_id    | 20990 | RowExclusiveLock | t       | hgadmin | f       |                | idle in transaction | update test_select set name='aaa' where id=1;

waiting=f --持有锁的列

### 方法3

查看segment级别的锁
此粒度更细。

master节点：
查看segment锁情况
select gp_execution_dbid(), pid, relation::regclass, locktype, mode, granted 
from gp_dist_random('pg_locks');
查看具体什么语句持有的锁
select gp_execution_dbid() dbid,pid procpid,query current_query
from gp_dist_random('pg_stat_activity')  
where pid in  
(select pid from gp_dist_random('pg_locks') where mode like '%ExclusiveLock%');
通过以上语句大概定位到持有锁的segment

segment节点：
根据实际情况进行处理
1.连接相关segment,xxxx替换为实际segment节点的ip,端口，库名
PGOPTIONS="-c gp_session_role=utility" psql -h xxxxxxxxx -p xxxx -d  xxxxx
2.在segment查询相关锁情况
SELECT
w.query as waiting_query,
w.pid as w_pid,
w.usename as w_user,
l.query as locking_query,
l.pid as l_pid,
l.usename as l_user,
t.schemaname || '.' || t.relname as tablename
from pg_stat_activity w
join pg_locks l1 on w.pid = l1.pid and not l1.granted
join pg_locks l2 on l1.relation = l2.relation and l2.granted
join pg_stat_activity l on l2.pid = l.pid
join pg_stat_user_tables t on l1.relation = t.relid
where w.waiting;

## 锁处理

处理持有锁的pid
select pg_terminate_backend('procpid');

## reference

https://www.postgresql.org/docs/9.4/explicit-locking.html
http://www.postgres.cn/docs/9.4/monitoring-stats.html#PG-STAT-ACTIVITY-VIEW
http://postgres.cn/docs/9.4/view-pg-locks.html
https://developer.aliyun.com/article/700364?spm=a2c6h.13262185.0.0.4cac622fPB5CWY
https://github.com/digoal/blog/blob/master/201705/20170521_01.md?spm=a2c6h.12873639.0.0.213d199f5iG17M&file=20170521_01.md
https://blog.csdn.net/Explorren/article/details/105107672?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.edu_weight&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.edu_weight