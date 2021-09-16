Oracle Restore database 异机恢复

异机恢复 》RAC-单机

兼容性参考mos
RMAN DUPLICATE/RESTORE/RECOVER Mixed Platform Support (文档 ID 1079563.1)
 异机恢复
通过异机恢复，测试备份可用性
 
恢复测试环境要求：
安装相同版本的操作系统
安装相同版本的oracle软件


[oracle@syjdb3 backup]$ ls -atl
total 1475212
-rw-------   1 oracle oinstall        276 May 30 16:58 nohup.out
-rw-r-----   1 oracle asmadmin      98304 May 30 16:58 spfile_inc1_0ht4721l_1_1
drwxrwxr-x   3 oracle oinstall       4096 May 30 16:58 ./
-rw-r-----   1 oracle asmadmin   18546688 May 30 16:58 ctl_inc1_0gt4721j_1_1
-rw-r-----   1 oracle asmadmin   82067968 May 30 16:58 arch_inc1_0ft4721h_1_1
-rw-r-----   1 oracle asmadmin   18579456 May 30 16:58 full_inc1_0et47215_1_1
-rw-r-----   1 oracle asmadmin   22175744 May 30 16:58 full_inc1_0dt4720m_1_1
drwxr-xr-x   2 oracle oinstall       4096 May 30 16:08 log/
-rw-r-----   1 oracle asmadmin      98304 May 30 16:07 spfile_inc0_07t46v2k_1_1
-rw-r-----   1 oracle asmadmin   18546688 May 30 16:07 ctl_inc0_06t46v2i_1_1
-rw-r-----   1 oracle asmadmin  120906752 May 30 16:07 arch_inc0_05t46v2g_1_1
-rw-r-----   1 oracle asmadmin 1229561856 May 30 16:07 full_inc0_03t46v1k_1_1
-rwxrwxr-x   1 oracle oinstall        662 May 30 16:07 bak_rman1.sh*
-rwxrwxr-x   1 oracle oinstall        818 May 30 16:06 bak_rman0.sh*
dr-xr-xr-x. 29 root   root           4096 May 30 15:56 ../
[oracle@syjdb3 backup]$
 
将全量备份和增量备份拷贝到测试环境
scp *inc* 10.100.9.113:/home/bak
将最新的spfile，controlfile，archivelog备份拷贝到测试环境
spfile_inc1_0mt47ust_1_1
ctl_inc1_0lt47usr_1_1
 
将最新产生的归档拷贝到测试环境
根据rman日志，已知备份的归档截止到
channel d1: specifying archived log(s) in backup set
input archived log thread=1 sequence=474 RECID=900 STAMP=965527494
input archived log thread=1 sequence=475 RECID=903 STAMP=965527499
input archived log thread=2 sequence=432 RECID=902 STAMP=965527498
channel d1: starting piece 1 at 2018-01-16 02:34:58
 
当前日志情况
ASMCMD> ls
thread_1_seq_474.294.965527493
thread_1_seq_475.297.965527499
thread_1_seq_476.298.965552097
thread_2_seq_431.295.965527495
thread_2_seq_432.296.965527499
 
ASMCMD> cp thread_1_seq_476.298.965552097 to '/tmp/thread_1_seq_476.298.965552097';
 
scp 10.100.9.112:/tmp/thread_1_seq_476.298.965552097 .
 
 
1生成pfile参数文件，修改参数文件
strings spfile_inc0_07t46v2k_1_1 > init.ora
 
参数修改
*.audit_file_dest='/home/u01/app/oracle/admin/test/adump'
*.control_files='/home/oradata/current.ctl'
*.db_create_file_dest='/home/oradata'
*.diagnostic_dest='/home/u01/app/oracle'
*.log_archive_dest_1='LOCATION=/home/arch'
 
mkdir /home/arch
chown oracle:oinstall /home/arch
chmod 775 /home/arch
 
mkdir -p /home/u01/app/oracle/admin/test/adump
 
2 启动实例，生成新的spfile参数文件
export ORACLE_SID=test
startup nomount pfile=
create spfile from pfile='/home/bak/initORCL20180116.ora';
shutdown abort
startup nomount
 
3 将备份移至目标端
还原控制文件
restore controlfile from '/home/bak/ctl_inc1_0gt4721j_1_1';
 
4 注册并还原数据文件
catalog start with '/home/bak/';
 
