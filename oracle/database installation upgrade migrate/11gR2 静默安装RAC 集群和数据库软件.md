11gR2 静默安装RAC 集群和数据库软件
By: Jason Yang | Principal Product Manager

   由于某些远程安装的需求，OUI 的 GUI 界面远程交互比较慢，会影响DBA安装RAC时的速度。或者某些企业禁用了X Window，也造成了无法使用OUI来进行标准的RAC安装。
   以下是一个静默安装数据库集群软件(GI HOME)和数据库软件(RDBMS HOME)的测试，希望对遇到以上无法使用OUI的DBA有所帮助。
   测试环境是静默安装11.2.0.3版本的两节点RAC。OS 环境如下：
$ uname -a
Linux nascds10 2.6.9-78.0.0.0.1.ELhugemem #1 SMP Fri Jul 25 14:53:18 EDT 2008 i686 i686 i386 GNU/Linux
-bash-3.00$ cat enterprise-release
Enterprise Linux Enterprise Linux AS release 4 (October Update 7)
   存储使用了oracleasmlib 来配置管理: 
[root@nascds10 ~]# /etc/init.d/oracleasm listdisks
DATA
OCR
RECO
  具体步骤如下:
11.2.0.3 集群软件(GI) 静默安装
将11.2.0.3 集群安装软件解压缩到/home/grid/11.2.0.3/grid路径下。
1. 使用runcluvfy.sh 来执行安装前的预检查，来避免由于环境配置引发的安装失败问题。
su - grid
cd /home/grid/11.2.0.3/grid
-bash-3.00$ ./runcluvfy.sh stage -pre crsinst -n nascds10, nascds11 -verbose
具体输出，请参考附件 runcluvfy-output.txt
2. 安装检查通过之后，
配置grid.rsp文件。具体信息，请参考附件 grid.rsp
3. 使用以下命令来开始静默安装集群软件：
./runInstaller -silent -responseFile /home/grid/grid.rsp  
安装最后，会有类似
# You can find the log of this install session at:  
#   
#  /u01/app/oraInventory/logs/installActions2012-04-30_11-48-55PM.log
#   
# As a root user, execute the following script(s):  
#   
#         1. /u01/app/11.2.0/grid/root.sh  
#   
# As install user, execute the following script to complete the configuration.  
#   
#         1. /u01/app/11.2.0/grid/cfgtoollogs/configToolAllCommands 
#   
#         Note:  
#   
#         1. This script should be run in the same environment from where the installer has been run.  
#   
#         2. This script needs a small password properties file for configuration assistants that require passwords (refer to install guide documentation).  
#   
# Successfully Setup Software.  
之后，在两个节点分别使用ROOT用户来执行 root.sh脚本。
在 nascds10 节点，登录root用户，执行
cd <GI_HOME>
./root.sh
在 nascds11 节点，登录root用户，执行
cd <GI_HOME>
./root.sh
在所有节点执行root.sh脚本成功之后，回到发起的nascds10节点，使用grid用户继续执行 以上安装日志中提到的configToolAllCommands：
首先需要创建一个cfgrsp.properties空文件来确保configToolAllCommands脚本的成功： 
$ touch cfgrsp.properties
su - root
# chmod 600 cfgrsp.properties  
# ls -rtl /u01/app/11.2.0/grid/cfgtoollogs
-rw------- 1 grid oinstall 330 Apr 30 11:50 /u01/app/11.2.0/grid/cfgtoollogs/cfgrsp.properties  
su - grid
$cd /u01/app/11.2.0/grid/cfgtoollogs/
$./configToolAllCommands RESPONSE_FILE=/u01/app/11.2.0/grid/cfgtoollogs/cfgrsp.properties 
4. 命令完成之后，GI软件安装完成。执行以下命令来确保集群服务的启动情况
# $GRID_HOME/bin/crsctl stat res -t 
# $GRID_HOME/bin/crsctl stat res -t -init  
# $GRID_HOME/bin/crsctl check cluster -all
详细的安装日志，请参考附件：
LOG:installActions2012-04-30_11-48-55PM.log 
configActions2012-05-01_12-27-23-AM.log
 
********************
11.2.0.3 ORACLE RAC 数据库静默安装
1. 同上，请参考db.rsp日志来配置静默安装脚本。见附件 db.rsp
2. 安装RAC DB 软件：
su - oracle
./runInstaller -silent -responseFile /home/oracle/db.rsp -ignorePrereq -ignoreSysPreReqs -ignoreDiskWarning
之后，根据命令提示，在所有节点使用ROOT用户执行root.sh脚本：
在 nascds10 节点，登录ROOT用户，执行 
cd <ORACLE_HOME>
./root.sh
在 nascds11 节点，登录ROOT用户，执行
cd <ORACLE_HOME>
./root.sh
安装日志请参考附件
installActions2012-05-01_12-41-40AM.log
**********************
以上为GI_HOME和ORACLE_HOME的静默安装步骤。后续执行ASMCA 来配置数据库存储 及 使用DBCA来创建RAC数据库。
由于ASMCA 和DBCA的静默安装有已知的文档，请参考
**********************
ASMCA 官网文章note:1068788.1
How to use ASMCA in silent mode to configure ASM for a stand-alone server (Doc ID 1068788.1)
***********************
DBCA 请参考官方文档：
http://docs.oracle.com/cd/B28359_01/install.111/b28264/scripts.htm
B.2 Using DBCA Noninteractive (Silent) Configuration for Oracle RAC
reference:
https://blogs.oracle.com/Database4CN/entry/11gr2_%E9%9D%99%E9%BB%98%E5%AE%89%E8%A3%85rac_%E9%9B%86%E7%BE%A4%E5%92%8C%E6%95%B0%E6%8D%AE%E5%BA%93%E8%BD%AF%E4%BB%B61
How to Install 11.2 / 12.1 Database/Client Software in Silent Mode without Using Response File (文档 ID 885643.1)
How to Install Oracle Grid Infrastructure Standalone ASM in Silent Mode (文档 ID 2052802.1)
In a Silent Install Oracle Advanced Security Option is installed when not selected (文档 ID 427492.1)
 
来自 <https://blogs.oracle.com/database4cn/11gr2-rac>