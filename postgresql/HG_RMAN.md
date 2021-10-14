# HG_RMAN

**作者**

Chrisx

**日期**

2021-10-09

**内容**

hg_rman的使用测试

----

[toc]

## 介绍

为了防止数据库丢失数据以及在数据丢失后重建数据库，数据库备份与恢复工具对于数据库生产运维来说是不可缺少的。瀚高备份恢复工具 RMAN 是一个用于执行备份和恢复操作的数据库组件。使用它可执行一致性备份或非一致性备份，执行增量备份或完全备份，也可备份整体数据库或数据库的一部分（单个数据文件）。如果为了快速恢复， RMAN 可将备份存储在磁盘上；如果为了长期存储，也可将备份放置在磁带上。

## 前提条件

hgrman 是物理备份，进行物理备份前需要开启归档模式

```
alter system set archive_mode=on;
alter system set archive_directory='/arch/arch5';
重启服务器生效
pg_ctl restart
```
# 1.hg_rman 初始化
```
hg_rman -D /opt/HighGoDB-5.6.4/data -A /arch/arch5 -B /backup   init 
```
执行初始化命令后，会生成配置文件 $PGHOME/conf/hg_rman.ini
# 2. 查看配置
```
[highgo@hgdb conf]$ hg_rman config --list
=============================================================================================
ArguName                      Source          Value 
=============================================================================================
pgdata                        CONFFILE        /opt/HighGoDB-5.6.4/data
arclog-path                   CONFFILE        /arch/arch5
backup-path                   CONFFILE        /backup
backup-mode                   CONFFILE        FULL
compress-data                 CONFFILE        NO
smooth-checkpoint             CONFFILE        YES
keep-data-days                CONFFILE        7
keep-arclog-files             CONFFILE        -1
hgdb_home                     ENVIRONMENT     /opt/HighGoDB-5.6.4
dbname                        DEFAULT         highgo
=============================================================================================
```
# 3. 执行备份
```
全备
hg_rman -h 127.0.0.1 -d highgo -p 5866 -U highgo -b full backup
全备指定备份路径
hg_rman -h 127.0.0.1 -d highgo -p 5866 -U highgo -b full -B /tmp backup
全备包含归档
hg_rman -h 127.0.0.1 -d highgo -p 5866 -U highgo -b full -X backup
增量备份
hg_rman -h 127.0.0.1 -d highgo -p 5866 -U highgo -b incremental backup
归档备份
hg_rman -h 127.0.0.1 -d highgo -p 5866 -U highgo -b archive backup
```
# 4. 查看备份
查看全部备份
```
[highgo@hgdb ~]$ hg_rman -a show
=========================================================================================================================
BK_key   Tag                  ElapsedTime    EndTime              Mode    Size       TLI           chkpt       Status
=========================================================================================================================
5        TAG20190930T150429   00:00:01       2019-09-30 15:04:30  ARCH    50MB       1             0/0         OK
4        TAG20190930T150318   00:00:02       2019-09-30 15:03:20  INCR    16kB       1             0/9000028   OK
3        TAG20190930T150154   00:00:06       2019-09-30 15:02:00  FULL    143MB      1             0/7000028   OK
2        TAG20190930T150010   00:00:08       2019-09-30 15:00:18  FULL    25MB       1             0/5000028   OK
1        TAG20190930T145652   00:00:04       2019-09-30 14:56:56  FULL    25MB       1             0/3000060   OK
```
查看详细信息
 hg_rman -a show detail 
