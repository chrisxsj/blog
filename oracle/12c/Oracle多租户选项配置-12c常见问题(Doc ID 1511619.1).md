Oracle多租户选项配置-12c：常见问题 (Doc ID 1511619.1)。
本文档的
目的
问答
	在12c多租户体系架构中CDB/PDB一般概念
		在多租户架构中什么是可插拔数据库（PDB）？
		为什么我会考虑使用多租户选项配置？
		我可以从多租户选项中获得什么其他好处呢？
		将现有的12.1版本之前的数据库迁移到12c多租户数据库中很容易吗？
		在多租户架构中哪些数据库功能当前不受支持？
	基本的多租户CDB/PDB操作
		如何知道我的数据库是不是多租户架构？
		在容器数据库中我们有哪些可插拔数据库？
		如何连接到可插拔数据库，比如说，PDB6?
		如何切换到主容器数据库？
		如何确定我当前连接的是PDB还是CDB？
		如何启动一个可插拔数据库？
		如何停止/关闭一个可插拔数据库？
		如何关闭/启动一个容器数据库？
		在PDB级别可以修改哪些参数？
		在CDB中我可以有哪些通用用户？
		如何创建一个通用用户？
		如何创建一个本地用户？
	多租户体系架构
		容器id为0和1的区别是什么？
		PDB是否有相关的后台进程，如 PMON,SMON?
		每个PDB是否需要有自己单独的控制文件？
		在PDB中我可以通过PDB基础操作监视SGA的使用吗？
		在PDB中我可以通过PDB基础操作监视PGA的使用吗？
		每个PDB都需要有单独的UNDO表空间吗？
		每个PDB都需要有单独的SYSTEM表空间吗？
		每个PDB都需要有单独的SYSAUX表空间吗？
		每个PDB都需要有单独的临时表空间吗？
		对root和每个PDB我可以单独制定默认表空间吗？
		对于root和PDB数据文件是分开的吗？
		可插拔数据库支持单独的字符集吗？
		如何配置Oracle网络相关的配置文件在有可插拔数据库的环境中？
	高级CDB/PDB操作
		如何安装和设置可插拔数据库？
		在PDB中什么操作可以看作整体操作？
		如何创建一个可插拔数据库？
		如何永久删除一个PDB?
		如何克隆一个PDB从已存在的PDB?
		如何拔出一个PDB?
	可扩展性和RAC
		如何添加和更改一个用户管理的服务？
		如何查看哪个服务对应我的可插拔数据库？
	诊断
		如何查看可插拔数据库的告警日志？
		如何查看可插拔数据库相关的追踪日志？
	其他
		如果一个用户定义的通用用户在PDB中创建了一个模式对象，之后PDB被拔出并插入到另外一个CDB，这个CDB没有通用用户？模式对象会发生什么情况？它们将属于哪个用户？PDB中其他用户曾经被授予这些模式对象的相关权限的用户，仍然会保留自己的权限吗？
		多租户选项可以用在标准版中吗？
		一个事物可以跨越PDB执行吗？
		可以从每个容器相关的CDB_和V$视图中看到哪些数据？
		可以在每个单独的PDB中设置数据库时区吗？
		可以在每个单独的PDB中设置NLS货币参数（NLS_CURRENCY）配置吗?
		如何监视每个容器/数据库在CDB/PDB中对undo的使用？
		基于模式对象的整合数据库和多租户架构有什么区别？
			<内部使用>增强查询：13734561<内部使用>
>适用于：
Oracle Database - Enterprise Edition - Version 12.1.0.1 to 12.1.0.1 [Release 12.1]
Information in this document applies to any platform.

>目的：
对可插拔数据库多方面的描述文档和用法，为了更好的理解和快速参考这个产品。

>问答：

