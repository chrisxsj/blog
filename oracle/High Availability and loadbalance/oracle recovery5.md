restore archivelog 的用法
(2012-09-23 09:13:14)

1.备份所有归档日志文件
RMAN> backup archivelog all delete input;
第二: restore archivelog 的各种选项
0.根据rac线程restore archivelog from logseq 6160 thread 2;
1.restore archivelog all   恢复全部归档日志文件
RMAN> restore archivelog all;
2.只恢复 5到8这四个归档日志文件
RMAN> restore archivelog from logseq 5 until logseq 8;
3.恢复从第5个归档日志起
RMAN> restore archivelog from logseq 5;
4.恢复7天内的归档日志
RMAN> restore archivelog from time 'sysdate-7';
restore archivelog from time "to_date('2017-06-05 14:00:00','yyyy-mm-dd hh24:mi:ss')";
5. sequence between 写法
RMAN> restore archivelog sequence between 1 and 3;
6.恢复到哪个日志文件为止
RMAN> restore archivelog until logseq 3;
6.从第五个日志开始恢复
RMAN> restore archivelog low logseq 5;
7.到第5个日志为止
RMAN> restore archivelog high logseq 5;
如果想改变恢复到另外路径下 则可用下面语句
set archivelog destination to 'd:\backup';
RMAN> run
2> {allocate channel ci type disk;
3> set archivelog destination to 'd:\backup';
4> restore archivelog all;
5> release channel ci;
6> }
8.根据时间查看需要的备份集：
ERPDB1@/orabak>rman target /
RMAN> list backup of archivelog time between "to_date('2009-06-24 08:00:00','yyyy-mm-dd hh24:mi:ss')" and "to_date('2009-06-24 13:00','yyyy-mm-dd hh24:mi:ss')";
恢复指定时间段
RMAN> run {
2> set archivelog destination to '/orabak/testarch';
3> SQL 'ALTER SESSION SET NLS_DATE_FORMAT="YYYY-MM-DD:HH24:MI:SS"';
4> restore archivelog time between '2009-06-24 09:00:00' and '2009-06-24 12:10:00';
5> }
until time
from time
between time