查看单个备份集信息
```
[highgo@hgdb ~]$ hg_rman show backup 2
# configuration
BACKUP_MODE=FULL
FULL_BACKUP_ON_ERROR=false
COMPRESS_DATA=false
WITH_ARCLOG=false
BACKUP_PATH=/tmp/2_TAG20190930T150010
# result
SYSTEM_IDENTIFIER=6742286241087679285
CATALOG_IDENTIFIER=6742341909220320634
BACKUP_ID=2
TAG='TAG20190930T150010'
PREBACKUP_ID=-1
TIMELINEID=1
START_LSN=0/05000028
STOP_LSN=0/05000130
START_TIME='2019-09-30 15:00:10'
END_TIME='2019-09-30 15:00:18'
RECOVERY_XID=584
RECOVERY_TIME='2019-09-30 15:00:18'
TOTAL_DATA_BYTES=25789197
READ_DATA_BYTES=25788984
WRITE_BYTES=25811165
BLOCK_SIZE=8192
XLOG_BLOCK_SIZE=8192
STATUS=OK
[highgo@hgdb ~]$ 
```
# 5. 验证备份可用性
查看备份集 2 的可用性
```
[highgo@hgdb ~]$ hg_rman validate backup 2
INFO: validate: "2" backup and archive log files by CRC
INFO: backup "2" is valid
```
# 6. 备份删除
删除备份集 1
```
[highgo@hgdb ~]$ hg_rman delete backup 1
ERROR: The backup with ID '1' can not be deleted.
```
无法删除，查看配置信息
```
$ hg_rman config --list
=============================================================================================
ArguName                      Source          Value 
=============================================================================================
pgdata                        CONFFILE        /opt/HighGoDB-5.6.4/data
arclog-path                   CONFFILE        /arch/arch5
backup-path                   CONFFILE        /backup
backup-mode                   CONFFILE        FULL
compress-data                 CONFFILE        NO
smooth-checkpoint             CONFFILE        YES
keep-data-days                CONFFILE        7
keep-arclog-files             CONFFILE        -1
hgdb_home                     ENVIRONMENT     /opt/HighGoDB-5.6.4
dbname                        DEFAULT         highgo
=============================================================================================
默认保留天数为 7 天
```
指定保留策略删除，指定保留天数为不限制
```
[highgo@hgdb ~]$ hg_rman --keep-data-days=-1 delete backup  1
=========================================================================================================================
BK_key   Tag                  ElapsedTime    EndTime              Mode    Size       TLI           chkpt       Status
=========================================================================================================================
1        TAG20190930T145652   00:00:04       2019-09-30 14:56:56  FULL    25MB       1             0/3000060   OK
Do you want to delete the backups above? ('Yes' or 'No'):yes
INFO: delete the backup with ID: "1"
[highgo@hgdb ~]$ 
```
删除备份集 2
指定保留策略删除，指定保留冗余份数 1
```
hg_rman --keep-data-generations=2 delete backup  2
```
删除归档日志
删除 2 天前的归档日志
```
[highgo@hgdb ~]$ hg_rman --keep-arclog-days=2 delete arclog
INFO: start deleting old archived WAL files from ARCLOG_PATH (keep days = 2)
INFO: the threshold timestamp calculated by keep days is "2019-09-28 00:00:00"
```
# 7. 清理备份文件
通过 delete 命令，将备份标记为删除，实际备份文件还存在，通过 purge 命令清理备份文件
可用的备份集为 3 、 4 、 5
```
[highgo@hgdb backup]$ hg_rman show
=========================================================================================================================
BK_key   Tag                  ElapsedTime    EndTime              Mode    Size       TLI           chkpt       Status
=========================================================================================================================
5        TAG20190930T150429   00:00:01       2019-09-30 15:04:30  ARCH    50MB       1             0/0         OK
4        TAG20190930T150318   00:00:02       2019-09-30 15:03:20  INCR    16kB       1             0/9000028   OK
3        TAG20190930T150154   00:00:06       2019-09-30 15:02:00  FULL    143MB      1             0/7000028   OK
备份集 1 、 2 的备份文件还存在
[highgo@hgdb backup]$ ls -atl
total 0
drwx------   2 highgo highgo  66 Sep 30 15:18 1_TAG20190930T145652
drwx------   4 highgo highgo  77 Sep 30 15:04 5_TAG20190930T150429
drwxr-xr-x   6 highgo highgo 118 Sep 30 15:04 .
drwx------   4 highgo highgo  96 Sep 30 15:03 4_TAG20190930T150318
drwx------   4 highgo highgo 119 Sep 30 15:02 3_TAG20190930T150154
dr-xr-xr-x. 20 root   root   265 Sep 30 14:09 ..
[highgo@hgdb backup]$ ls -atl /tmp/
total 24
drwxrwxrwt. 17 root   root   4096 Sep 30 15:29 .
drwx------   2 highgo highgo   66 Sep 30 15:19 2_TAG20190930T150010
```
清理备份文件
```
[highgo@hgdb backup]$ hg_rman purge
INFO: DELETED backup "2" is purged
INFO: DELETED backup "1" is purged
```
# 8. 注册备份
当有一个可用的备份，而备份数据字典中没有备份集信息时，可通过 catalog 命令将备份重新注册为可用。
```
[highgo@hgdb backup]$ ls
7_TAG20190930T153601  8_TAG20190930T154012
[highgo@hgdb backup]$ hg_rman show
=========================================================================================================================
BK_key   Tag                  ElapsedTime    EndTime              Mode    Size       TLI           chkpt       Status
=========================================================================================================================
8        TAG20190930T154012   00:00:02       2019-09-30 15:40:14  FULL    25MB       1             0/10000028  OK
[highgo@hgdb backup]$ hg_rman catalog backup 7_TAG20190930T153601/
INFO: validate: "7" backup and archive log files by SIZE
INFO: backup "7" is valid
INFO: backup "7_TAG20190930T153601/" has been cataloged into hg_rman.ctl successfully
[highgo@hgdb backup]$ hg_rman show
=========================================================================================================================
BK_key   Tag                  ElapsedTime    EndTime              Mode    Size       TLI           chkpt       Status
=========================================================================================================================
8        TAG20190930T154012   00:00:02       2019-09-30 15:40:14  FULL    25MB       1             0/10000028  OK
7        TAG20190930T153601   00:00:02       2019-09-30 15:36:03  FULL    25MB       1             0/E000028   OK
[highgo@hgdb backup]$ 
```
# 9. 完全恢复
完全恢复即将数据库恢复至故障时间点，不会造成数据丢失
查询数据
```
highgo=# select * from test_backup;
 id | name 
----+------
  1 | aaa
  2 | bbb
(2 rows)
```
数据库故障
```
[highgo@hgdb data]$ psql
psql: FATAL:  3D000: database "highgo" does not exist
DETAIL:  The database subdirectory "base/13862" is missing.
[highgo@hgdb data]$ 
```
数据恢复（如数据库 open ，需要先关闭数据库）
```
[highgo@hgdb data]$ pg_ctl stop
waiting for server to shut down.... done
server stopped
[highgo@hgdb data]$ 
[highgo@hgdb data]$ 
[highgo@hgdb data]$ hg_rman restore
INFO: backup "9" is valid
INFO: the recovery target timeline ID is not given
INFO: use timeline ID of current database cluster as recovery target: 1
INFO: calculating timeline branches to be used to recovery target point
INFO: searching latest full backup which can be used as restore start point
INFO: found the full backup can be used as base in recovery: "2019-09-30 16:08:53"
INFO: validate: "9" backup and archive log files by CRC
INFO: backup "9" is valid
INFO: copying online WAL files and server log files
INFO: restoring database files from the full mode backup "9"
Processed 1009 of 1009 files, skipped 28
INFO: searching incremental backup to be restored
INFO: searching backup which contained archived WAL files to be restored
INFO: restoring online WAL files and server log files
INFO: generating recovery.conf
INFO: restore complete
HINT: Recovery will start automatically when the PostgreSQL server is started.
[highgo@hgdb data]$ 
```
恢复后查询数据
```
[highgo@hgdb data]$ pg_ctl start
highgo=# select * from test_backup;
 id | name 
----+------
  1 | aaa
  2 | bbb
(2 rows)
```
# 10. 不完全恢复
不完全恢复指将数据库恢复至过去某一时间点，会丢失部分数据。
时间点 1 数据状态
```
highgo=# select current_timestamp;
       current_timestamp       
-------------------------------
 2019-09-30 16:15:16.401069+08
(1 row)
highgo=# select * from test_backup;
 id | name 
----+------
  1 | aaa
  2 | bbb
(2 rows)
```
时间点 2 ，有人执行了 delete 操作。此操作为误操作，需要将误删除的数据恢复
```
highgo=# select current_timestamp;
       current_timestamp       
-------------------------------
 2019-09-30 16:18:56.340673+08
(1 row)
highgo=# delete from test_backup where id=2;
DELETE 1
highgo=# 
```
不完全恢复，将数据库恢复至时间点 1
```
[highgo@hgdb data]$ pg_ctl stop
waiting for server to shut down.... done
server stopped
[highgo@hgdb data]$ hg_rman --recovery-target-time='2019-09-30 16:15:16' restore
INFO: backup "9" is valid
INFO: the recovery target timeline ID is not given
INFO: use timeline ID of current database cluster as recovery target: 2
INFO: calculating timeline branches to be used to recovery target point
INFO: searching latest full backup which can be used as restore start point
INFO: found the full backup can be used as base in recovery: "2019-09-30 16:08:53"
INFO: validate: "9" backup and archive log files by CRC
INFO: backup "9" is valid
INFO: copying online WAL files and server log files
INFO: restoring database files from the full mode backup "9"
Processed 1009 of 1009 files, skipped 28
INFO: searching incremental backup to be restored
INFO: searching backup which contained archived WAL files to be restored
INFO: restoring online WAL files and server log files
INFO: generating recovery.conf
INFO: restore complete
HINT: Recovery will start automatically when the PostgreSQL server is started.
[highgo@hgdb data]$ pg_ctl start
```
恢复后查询数据
```
highgo=# select * from test_backup;
 id | name 
----+------
  1 | aaa
  2 | bbb
(2 rows)
```
结束恢复
```
Select pg_wal_replay_resume()
```

