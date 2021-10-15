# dataguard_Role_Transitions

**作者**

Chrisx

**日期**

2021-10-15

**内容**

dataguard Role Transitions

switchover（转换）

允许主数据库与其备用数据库之一切换角色。在切换过程中没有数据丢失。切换后，每个数据库将继续使用其新角色参与数据保护配置。

failover（故障转移）

将备用数据库更改为主角色以响应主数据库故障。如果主数据库在发生故障之前未在最大保护模式或最大可用性模式下运行，则可能会发生某些数据丢失。如果在主数据库上启用了Flashback数据库，则在更正故障原因后，可以将其恢复为新主数据库的备用数据库。

ref [Role Transitions](https://docs.oracle.com/cd/E11882_01/server.112/e41134/role_management.htm#SBYDB00600) 

----

[toc]

## Preparing for a Role Transition

1. dg参数均配置正确

primary，standby确认参数

```sql
show parameter DB_FILE_NAME_CONVERT
show parameter LOG_FILE_NAME_CONVERT
show parameter fal_server
show parameter compatible

```

2. 确认没有redo传输错误和redo gaps

```sql
SQL> SELECT STATUS, GAP_STATUS FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID = 2;
 
STATUS GAP_STATUS
--------- ------------------------
VALID NO GAP

SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2;
```

对每一个DEST_ID查看，如果有gaps，必须先解决

3. 确定一个没有延迟的备库

```sql
COLUMN NAME FORMAT A24
COLUMN VALUE FORMAT A16     
COLUMN DATUM_TIME FORMAT A24
SELECT NAME, VALUE, DATUM_TIME FROM V$DATAGUARD_STATS;

```

4. 其他检查项

```sh

1. 检查主库和备库的临时表空间和所有的数据文件是否为ONLINE状态

SELECT TMP.NAME FILENAME, BYTES, TS.NAME TABLESPACE FROM V$TEMPFILE TMP, V$TABLESPACE TS WHERE TMP.TS#=TS.TS#;
SELECT NAME FROM V$DATAFILE WHERE STATUS='OFFLINE';

2. 清除可能受阻的参数与jobs

主端查看当前DBMS_JOB 的状态
SELECT * FROM DBA_JOBS_RUNNING; 

如果有正在运行的job则不建议切换，最好等job运行完，或者停掉job（详细参考oracle Job操作手册）。 
HOW PARAMETER job_queue_processes
ALTER SYSTEM SET job_queue_processes=0 SCOPE=BOTH SID='*'; 


```

## Performing a Switchover to a Physical Standby Database

Step 1   Verify that the primary database can be switched to the standby role.

```sql
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS 
 ----------------- 
 TO STANDBY 
 1 row selected 

```

值为TO STANDBY或SESSIONS ACTIVE表示主数据库可以切换到备用角色。如果这两个值均未返回，则无法进行切换，因为重做传输配置错误或运行不正常。

<!--
LOG SWITCH GAP
shutown immediate
startup mount
ALTER SYSTEM FLUSH REDO TO 'orcldg';
alter database open;
-->

Step 2   Initiate the switchover on the primary database.

```sql
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

```

Step 3   Shut down and then mount the former primary database.

```sql
SQL> SHUTDOWN ABORT;
SQL> STARTUP MOUNT;

```

Step 4   Verify that the switchover target is ready to be switched to the primary role.

```sql
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS 
----------------- 
TO_PRIMARY 
1 row selected

```

Step 5   Switch the target physical standby database role to the primary role.

```sql
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;

```

Step 6   Open the new primary database.

```sql
SQL> ALTER DATABASE OPEN;

```

Step 7   Start Redo Apply on the new physical standby database.

```sql
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

```

Step 8   Restart Redo Apply if it has stopped at any of the other physical standby databases in your Data Guard configuration.

```sql
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

```

## Performing a Failover to a Physical Standby Database

ref [Performing a Failover to a Physical Standby Database](https://docs.oracle.com/cd/E11882_01/server.112/e41134/role_management.htm#SBYDB00625)

## 收尾

```sql
SQL> ALTER SYSTEM SET job_queue_processes=<value saved> scope=both sid=’*’
SQL> EXECUTE DBMS_SCHEDULER.ENABLE(<for each job name captured>);
SQL> DROP RESTORE POINT SWITCHOVER_START_GRP;

```

## Using Flashback Database After a Role Transition

角色转换后，可以选择使用FLASHBACK数据库命令将数据库还原到角色转换之前的时间点或系统更改号（SCN）。如果回闪主数据库，则必须将其所有备用数据库回闪到相同（或更早）的SCN或时间。以这种方式回闪主数据库或备用数据库时，您不必知道过去的切换。如果SCN/时间在任何过去的切换之前，Oracle可以自动闪回过去的切换。

注意：在角色转换发生之前，必须在数据库上启用闪回数据库。

### 启用闪回数据库

```sql
shutdown immediate
startup mount
alter database flashback on;
alter database open;
select flashback_on from v$database;

```

### 配置还原点

```sh
创建可靠还原点（可选）如果switch切换后有问题可以通过还原点回退数据库。主备库都执行
show parameter DB_RECOVERY

备库创建还原点
RECOVER MANAGED STANDBY DATABASE CANCEL;
CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;
RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;

主库同样检查是否开启闪回，并创建还原点
CREATE RESTORE POINT SWITCHOVER_START_GRP GUARANTEE FLASHBACK DATABASE;

查看还原点
col NAME format a30
col time format a40
set line 300
select NAME,SCN,TIME from v$restore_point;


注意如果创建还原点，在switch 切换完毕后一定要删除主备节点上还原点，否则还原点的文件会不断增长直到磁盘爆满。
删除方法：
drop restore point SWITCHOVER_START_GRP;
```