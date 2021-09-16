您好，

谢谢您的更新，

10046主要用于SQL性能的分析和诊断，详细抓取了SQL执行的每步消耗的时间和信息。
而hanganalzye主要用于数据库hang 和某个session被阻塞的分析，主要体现chain链。

具体，请您参考：
EVENT: 10046 "enable SQL statement tracing (including binds/waits)" ( Doc ID 21154.1 )
EVENT: HANGANALYZE - Reference Note ( Doc ID 130874.1 )

当当前问题的SQL的10046收集到SR，我继续帮您查看在哪个row source operation消耗的时间，问题点。谢谢




During the RAC database hang, 
database hang analyze


1. Please run the following on one instance as sysdba: 
$sqlplus / as sysdba <==When you can login to DB
~or~
$sqlplus -prelim / as sysdba<==When you can’t login to DB when DB is hanging




1. These steps could help you to find the 10046 trace more easily:
Open sqlplus window A:
SQL> connect / as sysdba
SQL>oradebug setmypid
SQL>oradebug unlimit
SQL>oradebug event 10046 trace name context forever, level 12
SELECT 'D,',t.NAME,',',d.STATUS,',',d.ENABLED,',',TO_CHAR(d.BYTES),',',TO_CHAR
(d.BYTES - NVL(ff.fbytes,0)),',',TRIM(' ' FROM d.NAME),',',TRIM(' ' FROM d.FILE#) FROM
v$datafile d, v$tablespace t, (SELECT f.file_id file_id, SUM(f.bytes) fbytes FROM
DBA_FREE_SPACE f GROUP BY f.file_id) ff WHERE d.TS#=t.TS# AND ff.file_id (+)= d.FILE#
ORDER BY t.NAME;



call     count       cpu    elapsed       disk      query    current        rows
------- ------  -------- ---------- ---------- ---------- ----------  ----------
Parse        1      0.00       0.00          0          0          0           0
Execute      1      0.00       0.00          0          0          0           0
Fetch        2      0.00       0.00          0          5          0          99
------- ------  -------- ---------- ---------- ---------- ----------  ----------
total        4      0.00       0.00          0          5          0          99
2014/12/12 11:41:00
不吃鱼的猫
execute阶段确定了要取哪些数据。 fetch就是从buffer或者磁盘(direct path)把数据放到pga
不吃鱼的猫
pga相当于socket的buffer








==>Wait for some minutes, 


2 hang analyze
Dear customer,

As discussed please collect the below information from one of nodes.

1. Please run the following on one instance as sysdba:
 $sqlplus / as sysdba  
 ~or~
 $sqlplus -prelim / as sysdba<==When you can’t login to DB when DB is hanging

 SQL>oradebug setmypid
 SQL>oradebug unlimit
 SQL>oradebug -g all hanganalyze 3
 Wait for 30 seconds
 SQL>oradebug -g all hanganalyze 3


 To get systemstate dumps, please run the following command on only one instance:

 SQL> conn / as sysdba
 SQL> oradebug setmypid
 SQL> oradebug unlimit
 SQL> oradebug -G all dump systemstate 267

 <...wait 30 seconds, gather a second systemstate dump...>

 SQL> oradebug setmypid
 SQL> oradebug unlimit;
 SQL> oradebug -G all dump systemstate 267
 SQL> oradebug tracefile_name
SQL>exit


The generated trace files will be in the diag trace file in BDUMP for each instance, please upload these files.
SQL> show parameter background_dump_dest


NAME TYPE VALUE
------------------------------------ ----------- ------------------------------
background_dump_dest string /u01/app/oracle/admin/ONEPIECE/bdump <=====This folder


cd /u01/app/oracle/admin/ONEPIECE/bdump
ls -l *diag*


-rw-rw---- 1 oracle oinstall 1012 Dec 17 19:19 onepiece2_diag_875.trc
-rw-r----- 1 oracle oinstall 910 Dec 19 18:49 onepiece2_diag_2523.trc


Please zip and upload the last trace file.


一般只需要hanganalyze就可以

3.Please get back to window A and press CTRL-C in the first window A if the SQL take too long:
CTRL-C
select * from dual;

SQL>oradebug event 10046 trace name context off;
SQL>oradebug tracefile_name ==>This is the generated trace file name

=============================================
不同 level 转储的内容详细程度不同，此命令的可用级别主要有 1～10 级，其中各级别的
 含义如下。
 ¡  Level 1：仅包含 Buffer Headers 信息。
 ¡  Level 2：包含 Buffer Headers 和 Buffer 概要信息转储。
 ¡  Level 3：包含 Buffer Headers 和完整 Buffer 内容转储。
 ¡  Level 4：Level 1 + Latch 转储 + LRU 队列。
 ¡  Level 5：Level 4 + Buffer 概要信息转储。
 ¡  Level 6 和 Level 7：Level 4 + 完整的 Buffer 内容转储。
 ¡  Level 8：Level 4 + 显示 users/waiters 信息。
 ¡  Level 9：Level 5 + 显示 users/waiters 信息。
 ¡  Level 10：Level 6 + 显示 users/waiters 信息。