# 11. 块恢复

如果硬盘上的一个块发生损坏，在备份集和 wal 日志完备的情况下，可以在   线执行损坏块的恢复。
执行块恢复

```shell
$hg_rman --datafile=1663/13899/16434 --block=0 blockrecover
```

需要指定 --datafile 和 --block

# 12. 块追踪配置
hg_rman 添加了特有的块跟踪机制：在数据库运行过程中，对有变更的 page 
号做出记录，在执行数据库增量备份的过程中，就不需要全盘扫描数据库文件来  
获取数据库变更 page 了。这样将大大提升了在某些场景下数据库的备份效率。
$PGDATA/postgresql.conf
## Block change tracking
#hg_db_block_change_tracking = off  # 块追踪开关
#hg_db_bct_file_buffers = 32MB  # min 128kB,BCT 文件使用的 sharebuffer 大小
#hg_db_bct_cache_size = 128MB # min 800kB, BCT 运行过程中所需的 sharebuffer
#bctwriter_delay = 200ms  # 10-10000ms between rounds,BctWriter 进程转化块信息 & 写入磁盘的时间间隔
开启块追踪
```
alter system set hg_db_block_change_tracking = on;
```
** 注意：  Windows 平台数据库不支持块跟踪机制，请将 hg_db_block_change_tracking 
参数设置为 off**
** 注意：开启块追踪会在目录 $PGDATA/bct 中生成块追踪文件 **
 