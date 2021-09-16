oracle auto backup for windows

script

windows 调用sql脚本

insert.bat
sqlplus / as sysdba @D:\insert.sql
insert.sql
insert into test values (1);
coomit;
quit
1 创建脚本 bak_rman.bat
#echo %date%
#echo %time%
#set da=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
#set oracle_sid=orcl
#set oraclepath="d:\app\Administrator\product\11.2.0\dbhome_1"
rman  cmdfile=D:\script\bak_rman.rcv log=D:\script\log\bak_rman%da%.log
2 创建脚本 bak_rman.rcv
connect target sys/oracle@hosp
run {
allocate channel d1 type disk;
allocate channel d2 type disk;
allocate channel d3 type disk;
backup database format 'D:\backup\full%U';
sql 'alter system archive log current';
backup archivelog all delete input format 'D:\backup\arc%U';
backup current controlfile format 'D:\backup\ctl%U';
backup spfile format 'D:\backup\spfie%U';
release channel d1;
release channel d2;
release channel d3;
}
run {
#sql 'select * from v$recover_file';
crosscheck backup;
delete noprompt expired backup;
crosscheck archivelog all;
delete noprompt expired archivelog all;
crosscheck copy;
delete noprompt expired copy;
report obsolete;
delete noprompt obsolete device type disk;
}

==============
记得在rman中打开控制文件的自动备份

在任务计划里设置！！！！

打开计划任务程序》右击，创建基本任务》常规，不管用户是否登录都要运行》