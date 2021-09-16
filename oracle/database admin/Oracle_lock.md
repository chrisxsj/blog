# Oracle lock check

# 锁等待检查
 
 
with lk as (select blocking_instance||'.'||blocking_session blocker, inst_id||'.'||sid waiter
            from gv$session
            where blocking_instance is not null
              and blocking_session is not null)
select lpad('  ',2*(level-1))||waiter lock_tree from
 (select * from lk
  union all
  select distinct 'root', blocker from lk
  where blocker not in (select waiter from lk))
connect by prior waiter=blocker start with blocker='root';
 
or
 
select sid, serial#, osuser, program
  from v$session
where sid in (select blocking_session
                 from v$session
                where event = 'latch: library cache');
 
select SID,TYPE,ID1,ID2,LMODE,REQUEST,CTIME,BLOCK from V$lock where block=1 or request<>0;
 
注意:该语句不能在plsql-dev的sql windows窗口中执行，可以在plsql-dev的command windows窗口中执行，可以在sqlplus中执行。
检测锁等待（或者说行锁争用），不是检测锁。持有锁的语句无法查询到，可以看ash报告！


# 锁分析
 
》查询持有锁的会话信息
set linesize 200
col program format a20
col terminal format a20
col machine format a30
select inst_id,sid,serial#,username,program,terminal,machine,sql_id,type,logon_time,event,WAIT_CLASS from gv$session where sid in (618,918) and inst_id=1;
 
》查询持有锁会话占用的undo段
SELECT s.inst_id,s.USERNAME,s.SID,s.SERIAL#,t.USED_UBLK "Number os undo Blocks Used"
   FROM gv$session s,gv$transaction t,v$rollname r
   WHERE s.SADDR=t.SES_ADDR  AND t.XIDUSN=r.usn  and s.sid in (618,918)  and s.inst_id=1;
 
其中t.USED_UBLK "Number os undo Blocks Used" 就是该会话占用的回滚段数据量，之所以记录是如果后面需要强制杀掉该session后需要回滚相应的事务，如果回滚段数量比较大，则回滚时间会比较长。大事务长时间回滚会导致smon进程对回滚数据对象持锁，从而导致新的行锁等待，因此如果要强制杀掉持锁会话，要先告知客户事务较大回滚时间稍长，在回滚期间有可能会导致其他行锁。
 
》查询等待会话sql
set line 500
set pages 500
set long 100000  
select sql_id,HASH_VALUE,sql_fulltext from gv$sqlarea  where sql_id ='096w78wxxfs0k';
 
#持有锁的回话是2实例的1568 session ，则可以用如下sql查询被阻塞的会话正在执行的sql ，从而推测 1568 session 锁定的资源信息。
持锁的sql可能和锁等待的sql一样，或者至少涉及相同的资源。

# 锁处理
 
获取操作系统进程的号及sql_id
我们可以通过ＳＩＤ确认很多信息，type=user
select s.inst_id,s.sid,s.serial#,s.machine,s.program,s.osuser,s.terminal,p.spid,s.sql_id,s.type from gv$session s,gv$process p where s.paddr=p.addr and s.sid=973 and s.inst_id=1;
 
 
在数据库层面杀掉会话：
alter system kill session 'sid,serial#' ;
alter system kill session '1568,27761,@2' immediate;
被kill掉的session,状态会被标记为killed,Oracle会在该用户下一次touch时清除该进程.
 
 
@符号10g不支持！！！
获取操作系统进程的号，建议在数据库层面先通过alter system kill session方式杀掉进程，如果进程不能成功或者快速杀掉，可以再通过在系统层面直接kill -9 xxxx 进程的方式结束会话，（xxxx 就是上面sql的查询结果）注意kill -9 进程时要登录正确的实例主机，并检查是LOCAL=NO的进程才可能kill。
 
 
Resolving Issues Where 'enq: TX - row lock contention' Waits are Occurring (文档 ID 1476298.1)Waits for 'Enq: TX - ...' Type Events - Transaction (TX) Lock Example Scenarios (文档 ID 62354.1)
如上两篇文章中均提到了如下一段话：
NOTE: TX lock is an application coding, design and usage problem and can ONLY be fixed by changing application code with more frequent and explicit COMMIT statements and any other minor code changes. Oracle Support cannot fix TX lock wait issues other than helping to identify the objects and commands causing the waits. Please work with Developers to fix the code and to alleviate TX lock waits.

# 异常处理1
 
当执行完alter system kill session 'sid,serial#'之后，找到该sid对应的os进程ospid的方法：
As it can be seen, after killing the session, the paddr changes only in v$session. It is no longer possible to join the 2 views.
 
As a result of the bug, 2 additional columns have been added to V$SESSION from 11g on:
V$SESSION
CREATOR_ADDR - state object address of creating process
CREATOR_SERIAL# - serial number of creating process
CREATOR_ADDR is the column that can be joined with the ADDR column in V$PROCESS to uniquely identify the killed process corresponding to the former session.
Following the previous example, this would identify the killed session:
 
11.1以前版本
select spid, program from v$process
    where program!= 'PSEUDO'
    and addr not in (select paddr from v$session)
    and addr not in (select paddr from v$bgprocess)
    and addr not in (select paddr from v$dispatcher)
    and addr not in (select paddr from v$shared_server);
