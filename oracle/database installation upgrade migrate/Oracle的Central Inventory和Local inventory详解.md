Oracle的Central Inventory和Local inventory详解
很多朋友对Oracle的inventory信息不太了解以至遇到相关的问题不知道如何处理，这篇文章我们将详细讲解Oracle的Central Inventory (oraInventory)和Local Inventory (Oracle Home inventory)
首先我们通过查看$ opatch lsinventory的输出来抛出几个问题：
[oracle@dbnode1 OPatch]$ ./opatch lsinventory
Invoking OPatch 11.2.0.1.7
Oracle Interim Patch Installer version 11.2.0.1.7
Copyright (c) 2011, Oracle Corporation.  All rights reserved.
Oracle Home       : /u01/app/oracle/product/11.2.0/db_1
Central Inventory : /u01/app/oraInventory  <<<<<=====什么是Central Inventory?
   from           : /etc/oraInst.loc<<<<<=====oraInst.loc是什么文件，它有什么作用？如果它被删除掉了会怎么样？
OPatch version    : 11.2.0.1.7<<<<<=====这是OPatch版本？
OUI version       : 11.2.0.3.0<<<<<=====OUI version 这里OUI 版本是指的什么？  
Log file location : /u01/app/oracle/product/11.2.0/db_1/cfgtoollogs/opatch/opatch2014-03-23_21-03-24PM.log
Lsinventory Output file location : /u01/app/oracle/product/11.2.0/db_1/cfgtoollogs/opatch/lsinv/lsinventory2014-03-23_21-03-24PM.txt
--------------------------------------------------------------------------------
Installed Top-level Products (1):
Oracle Database 11g                                                  11.2.0.3.0
There are 1 products installed in this Oracle Home.
There are no Interim patches installed in this Oracle Home.
--------------------------------------------------------------------------------
OPatch succeeded.
这里OPatch version 就是Opatch的版本，它是不同于数据库版本的。
如果OPatch 版本过低那打patch时就会报错，不过这个问题很快可以通过查看patch的readme通过其指定的Note 下载最新的Opatch 来解决。
OUI version 就是安装的ORACLE_HOME的版本
言归正传，什么是Central Inventory (oraInventory)呢 ？
每一个安装了Oracle产品的操作系统上都至少有一个Central Inventory (oraInventory)，他通过一个叫做inventory.xml的文件记录了在此操作系统上安装过的Oracle Homes等信息。
实际上Oracle就是通过Central Inventory (oraInventory) 来确定Oracle Home的位置，名称，是否是CRS_HOME及其他节点等信息的。
我们可以具体看一下inventory.xml的内容：
inventory.xml位置就在< Central Inventory >/ContentsXML/inventory.xml
例如：
[oracle@dbnode1 OPatch]$ cd /u01/app/oraInventory/ContentsXML/
[oracle@dbnode1 ContentsXML]$ ls
comps.xml  inventory.xml  libs.xml
[oracle@dbnode1 ContentsXML]$ cat inventory.xml
<?xml version="1.0" standalone="yes" ?>
<!-- Copyright (c) 1999, 2011, Oracle. All rights reserved. -->
<!-- Do not modify the contents of this file by hand. -->
<INVENTORY>
<VERSION_INFO>
   <SAVED_WITH>11.2.0.3.0</SAVED_WITH>
   <MINIMUM_VER>2.1.0.6.0</MINIMUM_VER>
