

![image-20200519170406920](https://gitee.com/jasonxian/picture/raw/master/oracle-bak-image-20200519170406920.png)

知识

backup：1 数据都是放在磁盘驱动器这样的机械装置里，因此极易受到诸如电源故障和自然灾害等无法预料事件损坏。

​    2 程序和用户错误也需要强大备份的保护

备份是为了恢复而备份

recover：1 必须在尽可能短的停机时间内使数据库恢复到正常操作状态

​     2 决不能丢失任何有用的数据。

数据库全备

1 用户管理的备份和恢复:操作系统命令冷备。逻辑备份只能作为物理备份的补充手段

2 Rman.热备，如果使用闪回恢复区，则可自动管理磁盘空间。否则，手动管理磁盘空间。物理备份是最强健的保护方式。是备份首选。

3 oracle secure backup可将数据文件直接备份到磁带上

4 可使用oracle中的闪回技术恢复逻辑错误！

flashback database，flashback table，flashback drop，flashback query，flashback version query，flashback transaction query

参考《11G数据库管理艺术》16章

recover所需组件

控制文件：数据文件和日志文件信息及最新的系统更改号scn

数据库备份：数据文件备份-由于定期制作，可能未包含数据库最新数据

​      归档日志文件备份

重做日志：包括数据库所有更改，提交和未提交的。

撤销记录：未提交更改块的前映像。

恢复分为，实例恢复和介质恢复

1 实例恢复：

1 根据联机日志内容进行rollover

2 打开数据库，提供服务

3 smon或用户进程进行rollback

实例恢复过程

重做应用从重做日志中的某个点（线程检查点重做字节地址-thread checkpoint redo byte address）开始，

崩溃之前完成的最后一个检查点就是这时完成的（检查点完成后所有数据都刷新到磁盘）。所以只有最后检查点位置之后的数据需要恢复。

快速启动检查点（fast-start checkpointing）经常让dbwn刷新dirty data到disk。

他是Oracle fast-start fault recovery（Oracle快速启动故障恢复)的基础。

可通过不断前移checkpoint是恢复时间最少

Oracle 使用两遍式扫描技术利用检查点执行恢复。第一遍扫描中确定日志文件中那些数据块需要恢复，第二遍扫描中数据库运用所需更改。

Oracle 10G开始，自动检查点调优,更具何时进行dbwn对吞吐量最小。

FAST_START_MTTR_TARGET 设置估计崩溃恢复所需时间。默认为0最大3600秒

alter database set FAST_START_MTTR_TARGET=60;

select recovery_estimated_ios,estimated_mttr,target_mttr from v$instance_recovery;

使用Oracle fast-start fault recovery（Oracle快速启动故障恢复)可将崩溃恢复时间降至1分钟一下，

虽让频繁的检查点有性能成本，但研究表明可忽略不计（I/O？？？？）

快速实例启动。

 

 

2 介质恢复：恢复到故障点。包括完全恢复和不完全恢复。

介质恢复不是自动化，需启动恢复进程

介质恢复：打开的介质恢复（数据库打开使用，只是部分表空间脱机）和关闭的介质恢复（整个数据库关闭）

需要以下4个条件

全备

全备以来的归档

控制文件副本

当前联机在线日志

介质回复过程

告诉缓存恢复（前滚）：应用归档日志文件和重做日志文件是数据库恢复为最新的过程称之为告诉缓存恢复

完成高速缓存恢复将获得所有已提交和未提交更改

事物回复（回退）：Oracle通过告诉缓存恢复（前滚）获得撤销数据，他从重做日志重新生成回滚段

完全恢复，restore，recover：没有数据丢失的恢复

restore：使用备份副本替换丢失的数据文件和控制文件称为复原

recover：使用备份副本的数据文件和归档重做日志文件是数据库恢复到最新为恢复

特例：数据库结果发生了变化

select name from v$datafile;

backup database;

create tablespace ttt datafile '+DATA';

alter tablespace ttt add datafile '+DATA';

select name from v$datafile;

create table test as select * from hr.employees;

关闭数据库，删除数据文件。模拟灾难场景

启动数据库

restore不可行，没有想想过数据库文件备份。recover不行，想过物理文件不存在

alter database create datafile 5;

alter database create datafile ‘+DATA/test2.dbf';

recover datafile 5; --此时出错，asm建立时要求文件名唯一，此时文件名与控制文件中名字不一致

alter database rename file ’+DATA/...' to '+DATA/..';

..

RECOVER DATAFILE 5;

不完全恢复：无法恢复到故障那一点。只能恢复到之前哪一点，数据会丢失或数据不是最新版本

用户错误数据丢失需要不完全恢复

参数文件（重建），控制文件（备份或重建），数据文件（备份）丢失不会引起数据丢失。

联机日志或归档日志，可能会引起不完全恢复。

对于inactive的联机日志，损坏或丢失。可以直接删除，在添加一組新的日志

current/active状态联机日志损坏：正常关闭数据库，联机日志内没有未决事务。恢复后只需重建日志即可，不会丢失数据。数据库异常关闭，关闭时还有未决事务，instance recovery后，可能会造成数据丢失。。需要不完全恢复。

例子：

backup database

shutdown abort

删除控制文件，数据文件，在线日志文件。

restore controlfile from ’/oracle....';

sql 'alter database mount';

restore database;  --此时恢复过程中，sm建立时要求文件名唯一，此时恢复过来的数据文件改名并登入到控制文件中。

select name from v$archived_log; --查看控制文件中归档日志记录；

查看磁盘归档。。。会有缺少的归档在备份之后产生。

使用rman， catalog 相关归档

rman> catalog archivelog '...';

此时执行不完全恢复

sql> recover database using backup controlfile until cancel; --单实例归档scn连续分布。会尝试重用所有归档日志。rac下scn在实例间分布，scn不连续。某些归档存在但是不能恢复到走后时刻。

alter database open resetlogs;

 

 

3 非介质恢复

闪回

logminer

datapump

4 使用rman恢复

rman的好处

选择应用必须的数据和日志文件

选择需要恢复的最近的备份集和映像副本

利用块介质恢复

提供复原优化，恢复过程中绕过好的数据文件

使用增量恢复

使用duplicate 克隆数据库

5 验证rman备分

list backupset --获取备份集信息

validate backupset 1  --验证备份集是否可用

最后一行validation complete是rman认定备份集可用的信息。

restore tablespace users validate  --确认是否可从备份集中复原数据

restore database review  --验证恢复所需的数据文件和日志文件

restore tablespace users

restore datafile 3 review

6 找出需要恢复的文件

select r.file#  as df#,

​    d.name  as df_name,

​    t.name  as tbsp_name,

​    d.status,

​    r.error,

​    r.change#,

​    r.time

 from v$recover_file r, v$datafile d, v$tablespace t

 where t.ts# = d.ts#

  and d.file# = r.file#;

7 监控rman作业

select operation,status from v$rman_status;

select operation,status,start_time,end_time from v$rman_staus; --查询备份状态

select opname,to_char(start_time,'DD-MON-YY HH24:MI:SS') "start of backup",sofar,totalwork,elapsed_seconds/60 "elapsed time in minutes",round(sofar/totalwork*100,2) "percentage complleted so far" from v$session_longops where opname='NAME'; --查询备份进度

8 用户管理的备份和恢复