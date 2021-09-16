# gprecoverseg

## 恢复有Mirror的系统

1. 第一步是确保从Master主机可以连通该Segment主机。例如： $ ping failed_seg_host_address
2. 找到Master无法连接到Segment主机的故障并排除。例如，Segment主机可 能需要重启或更换。
 3. 主机正常启动之后，先确认可以连接，然后从Master主机执行gprecoverseg 命令恢复失败的Instance。例如(从Master主机执行)： $ gprecoverseg
4. 恢复进程会唤醒失败的Instance并确定需要被同步的变化文件。在此期间不 能取消gprecoverseg进程，耐心的等待其结束。在此过程中，数据库暂时终 止写操作。
5. 在gprecoverseg完成之后，系统变为重新同步(Resynchronizing)状态，开始 拷贝覆盖变化的文件。此进程是后台运行的，期间系统处于可用状态且接 受数据库请求。
 6. 当重新同步进程完成，系统将重新变为已同步(Synchronized)状态。运行

## 查看状态

```bash
gpstate 

20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-Greenplum instance status summary
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Master instance                                           = Active
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Master standby                                            = hgdb-secondary-27
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Standby master state                                      = Standby host passive
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total segment instance count from metadata                = 8
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Primary Segment Status
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total primary segments                                    = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total primary segment valid (at master)                   = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total primary segment failures (at master)                = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid files found                = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of /tmp lock files found                     = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number postmaster processes found                   = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Mirror Segment Status
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total mirror segments                                     = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total mirror segment valid (at master)                    = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total mirror segment failures (at master)                 = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid files found                = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number of /tmp lock files found                     = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number postmaster processes found                   = 4
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[WARNING]:-Total number mirror segments acting as primary segments   = 1                      <<<<<<<<
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Total number mirror segments acting as mirror segments    = 3
20200715:09:29:42:005149 gpstate:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------

```

注意查看是否有失败的segment
Total primary segment failures (at master)                = 0
......
Total mirror segment failures (at master)                 = 0

如果以后失败的segment需要先修复失败的segment再切换角色

## 修复失败的segment

> 注意：修复前，先关闭需要修复的实例。默认会检查数据库状态

```bash

[gpadmin@ps1 hgdw4]$ gprecoverseg
20190422:11:09:21:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Starting gprecoverseg with args:
20190422:11:09:21:097536 gprecoverseg:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190422:11:09:22:097536 gprecoverseg:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190422:11:09:22:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Checking if segments are ready to connect
20190422:11:09:22:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190422:11:09:22:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Heap checksum setting is consistent between master and the segments that are candidates for recoverseg
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Greenplum instance recovery parameters
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Recovery type              = Standard
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Recovery 1 of 1
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Synchronization mode                        = Incremental
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance host                        = ps1
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance address                     = ps1
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance directory                   = /home/gpadmin/hgdata/primary/hgdw4
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance port                        = 25436
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance replication port            = 28436
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance host               = ps2
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance address            = ps2
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance directory          = /home/gpadmin/mirror/hgdw4
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance port               = 26436
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance replication port   = 27436
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Target                             = in-place
20190422:11:09:23:097536 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
 
Continue with segment recovery procedure Yy|Nn (default=N):
> y
20190422:11:09:30:097536 gprecoverseg:ps1:gpadmin-[INFO]:-1 segment(s) to recover
20190422:11:09:30:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Ensuring 1 failed segment(s) are stopped
 
20190422:11:09:31:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Ensuring that shared memory is cleaned up for stopped segments
20190422:11:09:31:097536 gprecoverseg:ps1:gpadmin-[ERROR]:-Unable to clean up shared memory for segment: (ipcrm: already removed id (1277955)
)
Traceback (most recent call last):
  File "/home/gpadmin/greenplum-db/lib/python/gppylib/commands/base.py", line 243, in run
    self.cmd.run()
  File "/home/gpadmin/greenplum-db/lib/python/gppylib/operations/__init__.py", line 53, in run
    self.ret = self.execute()
  File "/home/gpadmin/greenplum-db/lib/python/gppylib/operations/utils.py", line 52, in execute
    raise ret
Exception: Unable to clean up shared memory for segment: (ipcrm: already removed id (1277955)
)
20190422:11:09:31:097536 gprecoverseg:ps1:gpadmin-[WARNING]:-Unable to clean up shared memory for stopped segments on host (ps1)
updating flat files
20190422:11:09:31:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Updating configuration with new mirrors
20190422:11:09:31:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Updating mirrors
.
20190422:11:09:32:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Starting mirrors
20190422:11:09:32:097536 gprecoverseg:ps1:gpadmin-[INFO]:-era is 78cdf816ba933af5_190422101021
20190422:11:09:32:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
.........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
20190422:11:19:34:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Process results...
20190422:11:19:34:097536 gprecoverseg:ps1:gpadmin-[WARNING]:-Failed to start segment.  The fault prober will shortly mark it as down. Segment: ps1:/home/gpadmin/hgdata/primary/hgdw4:content=4:dbid=6:mode=r:status=d: REASON: PG_CTL failed.
20190422:11:19:34:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Updating configuration to mark mirrors up
20190422:11:19:34:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Updating primaries
20190422:11:19:34:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Commencing parallel primary conversion of 1 segments, please wait...
........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
20190422:11:29:35:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Process results...
20190422:11:29:35:097536 gprecoverseg:ps1:gpadmin-[WARNING]:-Failed to inform primary segment of updated mirroring state.  Segment: ps2:/home/gpadmin/mirror/hgdw4:content=4:dbid=17:mode=r:status=u: REASON: Conversion failed.  stdout:""  stderr:"failure: Error: MirroringFailure failure: Error: MirroringFailure "
20190422:11:29:35:097536 gprecoverseg:ps1:gpadmin-[INFO]:-Done updating primaries
[gpadmin@ps1 hgdw4]$

```

