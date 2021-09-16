Rman monitor

--监视RMAN备份，run脚本不要拷贝，要手工输入，指定id将会话和通道关联起来
RMAN> run {
allocate channel c1 type disk;
set command id to 'rman';
backup database;
release channel c1;
}
--获取其会话标识符 (SID) 和操作系统进程标识符 (SPID)
SQL> select sid,spid,client_info from v$process p,v$session s where p.addr=s.paddr and client_info like '%id=rman%';
 
查看备份进度  
SELECT SID,
       SERIAL#,
       CONTEXT,
       SOFAR,
       TOTALWORK,
       ROUND(SOFAR / TOTALWORK * 100, 2) "%_COMPLETE"
  FROM V$SESSION_LONGOPS
WHERE OPNAME LIKE 'RMAN%'
   AND OPNAME NOT LIKE '%aggregate%'
   AND TOTALWORK != 0
   AND SOFAR <> TOTALWORK;
查看恢复的进度
SELECT sid, serial#, context,sofar,totalwork,round(sofar/totalwork*100,2)"% Complete" FROM v$session_longops WHERE opname LIKE 'RMAN:%'AND opname NOT LIKE 'RMAN: aggregate%';
 