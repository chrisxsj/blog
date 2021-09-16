

oracle 11G 
Deinstallation Tool
$ORACLE_HOME/deinstall/deinstall


过程中有3个脚本


oracle 11g


先卸载db（rac），在卸载cluster
1 、卸载 Oracle Grid Infrastructure
Deconfiguring Oracle Clusterware Without Removing Binaries
cd /u01/app/11.2.0/grid/crs/install
1、 Run rootcrs.pl with the -deconfig -force flags. For example
# perl rootcrs.pl -deconfig –force
Repeat on other nodes as required
2、 If you are deconfiguring Oracle Clusterware on all nodes in the cluster, then on the last node, enter the following command:
# perl rootcrs.pl -deconfig -force –lastnode
3、 Removing Grid Infrastructure
The default method for running the deinstall tool is from the deinstall directory in the grid home. For example:
$ cd /u01/app/11.2.0/grid/deinstall
$ ./deinstall
2 、卸载 Oracle Real Application Clusters Software
Overview of Deinstallation Procedures
To completely remove all Oracle databases, instances, and software from an Oracle home directory:
	• Identify all instances associated with the Oracle home
	• Shut down processes
	• Remove listeners installed in the Oracle Database home
	• Remove database instances
	• Remove Automatic Storage Management (11.1 or earlier)
	• Remove Oracle Clusterware and Oracle Automatic Storage Management (Oracle grid infrastructure)
Deinstalling Oracle RAC Software


$ cd $ORACLE_HOME/deinstall
$ ./deinstall


注意删除inventory 产品清单


安装群集和数据库失败如何快速重来，需要清理重来？
RAC 安装失败后的删除
如果已经运行了root.sh脚本则要清理掉crs磁盘组的相关共享磁盘，命令格式如下：
dd if=/dev/zero of=/dev/raw/raw1 bs=1k count=3000
 删除grid和oracle的软件安装目录：
rm -rf /u02/*
rm -rf /u01/*
删除其他生成的配置文件：
rm  -rf /home/oracle/oracle/*
rm  -rf /etc/rc.d/rc5.d/S96init.crs
rm  -rf /etc/rc.d/init.d/init.crs
rm  -rf /etc/rc.d/rc4.d/K96init.crs
rm  -rf /etc/rc.d/rc6.d/K96init.crs 
rm  -rf /etc/rc.d/rc1.d/K96init.crs
rm  -rf /etc/rc.d/rc0.d/K96init.crs
rm  -rf /etc/rc.d/rc2.d/K96init.crs
rm  -rf /etc/rc.d/rc3.d/S96init.crs
rm  -rf /etc/oracle/*
rm  -rf /etc/oraInst.loc
rm  -rf /etc/oratab
rm  -rf /usr/local/bin/coraenv
rm  -rf /usr/local/bin/dbhome
rm  -rf /usr/local/bin/oraenv
rm -f /etc/init.d/init.cssd
rm -f /etc/init.d/init.crs
rm -f /etc/init.d/init.crsd
rm -f /etc/init.d/init.evmd
rm -f /etc/rc2.d/K96init.crs
rm -f /etc/rc2.d/S96init.crs
rm -f /etc/rc3.d/K96init.crs
rm -f /etc/rc3.d/S96init.crs
rm -f /etc/rc5.d/K96init.crs
rm -f /etc/rc5.d/S96init.crs
rm -f /etc/inittab.crs
rm -rf /tmp/.oracle/
rm -rf /etc/init.d/init.ohasd
rm -rf /etc/init.d/init.*
rm -rf /etc/oracle/
rm -rf /etc/oraInst.loc
rm -rf /var/tmp/.oracle/
rm -rf /tmp/.oracle/
rm -rf /var/tmp/.oracle/
rm -rf /usr/tmp/.oracle/
rm -f /etc/rc.d/init.d/ohasd
以上rm操作同样适用于10Grac的清理。
清理完成后需要重启下所有服务器，使得相应进程关闭。