## 强制修复

失败，用-F强制模式

```
[gpadmin@ps1 hgdw4]$ gprecoverseg -F
20190422:11:30:25:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Starting gprecoverseg with args: -F
20190422:11:30:25:099941 gprecoverseg:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190422:11:30:25:099941 gprecoverseg:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190422:11:30:25:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Checking if segments are ready to connect
20190422:11:30:25:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190422:11:30:46:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Unable to connect to database. Retrying 1
20190422:11:30:51:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Checking if segments are ready to connect
20190422:11:30:51:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190422:11:30:51:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Heap checksum setting is consistent between master and the segments that are candidates for recoverseg
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Greenplum instance recovery parameters
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Recovery type              = Standard
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Recovery 1 of 1
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Synchronization mode                        = Full
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance host                        = ps1
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance address                     = ps1
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance directory                   = /home/gpadmin/hgdata/primary/hgdw4
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance port                        = 25436
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Failed instance replication port            = 28436
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance host               = ps2
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance address            = ps2
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance directory          = /home/gpadmin/mirror/hgdw4
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance port               = 26436
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Source instance replication port   = 27436
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:-   Recovery Target                             = in-place
20190422:11:30:52:099941 gprecoverseg:ps1:gpadmin-[INFO]:----------------------------------------------------------
 
Continue with segment recovery procedure Yy|Nn (default=N):
> y
20190422:11:30:56:099941 gprecoverseg:ps1:gpadmin-[INFO]:-1 segment(s) to recover
20190422:11:30:56:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Ensuring 1 failed segment(s) are stopped
 
20190422:11:30:56:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Ensuring that shared memory is cleaned up for stopped segments
20190422:11:30:57:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Cleaning files from 1 segment(s)
..
20190422:11:30:59:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Building template directory
20190422:11:31:00:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Validating remote directories
.
20190422:11:31:01:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Copying template directory file
.
20190422:11:31:02:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Configuring new segments
.
20190422:11:31:03:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Cleaning files
.
20190422:11:31:04:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Starting file move procedure for ps1:/home/gpadmin/hgdata/primary/hgdw4:content=4:dbid=6:mode=r:status=d
updating flat files
20190422:11:31:04:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Updating configuration with new mirrors
20190422:11:31:05:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Updating mirrors
.
20190422:11:31:06:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Starting mirrors
20190422:11:31:06:099941 gprecoverseg:ps1:gpadmin-[INFO]:-era is 78cdf816ba933af5_190422101021
20190422:11:31:06:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
..
20190422:11:31:08:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Process results...
20190422:11:31:08:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Updating configuration to mark mirrors up
20190422:11:31:08:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Updating primaries
20190422:11:31:08:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Commencing parallel primary conversion of 1 segments, please wait...
...
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Process results...
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Done updating primaries
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-******************************************************************
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Updating segments for resynchronization is completed.
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-For segments updated successfully, resynchronization will continue in the background.
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-Use  gpstate -s  to check the resynchronization progress.
20190422:11:31:11:099941 gprecoverseg:ps1:gpadmin-[INFO]:-******************************************************************

```