>>在12c多租户体系架构中CDB/PDB一般概念
>>>在多租户架构中什么是可插拔数据库（PDB）？
可插拔数据库（PDBs）是Oracle数据库12c发行版（12.1）的新特性。你可以有多个可插拔数据库在一个单独的数据库中。可插拔数据库向后完全兼容12.1版本之前的普通数据库。
>>>为什么我会考虑使用多租户选项配置？
您应该考虑下面数据库整合目的的实现
*减少经营成本
-管理成本
-操作成本
-数据中心成本
-存储成本
-意外事件成本
*提高功能性
-资源利用率
-可管理性
-集成性
-服务的管理
*不能更改应用程序
*不能损害性能
*在应用程序之前必须提供资源的管理和分离
*必要简化数据库的打补丁和升级过程
>>>我可以从多租户选项中获得什么其他好处呢？
多租户可插拔数据库的好处有：
*对新数据库快速资源调配或依据现有数据库生成一个副本
*快速重新部署，插拔一个数据库导到新的平台。
*对多个数据库快速打补丁和升级数据库版本，只需一次减少成本。
*一台机器可以运行多个数据库实例以PDB的形式，而不是单独数据库，这样做为一个整体数据库。
*通过Oracle提供的管理职责的分开使得应用程序管理员的职责是分开的。
>>>将现有的12.1版本之前的数据库迁移到12c多租户数据库中很容易吗？
升级到12c可插拔数据库非常的容易和简单，你可以评估和采用最适合你的那一个。
计划A：
升级一个12.1之前版本数据库到12.1版本
插入一个数据库到CDB
计划B：
每个需要合并的数据库提供空PDB
使用数据泵（datapump）和goldengate replication将数据迁移到PDB
>>>在多租户架构中哪些数据库功能当前不受支持？
以下的Oracle数据库功能当前不受支持在CDB中
*连续查询通知
*闪回数据归档
*热图
*自动数据优化
如果你必须使用以上的特性，需要创建一个NON-CDB

>>基本的多租户CDB/PDB操作
>>>如何知道我的数据库是不是多租户架构？
创建一个会话，然后执行以下的查询
SQL> select NAME, DECODE(CDB, 'YES', 'Multitenant Option enabled', 'Regular 12c Database: ') "Multitenant Option ?" , OPEN_MODE, CON_ID from V$DATABASE;

NAME                        Multitenant Option ?                  OPEN_MODE              CON_ID
---------           ------------------------------           --------------------           ----------
CDB2              Multitenant Option enabled                      MOUNTED                       0
>>>在容器数据库中我们有哪些可插拔数据库？
SQL>  select CON_ID, NAME, OPEN_MODE from V$PDBS;

    CON_ID NAME                          OPEN_MODE
---------- ------------------------       ------------
         2 PDB$SEED                         READ ONLY
         3 PDB1                                 MOUNTED
         4 PDB2                                 MOUNTED
         5 PDB3                                 MOUNTED
         6 PDB4                                 MOUNTED
         7 PDB5                                 MOUNTED
         8 PDB6                                 MOUNTED
         9 PDB7                                 MOUNTED
 ...
>>>如何连接到可插拔数据库，比如说，PDB6?
你可以以下的命令切换到PDB6从其他PDB或root容器
SQL> alter session set container = pdb6;
使用SQL*Plus CONNECT命令直接连接到PDB
你可以是用使用下面的方法连接到PDB使用SQL*Plus CONNECT命令
A)数据库简便连接方式
      Ex: CONNECT username/password@host[:port][/service_name][:server][/instance_name]

Examples of SQLPLUS from Os prompt:

$ sqlplus hpal/hpal@//hpal-node1:1521/pdb2
OR
$ sqlplus hpal/hpal@//localhost:1521/pdb2
OR
$ sqlplus hpal/hpal@//localhost/pdb2

SQL> show con_name

CON_NAME
------------------------------
PDB2
B)使用网络服务名
Example TNSNAMES.ora:

=======

LISTENER_CDB1 =
  (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))


CDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cdb1)
    )
  )

PDB2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = hpal-node1.us.oracle.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = pdb2)
    )
  )
=======

Example of SQLPLUS from Os prompt:

$ sqlplus hpal/hpal@pdb2
>>>如何切换到主容器数据库？
SQL> ALTER SESSION SET CONTAINER = CDB$ROOT;
>>>如何确定我当前连接的是PDB还是CDB？
SQL> show con_name

CON_NAME
------------------------------
PDB6

OR

SQL>  select sys_context ( 'Userenv', 'Con_Name') "Container DB" from dual;

