RMAN  set newname for datafile


RMAN 中的 SET 命令可以用来为数据文件和临时文件重命名，这里三思就使用 set 命
令对数据文件和临时文件的路径进行重定义，然后再执行恢复操作，如下：
RMAN> RUN {
2> SET NEWNAME FOR DATAFILE 1 to '/data1/jssdb/system01.dbf';
3> SET NEWNAME FOR DATAFILE 2 to '/data1/jssdb/undoa01.dbf';
4> SET NEWNAME FOR DATAFILE 3 to '/data1/jssdb/sysaux01.dbf';
5> SET NEWNAME FOR DATAFILE 4 to '/data1/jssdb/undob01.dbf';
6> SET NEWNAME FOR DATAFILE 5 to '/data1/jssdb/users01.dbf';
7> SET NEWNAME FOR DATAFILE 6 to '/data1/jssdb/jsstbs01.dbf';
8> SET NEWNAME FOR TEMPFILE 1 to '/data1/jssdb/temp01.dbf';
9> RESTORE DATABASE;
10> SWITCH DATAFILE ALL;
11> SWITCH TEMPFILE ALL;
12> }
use a SWITCH command to update the control file with the new  filenames of the datafiles. The SWITCH command is equivalent to the SQL statement 
ALTER DATABASE RENAME FILE. 
SWITCH DATAFILE ALL updates the control file to reflect the new names for all datafiles for which a SET NEWNAME has been issued in the RUN block. 
 