## 确认同步进程的状态

```bash
$ gpstate -m



[gpadmin@ps1 hgdw4]$ gpstate  -m
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-Starting gpstate with args: -m
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:--Current GPDB mirror list and status
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:--Type = Group
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   Mirror   Datadir                      Port    Status              Data Status      
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps2      /home/gpadmin/mirror/hgdw0   26432   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps2      /home/gpadmin/mirror/hgdw1   26433   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps2      /home/gpadmin/mirror/hgdw2   26434   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps2      /home/gpadmin/mirror/hgdw3   26435   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps2      /home/gpadmin/mirror/hgdw4   26436   Acting as Primary   Resynchronizing
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps1      /home/gpadmin/mirror/hgdw5   26432   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps1      /home/gpadmin/mirror/hgdw6   26433   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps1      /home/gpadmin/mirror/hgdw7   26434   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps1      /home/gpadmin/mirror/hgdw8   26435   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:-   ps1      /home/gpadmin/mirror/hgdw9   26436   Passive             Synchronized
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
20190422:11:31:22:101369 gpstate:ps1:gpadmin-[WARNING]:-1 segment(s) configured as mirror(s) are acting as primaries
[gpadmin@ps1 hgdw4]$

```

等到状态变为Synchronized， 如

```bash
[dgadmin@hgdb-master-26 devops]$ gpstate -c
20200715:09:39:11:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-Starting gpstate with args: -c
20200715:09:39:11:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.17.0+3fab7bf build ga'
20200715:09:39:11:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.17.0+3fab7bf build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Feb 24 2019 10:00:35'
20200715:09:39:11:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:--------------------------------------------------------------
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:--Current GPDB mirror list and status
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:--Type = Spread
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:--------------------------------------------------------------
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Status                             Data State     Primary        Datadir                          Port    Mirror         Datadir                         Port
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Primary Active, Mirror Available   Synchronized   hgdb-data-22   /data/db/dgdata/primary/hgseg0   40000   hgdb-data-23   /data/db/dgdata/mirror/hgseg0   50000
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Primary Active, Mirror Available   Synchronized   hgdb-data-23   /data/db/dgdata/primary/hgseg1   40000   hgdb-data-24   /data/db/dgdata/mirror/hgseg1   50000
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Primary Active, Mirror Available   Synchronized   hgdb-data-24   /data/db/dgdata/primary/hgseg2   40000   hgdb-data-25   /data/db/dgdata/mirror/hgseg2   50000
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Mirror Active, Primary Available   Synchronized   hgdb-data-25   /data/db/dgdata/primary/hgseg3   40000   hgdb-data-22   /data/db/dgdata/mirror/hgseg3   50000
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[INFO]:--------------------------------------------------------------
20200715:09:39:12:005804 gpstate:hgdb-master-26:dgadmin-[WARNING]:-1 segment(s) configured as mirror(s) are acting as primaries
[dgadmin@hgdb-master-26 devops]$ 


``` 

## 修复角色

修复好了后，需要恢复所有Instance到原有角色
注意：一定要等到同步状态完成(Synchronized)！！！！！！！！

$ gprecoverseg -r

