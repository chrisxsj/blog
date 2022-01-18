# hgaudit

**作者**

Chrisx

**日期**

2021-05-19

**内容**

瀚高数据库审计功能

ref [管理手册-12 安全审计](./)

----

[TOC]

## 概述

用户配置审计事件/系统审计事件-->审计事件发生-->审计模块把审计事件记录到审计文件当中，若配置了审计分析规则，按照审计分析规则做额外的处理。

* Data/hgaudit :审计文件生成的路径，审计文件的格式hgaudit-2020-09-10-111948.log
* Data/hgaudit/audit_archive_ready：写完一个审计文件，会在该路径下生成 hgaudit-2020-09-10-111948.log.ready ，这个是审计归档的依据。

审计记录查看，hgaudit_imp 导入到 hg_t_audit_log，syssao 用户查看

```sql
highgo=> select log_time,audittype,oper_opts,username,dbname,command from public.hg_t_audit_log where oper_opts ='DELETE';
           log_time            | audittype | oper_opts | username | dbname |               command
-------------------------------+-----------+-----------+----------+--------+--------------------------------------
 2021-05-24 06:01:26.104649+00 | statement | DELETE    | taudit   | highgo | delete from test_audit where id >90;
 2021-05-24 06:01:26.104668+00 | statement | DELETE    | taudit   | highgo | delete from test_audit where id >90;
 2021-05-24 06:01:26.10467+00  | statement | DELETE    | taudit   | highgo | delete from test_audit where id >90;
 2021-05-24 06:01:26.104671+00 | statement | DELETE    | taudit   | highgo | delete from test_audit where id >90;
 2021-05-24 06:01:26.104671+00 | statement | DELETE    | taudit   | highgo | delete from test_audit where id >90;
 2021-05-24 06:01:26.104672+00 | statement | DELETE    | taudit   | highgo | delete from test_audit where id >90;
 2021-05-24 06:01:26.104673+00 | statement | DELETE    | taudit   | highgo | delete from test_audit where id >90;
(7 rows)
```

## 审计配置

### 1. 安全审计参数配置

审计管理员可以通过 select show_audit_param();来查看当前的审计策略配置。默认配置如下

```sql
highgo=> select show_audit_param();
          show_audit_param
------------------------------------
 hg_audit = on,                    +    --审计总开关，默认为 on。
 hg_audit_analyze = off,           +    --审计分析开关，on 表示需要检查用户配置的审计事件风险等级， 并根据风险等级进行处理，off 表示只记录审计记录，而不处理风险等级，默认为 off.
 hg_audit_alarm = email,           +    --审计告警方式，启用 email 告警方式，即当需要进行审计告警时， 发送邮件到 hg_audit_alarm_email 所配置的邮箱.
 hg_audit_alarm_email =            +    --审计告警邮箱.
 hg_audit_logsize = 16MB,          +    --生成的审计文件大小，可配置的范围为 16MB~1GB；默认为 16MB。
 hg_audit_keep_days = 7,           +    --目录下的审计记录文件所保存的时间(以天为单位)，若 超过这个时间，相关文件将会被删除。（该参数在 HGDB-SEE V4.5.6 及以后的版本中 支持）
 hg_audit_full_mode = 1            +    --当没有足够的磁盘空间时的审计处理策略。可取值为 1,2。取 值为 1 时：暂停审计，并发出告警；取值为 2 时：采取 1 的策略外，同时停止数据库服务。当一条审计日志写入磁盘失败后，就会认为当前磁盘空间不足，系统会自动发送邮 件至审计告警邮箱，同时，审计日志里会记录给 xxx 邮箱发送了一封邮件。
 hg_audit_file_archive_mode = off, +    --审计自动归档模式的开关，on 表示打开审计文件自动 归档，审计归档进程扫描 hgaudit/udit_archive_ready 下的 ready 文件，把相应的审计日 志文件归档到 hg_audit_file_archive_dest 指定的路径下。默认为 off
 hg_audit_file_archive_dest =      +    --审计归档路径，只支持绝对路径。设定的路径必须存在 且数据库运行用户对其有写权限。

```

审计管理员可以用 select set_audit_param()函数来设置上述配置，第一个参数是要配置的参数名称，后边是要设置的值，两个参数全部都是字符串类型。

### 2. 安全审计策略配置

审计管理员可以对安全审计策略进行配置，可以配置语句审计与对象审计。

参考[管理手册-12 安全审计](./)

1. 语句审计