Container DB
--------------------------------------------------------------------------------
PDB6
>>>如何启动一个可插拔数据库
当连接到当前的PDB:
SQL> alter pluggable database open;
当连接到root:
SQL> alter pluggable database pdb6 open;
>>>如何停止/关闭一个可插拔数据库
当连接到当前的PDB
SQL> alter pluggable database close;
当连接到root
SQL> alter pluggable database pdb6 close;
>>>如何关闭/打开容器数据库
使用startup/shutdown命令就像startup/shutdown一个非CDB
当容器数据库是关闭的状态，所有的PDB都不可访问
在CDB中，root和所有的PDBs共享一个实例，或者，当使用RAC的时候，共享多重并发数据库实例。你启动和关闭整个CDB，而不是单独的PDBs。然而，当CDB打开，你可以更改单独的PDB打开模式使用命令语句ALTER PLUGGABLE DATABASE。
>>>在PDB级别可以修改哪些参数？
select NAME, ISPDB_MODIFIABLE from V$PARAMETER;
>>>在CDB中我可以有哪些通用用户？
SQL> select distinct USERNAME from CDB_USERS where common = 'YES';
>>>如何创建一个通用用户
SQL> create user c##db_dba1 identified by manager1 container=all;
>>>如何创建一个本地用户
SQL> create user pdb6_dba1 identified by manager1 container=current; 

>>多租户体系架构
>>>容器id为0和1的区别是什么？
CON_ID为“0”表示数据不适用于任何特殊的容器但整体属于CDB.比如：从v$database获取一行数据，适用于CDB而不属于任意的特殊容器，所以CON_ID设置为“0”。一个容器数据对象就像CDB一样作为一个整体，我们可以想象到返回的数据适用于多个容器（包括root其CON_ID==1），在CDB中CON_ID将被设置为“0”。
下面的表描述CON_ID列多个不同值代表的数据对象有哪些
0=数据适用于整个CDB
1=数据适用于root
2=数据适用于seed
3-254=数据适用于PDB，每个PDB都有他自己的容器ID
>>>PDB是否有相关的后台进程，如 PMON,SMON?
没有，只有一组后台进程被root和所有的PDB共享
>>>每个PDB是否需要有自己单独的控制文件？
没有，只有单独的redo log和单独的control file对整个CDB.
>>>在PDB中我可以通过PDB基础操作监视SGA的使用吗？
只有单独的SGA被所有的可插拔数据库共享，然而，你可以确认SGA对所有容器的消耗使用。如：root和PDB
SQL> alter session set container=CDB$ROOT;
SQL> select POOL, NAME, BYTES from V$SGASTAT where CON_ID = '&con_id';
SQL> select CON_ID, POOL, sum(bytes) from  v$sgastat
group by CON_ID, POOL order by  CON_ID, POOL;
>>>在PDB中我可以通过PDB基础操作监视PGA的使用吗？
select CON_ID, sum(PGA_USED_MEM), sum(PGA_ALLOC_MEM), sum(PGA_MAX_MEM)
from  v$process
group by CON_ID order by  CON_ID;

alter session set container =CDB$ROOT;
select NAME , value from  v$sysstat  where NAME like 'workarea%';