</VERSION_INFO>
<HOME_LIST>
<HOME NAME="OraDb11g_home1" LOC="/u01/app/oracle/product/11.2.0/db_1" TYPE="O" IDX="1"/>
</HOME_LIST>
<COMPOSITEHOME_LIST>
</COMPOSITEHOME_LIST>
</INVENTORY>
[oracle@dbnode1 ContentsXML]$ pwd
/u01/app/oraInventory/ContentsXML
这里我们只安装了一个ORACLE_HOME它的名字叫OraDb11g_home1，路径在/u01/app/oracle/product/11.2.0/db_1。
请注意这里TYPE="O" IDX="1"
TYPE="O"意思是这是一个ORACLE数据库的HOME，如果它后面还有CRS="true"这样的标记就表明这是一个CRS_HOME。
IDX="1" 意思就是该HOME是第一个安装的产品。
我们再看一个安装了CRS的inventory.xml输出来对比一下
[oracle@ ContentsXML]$ cat inventory.xml
<?xml version="1.0" standalone="yes" ?>
<!-- Copyright (c) 1999, 2011, Oracle. All rights reserved. -->
<!-- Do not modify the contents of this file by hand. -->
<INVENTORY>
<VERSION_INFO>
   <SAVED_WITH>11.2.0.3.0</SAVED_WITH>
   <MINIMUM_VER>2.1.0.6.0</MINIMUM_VER>
</VERSION_INFO>
<HOME_LIST>
<HOME NAME="Ora11g_gridinfrahome1" LOC="/u01/app/11.2.0/grid" TYPE="O" IDX="1" CRS="true">
   <NODE_LIST>
      <NODE NAME="nascds10"/>
      <NODE NAME="nascds11"/>
   </NODE_LIST>
</HOME>
<HOME NAME="OraDb11g_home1" LOC="/u01/app/oracle/product/11.2.0/db_1" TYPE="O" IDX="2">
   <NODE_LIST>
      <NODE NAME="nascds10"/>
      <NODE NAME="nascds11"/>
   </NODE_LIST>
</HOME>
</HOME_LIST>
<COMPOSITEHOME_LIST>
</COMPOSITEHOME_LIST>
</INVENTORY>
通过对比我们已经非常明显的看到inventory.xml 里记录了详细ORACLE_HOME信息。
问题是Oracle是如何知道< Central Inventory >在哪里的呢？
答案很多人可能已经猜到了就是opatch lsinventory里列出来的
from           : /etc/oraInst.loc
这个/etc/oraInst.loc是有专业名称的，它的名字就叫Central Inventory Pointer File。
这个指向文件在不同的操作系统上有不同的默认位置，例如：
Linux And AIX — /etc/oraInst.loc
Other Unix Platforms — /var/opt/oracle/oraInst.loc
Windows — The pointer is located in the registry key:
\\HKEY_LOCAL_MACHINE\\Software\Oracle\inst.loc
Opatch就是通过Central Inventory Pointer File找到< Central Inventory >的路径，然后读取ORACLE_HOME的详细信息的。
现在又有新的问题了？
1.我们是否可以删除Central Inventory Pointer File？或者如果Central Inventory Pointer File丢失了会怎么样？
2. Central Inventory丢失或者损坏了会怎么样？
3. 我们能否手工修改Central Inventory的内容？
我先回答这几个问题，然后通过几个实验来看一下具体的情况。
答案：
1.不能删除Central Inventory Pointer File，如果Central Inventory Pointer File丢失了可以手工重建该文件。如果Central Inventory Pointer File丢失或者损坏那么opatch的所有命令都将失败。
2.也不能删除Central Inventory的文件，如果Central Inventory的文件是损坏的，比如内容不完整，或者内容是错误的，都将导致opatch失败。Central Inventory在ORACLE_HOME完好的情况下可以通过重建的方式解决以上问题。
3.Oracle官方不support手工修改Central Inventory的内容。
 
请注意以下所有的实验都不要在生产环境操作,以免导致Inventory错误.
实验1: 模拟Central Inventory Pointer File丢失的场景
[root@dbnode1]# mv /etc/oraInst.loc /etc/oraInst.loc.bak  <<<<<<=====这里手工mv了oraInst.loc文件，实验结束后需要手工再mv 回来
[root@dbnode1]# exit
exit
[oracle@dbnode1]$ cd /u01/app/oracle/product/11.2.0/db_1/OPatch/
[oracle@dbnode1 OPatch]$ ./opatch lsinventory
Invoking OPatch 11.2.0.1.7
Oracle Interim Patch Installer version 11.2.0.1.7
Copyright (c) 2011, Oracle Corporation.  All rights reserved.
Oracle Home       : /u01/app/oracle/product/11.2.0/db_1
Central Inventory : n/a
   from           :
