Could not locate command: 'rsync'


[dgadmin@hgdb-master-26 backup]$ gpstate -m
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-Starting gpstate with args: -m
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.17.0+3fab7bf build ga'
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.17.0+3fab7bf build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Feb 24 2019 10:00:35'
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:--------------------------------------------------------------
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:--Current GPDB mirror list and status
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:--Type = Spread
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:--------------------------------------------------------------
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-   Mirror         Datadir                         Port    Status              Data Status      
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-23   /data/db/dgdata/mirror/hgseg0   50000   Passive             Synchronized
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-24   /data/db/dgdata/mirror/hgseg1   50000   Acting as Primary   Change Tracking
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-25   /data/db/dgdata/mirror/hgseg2   50000   Acting as Primary   Synchronized
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-22   /data/db/dgdata/mirror/hgseg3   50000   Passive             Synchronized
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[INFO]:--------------------------------------------------------------
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[WARNING]:-2 segment(s) configured as mirror(s) are acting as primaries
20190419:14:45:55:017362 gpstate:hgdb-master-26:dgadmin-[WARNING]:-1 mirror segment(s) acting as primaries are in change tracking
 
以上可以看出，修复了3个segment节点，还有一个节点无法修复，经排查，此节点数据库故障，无法启动，故，通过正常的修复手段无法成功。采用强制修复。
 
 
[dgadmin@hgdb-master-26 gpAdminLogs]$ gprecoverseg -F
 
20190419:15:31:50:021222 gprecoverseg:hgdb-master-26:dgadmin-[CRITICAL]:-Error occurred: Error Executing Command:
 Command was: 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 hgdb-data-23 ". /home/dgadmin/deepgreendb/greenplum_path.sh; $GPHOME/sbin/gpcleansegmentdir.py -p KGxwMAooaWdwcHlsaWIuZ3BhcnJheQpHcERCCnAxCihkcDIKUydzdGF0dXMnCnAzClMnZCcKcDQKc1MndmFsaWQnCnA1CkkwMApzUydkYmlkJwpwNgpJMwpzUydob3N0bmFtZScKcDcKUydoZ2RiLWRhdGEtMjMnCnA4CnNTJ3ByZWZlcnJlZF9yb2xlJwpwOQpTJ3AnCnAxMApzUydfR3BEQl9fcGVuZGluZ19maWxlc3BhY2UnCnAxMQpOc1MnY2F0ZGlycycKcDEyCihscDEzClMnL2RhdGEvZGIvZGdkYXRhL3ByaW1hcnkvaGdzZWcxL2Jhc2UvMScKcDE0CmFTJy9kYXRhL2RiL2RnZGF0YS9wcmltYXJ5L2hnc2VnMS9iYXNlLzEyMDk5JwpwMTUKYVMnL2RhdGEvZGIvZGdkYXRhL3ByaW1hcnkvaGdzZWcxL2Jhc2UvMTIxMDAnCnAxNgphUycvZGF0YS9kYi9kZ2RhdGEvcHJpbWFyeS9oZ3NlZzEvYmFzZS8xNjM4NCcKcDE3CmFTJy9kYXRhL2RiL2RnZGF0YS9wcmltYXJ5L2hnc2VnMS9iYXNlLzE2Mzg2JwpwMTgKYXNTJ2NvbnRlbnQnCnAxOQpJMQpzUydkYXRhZGlyJwpwMjAKUycvZGF0YS9kYi9kZ2RhdGEvcHJpbWFyeS9oZ3NlZzEnCnAyMQpzUydfR3BEQl9fZmlsZXNwYWNlcycKcDIyCihkcDIzCkkzMDUyCmcyMQpzc1Mncm9sZScKcDI0ClMnbScKcDI1CnNTJ21vZGUnCnAyNgpTJ3MnCnAyNwpzUydhZGRyZXNzJwpwMjgKUydoZ2RiLWRhdGEtMjMnCnAyOQpzUydyZXBsaWNhdGlvblBvcnQnCnAzMApJNDEwMDAKc1MncG9ydCcKcDMxCkk0MDAwMApzYmEu"'