alter session set container = <targetPDB>;
select NAME , value from  v$sysstat  where NAME like 'workarea%';
>>>每个PDB都需要有单独的UNDO表空间吗？
对单实例CDB来说只有一个活动的undo表空间，对RAC CDB来说，每个实例都有一个活动的undo表空间，只有那些有对应权限的通用用户和当前容器为root，才可以创建undo表空间
>>>每个PDB都需要有单独的SYSTEM表空间吗？
对root和每个PDB来说，都有一个单独的SYSTEM表空间
>>>每个PDB都需要有单独的SYSAUX表空间吗？
对root和每个PDB来说，都有一个单独的SYSAUX表空间
>>>每个PDB都需要有单独的临时表空间吗？
对整个CDB只有一个默认的临时表空间，然而，你可以在独立的PDBs中创建额外的临时表空间。单实例CDB至少需要一个活动的临时表空间，RAC CDB每个实例都需要一个活动的临时表空间。
>>>对root和每个PDB我可以单独制定默认表空间吗？
是的，对于root和PDB你可以指定单独的默认表空间。
>>>对于root和PDB数据文件是分开的吗？
是的，对于root，seed，和每个PDB都有单独的数据文件
在CDB中，用户数据如何存储呢？
在CDB中，多数用户数据在PDBs中，root容器没有用户数据或只有很少用户数据。
>>>可插拔数据库支持单独的字符集吗？
一个CDB使用一个字符集，所有的PDBs都使用同一个字符集。
Oracle建议：
*如果所有的PDBs都创建为空，对所有新应用部署来说，Oracle强烈建议在CDB中使用AL32UTF8字符集和AL16UTF6国家字符集
*如果你可以在整合之前将您现有的数据库迁移到 AL32UTF8，Oracle 建议你这样做，然后整合到一个或多个 AL32UTF8 CDB中。根据您的需要。对Unicode 您可以使用Oracle 数据库迁移助手将no-cdb迁移到 AL32UTF8。数据库创建之后，您不能使用Oracle 数据库迁移助手将CDB迁移到unicode。
*如果你不能迁移系哪有的数据库在整合之前，你需要将他们分成和插入数据库想兼容的部分，让后把他们出入到具有适当超集字符集的单独CDB中。
参考: Oracle Database Globalization Support Guide, 12c Release 1 (12.1)
>>>如何配置Oracle网络相关的配置文件在有可插拔数据库的环境中？
只有一个单独的listener.ora,tnsnames.ora和sqlnet.ora配置文件对于整个CDB来说，CDB中所有的pdbs都共同使用它们。

>>高级CDB/PDB操作
>>>如何安装和设置可插拔数据库？
使用runInstaller 安装数据库软件
使用dbca创建数据库。你可以创建多个可插拔数据库在这个操作中。
DBCA允许你在CDB中指定PDBs的个数在创建的过程中。CDB创建完成后，你可以使用DBCA插拔pdb在CDB中。
>>>在PDB中什么操作可以看作整体操作？
这些操作可以做为整体操作在PDBs中
*创建PDB(创建新的，依据现有的克隆，插入一个为插入的PDB)
*拔出PDB
*删除PDB
*设置PDB的open_mode
>>>如何创建一个可插拔数据库？
create pluggable database x admin user a identified by p;
create pluggable database y admin user a identified by p file_name_convert = ('pdbseed', 'y');
>>>如何永久删除一个PDB
drop pluggable database x
including datafiles;

How easy is it   to manage the provisioning of PDBs using PL/SQL ?

Following an Example of PL/SQL Code to show this.

-- Using Oracle-Managed Files

declare

t0 integer not null := -1;

procedure Show_Time(What in varchar2) is

t varchar2(10);

begin

t := Lpad((DBMS_Utility.Get_Time() - t0), 5);

DBMS_Output.Put_Line('create PDB:'||t||' centiseconds');

end Show_Time;

begin

t0 := DBMS_Utility.Get_Time();

execute immediate '

create pluggable database x

admin user a identified by p

';

Show_Time('create PDB:');

t0 := DBMS_Utility.Get_Time();

execute immediate '

drop pluggable database x

including datafiles

';

Show_Time('drop PDB: ');

end;
>>>如何从已存在的PDB克隆一个PDB
克隆必须以read only模式打开
-- Using Oracle-Managed Files
create pluggable database x2
from x;
>>>如何拔出一个PDB
alter pluggable database x unplug into '/some_directory/x_description.xml' ;
这个into关键字必须紧跟完整的PDB描述路径，操作生成的xml格式。

>>可扩展性和RAC
>>>如何添加和更改用户定义的服务
srvctl add service … –pdb <pdb_name>
开始使用的用户管理服务
srvctl会自动打开pdb实例，如果这些服务已经启动。指定空字符串 ("") 为 <pdb_name> 将导致可插入数据库服务要设置的属性为 null。然后，只能使用服务连接到root。
>>>如何查看哪个服务对应我的可插拔数据库？
SQL> column NAME format a30

SQL> select PDB, INST_ID, NAME from gv$services order by 1;

PDB                                    INST_ID    NAME
-------------------------------- ---------- --------------------------------
CDB$ROOT                                  1 cdb1XDB
CDB$ROOT                                  1 SYS$BACKGROUND
CDB$ROOT                                  1 SYS$USERS
CDB$ROOT                                  1 cdb1
PDB1                                           1 pdb1
PDB2                                           1 pdb2