OPatch version    : 11.2.0.1.7
OUI version       : 11.2.0.3.0
Log file location : n/a<<<<<<=========
OPatch cannot find a valid oraInst.loc file to locate Central Inventory. <<<<<<=========
OPatch failed with error code 104<<<<<<=========
[oracle@dbnode1 OPatch]$
通过这个实验我们看到当Oracle不能找到一个有效的Central Inventory Pointer File时Opatch以失败告终。
这个时候如果我们确定Central Inventory是完好无损的情况下，可以在不同平台对应的默认路径下手工创建或者编辑oraInst.loc 文件
例如在linux平台，正常的内容如下
$ cat /etc/oraInst.loc
inventory_loc=/u01/app/oraInventory
inst_group=oinstall
实验2: 模拟Central Inventory丢失的场景
[oracle@dbnode1 app]$ mv oraInventory oraInventory.bak<<<<<<=====这里手工删除了oraInventory
[oracle@dbnode1 app]$ ls
oracle  oraInventory.bak
[oracle@dbnode1 app]$ cd /u01/app/oracle/product/11.2.0/db_1/OPatch/
[oracle@dbnode1 OPatch]$ ./opatch lsinventory
Invoking OPatch 11.2.0.1.7
Oracle Interim Patch Installer version 11.2.0.1.7
Copyright (c) 2011, Oracle Corporation.  All rights reserved.
Oracle Home       : /u01/app/oracle/product/11.2.0/db_1
Central Inventory : /u01/app/oraInventory
   from           : /etc/oraInst.loc
OPatch version    : 11.2.0.1.7
OUI version       : 11.2.0.3.0
Log file location : /u01/app/oracle/product/11.2.0/db_1/cfgtoollogs/opatch/opatch2014-03-24_12-15-04PM.log
OPatch failed to locate Central Inventory.  <<<<<<=====报错无法加载Central Inventory.
Possible causes are:
    The Central Inventory is corrupted
    The oraInst.loc file specified is not valid.
LsInventorySession failed: OPatch failed to locate Central Inventory.
Possible causes are:
    The Central Inventory is corrupted
    The oraInst.loc file specified is not valid.
OPatch failed with error code 73<<<<<<=====
这个实验可以说明当Central Inventory 丢失时Opatch也是失败的。
实验3 模拟Central Inventory内容损坏
为实验目的我们手工修改ORACLE_HOME LOC成/u01/app/oracle/product/11.2.0/db_100 实际上这个目录是不存在的。但请注意手工修改inventory.xml的任何内容都是不support的。
<HOME NAME="OraDb11g_home1" LOC="/u01/app/oracle/product/11.2.0/db_100" TYPE="O" IDX="1"/>
[oracle@dbnode1 OPatch]$ cd /u01/app/oraInventory/ContentsXML/
[oracle@dbnode1 ContentsXML]$ cp inventory.xml inventory.xml.bak
[oracle@dbnode1 ContentsXML]$ ls
comps.xml  inventory.xml  inventory.xml.bak  libs.xml
[oracle@dbnode1 ContentsXML]$ vi inventory.xml
[oracle@dbnode1 ContentsXML]$ cat inventory.xml
<?xml version="1.0" standalone="yes" ?>
<!-- Copyright (c) 1999, 2011, Oracle. All rights reserved. -->
<!-- Do not modify the contents of this file by hand. -->
<INVENTORY>
<VERSION_INFO>
   <SAVED_WITH>11.2.0.3.0</SAVED_WITH>
   <MINIMUM_VER>2.1.0.6.0</MINIMUM_VER>
</VERSION_INFO>
<HOME_LIST>
<HOME NAME="OraDb11g_home1" LOC="/u01/app/oracle/product/11.2.0/db_100" TYPE="O" IDX="1"/>
</HOME_LIST>
<COMPOSITEHOME_LIST>
</COMPOSITEHOME_LIST>
</INVENTORY>
[oracle@dbnode1 ContentsXML]$ /u01/app/oracle/product/11.2.0/db_1/OPatch/opatch lsinventory
Invoking OPatch 11.2.0.1.7
Oracle Interim Patch Installer version 11.2.0.1.7
Copyright (c) 2011, Oracle Corporation.  All rights reserved.
 
