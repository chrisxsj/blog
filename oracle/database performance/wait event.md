1 ps   查找出os pid
2 v$process: spid=os pid》pid，username，terminal，program
3 v$session:  v$process.addr=v$session.paddr >sid,serial#,machin,logon_time
4 v$sql: v$process.sql_id=v$sql.sql_id > sql_text
5 v$session_wait wait_class<>'Idle'
6  v$event_name

定时查看v$session_wait等待事件
SQL> select event,count(*) from v$session_wait where wait_class<>'Idle' group by event;
v$session

--检查IO等待
select 'kill -9 '||c.SPID,c.SPID,b.SQL_TEXT,b.SQL_FULLTEXT,a.USERNAME,a.SQL_ID,
        a.logon_time,a.EVENT,a.STATUS,a.PROGRAM,a.CLIENT_INFO,a.MACHINE,a.PADDR
   from v$session a, v$sql b, v$process c
 where a.sql_id = b.sql_id
    and a.PADDR = c.ADDR
    and a.wait_class = 'User I/O'
order by a.LOGON_TIME, a.EVENT

