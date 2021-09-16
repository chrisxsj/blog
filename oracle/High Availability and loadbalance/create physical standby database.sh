3.1 Preparing the Primary Database for Standby Database Creation

need force_logging!!!!!!!!!
SQL> select force_logging from v$database;

FOR
---
YES

need archivelog!!!!!!!!!
SQL> archive log list;
Database log mode	       Archive Mode
Automatic archival	       Enabled
Archive destination	       +DATA
Oldest online log sequence     3429
Next log sequence to archive   3431
Current log sequence	       3431
SQL> 

remote login password file!!!!!!!!!

DB_NAME=chicago
DB_UNIQUE_NAME=chicago
LOG_ARCHIVE_CONFIG='DG_CONFIG=(orcl,orcldg)'
CONTROL_FILES='/arch1/chicago/control1.ctl', '/arch2/chicago/control2.ctl'
LOG_ARCHIVE_DEST_1=
 'LOCATION=/arch1/chicago/ 
  VALID_FOR=(ALL_LOGFILES,ALL_ROLES)
  DB_UNIQUE_NAME=chicago'
LOG_ARCHIVE_DEST_2=
 'SERVICE=boston ASYNC
  VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) 
  DB_UNIQUE_NAME=boston'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE
REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE
LOG_ARCHIVE_FORMAT=%t_%s_%r.arc

Example 3-2 Primary Database: Standby Role Initialization Parameters
FAL_SERVER=boston
DB_FILE_NAME_CONVERT='boston','chicago'
LOG_FILE_NAME_CONVERT=
 '/arch1/boston/','/arch1/chicago/','/arch2/boston/','/arch2/chicago/' 
STANDBY_FILE_MANAGEMENT=AUTO
====================================
# primary role
alter system set LOG_ARCHIVE_CONFIG='DG_CONFIG=(orcl,orcldg,orclnew)';
alter system set log_archive_dest_3='SERVICE=orclnews ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) REOPEN=60 COMPRESSION=ENABLE DB_UNIQUE_NAME=orclnew';
alter system set LOG_ARCHIVE_DEST_STATE_3=ENABLE;

# standby role
# alter system set FAL_SERVER=orclnews;
# alter system set DB_FILE_NAME_CONVERT='+DATA/orclnew/datafile/','+DATA/orcl/datafile/' scope=spfile;
# alter system set LOG_FILE_NAME_CONVERT='+DATA/orclnew/onlinelog/','+DATA/orcl/onlinelog/' scope=spfile;
# alter system set STANDBY_FILE_MANAGEMENT=AUTO;




3.2 Step-by-Step Instructions for Creating a Physical Standby Database

backup

#!/bin/bash
DATE=`date +%Y-%m-%d`
source ~/.bash_profile
export ORACLE_SID=orcl1

rman log=/backup/dg/orclbak$DATE.log <<EOF
connect target /
run 
{ 
allocate channel c1 type disk;
allocate channel c2 type disk;
backup database format '/backup/dg/full%U';
backup archivelog all format '/backup/dg/archive%U';
backup current controlfile for standby format '/backup/dg/ctldg%U';
release channel c1;
release channel c2;
} 
EOF

parameter

DB_NAME=chicago
DB_UNIQUE_NAME=boston
LOG_ARCHIVE_CONFIG='DG_CONFIG=(chicago,boston)'
CONTROL_FILES='/arch1/boston/control1.ctl', '/arch2/boston/control2.ctl'
DB_FILE_NAME_CONVERT='chicago','boston'
LOG_FILE_NAME_CONVERT=
 '/arch1/chicago/','/arch1/boston/','/arch2/chicago/','/arch2/boston/'
LOG_ARCHIVE_FORMAT=log%t_%s_%r.arc
LOG_ARCHIVE_DEST_1=
 'LOCATION=/arch1/boston/
  VALID_FOR=(ALL_LOGFILES,ALL_ROLES) 
  DB_UNIQUE_NAME=boston'
LOG_ARCHIVE_DEST_2=
 'SERVICE=chicago ASYNC
  VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) 
  DB_UNIQUE_NAME=chicago'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE
REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE
STANDBY_FILE_MANAGEMENT=AUTO
FAL_SERVER=chicago
.
.
.

 
Ensure the COMPATIBLE initialization parameter is set to the same value on both the primary and standby databases. If the values differ, redo transport services may be unable to transmit redo data from the primary database to the standby databases

=============================================
DB_UNIQUE_NAME='orclnew'
LOG_ARCHIVE_CONFIG='DG_CONFIG=(orclnew,orcl)'
LOG_ARCHIVE_DEST_1='LOCATION=+FRA VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=orclnew'
DB_FILE_NAME_CONVERT='+DATA/orcl/datafile/','+DATA/orclnew/datafile/'
LOG_FILE_NAME_CONVERT='+DATA/orcl/onlinelog/','+DATA/orclnew/onlinelog/'
STANDBY_FILE_MANAGEMENT=AUTO
FAL_SERVER=orcls

#db_create_file_dest='/home/u01/app/oracle/oradata/'  --注意，此参数建议配置，最后要有"/"

3.2.4 Copy Files from the Primary System to the Standby System

3.2.5 Set Up the Environment to Support the Standby Database
user original listener
orclnews
orcls
SQL> startup nomount pfile='/home/oracle/initorcl20160629.ora'
SQL> create spfile='+data/orcl/spfileorcl.ora' from pfile='/home/oracle/initorcl20160629.ora';


3.2.6 Start the Physical Standby Database
restore
recover

restore standby controlfile from '/rmanbackup/dgbak/ctldg5dra9e72_1_1';
alter database mount;
RMAN> catalog start with '/rmanbackup/dgbak/';

searching for all files that match the pattern /rmanbackup/dgbak/

List of Files Unknown to the Database
=====================================
File Name: /rmanbackup/dgbak/archive1ur9aa2a_1_1
File Name: /rmanbackup/dgbak/full1mr9a3rg_1_1
File Name: /rmanbackup/dgbak/archive1qr9a8s7_1_1
File Name: /rmanbackup/dgbak/ctldg1vr9aaf1_1_1
File Name: /rmanbackup/dgbak/full1or9a8d1_1_1
File Name: /rmanbackup/dgbak/full1nr9a3rg_1_1
File Name: /rmanbackup/dgbak/archive1rr9a8s8_1_1
File Name: /rmanbackup/dgbak/full1pr9a8d3_1_1
File Name: /rmanbackup/dgbak/archive1tr9a9fm_1_1
File Name: /rmanbackup/dgbak/archive1sr9a9f6_1_1

Do you really want to catalog the above files (enter YES or NO)? yes
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: /rmanbackup/dgbak/archive1ur9aa2a_1_1
File Name: /rmanbackup/dgbak/full1mr9a3rg_1_1
File Name: /rmanbackup/dgbak/archive1qr9a8s7_1_1
File Name: /rmanbackup/dgbak/ctldg1vr9aaf1_1_1
File Name: /rmanbackup/dgbak/full1or9a8d1_1_1
File Name: /rmanbackup/dgbak/full1nr9a3rg_1_1
File Name: /rmanbackup/dgbak/archive1rr9a8s8_1_1
File Name: /rmanbackup/dgbak/full1pr9a8d3_1_1
File Name: /rmanbackup/dgbak/archive1tr9a9fm_1_1
File Name: /rmanbackup/dgbak/archive1sr9a9f6_1_1

RMAN> 

restore

#!/bin/bash
DATE=`date +%Y-%m-%d`
source ~/.bash_profile
export ORACLE_SID=JNRK

rman log=/rmanbackup/dgbak/orclrestore$DATE.log <<EOF
connect target /
run 
{ 
allocate channel c1 type disk;
allocate channel c2 type disk;
restore database;
switch datafile all;
release channel c1;
release channel c2;
} 
EOF


3.2.6 Start the Physical Standby Database

注意：如果主库已经提前创建好了standby redo log file，备库会根据LOG_FILE_NAME_CONVERT参数转换后自动创建与之对应的standby redo log file日志组。因此此步骤可省略。