>>诊断
>>>如何查看可插拔数据库的告警日志？
只有一个告警日志文件的副本生成，包括了所有PDBs警告和告警信息
XML版本的告警日志可以在“diag alert”下找到。text格式的告警日志可以在“diag trace”下发现，在容器数据库中。
你可以找到详细的内容，通过查询v$diag_info动态性能视图。
>>>如何查看可插拔数据库相关的追踪日志？
所有PDBs的追踪日志都可以在“diag trace”下发现。在容器数据库中。
你可以找到详细的内容，通过查询v$diag_info动态性能视图。

>>其他
>>>如果一个用户定义的通用用户在PDB中创建了一个模式对象，之后PDB被拔出并插入到另外一个CDB，这个CDB没有通用用户？模式对象会发生什么情况？它们将属于哪个用户？PDB中其他用户曾经被授予这些模式对象的相关权限的用户，仍然会保留自己的权限吗？
如果你插入一个拥有通用用户的PDB到一个CDB。下面的情况将会发生：
PDB中的通用用户将失去曾经拥有的被授予的权限。包括SET CONTAINER权限
如果目标CDB数据库中有一个通用用户和新插入的PDB中的通用用户重名。这两个用户将会聚合。目标CDB数据库中通用用户密码具有优先级。否则新插入PDB中的通用用户将被锁定，在这种情况下，你可以做胰以下的操作之一：
	离开锁定的账户，并使用他模式对象。
	使用数据泵将对象迁移到其他模式对象，然后删除锁定的账户。
	关闭PDB，连接到root，然后以锁定账户相同名字创建通用账户，当你重新打开PDB，oracle数据库解决这个角色和权限的差异。然后，你就可以解锁这个用户在PDB中。本地授予权限和角色将会任然保持。
>>>多租户选项可以用在标准版中吗？
可以，但是在每个CDB中你只能创建一个PDB.
>>>事物可以跨PDBS执行吗？
不能，再PDB中开始事物后，即使"alter session set container"被使用，只有select被允许在2个PDB中。但是，事物会被保存，当你切换回原来的PDB，你可以提交或回退这个事物。
>>>可以从每个容器相关的CDB_和V$视图中看到哪些数据？
CDB_*视图是容器数据对象。当一个用户连接到root查询CDB_*视图，这个查询结果将会依赖这个用户这个视图的CONTAINER_DATA属性。 ALTER USER语句的CONTAINER_DATA子句用来设置和更改用户的CONTAINER_DATA属性。
在CDB的root，CDB_*视图可以用来获取root和PDB相关的表，表空间，用户，权限，参数等信息
这个CDB_*视图属于sys用户，无论谁拥有基础的DBA_*视图。
默认情况下，用户连接到root将只能看到适用于root的数据。
>>>可以在每个单独的PDB中设置数据库时区吗？
可以
>>>可以在每个单独的PDB中设置NLS货币参数（NLS_CURRENCY）配置吗?
可以
>>>如何监视每个容器/数据库在CDB/PDB中对undo的使用？
select NAME,MAX(TUNED_UNDORETENTION), MAX(MAXQUERYLEN), MAX(NOSPACEERRCNT), MAX(EXPSTEALCNT)
from V$CONTAINERS c , V$UNDOSTAT u
where c.CON_ID=u.CON_ID
group by NAME;

select NAME,SNAP_ID,UNDOTSN,UNDOBLKS,TXNCOUNT,MAXQUERYLEN,MAXQUERYSQLID
from V$CONTAINERS c , DBA_HIST_UNDOSTAT u
where c.CON_ID=u.CON_ID
and u.CON_DBID=c.DBID
order by NAME;
>>>基于模式对象的整合数据库和多租户架构有什么区别？
1 名字冲突可能会组织基于模式对象的架构整合
2 基于模式对象的整合具有较低的安全性
3 每个应用程序，后台功能，基于点的恢复会异常困难
4 在应用程序和后台功能的资源管理会很困难
5 针对单个应用程序，后台功能，打oracle版本补丁会比较困难
6 克隆大哥应用程序，后台功能会比较困难