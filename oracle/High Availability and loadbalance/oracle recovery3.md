restore spfile

RMAN> startup nomount;

已连接到目标数据库 (未启动)
启动失败: ORA-01078: failure in processing system parameters
LRM-00109: ???????????????? 'D:\ORACLE\LIANGWEI\PRODUCT\11.2.0\DBHOME_1\DATABASE\INITLW.ORA'
在没有参数文件的情况下启动 Oracle 实例以检索 spfile
Oracle 实例已启动
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: startup 命令 (在 09/21/2011 22:15:22 上) 失败
ORA-00205: 标识控制文件时出错, 有关详细信息, 请查看预警日志
 RMAN> restore spfile to 'D:\ORACLE\LIANGWEI\spfile.ora' from 'D:\ORACLE\LIANGWEI\FLASH_RECOVERY_AREA\LW\AUTOBACKUP\2011_09_21\O1_MF_S_7
SQL> shutdown immediate; 
SQL> startup;  