Oracle Home       : /u01/app/oracle/product/11.2.0/db_1
Central Inventory : /u01/app/oraInventory
   from           : /etc/oraInst.loc
OPatch version    : 11.2.0.1.7
OUI version       : 11.2.0.3.0
Log file location : /u01/app/oracle/product/11.2.0/db_1/cfgtoollogs/opatch/opatch2014-03-24_12-25-43PM.log
List of Homes on this system:
  Home name= OraDb11g_home1, Location= "/u01/app/oracle/product/11.2.0/db_100"
Inventory load failed... OPatch cannot load inventory for the given Oracle Home.<<<=========
Possible causes are:
   Oracle Home dir. path does not exist in Central Inventory
   Oracle Home is a symbolic link
   Oracle Home inventory is corrupted
LsInventorySession failed: OracleHomeInventory gets null oracleHomeInfo
OPatch failed with error code 73
Central Inventory 如果损坏或者丢失是可以重建的。
重建过程非常简单，也不需要停机。我们来看下面的实验
实验4 重建Central Inventory
[oracle@dbnode1 ~]$ cd /u01/app
[oracle@dbnode1 app]$ ls
oracle  oraInventory
[oracle@dbnode1 app]$ mv oraInventory oraInventory.bak
[oracle@dbnode1 app]$ opatch lsinventory
Oracle Interim Patch Installer version 11.2.0.3.6
Copyright (c) 2013, Oracle Corporation.  All rights reserved.
Oracle Home       : /u01/app/oracle/product/11.2.0/db_1
Central Inventory : /u01/app/oraInventory
   from           : /u01/app/oracle/product/11.2.0/db_1/oraInst.loc
OPatch version    : 11.2.0.3.6
OUI version       : 11.2.0.3.0
Log file location : /u01/app/oracle/product/11.2.0/db_1/cfgtoollogs/opatch/opatch2014-03-25_17-13-48PM_1.log
OPatch failed to locate Central Inventory.
Possible causes are:
    The Central Inventory is corrupted
    The oraInst.loc file specified is not valid.
LsInventorySession failed: OPatch failed to locate Central Inventory.<<<==== Central Inventory 被删除了，这个报错就是期待的报错。
Possible causes are:
    The Central Inventory is corrupted
    The oraInst.loc file specified is not valid.
OPatch failed with error code 73<<<<<<<<<<<<<=================
[oracle@dbnode1 app]$ cd $ORACLE_HOME/oui/bin
[oracle@dbnode1 bin]$ pwd
/u01/app/oracle/product/11.2.0/db_1/oui/bin
[oracle@dbnode1 bin]$ ./runInstaller -silent -ignoreSysPrereqs -attachHome ORACLE_HOME="/u01/app/oracle/product/11.2.0/db_1" ORACLE_HOME_NAME="OraDb11g_home1"
Starting Oracle Universal Installer...
Checking swap space: must be greater than 500 MB.   Actual 2996 MB    Passed
The inventory pointer is located at /etc/oraInst.loc
The inventory is located at /u01/app/oraInventory
'AttachHome' was successful.
[oracle@dbnode1 bin]$ opatch lsinventory
Oracle Interim Patch Installer version 11.2.0.3.6
Copyright (c) 2013, Oracle Corporation.  All rights reserved.
Oracle Home       : /u01/app/oracle/product/11.2.0/db_1
Central Inventory : /u01/app/oraInventory
   from           : /u01/app/oracle/product/11.2.0/db_1/oraInst.loc