如果配置了OMF，自动创建文件及名字。使用如下脚本
#!/bin/bash
DATE=`date +%Y-%m-%d`
source ~/.bash_profile
export ORACLE_SID=ORCL
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
rman log=/home/bak/rmanrestore$DATE.log <<EOF
connect target /
run{
restore database;
}
EOF
 
如果没有使用OMF，需要set newname手动指定名字。使用如下脚本
#!/bin/bash
DATE=`date +%Y-%m-%d`
source ~/.bash_profile
export ORACLE_SID=ORCL
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
rman log=/dmp/bak/rmanrestore$DATE.log append <<EOF
connect target /
run{
set newname for datafile  4 to '/u01/app/oracle/oradata/gisdb/users01.dbf';
set newname for datafile  3 to '/u01/app/oracle/oradata/gisdb/sysaux01.dbf';
set newname for datafile  2 to '/u01/app/oracle/oradata/gisdb/undotbs01.dbf';
set newname for datafile  1 to '/u01/app/oracle/oradata/gisdb/system01.dbf';
set newname for datafile  5 to '/u01/app/oracle/oradata/gisdb/sde01.dbf';
set newname for datafile  6 to '/u01/app/oracle/oradata/gisdb/GIS371500000000.dbf';
set newname for datafile  7 to '/u01/app/oracle/oradata/gisdb/sqjwdata01.dbf';
set newname for datafile  8 to '/u01/app/oracle/oradata/gisdb/sqjwdata02.dbf';
set newname for datafile  9 to '/u01/app/oracle/oradata/gisdb/sqjwdata03.dbf';
restore database;
switch datafile all;
}
EOF
 
 
5 恢复应用日志，会应用增量备份
 
[oracle@bak2 bak]$ cat recover.sh
#!/bin/bash
DATE=`date +%Y-%m-%d-%H`
source ~/.bash_profile
export ORACLE_SID=ORCL
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
rman log=/home/bak/rmanrecover$DATE.log <<EOF
connect target /
run{
recover database;
}
EOF

7 一致性检查
 
set linesize 200 pagesize 200
alter session set NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss';
select fuzzy, status, error, recover, checkpoint_change#, checkpoint_time, count(*) from v$datafile_header group by fuzzy, status, error, recover, checkpoint_change#, checkpoint_time;
 
select status, enabled, count(*) from v$datafile group by status, enabled;
 
 
SQL> set linesize 200 pagesize 200
alter session set NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss';
select fuzzy, status, error, recover, checkpoint_change#, checkpoint_time, count(*) from v$datafile_header group by fuzzy, status, error, recover, checkpoint_change#, checkpoint_time;SQL>
Session altered.
 
SQL>
 
FUZ STATUS  ERROR                                   REC CHECKPOINT_CHANGE# CHECKPOINT_TIME        COUNT(*)
--- ------- ----------------------------------------------------------------- --- ------------------ ------------------- ----------
NO  ONLINE                                           1.4672E+13 2018-01-16 02:04:58     13
 
SQL>
SQL> select status, enabled, count(*) from v$datafile group by status, enabled;
 
STATUS     ENABLED      COUNT(*)
------- ---------- ----------
ONLINE     READ WRITE        12
SYSTEM     READ WRITE         1
 
8 resetlogs打开数据库
 
alter database open resetlogs;
使用了OMF 后 alert log自动重建在线日志和临时文件
Additional information: 3
Errors in file /home/u01/app/oracle/diag/rdbms/orcl/ORCL/trace/ORCL_dbw0_7855.trc:
ORA-01186: file 205 failed verification tests
ORA-01157: cannot identify/lock data file 205 - see DBWR trace file
ORA-01110: data file 205: '/home/oradata/spfxtemp01.dbf'
File 205 not verified due to error ORA-01157
Dictionary check complete
Verifying file header compatibility for 11g tablespace encryption..
Verifying 11g file header compatibility for tablespace encryption completed
SMON: enabling tx recovery
Re-creating tempfile /home/oradata/temp01.dbf
Redo thread 2 internally disabled at seq 1 (CKPT)
ARC2: Archiving disabled thread 2 sequence 1
Archived Log entry 909 added for thread 2 sequence 1 ID 0x0 dest 1:
ARC3: Archival started
ARC0: STARTING ARCH PROCESSES COMPLETE
Re-creating tempfile /home/oradata/sdzf_el_temp01.dbf
Re-creating tempfile /home/oradata/jianguan01.dbf
Re-creating tempfile /home/oradata/tmobileserver_temp01.dbf
Re-creating tempfile /home/oradata/spfxtemp01.dbf
 
