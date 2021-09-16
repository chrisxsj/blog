master与standby切换

## 当前环境
[gpadmin@ps1 ~]$ gpstate
20190418:14:18:16:042251 gpstate:ps1:gpadmin-[INFO]:-Starting gpstate with args:
20190418:14:18:16:042251 gpstate:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190418:14:18:16:042251 gpstate:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190418:14:18:16:042251 gpstate:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190418:14:18:16:042251 gpstate:ps1:gpadmin-[INFO]:-Gathering data from segments...
...
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-Greenplum instance status summary
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Master instance                                = Active
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Master standby                                 = No master standby configured
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total segment instance count from metadata     = 10
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Primary Segment Status
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total primary segments                         = 10
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total primary segment valid (at master)        = 10
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total primary segment failures (at master)     = 0
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid files missing   = 0
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid files found     = 10
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs missing    = 0
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs found      = 10
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number of /tmp lock files missing        = 0
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number of /tmp lock files found          = 10
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number postmaster processes missing      = 0
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Total number postmaster processes found        = 10
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Mirror Segment Status
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-   Mirrors not configured on this array
20190418:14:18:19:042251 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
[gpadmin@ps1 ~]$
 
 
[gpadmin@ps1 ~]$ gpstate -c
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-Starting gpstate with args: -c
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:--Primary list [physical mirroring not used]
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   Primary   Datadir                              Port
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps1       /home/gpadmin/hgdata/primary/hgdw0   25432
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps1       /home/gpadmin/hgdata/primary/hgdw1   25433
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps1       /home/gpadmin/hgdata/primary/hgdw2   25434
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps1       /home/gpadmin/hgdata/primary/hgdw3   25435
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps1       /home/gpadmin/hgdata/primary/hgdw4   25436
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps2       /home/gpadmin/hgdata/primary/hgdw5   25432
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps2       /home/gpadmin/hgdata/primary/hgdw6   25433
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps2       /home/gpadmin/hgdata/primary/hgdw7   25434
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps2       /home/gpadmin/hgdata/primary/hgdw8   25435
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:-   ps2       /home/gpadmin/hgdata/primary/hgdw9   25436
20190418:14:16:25:042100 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
[gpadmin@ps1 ~]$


## 添加一个mast mirror

[gpadmin@ps1 hgdw-1]$ gpinitstandby -s ps2
20190418:17:41:00:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Validating environment and parameters for standby initialization...
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Checking for filespace directory /home/gpadmin/hgdata/master/hgdw-1 on ps2
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:------------------------------------------------------
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum standby master initialization parameters
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:------------------------------------------------------
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum master hostname               = ps1
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum master data directory         = /home/gpadmin/hgdata/master/hgdw-1
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum master port                   = 15432
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum standby master hostname       = ps2
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum standby master port           = 15432
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum standby master data directory = /home/gpadmin/hgdata/master/hgdw-1
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Greenplum update system catalog         = On
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:------------------------------------------------------
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:- Filespace locations
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:------------------------------------------------------
20190418:17:41:01:057159 gpinitstandby:ps1:gpadmin-[INFO]:-pg_system -> /home/gpadmin/hgdata/master/hgdw-1
Do you want to continue with standby master initialization? Yy|Nn (default=N):
> y
20190418:17:41:04:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Syncing Greenplum Database extensions to standby
20190418:17:41:04:057159 gpinitstandby:ps1:gpadmin-[INFO]:-The packages on ps2 are consistent.
20190418:17:41:04:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Adding standby master to catalog...
20190418:17:41:05:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Database catalog updated successfully.
20190418:17:41:05:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Updating pg_hba.conf file...
20190418:17:41:05:057159 gpinitstandby:ps1:gpadmin-[INFO]:-pg_hba.conf files updated successfully.
20190418:17:41:16:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Updating filespace flat files...
20190418:17:41:16:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Filespace flat file updated successfully.
20190418:17:41:16:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Starting standby master
20190418:17:41:16:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Checking if standby master is running on host: ps2  in directory: /home/gpadmin/hgdata/master/hgdw-1
20190418:17:41:17:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Cleaning up pg_hba.conf backup files...
20190418:17:41:18:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Backup files of pg_hba.conf cleaned up successfully.
20190418:17:41:18:057159 gpinitstandby:ps1:gpadmin-[INFO]:-Successfully created standby master on ps2
[gpadmin@ps1 hgdw-1]$
 
 
[gpadmin@ps1 hgdw-1]$ gpstate
20190418:17:45:41:057614 gpstate:ps1:gpadmin-[INFO]:-Starting gpstate with args:
20190418:17:45:41:057614 gpstate:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190418:17:45:41:057614 gpstate:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190418:17:45:41:057614 gpstate:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190418:17:45:41:057614 gpstate:ps1:gpadmin-[INFO]:-Gathering data from segments...
....
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-Greenplum instance status summary
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Master instance                                = Active
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Master standby                                 = ps2
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Standby master state                           = Standby host passive
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total segment instance count from metadata     = 10
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Primary Segment Status
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total primary segments                         = 10
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total primary segment valid (at master)        = 10
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total primary segment failures (at master)     = 0
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid files missing   = 0
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid files found     = 10
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs missing    = 0
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs found      = 10
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number of /tmp lock files missing        = 0
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number of /tmp lock files found          = 10
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number postmaster processes missing      = 0
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Total number postmaster processes found        = 10
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Mirror Segment Status
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-   Mirrors not configured on this array
20190418:17:45:45:057614 gpstate:ps1:gpadmin-[INFO]:-----------------------------------------------------
[gpadmin@ps1 hgdw-1]$


