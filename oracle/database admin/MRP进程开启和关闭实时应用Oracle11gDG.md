# MRP 进程开启和关闭实时应用 Oracle11g DG


1、关闭MRP进程（停止应用日志）：
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;


2、开启MRP进程（开启应用日志）：
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;


3、查看应用日志延迟时间：
select value from v$dataguard_stats where name='apply lag';


4、查看接收日志延迟时间：
select value from v$dataguard_stats where name='transport lag';


5、删除两天前的归档日志：
su - oracle  【切换到数据库用户下】
rman target /
delete noprompt archivelog until time 'sysdate-2' all;

6、查看ASM DISKGROUP使用率：
set lines 300 pages 9999
col name for a15
col USED_PERCENT for a15
select GROUP_NUMBER,NAME,TOTAL_MB/1024 total_gb,FREE_MB/1024,USABLE_FILE_MB/1024,round((TOTAL_MB-USABLE_FILE_MB)*100/TOTAL_MB)||'%' USED_PERCENT
FROM V$ASM_DISKGROUP ORDER BY 1;



--补充：
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
停止redo应用
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
开启redo应用