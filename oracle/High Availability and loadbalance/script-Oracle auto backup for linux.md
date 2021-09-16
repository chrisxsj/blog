Oracle auto backup for linux

script

[oracle@dg1 script]$ cat rmanlevel0.sh
#!/bin/bash
DATE=`date +%Y-%m-%d-%H`
. ~/.bash_profile
export ORACLE_SID=ORCL1
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
rman log=/opt/script/log/bak_rman0$DATE.log <<EOF
connect target /
run{
CONFIGURE RETENTION POLICY TO REDUNDANCY 1;
CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 2 TIMES TO DEVICE TYPE disk;
}
run{
allocate channel d1 type disk;
allocate channel d2 type disk;
backup incremental level 0 database format '/nfs/bak/full_inc0_%U';
sql 'alter system archive log current';
backup archivelog all format '/nfs/bak/arch_inc0_%U' keep until time 'sysdate+10';
backup current controlfile format '/nfs/bak/ctl_inc0_%U';
backup spfile format '/nfs/bak/spfile_inc0_%U';
release channel d1;
release channel d2;
}
run
{
report obsolete redundancy 1;
report obsolete redundancy 1 device type disk;
delete noprompt obsolete redundancy 1 device type disk;
crosscheck backup device type disk;
delete noprompt expired backup device type disk;
}
run
{
#sql 'select * from v$recover_file';
crosscheck archivelog all;
delete noprompt expired archivelog all;
crosscheck copy device type disk;
delete noprompt expired copy device type disk;
delete backup completed before 'sysdate-1/24' device type disk;
}
list backup of database summary completed before 'sysdate-1/24' device type disk;
list backup of database completed before 'sysdate-1/24' device type disk;
EOF
 
[oracle@dg1 script]$ cat rmanlevel1.sh
#!/bin/bash
DATE=`date +%Y-%m-%d`
. ~/.bash_profile
rman log=/u01/app/oracle/script/log/rmanlevel1.log append <<EOF
connect target sys/jniywk_0912@standby
run{
allocate channel d1 type disk;
allocate channel d2 type disk;
backup incremental level 1 format '/ywkrman/ywk_inc1_%U' as backupset  database include current controlfile;
# backup incremental level 1 cumulative database;
host "/u01/app/oracle/script/logswitch.sh";
backup format '/ywkrman/arch_inc1_%U' archivelog all delete input;
release channel d1;
release channel d2;
}
EOF
 
建议：rman log=...    --不要加引号，否则变量$DATE不生效!
建议：添加tag
注意：默认冗余度为1，可手动指定其他冗余度，如删除超过冗余度 3 之前的备份
Report obsolete redundancy 3;
Delete noprompt obsolete redundancy 3 device type disk;
注意：依据oracle 分析，备份信息保留在控制文件中可被重用的位置，最小的保留日志为 7天，可能被覆盖。导致备份失效问题。可以修改控制文件保留时间
CONTROL_FILE_RECORD_KEEP_TIME = retention period + level 0 backup interval + 1
注意：
sql 'alter system archive log current';  ---为了保证备份的完整性和一致性（为了能够恢复到备份结束的时间点） ，需要备份备份期间产生的redo（而备份期间产生的redo还在online redo logfile中，数据库又不会备份redo） 所以需要归档操作！
Backing Up Logs with BACKUP ... PLUS ARCHIVELOG
You can add archived redo logs to a backup of other files by using the BACKUP ...
PLUS ARCHIVELOG clause.  Adding BACKUP ... PLUS ARCHIVELOG causes RMAN to
do the following:
 1. Runs the ALTER SYSTEM ARCHIVE LOG CURRENT command.
 2. Runs BACKUP ARCHIVELOG ALL. Note that if backup optimization is enabled, then
     RMAN skips logs that it has already backed up to the specified device.
 3. Backs up the rest of the files specified in BACKUP command.
 4. Runs the ALTER SYSTEM ARCHIVE LOG CURRENT command.
 5. Backs up any remaining archived logs generated during the backup.
This guarantees that datafile backups taken during the command are recoverable to a consistent state.
ALTER SYSTEM SWITCH LOGFILE ;
SWITCH LOGFILE Clause
The SWITCH LOGFILE clause lets you explicitly force Oracle to begin writing to a new redo log file group, regardless of whether the files in the current redo log file group are full. When you force a log switch, Oracle begins to perform a checkpoint but returns control to you immediately rather than when the checkpoint is complete. To use this clause, your instance must have the database open.
ALTER SYSTEM ARCHIVE LOG CURRENT ;
CURRENT Clause
Specify CURRENT to manually archive the current redo log file group of the specified thread（instance）, forcing a log switch. If you omit the THREAD parameter, then Oracle archives all redo log file groups from all enabled threads（instances）, including logs previous to current logs. You can specify CURRENT only when the database is open.
ALTER SYSTEM ARCHIVE LOG CURRENT NOSWITCH;
NOSWITCH
Specify NOSWITCH if you want to manually archive the current redo log file group without forcing a log switch. This setting is used primarily with standby databases to prevent data divergence when the primary database shuts down. Divergence implies the possibility of data loss in case of primary database failure.
You can use the NOSWITCH clause only when your instance has the database mounted but not open. If the database is open, then this operation closes the database automatically. You must then manually shut down the database before you can reopen it.
 
===========================================
dataguard备库保持一致性
[oracle@dg1 script]$ cat logswitch.sh
#!/bin/bash
. ~/.bash_profile
sqlplus -s "sys/jniywk_0912@jnywk as sysdba" <<EOF
alter system archive log current;
exit
EOF
[oracle@dg1 script]$
 
==================================================
sbt配置案列
# cat level0.sh
su - oracle -c "/u01/app/oracle/product/11.2.0_1/bin/rman"<<EOF
connect target /
run{
allocate channel t1 type 'sbt_tape' parms 'ENV=(tdpo_optfile=/usr/tivoli/tsm/client/oracle/bin64/tdpo.opt)';
allocate channel t2 type 'sbt_tape' parms 'ENV=(tdpo_optfile=/usr/tivoli/tsm/client/oracle/bin64/tdpo.opt)';
backup incremental level 0 database format='LEV0_%d_%t_%U';
backup spfile format='spfile_%d_%t_%U';
backup current controlfile format='ctl_%d_%t_%U';
sql 'alter system archive log current';
backup format 'arch_%t_%s_%p' archivelog all delete input;
crosscheck backup;
crosscheck archivelog all;
delete noprompt expired backup;
delete noprompt obsolete;
delete noprompt expired archivelog all;
release channel t1;
release channel t2;
}
EOF
 