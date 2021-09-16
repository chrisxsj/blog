# database roles
role 包含了users、groups的概念，所以role可以有object也可以有privilege，也可以将自身成员资格membership授予其他用户
role 是全局的，可全局访问整个database cluster
注意：在PostgreSQL 里没有区分用户和角色的概念，"CREATE USER" 为 "CREATE ROLE" 的别名，这两个命令几乎是完全相同的，唯一的区别是"CREATE USER" 命令创建的用户默认带有LOGIN属性，而"CREATE ROLE" 命令创建的用户默认不带LOGIN属性。
为了方便，可以在shell中调用封装程序创建role，带有login属性
createuser name
dropuser name

查看role信息，访问pg_roles系统目录
psql程序命令 \du 也有助于查看role信息

eg：
create role test1;
create role test2 with password 'test2';
create user test3 with password 'test3';
$ createuser test4
\du
                                   List of roles
Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
pg        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
test1     | Cannot login                                               | {}
test2     | Cannot login                                               | {}
test3     |                                                            | {}
test4     |                                                            | {}
 
postgres=# select rolname,rolcreatedb,rolcanlogin,rolreplication,rolconnlimit,rolpassword from pg_roles where rolname like 'test%';
rolname | rolcreatedb | rolcanlogin | rolreplication | rolconnlimit | rolpassword
---------+-------------+-------------+----------------+--------------+-------------
test1   | f           | f           | f              |           -1 | ********
test2   | f           | f           | f              |           -1 | ********
test3   | f           | t           | f              |           -1 | ********
test4   | f           | t           | f              |           -1 | ********
(4 rows)
postgres=# select * from pg_user;
usename | usesysid | usecreatedb | usesuper | userepl | usebypassrls |  passwd  | valuntil | useconfig
---------+----------+-------------+----------+---------+--------------+----------+----------+-----------
pg      |       10 | t           | t        | t       | t            | ******** |          |
test3   |    24585 | f           | f        | f       | f            | ******** |          |
test4   |    24586 | f           | f        | f       | f            | ******** |          |
(3 rows)
 
为了能够引导数据库，初始化initdb后，会有一个默认预定义角色predefined role ,其总是有superuser权限属性，默认其角色名与执行initdb的操作系统用户名一致。
很多客户端程序（包括createuser、psql）调用的角色名默认为当前操作系统用户名
su - pg
psql与psql -U pg具有相同的含义
2 Role Attributes》》》》》》》》》》》
数据库角色可以具有许多定义其权限并与客户端身份验证系统交互的属性。
login privilege
具有login权限的role可以被看做是一个user
CREATE ROLE name LOGIN;
CREATE USER name;
or
alter role test1 login;
postgres=# select * from pg_user;
usename | usesysid | usecreatedb | usesuper | userepl | usebypassrls |  passwd  | valuntil | useconfig
---------+----------+-------------+----------+---------+--------------+----------+----------+-----------
pg      |       10 | t           | t        | t       | t            | ******** |          |
test3   |    24585 | f           | f        | f       | f            | ******** |          |
test4   |    24586 | f           | f        | f       | f            | ******** |          |
test1   |    24583 | f           | f        | f       | f            | ******** |          |
(4 rows)
superuser status
数据库超级用户将绕过所有权限检查, 但login除外，权限非常大，小心使用。
postgres=# alter user test2 superuser;
ALTER ROLE
postgres=# \c postgres test2
FATAL:  role "test2" is not permitted to log in
Previous connection kept
database creation
创建数据库的权限需要明确指出，但除了superuser status
alter user test2 createdb;
role creation
创建角色的权限需要明确指出，但除了superuser status
alter user test2 createrole;
CREATEROLE privilege可以更改、删除其他role，但不能是具有superuser status的role
initiating replication
初始化流复制的权限需要明确指出，但除了superuser status。使用流复制的用户必须有LOGIN权限
alter user test2 replication login;
postgres=# \du
                                   List of roles
Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
pg        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
test1     |                                                            | {}
test2     | Superuser, Create role, Create DB, Replication             | {}
test3     |                                                            | {}
test4     |                                                            | {}
password
只有当客户端身份验证方法要求用户在连接到数据库时提供密码时, 密码才有意义。密码和 md5 身份验证方法使用密码。
TIP
建议create role时授予CREATEDB和CREATEROLE权限，而不是superuser
create role ttt createdb createrole login;
还可以更改role其他配置，如
ALTER ROLE myname SET enable_indexscan TO off;
3 Role Membership》》》》》》》》》》》》》》》》
role包括一组权限，为了方便权限的管理，我们会创建一个role（没有login权限）作为一个group。
通常来说，没有login权限且用来管理一组权限功能的role可以被看做是一个group
group中的成员是membership
可以使用grant和revoke命令给group授予role
grant ttt2 to ttt;
\du
                                   List of roles
Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
pg        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
test1     |                                                            | {}
test2     | Superuser, Create role, Create DB, Replication             | {}
test3     |                                                            | {}
test4     |                                                            | {}
ttt       | Create role, Create DB                                     | {ttt2}
ttt2      | Cannot login                                               | {}
注意：
1 不允许循环授予membership
2 不允许将membership授予public
如果一个role具有INHERIT属性，则权限会继承
CREATE ROLE joe LOGIN INHERIT;
CREATE ROLE admin NOINHERIT;
CREATE ROLE wheel NOINHERIT;
GRANT admin TO joe;
GRANT wheel TO admin;
使用joe连接数据库，其inherit admin权限，但不能inherit wheel权限
create role grp with password 'grp' inherit;
create role m1 login inherit;
create role m2 createrole noinherit;
grant m1,m2 to grp;
postgres=# \c postgres grp
FATAL:  role "grp" is not permitted to log in
Previous connection kept
postgres-# \c postgres m1
You are now connected to database "postgres" as user "m1".
 