OPatch version    : 11.2.0.3.6
OUI version       : 11.2.0.3.0
Log file location : /u01/app/oracle/product/11.2.0/db_1/cfgtoollogs/opatch/opatch2014-03-25_17-16-37PM_1.log
Lsinventory Output file location : /u01/app/oracle/product/11.2.0/db_1/cfgtoollogs/opatch/lsinv/lsinventory2014-03-25_17-16-37PM.txt
--------------------------------------------------------------------------------
Installed Top-level Products (1):
Oracle Database 11g                                                  11.2.0.3.0
There are 1 product(s) installed in this Oracle Home.
Interim patches (1) :
Patch  17540582     : applied on Mon Mar 24 17:08:31 CST 2014
Unique Patch ID:  16985511
Patch description:  "Database Patch Set Update : 11.2.0.3.9 (17540582)"
   Created on 7 Jan 2014, 03:01:22 hrs PST8PDT
Sub-patch  16902043; "Database Patch Set Update : 11.2.0.3.8 (16902043)"
Sub-patch  16619892; "Database Patch Set Update : 11.2.0.3.7 (16619892)"
Sub-patch  16056266; "Database Patch Set Update : 11.2.0.3.6 (16056266)"
Sub-patch  14727310; "Database Patch Set Update : 11.2.0.3.5 (14727310)"
Sub-patch  14275605; "Database Patch Set Update : 11.2.0.3.4 (14275605)"
Sub-patch  13923374; "Database Patch Set Update : 11.2.0.3.3 (13923374)"
Sub-patch  13696216; "Database Patch Set Update : 11.2.0.3.2 (13696216)"
Sub-patch  13343438; "Database Patch Set Update : 11.2.0.3.1 (13343438)"
   Bugs fixed:
     13593999, 10350832, 14138130, 12919564, 13561951, 14198511, 13588248
     13080778, 13804294, 16710324, 12873183, 14472647, 12880299, 13369579
   ...............
     13059165, 14062797, 12959852, 12345082, 16703112, 13890080, 17333198
     16450169, 12658411, 13780035, 14062793, 13038684, 16742095, 13742464
     14052474, 13060271, 13911821, 13457582, 7509451, 13791364, 12821418
     13502183, 13705338, 16794239, 15862024, 13554409, 13645917, 13103913, 12772404
--------------------------------------------------------------------------------
OPatch succeeded.
[oracle@dbnode1 bin]$ cd /u01/app
[oracle@dbnode1 app]$ ls -l
total 12
drwxrwxr-x 9 oracle oinstall 4096 Nov 24 23:25 oracle
drwxrwx--- 4 oracle oinstall 4096 Mar 25 17:16 oraInventory<<<<<<<==新创建的Central Inventory
drwxrwx--- 5 oracle oinstall 4096 Mar 24 17:12 oraInventory.bak
Central Inventory里只记录了Oracle的HOME信息，但是在这个HOME下打了哪些patch Oracle是怎么知道的呢？
答案就是Local Inventory (Oracle Home inventory)。
Local Inventory (Oracle Home inventory) 存在于每一个ORACLE_HOME中，它记录了这个HOME中的相关信息，比如这个HOME中包含的组件，打过的补丁集（patchset 信息），打过的小补丁和PSU等信息。这些信息被记录在Local Inventory 中的comps.xml文件。
ORACLE_HOME/inventory/ContentsXML/comps.xml
同样Local Inventory (Oracle Home inventory)里的任何文件都是不允许手工修改的。
一个重要的信息是Oracle的Local Inventory (Oracle Home inventory)如果丢失或者损坏时无法重建的，只能通过重新安装ORACLE软件的方式解决。
参考文章：
FAQs on Central Inventory and Oracle Home Inventory (Local Inventory) in Oracle RDBMS (Doc ID 564192.1)
Steps To Recreate Central Inventory(oraInventory) In RDBMS Homes (Doc ID 556834.1)
Steps to Recreate Central Inventory in Real Applications Clusters (Doc ID 413939.1)
参与此主题的后续讨论，请回复blog，或者访问我们的中文社区，跟帖 "Oracle的Central Inventory和Local inventory详解 "
 
来自 <https://blogs.oracle.com/database4cn/oraclecentral-inventorylocal-inventory>