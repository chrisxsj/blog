Home / Database / Oracle Database Online Documentation 11g Release 2 (11.2) / Database Administration
Database Security Guide



>sys管理员无法登录案例
数据库使用sys管理员登录报错，普通用户可以正常登录
从alert log中可以看到告警信息，无法生成trace file
查看本地磁盘空间满，但为什么会出现sys无法登录，普通用户可以登录的怪现象呢？

因为sys登录会生成审计trac文件，而没有空间存放审计文件就会造成以上的现象

> 基础知识
Oracle审计分类
一般活动标准数据库审计：可审计sql语句，权限，对象等
默认安全相关的sql语句及权限审计：数据库提供的默认审计，可启用和关闭
详列细的细粒度审计：可审计列对象，执行触发器等
sys管理员用户审计：可审计顶级sql，包括sys执行的命令语句

针对sys用户审计需要知道几点
1sys用户或以sysdba/sysoper权限登录数据库的审计是默认强制的
2 如果想额外记录此用户更多的操作信息，需要启用sys管理员操作审计
ALTER SYSTEM SET AUDIT_SYS_OPERATIONS=TRUE SCOPE=SPFILE;
3 不管参数设置成那种db形势，sys管理员用户审计的审计记录都会存储在操作系统上，因为sys用户可以清空SYS.AUD$ table
This enables you to write the actions of administrative users to an operating system file, even if the AUDIT_TRAIL parameter is set to NONE, DB, or DB, EXTENDED

针对sys用户审计记录目录位置
1 audit_file_dest参数指定的目录----优先使用
2 $ORACLE_BASE/admin/$ORACLE_SID/adump----如果audit_file_dest参数没有设置使用第一默认路径
3 $ORACLE_HOME/rdbms/audit   --第一默认路径失败或数据库为关闭状态使用备份默认路径
4 alert log  ---以上皆无法写入，在alert log中记录错误信息



> sys默认强制审计测试
SQL> conn / as sysdba
SQL> select userenv('sid') from dual;

USERENV('SID')
--------------
            41

select s.sid,s.serial#,p.spid from v$session s,v$process p where s.paddr=p.addr and s.sid=41;SQL> select s.sid,s.serial#,p.spid from v$session s,v$process p where s.paddr=p.addr and s.sid=41;

       SID    SERIAL# SPID
---------- ---------- ------------------------
        41        113 13991

SQL>

$ cat /u02/app/oracle/admin/orcl/adump/*13991*.aud

Audit file /u02/app/oracle/admin/orcl/adump/orcl_ora_13991_1.aud
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options
ORACLE_HOME = /u02/app/oracle/product/11.2.0/dbhome_1
System name:    Linux
Node name:      db
Release:        2.6.32-358.el6.x86_64
Version:        #1 SMP Tue Jan 29 11:47:41 EST 2013
Machine:        x86_64
VM name:        VMWare Version: 6
Instance name: orcl
Redo thread mounted by this instance: 1
Oracle process number: 31
Unix process pid: 13991, image: oracle@db (TNS V1-V3)

Thu Nov 10 19:14:47 2016 +08:00
LENGTH : '160'
ACTION :[7] 'CONNECT'
DATABASE USER:[1] '/'
PRIVILEGE :[6] 'SYSDBA'
CLIENT USER:[6] 'oracle'
CLIENT TERMINAL:[5] 'pts/0'
STATUS:[1] '0'
DBID:[10] '1395555907'

文档原创，转载请注明出处-------------------