4 Dropping Roles》》》》》》》》》》》》》》
因为role有对象也有权限，删除role时，必须考虑将其拥有的对象分配个其他所有者，必须考虑回收其权限
使用REASSIGN OWNED命令将要删除role拥有的对象转移给其他拥有者，REASSIGN OWNED不能跨数据库访问对象，所以每个数据库都需要执行
使用DROP OWNED删除role下的剩余对象
使用DROP ROLE删除role
如下删除一个role
REASSIGN OWNED BY doomed_role TO successor_role;
DROP OWNED BY doomed_role;
-- repeat the above commands in each database of the cluster
DROP ROLE doomed_role;
5  Default Roles》》》》》》》》》》》》》》
pg提供了一些默认role，供方便使用

Role
Allowed Access
pg_read_all_settings
Read all configuration variables, even those normally visible only to superusers.
pg_read_all_stats
Read all pg_stat_* views and use various statistics related extensions, even those normally visible only to superusers.
pg_stat_scan_tables
Execute monitoring functions that may take ACCESS SHARE locks on tables, potentially for a long time.
pg_signal_backend
Send signals to other backends (eg: cancel query, terminate).
pg_monitor
Read/execute various monitoring views and functions. This role is a member of pg_read_all_settings, pg_read_all_stats and pg_stat_scan_tables.


来自 <https://www.postgresql.org/docs/10/static/view-pg-roles.html>
 
1 系统权限
select * from pg_roles|pg_user;
2 对象权限
select grantee,table_schema,table_name,privilege_type from information_schema.table_privileges where table_name='highgo_table';
 
对象权限管理
1.建议使用角色（role），将一组权限授予角色，再将角色授予同类型的用户
2.数据库对象权限，可指定对象权限单独授予或指定授予模式对象（schema）中所有对象的同类权限。
对于dml操作可以单独授予也可以全部授予
单独授予权限
授予表的select权限给role
highgo=# grant select on test.test_table to groups;
GRANT
授予scahme的使用权限给role
highgo=# grant usage on schema test to groups;
GRANT
 
 
授予模式schema下的所有表的查询权限
grant select on all tables in schema test to logicalrep;
 
3.对象的drop和alter权限不被视为可扩展的权限;它是所有者固有的, 不能被授予或撤销。
但可以把对象的owner作为成员授予其他user。user成为此对象的owner就可以操作了
4.授权时需要考虑schema的权限（usage）和role的权限两部分
 
=================
Eg1: select 查询权限
 
1、创建用户test
highgo=# create role test with login password 'test';
CREATE ROLE
2、创建schema test属于用户test
highgo=# create schema test AUTHORIZATION test;
CREATE SCHEMA
highgo=# 
3、使用test用户创建的对象默认会存储在test schema中
highgo=# \c highgo test
 
highgo=> create table test_table (name varchar);
CREATE TABLE
highgo=> insert into test_table values ('xiaobai');
INSERT 0 1
highgo=> \d
              List of relations
     Schema     |    Name    | Type  | Owner 
----------------+------------+-------+--------
 oracle_catalog | dual       | view  | highgo
 test           | test_table | table | test
(2 rows)
 
4、创建角色groups
highgo=# create role groups with password 'groups';
CREATE ROLE
 
5、将对象的权限集中授予角色groups
授予表的select权限
highgo=# grant select on test.test_table to groups;
GRANT
授予scahme的使用权限
highgo=# grant usage on schema test to groups;
GRANT
 