```bash

[dgadmin@hgdb-master-26 devops]$ gprecoverseg -r
20200715:10:02:21:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Starting gprecoverseg with args: -r
20200715:10:02:21:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.17.0+3fab7bf build ga'
20200715:10:02:21:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.17.0+3fab7bf build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Feb 24 2019 10:00:35'
20200715:10:02:21:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Checking if segments are ready to connect
20200715:10:02:21:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200715:10:02:23:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Greenplum instance recovery parameters
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Recovery type              = Rebalance
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Unbalanced segment 1 of 2
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance host               = hgdb-data-22
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance address            = hgdb-data-22
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance directory          = /data/db/dgdata/mirror/hgseg3
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance port               = 50000
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance replication port   = 51000
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Balanced role                          = Mirror
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Current role                           = Primary
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Unbalanced segment 2 of 2
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance host               = hgdb-data-25
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance address            = hgdb-data-25
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance directory          = /data/db/dgdata/primary/hgseg3
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance port               = 40000
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Unbalanced instance replication port   = 41000
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Balanced role                          = Primary
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Current role                           = Mirror
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[WARNING]:-This operation will cancel queries that are currently executing.
20200715:10:02:27:007100 gprecoverseg:hgdb-master-26:dgadmin-[WARNING]:-Connections to the database however will not be interrupted.

Continue with segment rebalance procedure Yy|Nn (default=N):
> y
20200715:10:02:43:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Getting unbalanced segments
20200715:10:02:43:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Stopping unbalanced primary segments...
................................................................................................................................................................. 
20200715:10:05:24:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Triggering segment reconfiguration
20200715:10:05:29:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Starting segment synchronization
20200715:10:05:29:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-=============================START ANOTHER RECOVER=========================================
20200715:10:05:29:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.17.0+3fab7bf build ga'
20200715:10:05:29:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.17.0+3fab7bf build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Feb 24 2019 10:00:35'
20200715:10:05:29:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Checking if segments are ready to connect
20200715:10:05:29:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200715:10:05:29:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Unable to connect to database. Retrying 1
20200715:10:05:34:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Checking if segments are ready to connect
20200715:10:05:34:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200715:10:05:34:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Heap checksum setting is consistent between master and the segments that are candidates for recoverseg
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Greenplum instance recovery parameters
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Recovery type              = Standard
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Recovery 1 of 1
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Synchronization mode                        = Incremental
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance host                        = hgdb-data-22
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance address                     = hgdb-data-22
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance directory                   = /data/db/dgdata/mirror/hgseg3
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance port                        = 50000
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance replication port            = 51000
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance host               = hgdb-data-25
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance address            = hgdb-data-25
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance directory          = /data/db/dgdata/primary/hgseg3
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance port               = 40000
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance replication port   = 41000
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Target                             = in-place
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-1 segment(s) to recover
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Ensuring 1 failed segment(s) are stopped
 
20200715:10:05:42:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Ensuring that shared memory is cleaned up for stopped segments
updating flat files
20200715:10:05:43:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating configuration with new mirrors
20200715:10:05:44:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating mirrors
. 
20200715:10:05:45:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Starting mirrors
20200715:10:05:46:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-era is 99feec2fd35671d1_200203125353
20200715:10:05:46:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
.... 
20200715:10:05:50:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Process results...
20200715:10:05:50:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating configuration to mark mirrors up
20200715:10:05:50:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating primaries
20200715:10:05:50:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Commencing parallel primary conversion of 1 segments, please wait...
.. 
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Process results...
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Done updating primaries
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-******************************************************************
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating segments for resynchronization is completed.
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-For segments updated successfully, resynchronization will continue in the background.
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Use  gpstate -s  to check the resynchronization progress.
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-******************************************************************
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-==============================END ANOTHER RECOVER==========================================
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-******************************************************************
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-The rebalance operation has completed successfully.
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-There is a resynchronization running in the background to bring all
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-segments in sync.
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Use gpstate -e to check the resynchronization progress.
20200715:10:05:52:007100 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-******************************************************************
[dgadmin@hgdb-master-26 devops]$ 

```