rc=2, stdout='20190419:15:31:49:012169 gpcleansegmentdir.py_hgdb-data-23:dgadmin:hgdb-data-23:dgadmin-[INFO]:-Starting gpcleansegmentdir.py with args: -p KGxwMAooaWdwcHlsaWIuZ3BhcnJheQpHcERCCnAxCihkcDIKUydzdGF0dXMnCnAzClMnZCcKcDQKc1MndmFsaWQnCnA1CkkwMApzUydkYmlkJwpwNgpJMwpzUydob3N0bmFtZScKcDcKUydoZ2RiLWRhdGEtMjMnCnA4CnNTJ3ByZWZlcnJlZF9yb2xlJwpwOQpTJ3AnCnAxMApzUydfR3BEQl9fcGVuZGluZ19maWxlc3BhY2UnCnAxMQpOc1MnY2F0ZGlycycKcDEyCihscDEzClMnL2RhdGEvZGIvZGdkYXRhL3ByaW1hcnkvaGdzZWcxL2Jhc2UvMScKcDE0CmFTJy9kYXRhL2RiL2RnZGF0YS9wcmltYXJ5L2hnc2VnMS9iYXNlLzEyMDk5JwpwMTUKYVMnL2RhdGEvZGIvZGdkYXRhL3ByaW1hcnkvaGdzZWcxL2Jhc2UvMTIxMDAnCnAxNgphUycvZGF0YS9kYi9kZ2RhdGEvcHJpbWFyeS9oZ3NlZzEvYmFzZS8xNjM4NCcKcDE3CmFTJy9kYXRhL2RiL2RnZGF0YS9wcmltYXJ5L2hnc2VnMS9iYXNlLzE2Mzg2JwpwMTgKYXNTJ2NvbnRlbnQnCnAxOQpJMQpzUydkYXRhZGlyJwpwMjAKUycvZGF0YS9kYi9kZ2RhdGEvcHJpbWFyeS9oZ3NlZzEnCnAyMQpzUydfR3BEQl9fZmlsZXNwYWNlcycKcDIyCihkcDIzCkkzMDUyCmcyMQpzc1Mncm9sZScKcDI0ClMnbScKcDI1CnNTJ21vZGUnCnAyNgpTJ3MnCnAyNwpzUydhZGRyZXNzJwpwMjgKUydoZ2RiLWRhdGEtMjMnCnAyOQpzUydyZXBsaWNhdGlvblBvcnQnCnAzMApJNDEwMDAKc1MncG9ydCcKcDMxCkk0MDAwMApzYmEu
20190419:15:31:49:012169 gpcleansegmentdir.py_hgdb-data-23:dgadmin:hgdb-data-23:dgadmin-[INFO]:-Cleaning main data directories
20190419:15:31:49:012169 gpcleansegmentdir.py_hgdb-data-23:dgadmin:hgdb-data-23:dgadmin-[INFO]:-Cleaning /data/db/dgdata/primary/hgseg1
20190419:15:31:49:012169 gpcleansegmentdir.py_hgdb-data-23:dgadmin:hgdb-data-23:dgadmin-[CRITICAL]:-Command rsync not found
20190419:15:31:49:012169 gpcleansegmentdir.py_hgdb-data-23:dgadmin:hgdb-data-23:dgadmin-[CRITICAL]:-gpcleansegmentdir.py failed. (Reason='Could not locate command: 'rsync' in this set of paths: ['/usr/kerberos/bin', '/usr/sfw/bin', '/opt/sfw/bin', '/bin', '/usr/local/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/ucb', '/sw/bin', '/opt/Navisphere/bin', '/home/dgadmin/deepgreendb']') exiting...
', stderr=''
 
以上显示强制修复报错，无法调用rsync命令，需要安装必须的系统包
 
5、安装系统包
mount -o loop -t iso9660 /data/centos7.4/CentOS-7-x86_64-DVD-1708.iso /mnt
 
yum install perl-5.16.3-292.el7.x86_64.rpm -y
 
yum install gcc-4.8.5-16.el7.x86_64.rpm -y
 
6、强制修复
[dgadmin@hgdb-master-26 ~]$ gprecoverseg -F
20190424:16:22:23:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Starting gprecoverseg with args: -F
20190424:16:22:23:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.17.0+3fab7bf build ga'
20190424:16:22:23:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.17.0+3fab7bf build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Feb 24 2019 10:00:35'
20190424:16:22:23:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Checking if segments are ready to connect
20190424:16:22:23:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20190424:16:22:24:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20190424:16:22:25:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Heap checksum setting is consistent between master and the segments that are candidates for recoverseg
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Greenplum instance recovery parameters
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Recovery type              = Standard
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Recovery 1 of 1
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Synchronization mode                        = Full
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance host                        = hgdb-data-23
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance address                     = hgdb-data-23
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance directory                   = /data/db/dgdata/primary/hgseg1
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance port                        = 40000
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Failed instance replication port            = 41000
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance host               = hgdb-data-24
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance address            = hgdb-data-24
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance directory          = /data/db/dgdata/mirror/hgseg1
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance port               = 50000
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Source instance replication port   = 51000
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-   Recovery Target                             = in-place
20190424:16:22:26:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:----------------------------------------------------------
 
Continue with segment recovery procedure Yy|Nn (default=N):
> y
20190424:16:22:45:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-1 segment(s) to recover
20190424:16:22:45:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Ensuring 1 failed segment(s) are stopped
 
20190424:16:22:45:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Ensuring that shared memory is cleaned up for stopped segments
20190424:16:22:46:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Cleaning files from 1 segment(s)
..
20190424:16:22:48:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Building template directory
20190424:16:22:49:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Validating remote directories
.
20190424:16:22:50:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Copying template directory file
.
20190424:16:22:51:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Configuring new segments
.
20190424:16:22:52:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Cleaning files
.
20190424:16:22:53:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Starting file move procedure for hgdb-data-23:/data/db/dgdata/primary/hgseg1:content=1:dbid=3:mode=s:status=d
updating flat files
20190424:16:22:53:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating configuration with new mirrors
20190424:16:22:54:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating mirrors
.
20190424:16:22:55:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Starting mirrors
20190424:16:22:55:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-era is 99feec2fd35671d1_190419152620
20190424:16:22:55:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
..
20190424:16:22:57:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Process results...
20190424:16:22:57:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating configuration to mark mirrors up
20190424:16:22:57:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating primaries
20190424:16:22:57:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Commencing parallel primary conversion of 1 segments, please wait...
...
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Process results...
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Done updating primaries
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-******************************************************************
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Updating segments for resynchronization is completed.
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-For segments updated successfully, resynchronization will continue in the background.
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-Use  gpstate -s  to check the resynchronization progress.
20190424:16:23:00:031792 gprecoverseg:hgdb-master-26:dgadmin-[INFO]:-******************************************************************
[dgadmin@hgdb-master-26 ~]$
 
修复成功。