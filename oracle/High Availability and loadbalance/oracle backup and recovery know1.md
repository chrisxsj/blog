RMAN备份恢复情况

1 不完全恢复-带有offline的数据文件

场景：
rman不完全恢复需要指定recover到过去一个时间点，但是如果restore中存在offline的数据文件
 
会遇到如下错误
 
run {
set until time "to_date('20180108 10:09:53','yyyymmdd hh24:mi:ss')";
recover database;
}
 
Oracle Error:
ORA-01547: warning: RECOVER succeeded but OPEN RESETLOGS would get error below
ORA-01194: file 2 needs more recovery to be consistent
ORA-01110: data file 2: '/u01/app/oradata/myorcl/undotbs01.dbf'
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of recover command at 03/27/2014 22:50:52
RMAN-06054: media recovery requesting unknown log: thread 1 seq 26 lowscn 662459
 
分析：
online的数据文件中，min(v$datafile_header.CHECKPOINT_CHANGE#) > thread 1 seq 26 lowscn 662459，为什么还需要这个日志呢？
看来是offline的数据文件需要这个日志，数据文件offline了，为什么还需要recover呢？
 
参考docs：
https://docs.oracle.com/cd/E11882_01/backup.112/e10643/rcmsynta2001.htm#RCMRF140
 
By default, the RECOVER DATABASE command does not recover files that are offline normal at the point in time to which the files are being recovered. RMAN omits offline normal files with no further checking.
这里明确指出recover 数据库时offline normal的数据文件会被忽略。offline normal是什么状态呢？
参考docs
https://docs.oracle.com/cd/E11882_01/backup.112/e10642/glossary.htm#BRADV90215
 
offline normal
A tablespace is offline normal when taken offline with the ALTER TABLESPACE ... OFFLINE NORMAL statement. The data files in the tablespace are checkpointed and do not require recovery before being brought online. If a tablespace is not taken offline normal, then its data files must be recovered before being brought online.
 
通过以上可知，open时对数据文件做offlne操作后，在recover database时仍然需要recover
 
但是如果数据文件offline时间太长，所需要的归档早已不在（包括磁盘和备份）怎么办？
 
针对以上情况需要重建控制文件，在脚本中去掉offline的数据文件（这部分数据理论上也不需要）
参考mos
How to Recreate a Controlfile (Doc ID 735106.1)
 
注意：不完全恢复使用#2. RESETLOGS case，归档日志序号会归0，需要catalog所需的归档日志再recover
 
2 不完全恢复-带有新建数据文件
场景：
备份时间过长，需要recover大部分归档日志来追加数据，但backup piece之后有多个新建的数据文件
如果是异机恢复，目录不一致，recover archivelog 时会遇到错误，因为归档日志中创建数据文件的语句找不到目录
 
类似dg环境中，同步中断，主库新加了数据文件情况，备库如何增量修复情况
 
分析：
可用方法1
需要restore一个包含新数据文件的controlfile，restore set newname此数据文件，继续recover
参考mos
Steps to perform for Rolling forward a standby database using RMAN incremental backup when datafile is added to primary (Doc ID 1531031.1)
可用方法2
使用OMF，自动创建在OMF路径下
可用方法3
创建数据文件指定路径不对情况，会自动创建在数据库默认路径下（$ORACLE_HOME/dbs）
使用如下命令修改控制文件，继续recover
 
alter database create datafile 2993 as '/oradata1/tbs_yyk_ssddd.dbf';
 
3 RMAN对归档日志的删除
场景：
rman使用以下命令时，会删除过期的备份及备份之前不需要的归档日志
delete noprompt obsolete redundancy 1 device type disk;
 
参考docs
https://docs.oracle.com/database/121/RCMRF/rcmsynta015.htm#RCMRF121
OBSOLETE
Deletes data file backups and copies recorded in the RMAN repository that are obsolete, that is, no longer needed (see Example 2-76). RMAN also deletes obsolete archived redo log files and log backups.
 
如：
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=910 instance=orcl2 device type=DISK
Deleting the following obsolete backups and copies:
Type                 Key    Completion Time    Filename/Handle
-------------------- ------ ------------------ --------------------
Archive Log          6458   2018-01-08 23:19:00 +FRA/orcl/archivelog/2018_01_08/thread_1_seq_4344.547.964912739
Archive Log          6459   2018-01-09 00:11:59 +FRA/orcl/archivelog/2018_01_09/thread_2_seq_2118.653.964915919
Archive Log          6460   2018-01-09 00:12:00 +FRA/orcl/archivelog/2018_01_09/thread_1_seq_4345.277.964915919
Archive Log          6461   2018-01-09 01:35:03 +FRA/orcl/archivelog/2018_01_09/thread_1_seq_4346.678.964920901
但有时我们只希望删除备份而不删除归档日志，用技术来规避一些潜在的风险
如dg，ogg，存在多个备份环境，我们保留这些归档，让dg，ogg，其他备份来使用
 
分析
针对此种情况oracle是没有相应的命令实现的，只能变通
如：使用以下命令代替delete obsolete
delete backup completed before 'sysdate-7' device type disk;
如：
根据MOS文章RMAN backup retention policy ( Doc ID 462978.1 )里
Exempting Backups from the Retention Policy 这个段落的内容，
可以采取这样的命令，在保留策略之外，伴随着一份数据库备份来单独保留一份归档日志：
RMAN> BACKUP DATABASE KEEP UNTIL TIME "TO_DATE('31-FEB-2018', 'dd-mon-yyyy')" LOGS;
 
以上的方法均存在缺点，还需要进一步探讨
 
 
4 增量备份
参考docs
https://docs.oracle.com/cd/E11882_01/backup.112/e10643/rcmsynta007.htm#RCMRF107
 
1 在做1级增量时，oracle内部会使用recover命令检查，如果没有0级增量，自动做一个0级增量
2 因为差异增量总是和上一级做对比，备份策略中有几个差异备份失败，理论上不影响数据的恢复
 
5 提高recover性能
如存在大量recover操作，可通过指定parallel提高性能，parallel是默认开启，默认值依赖于服务器cpu
注意：RECOVERY_PARALLELISM 只影响实例恢复不影响介质恢复
参考docs
https://docs.oracle.com/cd/E11882_01/backup.112/e10643/rcmsynta2001.htm#RCMRF140
 
Specifies parallel recovery (default).
By default, the database uses parallel media recovery to improve performance of the roll forward phase of media recovery. To override the default behavior of performing parallel recovery, use the RECOVER with the NOPARALLEL option, or RECOVER PARALLEL 0.
 
The number of processes is derived from the CPU_COUNT initialization parameter, which by default equals the number of CPUs on the system
 
Note: The RECOVERY_PARALLELISM initialization parameter controls instance or crash recovery only. Media recovery is not affected by the value used for RECOVERY_PARALLELISM.