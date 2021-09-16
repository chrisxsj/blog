OPatch failed with error code 73 



1.执行opatch apply 报错 OPatch failed with error code 73 

 

[oracle@ora_11g 14275605]$ /opt/oracle/product/db_1/OPatch/opatch apply ./ 

Oracle Interim Patch Installer version 11.2.0.3.0 

Copyright (c) 2012, Oracle Corporation. All rights reserved. 

 

 

Oracle Home    : /opt/oracle/product/db_1 

Central Inventory : /opt/oraInventory 

  from      : /opt/oracle/product/db_1/oraInst.loc 

OPatch version  : 11.2.0.3.0 

OUI version    : 11.2.0.3.0 

Log file location : /opt/oracle/product/db_1/cfgtoollogs/opatch/opatch2012-12-18_21-45-13PM_1.log 

 

Verifying environment and performing prerequisite checks... 

Prerequisite check "CheckActiveFilesAndExecutables" failed. 

The details are: 

 

 

Following executables are active : 

/opt/oracle/product/db_1/bin/oracle 

Prerequisite check "CheckActiveFilesAndExecutables" failed. 

The details are: 

 

 

Following executables are active : 

/opt/oracle/product/db_1/lib/libclntsh.so.11.1 

UtilSession failed: Prerequisite check "CheckActiveFilesAndExecutables" failed.Prerequisite check "CheckActiveFilesAndExecutables" failed. 

Log file location: /opt/oracle/product/db_1/cfgtoollogs/opatch/opatch2012-12-18_21-45-13PM_1.log 

 

OPatch failed with error code 73 

 

仔细查看报错提示“Check Active Files And Executables”可能是有些执行程序用到了 

/opt/oracle/product/db_1/lib/目录下的库文件libclntsh.so.11.1 

 

2.使用fuser查看 

[oracle@ora_11g oinstall]$ /sbin/fuser  /opt/oracle/product/db_1/lib/libclntsh.so.11.1 

/opt/oracle/product/db_1/lib/libclntsh.so.11.1: 12831m 

 

3.查看12831号进程，12831号进程为sqlplus 程序，应该就是sqlplus正在使用libclntsh.so.11.1库文件 

[oracle@ora_11g oinstall]$ ps -ef | grep 12831 

oracle  12831 6986 0 21:44 pts/3  00:00:00 sqlplus  as sysdba 

oracle  12832 12831 0 21:44 ?    00:00:00 oracletest01 (DESCRIPTION=(LOCAL=YES)(ADDRESS=(PROTOCOL=beq))) 

oracle  12993 9126 0 21:47 pts/1  00:00:00 grep 12831 

[oracle@ora_11g oinstall]$ 

 

4.杀掉12831进程，查看结果 

[oracle@ora_11g oinstall]$ kill -9 12831 

[oracle@ora_11g oinstall]$ ps -ef | grep 12831 

oracle  13013 9126 0 21:55 pts/1  00:00:00 grep 12831 

 

5.重新执行opatch 顺利执行完成 

 

来自 <http://blog.csdn.net/evils798/article/details/8316458>