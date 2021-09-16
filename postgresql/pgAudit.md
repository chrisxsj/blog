# pgAudit

**作者**

Chrisx

**日期**

2021-04-25

**内容**

pgaudit审计插件

Open Source PostgreSQL Audit Logging

ref [pgAudit](https://github.com/pgaudit/pgaudit)

---

[TOC]

:warning:2ndQuadrant开源项目

是pg的一个扩展插件,能够提供详细的会话和对象审计日志。以满足个人或组织对审计的需求

为了支持每个 PostgreSQL 版本中引入的新功能，pgAudit 为每个 PostgreSQL 主要版本（当前 PostgreSQL 9.5 - 13）维护一个单独的分支，该分支将以类似于 PostgreSQL 项目的方式维护。

pgAudit versions relate to PostgreSQL major versions as follows:

```bash
pgAudit v1.5.X is intended to support PostgreSQL 13.
pgAudit v1.4.X is intended to support PostgreSQL 12.
pgAudit v1.3.X is intended to support PostgreSQL 11.
pgAudit v1.2.X is intended to support PostgreSQL 10.
pgAudit v1.1.X is intended to support PostgreSQL 9.6.
pgAudit v1.0.X is intended to support PostgreSQL 9.5.
```

## 1.安装插件

此插件没有加入到pg核心，需要单独下载安装。本文以pg13为例

[源码地址-master](https://github.com/pgaudit/pgaudit)

[源码地址-branches](https://github.com/pgaudit/pgaudit/branches)

```bash
unzip pgaudit-master.zip
unzip pgaudit-REL_13_STABLE.zip

mv pgaudit-REL_13_STABLE pgaudit-master

cd pgaudit-master
make install USE_PGXS=1 PG_CONFIG=/opt/pg131/bin/pg_config

```

<!--
[pg131@db pgaudit-master]$ make install USE_PGXS=1 PG_CONFIG=/opt/pg131/bin/pg_config
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o pgaudit.o pgaudit.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -shared -o pgaudit.so pgaudit.o  -L/opt/pg131/lib    -Wl,--as-needed -Wl,-rpath,'/opt/pg131/lib',--enable-new-dtags
/bin/mkdir -p '/opt/pg131/lib/postgresql'
/bin/mkdir -p '/opt/pg131/share/postgresql/extension'
/bin/mkdir -p '/opt/pg131/share/postgresql/extension'
/bin/install -c -m 755  pgaudit.so '/opt/pg131/lib/postgresql/pgaudit.so'
/bin/install -c -m 644 .//pgaudit.control '/opt/pg131/share/postgresql/extension/'
/bin/install -c -m 644 .//pgaudit--1.5.sql  '/opt/pg131/share/postgresql/extension/'
[pg131@db pgaudit-master]$

-->

查看可用的扩展插件

```sql
postgres=# select * from pg_available_extensions where name like '%audit%';
  name   | default_version | installed_version |             comment
---------+-----------------+-------------------+---------------------------------
 pgaudit | 1.5             |                   | provides auditing functionality
(1 row)

```

## 2.配置

### 安装加载扩展

```sql
alter system set shared_preload_libraries=pgaudit;
\! pg_ctl restart
create extension pgaudit;
\dx

```

<!--
Settings
Settings may be modified only by a superuser. Allowing normal users to change their settings would defeat the point of an audit log.

Settings can be specified globally (in postgresql.conf or using ALTER SYSTEM ... SET), at the database level (using ALTER DATABASE ... SET), or at the role level (using ALTER ROLE ... SET). Note that settings are not inherited through normal role inheritance and SET ROLE will not alter a user's pgAudit settings. This is a limitation of the roles system and not inherent to pgAudit.

The pgAudit extension must be loaded in shared_preload_libraries. Otherwise, an error will be raised at load time and no audit logging will occur. In addition, CREATE EXTENSION pgaudit must be called before pgaudit.log is set. If the pgaudit extension is dropped and needs to be recreated then pgaudit.log must be unset first otherwise an error will be raised.
-->

### pgaudit 的参数

参数信息

```sql
select name,setting from pg_settings where name like 'pgaudit%';
            name            | setting
----------------------------+---------
 pgaudit.log                | none
 pgaudit.log_catalog        | on
 pgaudit.log_client         | off
 pgaudit.log_level          | log
 pgaudit.log_parameter      | off
 pgaudit.log_relation       | off
 pgaudit.log_statement_once | off
 pgaudit.role               |
(8 rows)


```

通过配置参数来审计不同类别的命令

详细参数参照[pgaudit文档](https://github.com/pgaudit/pgaudit)

```sql
alter system set pgaudit.log = WRITE,ROLE,DDL;
or
set pgaudit.log = WRITE,ROLE,DDL;
```

### 审计策略

#### Session Audit Logging

会话审核日志记录提供用户在后端执行的所有语句的详细日志。

配置
会话日志记录使用 pgaudit.log启用。

```sql
set pgaudit.log = 'write, ddl';

create table account
(
    id int,
    name text,
    password text,
    description text
);

insert into account (id, name, password, description)
             values (1, 'user1', 'HASH1', 'blah, blah');

select * from account;

```

#### Object Audit Logging

对象审计记录针对特定对象的审计日志，仅支持SELECT, INSERT, UPDATE and DELETE语句，不支持truncate。

对象审计比会话审计更具有细粒度，可替代会话审计。因此将它们结合使用可能没有意义，除非需要更多详细信息。

对象级审核日志记录通过角色系统实现。pgaudit.role 设置定义将用于审核日志记录的角色

set pgaudit.role = 'auditor';

grant select, delete
   on public.account
   to auditor;

则角色auditor对对象表public.account的操作会被记录

```sql

create role aud with login password 'aud';

alter system set pgaudit.role = 'aud';
select pg_reload_conf();

grant select(password),insert,delete
   on public.account
   to aud;

select * from public.account limit 2;
select name from public.account limit 2;
insert into public.account (id, name, password, description)
             values (2, 'user2', 'HASH2', 'Object Audit Logging');
delete from public.account where id=2;
```

### Format

审计条目会写入到标准日志输出中（pg_log）,包括如下内容

* AUDIT_TYPE - SESSION or OBJECT.
* STATEMENT_ID
* SUBSTATEMENT_ID
* CLASS
* COMMAND
* OBJECT_TYPE
* OBJECT_NAME
* STATEMENT
* PARAMETER

审计日志条目

```shell
2021-02-09 09:51:29.164 CST,"pg131","postgres",2286,"[local]",6021ea66.8ee,8,"CREATE TABLE",2021-02-09 09:50:30 CST,3/6,559,LOG,00000,"AUDIT: SESSION,2,1,DDL,CREATE TABLE,TABLE,public.account,""create table account
(
    id int,
    name text,
    password text,
    description text
);"",<not logged>",,,,,,,,,"psql","client backend"

2021-02-09 09:54:59.089 CST,"pg131","postgres",2286,"[local]",6021ea66.8ee,10,"DELETE",2021-02-09 09:50:30 CST,3/9,0,LOG,00000,"AUDIT: SESSION,4,1,WRITE,DELETE,,,delete from account;,<not logged>",,,,,,,,,"psql","client backend"

2021-02-09 09:56:40.058 CST,"pg131","postgres",2286,"[local]",6021ea66.8ee,16,"INSERT",2021-02-09 09:50:30 CST,3/15,0,LOG,00000,"AUDIT: OBJECT,6,1,WRITE,INSERT,TABLE,public.account,""insert into public.account (id, name, password, description)
             values (2, 'user2', 'HASH2', 'Object Audit Logging');"",<not logged>",,,,,,,,,"psql","client backend"

2021-02-09 09:56:44.597 CST,"pg131","postgres",2286,"[local]",6021ea66.8ee,18,"DELETE",2021-02-09 09:50:30 CST,3/16,0,LOG,00000,"AUDIT: OBJECT,7,1,WRITE,DELETE,TABLE,public.account,delete from public.account where id=2;,<not logged>",,,,,,,,,"psql","client backend"


```

<!--
pg_audit和rls

1. 请总结一下PostgreSQL的错误日志跟PGAudit的涵括范围差异，还有PGAudit对性能的影响具体是怎么样的，有这些我们才可以评估能否用“错误日志”代替PGAudit。

错误日志：可以保存数据库执行的所有操作或一类操作（如记录所有sql语句，仅记录ddl语句）可用于一般的监控。侧重于记录用户请求的sql。
PGAudit：不仅可以记录sql操作，还可提供审计需要的详细信息。如记录语句类型，对象类型，会话信息。pgAudit 则重点记录数据库满足请求时发生的情况的详细信息。

pgaudit会影响数据库的性能，并占用额外的磁盘空间，因为需要产生额外的审计日志。依据pgaudit的设置，影响不一。审计所有的sql影响较大，仅审计ddl或配置较少的审计项则影响较小。

2. 请说明没有RLS的话，我们怎样获取表格被修改的记录，已经开启RLS所带来的对性能的具体影响。

RLS是行安全策略，粒度更细。可以通过配置策略限定用户对行的操作（如一个用户只能修改表中特定的行数据）。RLS并不会产生额外的记录信息。获取表格被修改记录，可通过错误日志或pgaudit审计日志
grant权限是sql标准权限管理策略。粒度粗，限定对表的操作。（如一个用户不能修改整个表的数据）
grant权限已经实现权限控制，如需细粒度的行级控制可使用RLS。但RLS会有一定的性能影响，对于每一行，在计算任何来自用户查询的条件或函数之前，先会计算RLS策略。
-->
