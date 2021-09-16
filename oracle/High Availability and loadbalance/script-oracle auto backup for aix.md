oracle auto backup for aix
script

有些时候，写好的shell脚本手工运行很正常，但一旦把其配置在crontab上调度就会出现这样或那样的问题。本人就遇到到如下几种情况。
1、在调用Oracle的sqlplus、sqlldr等命令工具时必须写出其全路径才能在crontab中执行成功，否则，虽然手动运行很正常，但一配到crontab上就出现异常。
2、手动运行shell脚本时，可以用sh命令；但在cron中一定不能用sh执行命令，而要用直接的列出shell脚本文件的方式顺序执行。
3、在crontab调用时，如果有用到数据库，
最好把数据库的相关环境变量等列写出来。
4、要在crontab里调度，shell脚本中引用到的文件最好都写绝对路径。
对于crontab调度而出现的问题的查找，AIX的系统邮件，很是一个突破口。根据邮件中的内容，一步步对所调度的shell进行问题的查找及解决。
 
$ crontab -l
30 9 * * *    "/u01/app/oracle/script/get_last_sequence.sh"
11 17 * * *    "/u01/app/oracle/script/get_last_sequence.sh"
30 14 * * *    "/u01/app/oracle/script/get_last_sequence.sh"
30 21 * * 6    "/u01/app/oracle/script/rmanbackup0.rman"
30 21 * * 0-5    "/u01/app/oracle/script/rmanbackup1.rman"
00,10,20,30,40,50 * * * * /home/oracle/script/get_last_sequence.sh
05,15,25,35,45,55 * * * * /home/oracle/script/del_primary1.sh
#!/usr/bin/ksh
DATE=`date +%Y-%m-%d`
export ORACLE_HOME=/u01/app/oracle/product/10.2.0/db_1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_SID=jnywk
export PATH=$ORACLE_HOME/bin:$PATH
. ~/.profile
rman target / log=/u01/app/oracle/script/log/log_rman_$DATE <<eof
run
{
allocate channel d1 type disk;
backup archivelog all delete input format '/backup/ARCH-full%T%U';
backup current controlfile format '/backup/ctl_%s_%T.bak';
release channel d1;
crosscheck backup;
crosscheck archivelog all;
allocate channel for maintenance type disk;
05,15,25,35,45,55 * * * * /home/oracle/script/del_primary2.sh
$ cat /u01/app/oracle/script/rmanbackup0.rman
allocate channel d2 type disk;
backup incremental level=0 format '/backup/RMAN__%d-full%T%U' database;
sql 'alter system archive log current';
release channel d2;
}
#sql 'select * from v$recover_file';
DELETE FORCE NOPROMPT expired backup DEVICE TYPE DISK;
report obsolete redundancy 3; 
DELETE FORCE NOPROMPT OBSOLETE  redundancy 3 DEVICE TYPE DISK;
eof
$ cat /u01/app/oracle/script/rmanbackup1.rman
#!/usr/bin/ksh
DATE=`date +%Y-%m-%d`
export ORACLE_HOME=/u01/app/oracle/product/10.2.0/db_1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_SID=jnywk
export PATH=$ORACLE_HOME/bin:$PATH
. ~/.profile
rman target / log=/u01/app/oracle/script/log/log_rman_$DATE <<eof
run
{
allocate channel d1 type disk;
allocate channel d2 type disk;
backup incremental level=1 format '/backup/RMAN__%d-inc%T%U' database;
sql 'alter system archive log current';
backup archivelog all delete input format '/backup/ARCH-inc%T%U';
backup current controlfile format '/backup/ctl_%s_%T.bak';
release channel d1;
release channel d2;
}
#sql 'select * from v$recover_file';
crosscheck backup;
crosscheck archivelog all;
allocate channel for maintenance type disk;
DELETE FORCE NOPROMPT expired backup DEVICE TYPE DISK;
report obsolete redundancy 3; 
DELETE FORCE NOPROMPT OBSOLETE  redundancy 3 DEVICE TYPE DISK;
eof
$ 