如有主库未创建standby redo logfile，则备库必须手工创建日志文件组

公式如下：

如果主库是单实例数据库：Standby Redo Log组数=主库日志组总数+1

如果主库是RAC数据库：StandbyRedo Log组数=每个thread都要+1

# primary and standby role
alter database drop standby logfile group 7;
alter database drop standby logfile group 8;
alter database drop standby logfile group 9;
alter database drop standby logfile group 10;
alter database drop standby logfile group 11;
alter database drop standby logfile group 12;
alter database drop standby logfile group 13;
alter database drop standby logfile group 14;

alter database add standby logfile thread 1 group 11 '+DATA' size 512M;
alter database add standby logfile thread 2 group 12 '+DATA' size 512M;
alter database add standby logfile thread 1 group 13 '+DATA' size 512M;
alter database add standby logfile thread 2 group 14 '+DATA' size 512M;
alter database add standby logfile thread 1 group 15 '+DATA' size 512M;
alter database add standby logfile thread 2 group 16 '+DATA' size 512M;
alter database add standby logfile thread 1 group 17 '+DATA' size 512M;
alter database add standby logfile thread 2 group 18 '+DATA' size 512M;

asm> alter diskgroup data drop file '+data/orclnew/onlinelogstandby_5';
 
alter system set LOG_ARCHIVE_DEST_1='LOCATION=+FRA VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=orclnew';

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;   --没有recover步骤用不到备份的归档日志

临时文件在第一次open时会自动创建
Dictionary check complete
Re-creating tempfile /u01/app/oracle/oradata/gksdnew/temp.256.916675171
Database Characterset is ZHS16GBK
No Resource Manager plan active

=================================
SELECT SEQUENCE#, FIRST_TIME, NEXT_TIME FROM V$ARCHIVED_LOG ORDER BY SEQUENCE#;

 SELECT SEQUENCE#,APPLIED FROM V$ARCHIVED_LOG ORDER BY SEQUENCE#;
 
 
 ?????????????????ip 212.7.8.4??????????????????
 
=============================================================
#standby role transition config!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
create pfile='/home/oracle/initorcl20160707.ora' from spfile;
 
# standby role
alter system set FAL_SERVER=orcldgs;
alter system set DB_FILE_NAME_CONVERT='/home/u01/app/oracle/oradata/','+INDEX1/orcl/datafile/' scope=spfile;
alter system set LOG_FILE_NAME_CONVERT='/home/u01/app/oracle/oradata/','+DATA1/orcl/onlinelog/' scope=spfile;
alter system set STANDBY_FILE_MANAGEMENT=AUTO;
db_create_file_dest=/home/u01/app/oracle/oradata/
 
# primary role
alter system set LOG_ARCHIVE_CONFIG='DG_CONFIG=(ORCL,ORCLDG)';
alter system set log_archive_dest_2='SERVICE=orcldgs ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) REOPEN=60 COMPRESSION=ENABLE DB_UNIQUE_NAME=ORCLDG';
alter system set LOG_ARCHIVE_DEST_STATE_2=ENABLE;



srvctl add database -d orclnew -o /u02/app/oracle/product/11.2.0/db_home
srvctl add instance -d orclnew -i  orcl1 -n his1
srvctl add instance -d orclnew -i  orcl2 -n his2


srvctl modify database -d orclnew -n orcl -a 'DATA,FRA';

==========================================================
orapw file

network config   --11g使用scanip
tnsping orcls
tnsping orclnews


当数据库nomount,mount或者restricted时，动态监听显示状态为BLOCKED时，客户端可通过配置UR=A进行连接。
SQL> startup nomount;
SQL> ALTER SYSTEM REGISTER;

Services Summary...
Service "ora11gr2" has 1 instance(s).
  Instance "ora11gr2", status BLOCKED, has 1 handler(s) for this service...
The command completed successfully

bbed_ur =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.137.154)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ora11gr2)
	  (UR=A)
    )
  )


bbed =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.137.154)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ora11gr2)
    )
  )


==========================================================

查看数据库状态
SELECT open_mode FROM V$DATABASE;