11.1以后的版本
select spid from v$process where addr=(select creator_addr from v$session where sid=140);
 
reference
How To Find The Process Identifier (pid, spid) After The Corresponding Session Is Killed?(Doc ID 387077.1)
kill session时参考文章：http://www.eygle.com/faq/Kill_Session.htm
How to use historic ASH data to identify lock conflicts (文档 ID 1593227.1)
ALTER SYSTEM KILL Session Marked for Killed Forever(Doc ID 1020720.102)
 
如果session还是无法清理，手动触发pmon尝试
select pid,spid from v$process p,v$bgprocess b
where b.paddr=p.addr
and name='PMON';
 
oradebug wakeup  PID;   --手动触发pmon
oradebug wakeup  2;
 

# 异常处理2
 
行锁问题发生后应如何定位session_id，查询dba_hist_active_sess_history
 
set linesize 200 pagesize 200
col lock_duration format a40
col wait_event format a40
SELECT t.seq#,
       (MAX(t.sample_time) - MIN(t.sample_time)) "lock_duration",
       t.session_id "session_id_current",
       t.session_serial# "session_serial#_current",
       t.event "wait_event",
       t.blocking_session "blocking_id",
       t.blocking_session_serial# "blocking_SERIAL#"
  FROM dba_hist_active_sess_history t
 WHERE sample_time BETWEEN
       TO_DATE('2020-07-24 11:00:00', 'yyyy-mm-dd hh24:mi:ss') AND
       TO_DATE('2020-07-24 11:30:00', 'yyyy-mm-dd hh24:mi:ss')
   AND t.event LIKE '%TX%'
 GROUP BY t.session_id,
          t.session_serial#,
          t.blocking_session,
          t.blocking_session_serial#,
          t.event,
          t.seq#;
 
      SEQ# lock_duration                            session_id_current session_SERIAL#_current wait_event                                blocking_session_id blocking_sesion_SERIAL#
---------- ---------------------------------------- ------------------ ----------------------- ---------------------------------------- ------------------- -----------------------
      4825 +000000000 00:03:50.783                                  1019                          4861 enq: TX - row lock contention                                650                      47761
      6059 +000000000 00:00:00.000                                   815                         22769 enq: TX - row lock contention                                227                      31705
     28788 +000000000 00:00:00.000                                  1317                          9247 enq: TX - row lock contention
49 +000000000 00:00:00.000                                  1684                          4635 enq: TX - row lock contention
      9470 +000000000 00:06:31.477                                   624                         54075 enq: TX - row lock contention                                650                      47761
      8472 +000000000 00:00:00.000                                   227                         31705 enq: TX - row lock contention
      4825 +000000000 00:02:00.409                                  1019                          4861 enq: TX - row lock contention
 
 
查询具体的sql_id
set linesize 300 pagesize 200
col event for a40;
col p1text for a10;
col p2text for a20;
col p3text for a10;
SELECT session_id, sql_id, event, p1text, p1, p2text, p2, p3text, p3
  FROM dba_hist_active_sess_history
 WHERE sample_time BETWEEN
       TO_DATE('2019-04-08 8:00:00', 'yyyy-mm-dd hh24:mi:ss') AND
       TO_DATE('2019-04-08 9:00:00', 'yyyy-mm-dd hh24:mi:ss')
   AND session_id IN (733, 840)
   AND event LIKE '%TX%';
 
替换时间和ID
SESSION_ID SQL_ID         EVENT                                          P1TEXT             P1 P2TEXT                             P2 P3TEXT                   P3
---------- ------------- ---------------------------------------- ---------- ---------- -------------------- ---------- ---------- ----------
       624 gu8a90kru2h1p enq: TX - row lock contention                  name|mode  1415053318 usn<<16 | slot                 655364 sequence     11569750
       624 gu8a90kru2h1p enq: TX - row lock contention                  name|mode  1415053318 usn<<16 | slot                 655364 sequence     11569750
       624 gu8a90kru2h1p enq: TX - row lock contention                  name|mode  1415053318 usn<<16 | slot                 655364 sequence     11569750
 
enq: TX - row lock contention等待事件的三个参数如下
 
 * P1 = name|mode          <<<<<<< name一般都为0x5458代表TX锁; mode为4代表共享锁 mode为6代表排他锁
 * P2 = usn<<16 | slot      <<<<<<< v$transaction.xidusn  和 v$transaction.xidslot
 * P3 = sequence             <<<<<<< v$transaction.xidseq
不难发现P2和P3其实就是XID的组成部分
 
 
然后依据sql_id查询具体的sql,视图为v$sqltext（共享池中的）
可以通过查询V$EVENT_NAME知道每个等待事件对应的p1,p2,p3的含义
 
set long 99999
select sql_id,sql_text from v$sqltext where sql_id='aqvmv6prj443d';


dba_hist_sqltext。为历史sql。共享池中找不到，需要找历史sql
set long 99999
select sql_id,sql_text from dba_hist_sqltext where sql_id in('47ua00qcnyrsh','6dfcbm7b89gk6');

 
 分析sql，是因为行锁冲突还是业务逻辑

# 查询锁住对象的锁 


alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select t2.username,t2.sid,t2.serial#,t2.logon_time from v$locked_object t1,v$session t2 where t1.session_id=t2.sid;