可能的错误
20190418:17:02:43:053867 gpinitstandby:ps1:gpadmin-[INFO]:-Backup files of pg_hba.conf cleaned up successfully.
20190418:17:02:43:053867 gpinitstandby:ps1:gpadmin-[ERROR]:-Error initializing standby master: ExecutionError: 'non-zero rc: 1' occured.  Details: 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 ps2 ". /home/gpadmin/greenplum-db/./greenplum_path.sh; pg_basebackup -x -R -c fast -E ./pg_log -E ./db_dumps -E ./gpperfmon/data -E ./gpperfmon/logs -D /home/gpadmin/hgdata/master/hgdw-1 -h ps1 -p 15432"'  cmd had rc=1 completed=True halted=False
  stdout=''
  stderr='pg_basebackup: could not connect to server: could not connect to server: Connection timed out
Is the server running on host "ps1" (123.129.254.12) and accepting
TCP/IP connections on port 15432?
could not connect to server: Connection timed out
Is the server running on host "ps1" (123.129.254.13) and accepting
TCP/IP connections on port 15432?
could not connect to server: Connection timed out
Is the server running on host "ps1" (123.129.254.14) and accepting
TCP/IP connections on port 15432?
could not connect to server: Connection timed out
Is the server running on host "ps1" (123.129.254.15) and accepting
TCP/IP connections on port 15432?
 
'
用的主机名ps1/ps2，需要将主机名解析加入到hosts文件
 
 
## 管理节点主备切换测试
启用 Master Mirror GPDB系统的Standby既可以在初始化(gpinitsystem)时配置，也可以在现有的系 统上配置(gpinitstandby)。假设现有系统初始化时未设置Standby，本节讲述如何 为之增加Standby。
 
为已有系统增加Standby
1. 确保Standby主机已经正确的安装配置(gpadmin系统用户已创建，GPDB二 进制文件已安装，环境变量已设置，互信已建，数据目录已建)。
2. 在当前活动的Master主机上运行gpinitstandby命令已添加GPDB系统的 Standby。例如(-s参数指定Standby的主机名)： $ gpinitstandby -s smdw
3. 关于切换到Standby，参照”恢复失败的Master”相关章节。
 
检查日志同步程序的状态 如果Standby上的同步程序(gpsyncagent)失败了，这对于系统的用户可能是不明 显的。gp_master_mirroring日志表是GPDB管理员用以检查Standby目前是否处 于同步状态的地方。
例如：
$ psql dbname -c 'SELECT * FROM gp_master_mirroring;'
如果结果表明Standby的状态是”Not Synchronized”，检查detail_state 和 error_message列以确定错误的原因。
 
