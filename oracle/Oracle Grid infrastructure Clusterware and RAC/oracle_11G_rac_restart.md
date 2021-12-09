# oracle_11G_rac_restart

http://blog.csdn.net/tianlesoftware/article/details/8435772

Steps To Shutdown(stop)/Startup(start) CRS, OHAS, ASM, RDBMS & ACFS Services on a RAC Cluster 11.2 & 12.1 Configuration (Doc ID 1355977.1)



一 stop
 1 stop application


3 
ps -ef |grep "LOCAL=NO"| grep -v grep |awk '{print "kill -9 " $2}'
ps -ef | grep "LOCAL=NO"| grep -v grep |awk '{print "kill -9 " $2}' |sh

2 make checkpoint
 alter system switch logfile;
 alter system switch logfile;
 alter system switch logfile;
 alter system checkpoint



 4 file
 show parameter spfile;
 create pfile='/home/oracle/initSID20150415.ora' from spfile;
 show parameter control
 backup current controlfile format '/home/oracle/ctl20150423.ctl';

 note: asm info!!!
 select file_name from dba_data_files;

 先决条件检查(仅仅针对aix)：

 select path from v$asm_disk;

 查询出asm磁盘组所使用的pv，
 使用lspv 命令查看相关pv的pvid是否有，若是存在pvid，禁止停止asm实例，否则asm实例将启动不了。


5 stop cluster
1) Connect to node #1, then please check if the CRS/OHAS & services are enabled to autostart as follow (repeat this step on each node):
# $GRID_ORACLE_HOME/bin/crsctl config crs
2) If not, then you can enable it as follow (repeat this step on each node):
# $GRID_ORACLE_HOME/bin/crsctl enable crs
srvctl stop database -d NAME -o immeidate
srvctl stop listener -n HOSTNAME
crsctl stop crs -n
crsctl status resource -t
ps -ef|grep crs


$GRID_ORACLE_HOME/bin/crsctl check cluster -all
$GRID_ORACLE_HOME/bin/crsctl stop cluster
$GRID_ORACLE_HOME/bin/crsctl stop has 


注意点： 需要停止crs or cluster 后再去停止hacmp or 第三方软件

 6 stop mcsg
 cmviewcl


7 stop storage



	

=====================================================
 二 start

 1 start storage

 2 start mcsg
 cmviewcl

 3 automatic start(default)
 manual    

 crsctl start crs -n
 crsctl start crs -n


 srvctl start nodeapps -n raw1
 srvctl start nodeapps -n raw2
 srvctl start asm -n raw1
 srvctl start asm -n raw2
 srvctl start instance -d raw -i raw2
 srvctl start instance -d orcl -i raw1
 srvctl start listener
 emctl start dbconsole
                

 srvctl start database -d orcl
 srvctl stop database -d orcl   -o immediate

 =========================================================
 dataguard not stop
先转一段具体描述：在Oracle 11gR2 下的RAC，架构发生了变化。CRS的信息也是放在ASM 实例里的，所以要关asm必须关闭crs。如果还使用了acfs的话，一关crs那么acfs里的信息也不能访问了，所以一般不重启机器，不轻易关crs, 其他的service可以根据自己的需要去stop/start。注意：11g RAC 开启资源相对比较慢(即使命令后面显示的资源都start succeeded,通过crs_stat -t查看都不一定online), 需要耐心并查看log。
1，关闭数据库：
 这个和以前是一样的，还是以oracl用户执行srvctl命令：
[oracle@rac1 ~]$ srvctl stop listener -n rac1    --关闭监听

[oracle@rac1 ~]$ srvctl stop database -d ORCL -o immediate  ---停止所有节点上的实例



然后查看状态：
 [oracle@rac1 ~]$ srvctl status database -d orcl      
 Instance rac1 is not running on node rac1
 Instance rac2 is not running on node rac2



3，停止节点集群服务，必须以root用户：
 [root@rac1 oracle]# cd /u01/grid/11.2.0/grid/bin
 [root@rac1 bin]# ./crsctl stop cluster        ----停止本节点集群服务 
 [root@rac1 bin]# ./crsctl stop cluster -all  ----停止所有节点服务
 也可以如下控制所停节点：
 [root@rac1 bin]#  ./crsctl stop cluster -n rac1 rac2

[root@rac1 bin]#  ./crsctl stop has


而11g R2的RAC默认开机会自启动，当然如果需要手工启动：也就是按照cluster, HAS, database的顺序启动即可。？？？？？


注意：
 有这么一种可能，即使杀掉了所有的应用进程，数据库还是无法关闭，我们可能看到：
Thu Apr 17 18:21:13 2014
Shutting down instance (immediate)
License high water mark = 499
Thu Apr 17 18:21:13 2014
Stopping Job queue slave processes, flags = 7
Thu Apr 17 18:21:13 2014
Job queue slave processes stopped
Waiting for dispatcher 'D000' to shutdown
All dispatchers and shared servers shutdown
Thu Apr 17 18:21:19 2014
ALTER DATABASE CLOSE NORMAL
Thu Apr 17 18:21:21 2014
SMON: disabling tx recovery
Thu Apr 17 18:25:17 2014
Thread 1 advanced to log sequence 217749 (LGWR switch)
  Current log# 1 seq# 217749 mem# 0: +DGSYSTEM/dfkzyk/onlinelog/group_1.257.709402229
  Current log# 1 seq# 217749 mem# 1: +DGRECOVER/dfkzyk/onlinelog/group_1.257.709402231
Thu Apr 17 18:26:18 2014
Shutting down instance (abort)
此时停库的时候， SMON process 正在清理不再需要的extents，把他们标记为 free
主要是和临时段大小有关系。
数据库的临时表空间较多，且有的表空间很大。
这个时候，可以采用 shutdown abort的方式关闭数据库，这个时候不是干净的关闭。在下一次 startup的时候，数据库会接着清理。


参考 oracle support 文章
Shutdown Normal or Shutdown Immediate Hangs. SMON disabling TX Recovery (Doc ID 1076161.6)


==========================================

配置了Dataguard对RAC 重启没有什么特殊要求，正常重启就行，Dataguard会自动解决GAP。

 # crsctl stop crs
 # crsctl start crs

 如果Dataguard没有自动解决GAP，可以手工解决GAP
 http://docs.oracle.com/cd/E11882_01/server.112/e41134/log_transport.htm#BABIDDDC
 6.4.3.1 Manual Gap Resolution

 实在不行可以重启日志应用的进程例如：

 http://docs.oracle.com/cd/E11882_01/server.112/e41134/log_apply.htm#SBYDB00530

 To stop Redo Apply, issue the following SQL statement:

 SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;


 To start Redo Apply in the background, include the DISCONNECT keyword on the SQL statement. For example:

 SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;

 
ps -ef | grep "LOCAL=NO"| grep -v grep |awk '{print "kill -9 " $2}' |sh