9
如果没有使用OMF，在打开数据库时可能出现错误， 原因是在打开数据库时， ORACLE 会根据控制文件来创建，这里控制文件记录的位置，目标机上并没有
 
修改相关文件到正确的位置，因为控制文件记录的是源库的位置，源库如果为rac，则相关文件路径需要从ASM磁盘组修改到本地磁盘上去
 
修改日志文件路径
 
new_dest=/home/oradata
sqlplus / as sysdba > logfile.log<<EOF
set linesize 180 pagesize 100
select 'alter database rename file '''||member||''' to ''$new_dest/redoXXX.log'';' from v\$logfile;
EOF
 
alter database rename file '+DATA1/orcl/onlinelog/group_1.257.926279655' to '/home/oradata/redo101.log';
alter database rename file '+FRA/orcl/onlinelog/group_1.257.926279657' to '/home/oradata/redo102.log';
alter database rename file '+DATA1/orcl/onlinelog/group_2.258.926279659' to '/home/oradata/redo201.log';
alter database rename file '+FRA/orcl/onlinelog/group_2.258.926279661' to '/home/oradata/redo202.log';
alter database rename file '+DATA1/orcl/onlinelog/group_5.259.926279663' to '/home/oradata/redo501.log';
alter database rename file '+FRA/orcl/onlinelog/group_5.259.926279663' to '/home/oradata/redo502.log';
alter database rename file '+DATA1/orcl/onlinelog/group_3.266.926281331' to '/home/oradata/redo301.log';
alter database rename file '+FRA/orcl/onlinelog/group_3.260.926281333' to '/home/oradata/redo302.log';
alter database rename file '+DATA1/orcl/onlinelog/group_4.267.926281335' to '/home/oradata/redo401.log';
alter database rename file '+FRA/orcl/onlinelog/group_4.261.926281337' to '/home/oradata/redo402.log';
alter database rename file '+DATA1/orcl/onlinelog/group_6.268.926281337' to '/home/oradata/redo601.log';
alter database rename file '+FRA/orcl/onlinelog/group_6.262.926281339' to '/home/oradata/redo602.log';
 
修改临时文件路径
new_dest=/home/oradata
sqlplus / as sysdba > tempfile.log<<EOF
set linesize 180 pagesize 100
select 'alter database rename file '''||name||''' to ''$new_dest/tempXXX.dbf'';' from v\$tempfile;
EOF
 
 
alter database rename file '+DATA1/orcl/tempfile/temp.263.926279669' to '/home/oradata/temp01.dbf';
alter database rename file '+DATA1/orcl/tempfile/sdzf_el_temp.274.929877575' to '/home/oradata/sdzf_el_temp01.dbf';
alter database rename file '+DATA1/orcl/tempfile/jianguan.276.931101419' to '/home/oradata/jianguan01.dbf';
alter database rename file '+DATA1/orcl/tempfile/mobileserver_temp.279.941713709' to '/home/oradata/tmobileserver_temp01.dbf';
alter database rename file '+DATA1/orcl/tempfile/spfxtemp.282.962635761' to '/home/oradata/spfxtemp01.dbf';
 
10 其他
修改归档日志路径
alter system set log_archive_dest_1='location=/oradata/arch';
 
注意：如果是rac恢复单机，需要禁用thread 2
alter database disable thread 2;
注意2：如果rac恢复单机，日志文件在+ASM磁盘组中，无法重命名日志文件等错误，此时可以选择重建控制文件，修改重建脚本中日志文件的路径
resetlogs 
CREATE CONTROLFILE REUSE DATABASE "ORCL" RESETLOGS  ARCHIVELOG
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  GROUP 1 '/u02/app/oracle/oradata/redo01.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 2 '/u02/app/oracle/oradata/redo02.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 3 '/u02/app/oracle/oradata/redo03.log'  SIZE 50M BLOCKSIZE 512
DATAFILE
  '/u02/app/oracle/oradata/system.256.867775087',
  '/u02/app/oracle/oradata/sysaux.257.867775089',
  '/u02/app/oracle/oradata/undotbs1.258.867775089',
  '/u02/app/oracle/oradata/users.259.867775091',
  '/u02/app/oracle/oradata/example.265.867775185'
CHARACTER SET ZHS16GBK
;

######################
oracle用户注册相关服务到集群
$ srvctl add database -d BOSTON –o /opt/oracle/product/10g_db_rac
$ srvctl add instance -d BOSTON -i BOSTON1 -n boston_host1
$ srvctl add instance -d BOSTON -i BOSTON2 -n boston_host2