恢复一个已经不同步的Standby：
$ gpinitstandby -s standby_master_hostname -n
 
Eg:
 
做测试时应首先备份数据库：（建议两种备份都做）
热备：
gpcrondump -a -C --dump-stats -g -G -h -r -v --use-set-session-authorization -x postgresql -u /home/dgadmin/backup --prefix postgresql -l /home/dgadmin/backup
-u 指定备份存放路径
-x 指定备份数据库
--prefix 指定备份文件前缀
-l 指定日志存放路径
冷备：
gpstop -M fast    停库进行主备文件的冷备。
cp -a $MASTER_DATA_DIRECTORY $MASTER_DATA_DIRECTORY.bak
$MASTER_DATA_DIRECTORY 替换为实际路径。
 
恢复命令：
gpdbrestore -G -a -v --prefix postgresql -b 20190515 -u /home/dgadmin/backup -l /home/dgadmin/backup
--prefix 和备份时对应
-u 指定备份存放路径
-b    <YYYYMMDD>        在db_dumps/<YYYYMMDD>中的Greenplum Database主机阵列上的段数据目录中查找转储文件。
-l 指定日志存放路径
一、检测集群状态
显示集群详细信息：gpstate -s
检查备用主机详细状态：gpstate -f
注意：
1、备份
2、查询数据库信息

