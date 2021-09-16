Oracle 不同故障的恢复方案
标签： oracledatabase数据库date数据库服务器
2010-12-30 00:10 10584人阅读 评论(0) 收藏 举报
本文章已收录于： 分类：
Oracle Troubleshooting（193）
作者同类文章X
版权声明：本文为博主原创文章，未经博主允许不得转载。

  之前在Blog中对RMAN 的备份和恢复做了说明，刚看了下，在恢复这块还有知识点遗漏了。 而且恢复这块很重要，如果DB 真要出了什么问题，就要掌握对应的恢复方法。 所以把DB的恢复这块单独拿出来说明一下。

RMAN 备份与恢复 实例
http://blog.csdn.net/tianlesoftware/archive/2009/10/19/4699320.aspx

如何搭建一个数据库服务器平台
http://blog.csdn.net/tianlesoftware/archive/2010/05/17/5602291.aspx

如何 搭建 RMAN 备份平台
http://blog.csdn.net/tianlesoftware/archive/2010/07/16/5740896.aspx



在非Catalog模式下， 备份的信息存储在controlfile中。 所以在RMAN 备份的时候，别忘了备份控制文件。

1. SPFILE丢失
startup nomount;
set dbid 3988862108;
restore spfile from autobackup;
或者通过某个文件
restore spfile from 'path/file_name'
shutdown immediate;
set dbid 3988862108;
startup;

2. Controlfile全部丢失
  控制文件做了3个冗余，很少会发生全部丢失的情况，当遇到控制文件所有都丢失，恢复需要以下步骤:

RMAN>set dbid 3988862108;
RMAN>startup nomount;
RMAN>restore controlfile from autobackup;
或者从文件恢复
RMAN>restore controlfile from 'file_name';
RMAN>alter database mount;
RMAN>recover database; （保证数据一致，因为控制文件里scn发生改变）
RMAN>alter database open resetlogs;

resetlogs命令表示一个数据库逻辑生存期的结束和另一个数据库逻辑生存期的开始，每次使用resetlogs命令的时候，SCN不会被重置，不过Oracle会重置日志序列号，而且会重置联机重做日志内容. 这样做是为了防止不完全恢复后日志序列会发生冲突（因为现有日志和数据文件间有了时间差）。

3. Redo Log File损坏
  重做日志文件在数据库中是要求最高的组件，首先其对磁盘的IO要求极高，其次一旦CURRENT组发生故障，数据库会立即崩溃，并且100%会发生数据丢失，所以ORACLE建议至少每个组需要两个成员，并且在数据库运行过程中日志文件会一直被锁定，以防不测。
Redo log的恢复分为两种：CURRENT 和 非CURRENT

3.1 CURRENT 情况
造成redo 损坏，很多情况是与突然断电有关。这种情况下是比较麻烦的。

（1）如果有归档和备份，可以用不完全恢复。
SQL>startup mount;
SQL>recover database until cancel; 先选择auto，尽量恢复可以利用的归档日志，然后重新执行：
SQL>recover database until cancel; 这次输入cancel，完成不完全恢复,
用resetlogs打开数据：
SQL>alter database open resetlogs； 打开数据库

（2）强制恢复， 这种方法可能会导致数据不一致
sql>startup mount;
sql>alter system set "_allow_resetlogs_corruption"=true scope=spfile;
sql>recover database until cancel;
sql>alter database open resetlogs;

  运气好的话，数据库能正常打开，但是由于使用_allow_resetlogs_corruption方式打开，会造成数据的丢失，且数据库的状态不一致。因此，这种情况下Oracle建议通过EXP方式导出数据库。重建新数据库后，再导入。

redo 的损坏，一般还容易伴随以下2种错误：ORA-600[2662]（SCN有关）和 ORA-600[4000]（回滚段有关）。

metalink上的两篇文章介绍了两种情况的处理方法：
TECH: Summary For Forcing The Database Open With `_ALLOW_RESETLOGS_CORRUPTION` with Automatic Undo Management [ID 283945.1]
http://blog.csdn.net/tianlesoftware/archive/2010/12/29/6106083.aspx

ORA-600 [2662] Block SCN is ahead of Current SCN [ID 28929.1]
http://blog.csdn.net/tianlesoftware/archive/2010/12/29/6106130.aspx

这两种情况下的恢复有点复杂，回头单独做个测试，在补充进来。


3.2 非CURRENT 情况
  这种情况下的恢复比较简单，因为redo log 是已经完成归档或者正在归档。 没有正在使用。可以通过v$log 查看redo log 的状态。