```sql
audit statement_opts by username|all [whenever [not] successful]
```

* statement_opts：支持指定多个语句类型，用逗号分隔；如果对所有语句进行审计，则使用 all，此时，对每一种语句记录一条审计配置项；（支持的语句见 12.6）
* 配置后的语句审计策略可以通过系统视图 hgaudit_statement 查看
* 审计管理员可以删除已配置的语句审计策略

```sql
audit delete,truncate,drop table by taudit whenever successful;
select * from hgaudit_statement;
noaudit delete,truncate,drop table by taudit whenever successful;
```

2. 对象审计

```sql
audit object_opts on objtype [schema.]objname[.colname] by username|all [whenever [not] successful]
```

* object_opts：支持指定多个操作类型，用 逗号分隔；如果对该对象的所有操作审计，则使用 all；此时，对每一种操 作类型记录一条审计配置项。（支持的语句见 12.6）
* objtype：要审计的对象的类型，必填项；支持 table、view、column、sequence、 function、procedure；不支持同时指定多个。
* colname：列名。表示对该列进行审计。当 objtype 为 column 时才需要指定列名，若不指定，表示对表的所有列进行审计。
* 配置之后的对象审计策略可以通过系统视图 hgaudit_object 查看

```sql
audit delete,truncate on table public.test_audit by taudit whenever successful;
select * from hgaudit_object;
noaudit delete,truncate on table public.test_audit by taudit whenever successful;
```

## 3. 特殊的审计事件

除了用户自主配置的审计事件，系统中还定义了两种类型的特殊审计事件
1、mandatory(强制审计事件)：
一定会被审计的事件，无论审计功能是否开启 该类型的事件目前只包含一个：审计总开关 hg_audit 修改。
注：该审计事件在 HGDB-SEE V4.5.3 及以后的版本中支持
2、system(系统审计事件)：
不需要用户配置，只要 hg_audit 为 on 就会审计 包含以下事件

* 数据库启动
* 数据库停止
* 用户登陆
* 用户登出
* reload 配置文件

## 审计记录

审计记录包括以下信息

```sql
highgo=# \d public.hg_t_audit_log
                         Table "public.hg_t_audit_log"
       Column       |           Type           |
--------------------+--------------------------+
 log_time           | timestamp with time zone |    --记录时间
 risklevel          | "char"                   |    --风险等级
 audittype          | text                     |    --审计类型：包含 system(系统审计事件)，statement(语句审 计事件)，object(对象审计事件)，mandatory(强制审计事件)
 oper_opts          | text                     |    --审计语句类型
 username           | text                     |    --用户名
 rolename           | text                     |    --角色名称
 dbname             | text                     |    --数据库名称
 objtype            | text                     |    --对象类型
 schemaname         | text                     |    --模式名称
 objectname         | text                     |    --对象名称
 colname            | text                     |    --列名称
 privlevel          | text                     |    --权限等级：包含 SYSTEM，DATABASE， SCHEMAOBJECT，INSTACE
 procpid            | integer                  |    --进程 id
 session_start_time | timestamp with time zone |    --会话开始时间
 action_start_time  | timestamp with time zone |    --操作开始时间
 tansaction_id      | integer                  |    --事务 id
 client_mac         | text                     |    --客户端 mac
 client_ip          | text                     |    --客户端 ip
 client_port        | text                     |    --客户端 端口
 application_name   | text                     |    --客户端应用
 server_mac         | text                     |    --服务器 mac
 server_ip          | text                     |    --服务器 ip
 server_port        | text                     |    --服务器 端口
 command            | text                     |    --sql 命令
 affect_rows        | integer                  |    --命令影响的行数
 return_row         | integer                  |    --命令返回行数
 duration           | double precision         |    --命令持续时间
 result             | text                     |    --命令执行结果（成功或失败）

highgo=#

```

审计管理员可以通过审计导入工具 hgaudit_imp 把指定的审计文件导入 public.hg_t_audit_log 表中，审计管理员可以查看该表。
hgaudit_imp 使用时，会验证审计管理员的密码。

hgaudit_imp 支持的选项有：

* -f：指定需要导入的审计日志的文件，支持指定多个文件，多个文件用逗号分隔。 支持指定绝对路径和相对路径，相对路径相对于审计日志文件路径 $PGDATA/data/hgaudit。如不指定-f，则表示当前归档目录及审计日志目录下的审 计记录。未写完的审计日志也支持导入。
* -d：指定需要导入的数据库。
* -h：指定要连接数据库 IP（该参数在 HGDB-SEE V4.5.3 及以后的版本中支持）
* -p：指定数据库的 port（该参数在 HGDB-SEE V4.5.3 及以后的版本中支持）
* -P：syssao 用户的密码