6、将groups授予需要的用户
highgo=# grant groups to yewu;
GRANT ROLE
 
 
 
 
 
CREATE DATABASE name;
where name follows the usual rules for SQL identifiers. The current role automatically becomes the owner of the new database. It is the privilege of the owner of a database to remove it later (which also removes all the objects in it, even if they have a different owner).
 
From <https://www.postgresql.org/docs/10/manage-ag-createdb.html>
 
 
Database owner：可以删除数据库（数据库可以被看作一个对象）及修改数据库属性
 
 
 
 
=========================
Grant
 
GRANT — define access privileges
 
From <https://www.postgresql.org/docs/10/sql-grant.html>
The GRANT command has two basic variants: one that grants privileges on a database object (table, column, view, foreign table, sequence, database, foreign-data wrapper, foreign server, function, procedural language, schema, or tablespace), and one that grants membership in a role. These variants are similar in many ways, but they are different enough to be described separately.
 
From <https://www.postgresql.org/docs/10/sql-grant.html>
 
 
 
 

GRANT { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
    [, ...] | ALL [ PRIVILEGES ] }
    ON
 
ALL 代表之前的{ SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }所有的权限
 
Grant可以授予all on database/tablespace/table…对象的所有权限
 
 
There is also an option to grant privileges on all objects of the same type within one or more schemas. This functionality is currently supported only for tables, sequences, and functions (but note that ALL TABLES is considered to include views and foreign tables).
 
From <https://www.postgresql.org/docs/10/sql-grant.html>
 
Grant也可以授予select on all table…一组类似所有对象的。
还有一个选项，用于在一个或多个架构中授予相同类型的所有对象的权限。此功能目前仅支持表、序列和函数（但请注意，所有 TABLES 都被视为包含视图和外表）。
 
如：授予模式schema下的所有表的查询权限
grant select on all tables in schema test to logicalrep;
 --未来访问scott模式下所有新建的表：
alter default privileges in schema scott grant select on tables to readonly ;
 
GRANT on Database Objects
……
The right to drop an object, or to alter its definition in any way, is not treated as a grantable privilege; it is inherent in the owner, and cannot be granted or revoked. (However, a similar effect can be obtained by granting or revoking membership in the role that owns the object; see below.) The owner implicitly has all grant options for the object, too.
 
来自 <https://www.postgresql.org/docs/10/sql-grant.html>
 
 
对象的drop和alter权限不被视为可扩展的权限;它是所有者固有的, 不能被授予或撤销。
但可以把对象的owner作为成员授予其他user。user成为此对象的owner就可以操作了。
 
注意：
ALTER TABLE table_name OWNER TO new_owner;
Superusers can always do this; ordinary roles can only do it if they are both the current owner of the object (or a member of the owning role) and a member of the new owning role.
 
From <https://www.postgresql.org/docs/12/ddl-priv.html>
 
超级用户总是可以这样做;仅当普通角色既是对象的当前所有者（或所属角色的成员）和新的所属角色的成员时，才能执行此操作。
 
如：
 
postgres=> \c postgres ttt;
 
postgres=> drop table test.test_date;
ERROR:  must be owner of relation test_date
postgres=>
 
postgres=> \c postgres ttt;
postgres=> \d
                     List of relations
  Schema   |             Name              | Type  | Owner
-----------+-------------------------------+-------+-------
……
 test      | test_date                     | table | test
……
(22 rows)
 
postgres=> grant test to ttt;
GRANT ROLE
 
postgres=# \du
                                    List of roles
 Role name  |                         Attributes                         | Member of
------------+------------------------------------------------------------+-----------
 bms        |                                                            | {}
 logicalrep | Replication                                                | {}
 pg         | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 repuser    | Replication                                                | {}
 test       | Password valid until 2019-12-12 12:00:00+08                | {}
 ttt        |                                                            | {test}
 ttt2       | Cannot login                                               | {}
 
 
 
postgres=> \c postgres ttt;
postgres=> drop table test.test_date;
DROP TABLE
 
 
 
注意：缺少权限首先想到的是grant。grant选项很多，如下：
 
USAGE
For schemas, allows access to objects contained in the specified schema (assuming that the objects' own privilege requirements are also met). Essentially this allows the grantee to “look up” objects within the schema.
 
来自 <https://www.postgresql.org/docs/10/sql-grant.html>
 
 
bms=> create publication pub3;
ERROR:  permission denied for database bms
bms=>
 
 
CREATE
For databases, allows new schemas and publications to be created within the database.
 
来自 <https://www.postgresql.org/docs/10/sql-grant.html>
 
每个选项都要弄懂