（1）如果STATUS是INACTIVE,则表示已经完成了归档，直接清除掉这个redo log即可。

SQL>startup mount;
SQL> alter database clear logfile group 3 ;
SQL>alter database open;

（2）如果STATUS 是ACTIVE ，表示正在归档， 此时需要使用如下语句：
SQL>startup mount;
SQL> alter database clear unarchived logfile group 3 ;
SQL>alter database open;


4. 非系统表空间损坏
  若出现介质故障导致某表空间不可用，恢复可以在数据库处于 open 或 mount 状态下进行，步骤如下：
1. 将该表空间置于offline状态
2. 修复表空间数据
3. 恢复表空间并处于一致性
4. 将表空间online

rman> sql 'alter tablespace dave offline';
如果文件不存在，就加immediate参数
rman> sql 'alter tablespace dave offline immediate';
rman>restore tablespace dave;
rman>recover tablespace dave;
rman>sql 'alter tablespace dave online';


5. 数据文件损坏
  如果出现介质故障导致某表空间数据文件丢失（这种情况也可以参照表空间损坏的恢复）。
恢复可以在 数据库处于 open 或 mount 状态下进行，只需4个步骤
1. 将该数据文件置于 offline 状态
2. 修复数据文件（指定数据文件编号）
3. 恢复数据文件
4. 将数据文件 online

rman> sql 'alter datafile 8 offline ';
rman>restore datafile 8;
rman>recover datafile 8;
rman>sql 'alter datafile 8 online';


6. 基于时间点/SCN/日志序列的不完全恢复
  基于时间点/SCN/日志序列的不完全恢复，可以将数据库、表空间、数据文件等恢复至恢复备份集保存时间中的任何一个时间点/SCN/日志序列，但须谨慎，操作前一定需要做好备份，具备条件的情况下最好先恢复到异机。

6.1 基于时间点
run{
  set until time "to_date(12/29/10 23:00:00','mm/dd/yy hh24:mi:ss')";
  restore database;
  recover database;
  alter database open resetlogs;
}

SQL>STARTUP NOMOUNT;
SQL>alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
SQL> recover database until time '2010-12-29 23:19:00';
SQL>ALTER DATABASE OPEN RESETLOGS;

ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
SQL>startup mount;
SQL>restore database until time "to_date('2010-12-29 23:19:00','YYYY-MM-DD HH24:MI:SS')";
SQL>recover database until time "to_date('2010-12-29 23:19:00','YYYY-MM-DD HH24:MI:SS')";
SQL>alter database open resetlogs;


6.2 基于 SCN:
SQL>startup mount;
SQL>restore database until scn 10000;
SQL>recover database until scn 10000;
SQL>alter database open resetlogs;

6.3 基于日志序列
SQL>startup mount;
SQL>restore database until SEQUENCE 100 thread 1; //100是日志序列
SQL>recover database until SEQUENCE 100 thread 1;
SQL>alter database open resetlogs;

日志序列查看命令：
SQL>select sequence from v$log;
resetlogs就会把sequence 置为1


7. 非catalog下完全恢复
SQL>startup nomount;
SQL>restore controlfile from autobackup;
SQL>alter database mount;
SQL>restore database;
SQL>recover database;
SQL>alter database open resetlogs;

示例:
oracle ora10g> rm *;
oracle ora10g> ls;
oracle ora10g> //数据文件，控制文件全部删除

oracle ora10g> rman target /; //因为controlfile 丢失，不能够连接到rman
oracle ora10g> sqlplus /nolog;
oracle ora10g> connect / as sysdba;
oracle ora10g> shutdown abort;
oracle ora10g> rman target /

rman> startup nomount;
rman> restore controlfile from autabackup;
rman> alter database mount;
rman> restore database;
rman> recover database; //online redolog 不存在

SQL>recover database until cancel; //当redo log丢失，数据库在缺省的方式下，是不容许进行recover操作的,那么如何在这种情况下操作呢
SQL>create pfile from spfile;

vi /u01/product/10.20/dbs/initora10g.ora，在这个文件的最后一行添加
*.allow_resetlogs_corruption='TRUE'; //容许resetlog corruption

SQL>shutdown immediate;
SQL>startup pfile='/u01/product/10.20/dbs/initora10g.ora' mount;
SQL>alter database open resetlogs;

来自 <http://blog.csdn.net/tianlesoftware/article/details/6106178> 