1 查看日志传输和应用情况
set pagesize 200 linesize 200
select process,status,group#,thread#,sequence#,delay_mins from v$managed_standby;

SQL> set pagesize 200 linesize 200
select process,status,group#,thread#,sequence#,delay_mins from v$managed_standby;SQL> 

PROCESS   STATUS       GROUP#                              THREAD#  SEQUENCE# DELAY_MINS
--------- ------------ ---------------------------------------- ---------- ---------- ----------
ARCH    CONNECTED    N/A                                         0          0          0
ARCH    CONNECTED    N/A                                         0          0          0
ARCH    CONNECTED    N/A                                         0          0          0
ARCH    CLOSING      26                                  2      14925          0
ARCH    CLOSING      20                                  1      19525          0
ARCH    CONNECTED    N/A                                         0          0          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           17                                        2      14926          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           11                                        1      19526          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           N/A                                       0          0          0
RFS     IDLE           N/A                                       0          0          0
MRP0    APPLYING_LOG N/A                                         1      19475          0

19 rows selected.

SQL> 


2 查看dataguard日志

select * from v$dataguard_status;

Log Apply Services       Informational        0   239          0 NO  27-NOV-16
Media Recovery Log /arch/2_14892_916675163.dbf

Log Apply Services       Informational        0   240          0 NO  27-NOV-16
Media Recovery Log /arch/1_19473_916675163.dbf

Log Apply Services       Informational        0   241          0 NO  27-NOV-16
Media Recovery Log /arch/1_19474_916675163.dbf





3 估算延迟时间和实时查询环境
SQL> COLUMN NAME FORMAT A24
COLUMN VALUE FORMAT A16     
COLUMN DATUM_TIME FORMAT A24
SELECT NAME, VALUE, DATUM_TIME FROM V$DATAGUARD_STATS;SQL> SQL> SQL> 

NAME             VALUE            DATUM_TIME
------------------------ ---------------- ------------------------
transport lag            +00 00:00:00     11/27/2016 10:27:04
apply lag                +00 00:00:00     11/27/2016 10:27:04
apply finish time        +00 00:00:00.000
estimated startup time   34

SQL> 




==========================================================

[grid@his1 ~]$ crsctl status res -t
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.FRA.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.LISTENER.lsnr
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.OCR.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.asm
               ONLINE  ONLINE       his1                     Started             
               ONLINE  ONLINE       his2                     Started             
ora.gsd
               OFFLINE OFFLINE      his1                                         
               OFFLINE OFFLINE      his2                                         
ora.net1.network
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.ons
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.registry.acfs
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       his1                                         
ora.cvu
      1        ONLINE  ONLINE       his1                                         
ora.his1.vip
      1        ONLINE  ONLINE       his1                                         
ora.his2.vip
      1        ONLINE  ONLINE       his2                                         
ora.oc4j
      1        ONLINE  ONLINE       his1                                         
ora.orclnew.db
      1        OFFLINE OFFLINE                                                   
ora.scan1.vip
      1        ONLINE  ONLINE       his1                                         
[grid@his1 ~]$ 
====================================================
[grid@his1 ~]$ crsctl status res -t
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.FRA.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.LISTENER.lsnr
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.OCR.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.asm
               ONLINE  ONLINE       his1                     Started             
               ONLINE  ONLINE       his2                     Started             
ora.gsd
               OFFLINE OFFLINE      his1                                         
               OFFLINE OFFLINE      his2                                         
ora.net1.network
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.ons
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.registry.acfs
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       his1                                         
ora.cvu
      1        ONLINE  ONLINE       his1                                         
ora.his1.vip
      1        ONLINE  ONLINE       his1                                         
ora.his2.vip
      1        ONLINE  ONLINE       his2                                         
ora.oc4j
      1        ONLINE  ONLINE       his1                                         
ora.orclnew.db
      1        OFFLINE OFFLINE                                                   
      2        OFFLINE OFFLINE                                                   
ora.scan1.vip
      1        ONLINE  ONLINE       his1                                         
[grid@his1 ~]$ 