```sh
hgaudit_imp -f $PGDATA/hgaudit/hgaudit-2021-04-22-063813.log -d highgo -p 5966
select * from public.hg_t_audit_log where COMMAND like 'delete%';
```

## 审计分析

用户配置相应事件的风险等级-->审计事件发生的时候，根据风险等级发生相应的告警行为

* 用户可以通过参数 hg_audit_analyze，hg_audit_alarm，hg_audit_alarm_email 来配置 告警的方式。
* 当 hg_audit_analyze 为 on，hg_audit_alarm 为 email,且 hg_audit_alarm_email 为有效 邮箱的时候，告警方式即为向邮箱 hg_audit_alarm_email 发送告警邮件,并向 系统日志中 输出 warning.
* 若只有 hg_audit_analyze 为 on，其他两个参数未配置或无效，则只向系统日志中输 出 warning.

我们把审计事件分为 3 个等级，分别的告警行为为

* 低风险（1）：按照配置的告警方式告警
* 中风险（2）：违例进程终止。终止当前操作，但是用户连接仍存在。同时进行告警。
* 高风险（3）：服务取消。终止当前操作，断开用户连接，退出登录。同时进行告警。

用户可以使用函数自主配置审计事件的风险等级，以便触发相应的告警行为，我们称之为审计分析规则，操作审计分析规则使用内置函数完成。

添加一个审计分析规则：

```sql
add_actionaudit_rule(rulename,audittype,auditevent,risklevel)
```

* rulename：规则名称，必填项，唯一。
* audittype：审计类型，可取值 statement、object；必填项。
* auditevent：审计事件：填写 confid；必填项。
* risklevel：风险等级：1、2、3 分别代表低风险、中风险、高风险；必填 项，默认为 1

审计分析规则也可以被修改和删除。

示例

```sql
select set_audit_param('hg_audit_analyze','on'); --打开审计分析开关
restart
select * from hgaudit_statement;   --confid（24576），delete，risklevel=0
select add_actionaudit_rule('a','statement',24576,'1'); --添加一个审计规则
select * from hgaudit_statement;   --再次查看，risklevel=1
delete from test_audit where id=1; --delete操作成功,但有 warning
select alter_actionaudit_rule('a','2');   --修改风险等级为2
delete from test_audit where id=2; --delete操作失败，
```

<!--
操作成功，告警信息
2021-06-17 07:37:01.525 UTC,"taudit","highgo",18643,"[local]",60cafb5d.48d3,3,"DELETE",2021-06-17 07:35:57 UTC,4/20,571,WARNING,01000,"taudit performs a dangerous operation in the database highgo:delete from test_audit where id=1;",,,,,,,,,"psql"
2021-06-17 07:37:01.525 UTC,"taudit","highgo",18643,"[local]",60cafb5d.48d3,4,"DELETE",2021-06-17 07:35:57 UTC,4/20,571,WARNING,01000,"taudit performs a dangerous operation in the database highgo:delete from test_audit where id=1;",,,,,,,,,"psql"

操作失败，告警信息
2021-06-17 07:45:25.752 UTC,"taudit","highgo",19109,"[local]",60cafd93.4aa5,3,"DELETE",2021-06-17 07:45:23 UTC,4/27,0,ERROR,XX000,"taudit performs a dangerous operation in the database highgo:delete from test_audit where id=2;
,force to abort current operation",,,,,,"delete from test_audit where id=2;",,,"psql"
2021-06-17 07:45:25.752 UTC,"taudit","highgo",19109,"[local]",60cafd93.4aa5,4,"DELETE",2021-06-17 07:45:23 UTC,4/27,0,WARNING,01000,"taudit performs a dangerous operation in the database highgo:delete from test_audit where id=2;",,,,,,,,,"psql"

-->

## 审计归档

把写完的审计文件归档到归档路径

配置参数

```sql
select set_audit_param('hg_audit_file_archive_mode','on');
select set_audit_param('hg_audit_file_archive_dest','/opt/HighGo4.5.6_audi_arch');
restart
```

这样审计文件会被连续的长时间保存。

相比pgaudit，hgaudit对于审计功能进行了增强和完善。除了支持语句和对象审计，还支持特殊审计、审计分析规则、审计归档。