二、主备切换
1、状态检测
确认集群存在standby节点，可以通过gpstate（-s）命令查看：
gpstate
20190507:15:21:20:002187 gpstate:master:dgadmin-[INFO]:-Greenplum instance status summary
20190507:15:21:20:002187 gpstate:master:dgadmin-[INFO]:-----------------------------------------------------
20190507:15:21:20:002187 gpstate:master:dgadmin-[INFO]:-   Master instance                                = Active
20190507:15:21:20:002187 gpstate:master:dgadmin-[INFO]:-   Master standby                                 = smdw
20190507:15:21:20:002187 gpstate:master:dgadmin-[INFO]:-   Standby master state                           = Standby host passive
20190507:15:21:20:002187 gpstate:master:dgadmin-[INFO]:-   Total segment instance count from metadata     = 4
20190507:15:21:20:002187 gpstate:master:dgadmin-[INFO]:-----------------------------------------------------
gpstate -s
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-----------------------------------------------------
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:--Master Configuration & Status
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-----------------------------------------------------
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Master host                    = master
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Master postgres process ID     = 1850
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Master data directory          = /data/master/hgdwseg-1
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Master port                    = 5432
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Master current role            = dispatch
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Greenplum initsystem version   = 5.10.2+f116db0 build ga
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Greenplum current version      = PostgreSQL 8.3.23 (Greenplum Database 5.10.2+f116db0 build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Sep 14 2018 02:54:10
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Postgres version               = 8.3.23
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Master standby                 = smdw
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-   Standby master state           = Standby host passive
20190507:15:15:34:001964 gpstate:master:dgadmin-[INFO]:-----------------------------------------------------
2、关闭Master
切换之前确保master节点无postgresql进程，否则切换失败并报错：
Error activating standby master: Active postgres process on master
关闭master节点进程：
$ gpstop -m  （推荐使用改命令）
或
pg_ctl stop -m f -D /data/master/hgdwseg-1   （不推荐使用）
3、 切换主备机
在Standby主机上运行gpactivatestandby命令。例如，-d参数指定要被激活的Standby的数据路径（绝对路径）：
$ gpactivatestandby -d /data/master/gpseg-1
如果配置了环境变量也可以
$ gpactivatestandby -d $MASTER_DATA_DIRECTORY
例如：
[dgadmin@smdw ~]$ gpactivatestandby -d  $MASTER_DATA_DIRECTORY
20190507:15:40:10:002554 gpactivatestandby:smdw:dgadmin-[INFO]:------------------------------------------------------
20190507:15:40:10:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Standby data directory    = /data/master/hgdwseg-1
20190507:15:40:10:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Standby port              = 5432
20190507:15:40:10:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Standby running           = yes
20190507:15:40:10:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Force standby activation  = no
20190507:15:40:10:002554 gpactivatestandby:smdw:dgadmin-[INFO]:------------------------------------------------------
Do you want to continue with standby master activation? Yy|Nn (default=N):
> y
20190507:15:40:15:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-found standby postmaster process
20190507:15:40:15:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Updating transaction files filespace flat files...
20190507:15:40:15:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Updating temporary files filespace flat files...
20190507:15:40:15:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Promoting standby...
20190507:15:40:15:002554 gpactivatestandby:smdw:dgadmin-[DEBUG]:-Waiting for connection...
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Standby master is promoted
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Reading current configuration...
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[DEBUG]:-Connecting to dbname='postgresql'
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Writing the gp_dbid file - /data/master/hgdwseg-1/gp_dbid...
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-But found an already existing file.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Hence removed that existing file.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Creating a new file...
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Wrote dbid: 1 to the file.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Now marking it as read only...
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Verifying the file...
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:---------------------------------------------------
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-The activation of the standby master has completed successfully.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-smdw is now the new primary master.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-You will need to update your user access mechanism to reflect
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-the change of master hostname.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Do not re-start the failed master while the fail-over master is
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-operational, this could result in database corruption!
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-MASTER_DATA_DIRECTORY is now /data/master/hgdwseg-1 if
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-this has changed as a result of the standby master activation, remember
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-to change this in any startup scripts etc, that may be configured
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-to set this value.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-MASTER_PORT is now 5432, if this has changed, you
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-may need to make additional configuration changes to allow access
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-to the Greenplum instance.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Refer to the Administrator Guide for instructions on how to re-activate
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-the master to its previous state once it becomes available.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-Query planner statistics must be updated on all databases
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-following standby master activation.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:-When convenient, run ANALYZE against all user databases.
20190507:15:40:18:002554 gpactivatestandby:smdw:dgadmin-[INFO]:---------------------------------------------------
4、切换后状态检测
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-----------------------------------------------------
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:--Master Configuration & Status
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-----------------------------------------------------
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Master host                    = smdw
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Master postgres process ID     = 1441
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Master data directory          = /data/master/hgdwseg-1
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Master port                    = 5432
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Master current role            = dispatch
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Greenplum initsystem version   = 5.10.2+f116db0 build ga
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Greenplum current version      = PostgreSQL 8.3.23 (Greenplum Database 5.10.2+f116db0 build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Sep 14 2018 02:54:10
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Postgres version               = 8.3.23
20190507:15:42:40:002747 gpstate:smdw:dgadmin-[INFO]:-   Master standby                 = No master standby configured
5、收集统计信息
切换成功后需要做一次统计信息收集
$ psql dbname -c 'ANALYZE;'
例如：
[dgadmin@smdw ~]$ psql postgres -c 'ANALYZE';
ANALYZE
6、激活备机时同时新增另一个备机
一旦激活了Standby，其将成为GPDB集群的Master。如果想在此时配置
另外一个主机作为新的Standby，在运行gpactivatestandby时可以使用-c参数。例如：
$ gpactivatestandby -d /data/master/gpseg-1 -c new_standby_hostname
如果未在切换时指定新备机，在切换完成后可以使用如下命令重新指定：
gpinitstandby -s new_standby_master_hostname
三、恢复Master
1、检查Master节点
确保要恢复的节点状态可用并无路径冲突，在目前master节点执行以下操作，重新初始化 old master为new standby，将其加入集群：
$gpinitstandby -s original_master_hostname
例如：
[dgadmin@smdw ~]$ gpinitstandby -s master
20190507:16:10:06:003165 gpinitstandby:smdw:dgadmin-[INFO]:-Validating environment and parameters for standby initialization...
20190507:16:10:06:003165 gpinitstandby:smdw:dgadmin-[INFO]:-Checking for filespace directory /data/master/hgdwseg-1 on master
20190507:16:10:06:003165 gpinitstandby:smdw:dgadmin-[ERROR]:-Filespace directory already exists on host master
20190507:16:10:06:003165 gpinitstandby:smdw:dgadmin-[ERROR]:-Failed to create standby
20190507:16:10:06:003165 gpinitstandby:smdw:dgadmin-[ERROR]:-Error initializing standby master: master data directory exists
[dgadmin@smdw ~]$ gpinitstandby -s master
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Validating environment and parameters for standby initialization...
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Checking for filespace directory /data/master/hgdwseg-1 on master
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:------------------------------------------------------
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum standby master initialization parameters
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:------------------------------------------------------
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum master hostname               = smdw
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum master data directory         = /data/master/hgdwseg-1
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum master port                   = 5432
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum standby master hostname       = master
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum standby master port           = 5432
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum standby master data directory = /data/master/hgdwseg-1
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Greenplum update system catalog         = On
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:------------------------------------------------------
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:- Filespace locations
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:------------------------------------------------------
20190507:16:11:57:003227 gpinitstandby:smdw:dgadmin-[INFO]:-pg_system -> /data/master/hgdwseg-1
Do you want to continue with standby master initialization? Yy|Nn (default=N):
> y
20190507:16:11:59:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Syncing Greenplum Database extensions to standby
20190507:16:11:59:003227 gpinitstandby:smdw:dgadmin-[INFO]:-The packages on master are consistent.
20190507:16:11:59:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Adding standby master to catalog...
20190507:16:11:59:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Database catalog updated successfully.
20190507:16:12:00:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Updating pg_hba.conf file...
20190507:16:12:00:003227 gpinitstandby:smdw:dgadmin-[INFO]:-pg_hba.conf files updated successfully.
20190507:16:12:03:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Updating filespace flat files...
20190507:16:12:03:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Filespace flat file updated successfully.
20190507:16:12:03:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Starting standby master
20190507:16:12:03:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Checking if standby master is running on host: master  in directory: /data/master/hgdwseg-1
20190507:16:12:04:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Cleaning up pg_hba.conf backup files...
20190507:16:12:05:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Backup files of pg_hba.conf cleaned up successfully.
20190507:16:12:05:003227 gpinitstandby:smdw:dgadmin-[INFO]:-Successfully created standby master on master
2、关闭目前Master进程
在当前的Master主机(原始角色为Standby)上停止Master进程。
$gpstop -m
例如：
[dgadmin@smdw ~]$ gpstop -m
20190507:16:18:46:003378 gpstop:smdw:dgadmin-[INFO]:-Starting gpstop with args: -m
20190507:16:18:46:003378 gpstop:smdw:dgadmin-[INFO]:-Gathering information and validating the environment...
20190507:16:18:46:003378 gpstop:smdw:dgadmin-[INFO]:-Obtaining Greenplum Master catalog information
20190507:16:18:46:003378 gpstop:smdw:dgadmin-[INFO]:-Obtaining Segment details from master...
20190507:16:18:46:003378 gpstop:smdw:dgadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 5.10.2+f116db0 build ga'
 
Continue with master-only shutdown Yy|Nn (default=N):
> y
20190507:16:18:48:003378 gpstop:smdw:dgadmin-[INFO]:-There are 0 connections to the database
20190507:16:18:48:003378 gpstop:smdw:dgadmin-[INFO]:-Commencing Master instance shutdown with mode='smart'
20190507:16:18:48:003378 gpstop:smdw:dgadmin-[INFO]:-Master host=smdw
20190507:16:18:48:003378 gpstop:smdw:dgadmin-[INFO]:-Commencing Master instance shutdown with mode=smart
20190507:16:18:48:003378 gpstop:smdw:dgadmin-[INFO]:-Master segment instance directory=/data/master/hgdwseg-1
20190507:16:18:49:003378 gpstop:smdw:dgadmin-[INFO]:-Attempting forceful termination of any leftover master process
20190507:16:18:49:003378 gpstop:smdw:dgadmin-[INFO]:-Terminating processes for segment /data/master/hgdwseg-1
3、恢复Master
在原始Master主机上(当前为Standby)运行gpactivatestandby命令。例如，-d参数指定要被激活的Standby的数据路径：
$ gpactivatestandby -d $MASTER_DATA_DIRECTORY
例如：
[dgadmin@master master]$ gpactivatestandby -d $MASTER_DATA_DIRECTORY
20190507:16:20:18:003533 gpactivatestandby:master:dgadmin-[INFO]:------------------------------------------------------
20190507:16:20:18:003533 gpactivatestandby:master:dgadmin-[INFO]:-Standby data directory    = /data/master/hgdwseg-1
20190507:16:20:18:003533 gpactivatestandby:master:dgadmin-[INFO]:-Standby port              = 5432
20190507:16:20:18:003533 gpactivatestandby:master:dgadmin-[INFO]:-Standby running           = yes
20190507:16:20:18:003533 gpactivatestandby:master:dgadmin-[INFO]:-Force standby activation  = no
20190507:16:20:18:003533 gpactivatestandby:master:dgadmin-[INFO]:------------------------------------------------------
Do you want to continue with standby master activation? Yy|Nn (default=N):
> y
20190507:16:20:20:003533 gpactivatestandby:master:dgadmin-[INFO]:-found standby postmaster process
20190507:16:20:20:003533 gpactivatestandby:master:dgadmin-[INFO]:-Updating transaction files filespace flat files...
20190507:16:20:20:003533 gpactivatestandby:master:dgadmin-[INFO]:-Updating temporary files filespace flat files...
20190507:16:20:20:003533 gpactivatestandby:master:dgadmin-[INFO]:-Promoting standby...
20190507:16:20:20:003533 gpactivatestandby:master:dgadmin-[DEBUG]:-Waiting for connection...
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Standby master is promoted
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Reading current configuration...
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[DEBUG]:-Connecting to dbname='postgresql'
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Writing the gp_dbid file - /data/master/hgdwseg-1/gp_dbid...
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-But found an already existing file.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Hence removed that existing file.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Creating a new file...
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Wrote dbid: 1 to the file.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Now marking it as read only...
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Verifying the file...
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:------------------------------------------------------
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-The activation of the standby master has completed successfully.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-master is now the new primary master.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-You will need to update your user access mechanism to reflect
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-the change of master hostname.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Do not re-start the failed master while the fail-over master is
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-operational, this could result in database corruption!
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-MASTER_DATA_DIRECTORY is now /data/master/hgdwseg-1 if
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-this has changed as a result of the standby master activation, remember
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-to change this in any startup scripts etc, that may be configured
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-to set this value.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-MASTER_PORT is now 5432, if this has changed, you
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-may need to make additional configuration changes to allow access
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-to the Greenplum instance.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Refer to the Administrator Guide for instructions on how to re-activate
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-the master to its previous state once it becomes available.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-Query planner statistics must be updated on all databases
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-following standby master activation.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:-When convenient, run ANALYZE against all user databases.
20190507:16:20:23:003533 gpactivatestandby:master:dgadmin-[INFO]:------------------------------------------------------
4、检查恢复后状态
$gpstate -f
例如：
[dgadmin@master master]$  gpstate -f
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:-Starting gpstate with args: -f
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2+f116db0 build ga'
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2+f116db0 build ga) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.3.1 20170216 (Red Hat 6.3.1-3), 64-bit compiled on Sep 14 2018 02:54:10'
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:-Obtaining Segment details from master...
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:-Standby master instance not configured
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:--------------------------------------------------------------
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:--pg_stat_replication
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:--------------------------------------------------------------
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:-No entries found.
20190507:16:26:00:003669 gpstate:master:dgadmin-[INFO]:--------------------------------------------------------------
5、
$ gpinitstandby -s original_standby_master_hostname
例如：
原来Standby节点：
[dgadmin@smdw master]$ mv hgdwseg-1 hgdwseg-1.bak
[dgadmin@smdw master]$ pwd
/data/maste
Master节点：
[dgadmin@master master]$ gpinitstandby -s  smdw
20190507:16:35:58:003800 gpinitstandby:master:dgadmin-[INFO]:-Validating environment and parameters for standby initialization...
20190507:16:35:58:003800 gpinitstandby:master:dgadmin-[INFO]:-Checking for filespace directory /data/master/hgdwseg-1 on smdw
20190507:16:35:59:003800 gpinitstandby:master:dgadmin-[ERROR]:-Filespace directory already exists on host smdw
20190507:16:35:59:003800 gpinitstandby:master:dgadmin-[ERROR]:-Failed to create standby
20190507:16:35:59:003800 gpinitstandby:master:dgadmin-[ERROR]:-Error initializing standby master: master data directory exists
[dgadmin@master master]$ gpinitstandby -s  smdw
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Validating environment and parameters for standby initialization...
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Checking for filespace directory /data/master/hgdwseg-1 on smdw
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:------------------------------------------------------
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum standby master initialization parameters
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:------------------------------------------------------
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum master hostname               = master
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum master data directory         = /data/master/hgdwseg-1
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum master port                   = 5432
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum standby master hostname       = smdw
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum standby master port           = 5432
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum standby master data directory = /data/master/hgdwseg-1
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-Greenplum update system catalog         = On
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:------------------------------------------------------
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:- Filespace locations
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:------------------------------------------------------
20190507:16:37:17:003825 gpinitstandby:master:dgadmin-[INFO]:-pg_system -> /data/master/hgdwseg-1
Do you want to continue with standby master initialization? Yy|Nn (default=N):
> y
20190507:16:37:19:003825 gpinitstandby:master:dgadmin-[INFO]:-Syncing Greenplum Database extensions to standby
20190507:16:37:19:003825 gpinitstandby:master:dgadmin-[INFO]:-The packages on smdw are consistent.
20190507:16:37:19:003825 gpinitstandby:master:dgadmin-[INFO]:-Adding standby master to catalog...
20190507:16:37:19:003825 gpinitstandby:master:dgadmin-[INFO]:-Database catalog updated successfully.
20190507:16:37:19:003825 gpinitstandby:master:dgadmin-[INFO]:-Updating pg_hba.conf file...
20190507:16:37:20:003825 gpinitstandby:master:dgadmin-[INFO]:-pg_hba.conf files updated successfully.
20190507:16:37:25:003825 gpinitstandby:master:dgadmin-[INFO]:-Updating filespace flat files...
20190507:16:37:25:003825 gpinitstandby:master:dgadmin-[INFO]:-Filespace flat file updated successfully.
20190507:16:37:25:003825 gpinitstandby:master:dgadmin-[INFO]:-Starting standby master
20190507:16:37:25:003825 gpinitstandby:master:dgadmin-[INFO]:-Checking if standby master is running on host: smdw  in directory: /data/master/hgdwseg-1
20190507:16:37:26:003825 gpinitstandby:master:dgadmin-[INFO]:-Cleaning up pg_hba.conf backup files...
20190507:16:37:27:003825 gpinitstandby:master:dgadmin-[INFO]:-Backup files of pg_hba.conf cleaned up successfully.
20190507:16:37:27:003825 gpinitstandby:master:dgadmin-[INFO]:-Successfully created standby master on smdw
 
5、同步检查
重新同步Standby有时可能会出现Master与Standby之间的日志同步程序停止，或者同步时间已经过期。可通过pg_stat_replication系统日志表来查看Master与Standby之间的最后更新日期。
$ psql dbname -c 'SELECT * FROM gp_master_mirroring;'    --4.1—4.3版
$ select procpid,state from pg_stat_replication;  --4.3之后
例如：
postgresql=# select procpid,state from pg_stat_replication;
 procpid |   state  
---------+-----------
    3905 | streaming
(1 row)
要同步Standby并更新到最新的同步，运行下面的gpinitstandby命令(使用-n参数)：
$ gpinitstandby -s standby_master_hostname -n  --4.1—4.3版
$ gpinitstandby -n  --4.3之后
例如：
[dgadmin@master ~]$ gpinitstandby -n
20190507:17:13:58:004683 gpinitstandby:master:dgadmin-[INFO]:-Starting standby master
20190507:17:13:58:004683 gpinitstandby:master:dgadmin-[INFO]:-Checking if standby master is running on host: smdw  in directory: /data/master/hgdwseg-1
20190507:17:13:59:004683 gpinitstandby:master:dgadmin-[INFO]:-Successfully started standby master
 
 