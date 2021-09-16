# pg_tablespace

## 表空间的概念

PostgreSQL中的表空间允许在文件系统中定义用来存放表示数据库对象的文件的位置。在PostgreSQL中表空间实际上就是给表指定一个存储目录。

## 表空间的作用

官方解释

通过使用表空间，管理员可以控制一个PostgreSQL安装的磁盘布局。这么做至少有两个用处。

1. 如果初始化集簇所在的分区或者卷用光了空间，而又不能在逻辑上扩展或者做别的什么操作，那么表空间可以被创建在一个不同的分区上，直到系统可以被重新配置。
2. 表空间允许管理员根据数据库对象的使用模式来优化性能。例如，一个很频繁使用的索引可以被放在非常快并且非常可靠的磁盘上，如一种非常贵的固态设备。同时，一个很少使用的或者对性能要求不高的存储归档数据的表可以存储在一个便宜但比较慢的磁盘系统上。

用一句话来讲：能合理利用磁盘性能和空间,制定最优的物理存储方式来管理数据库表和索引。

## 表空间跟数据库关系

* 在Oracle数据库中；一个表空间只属于一个数据库使用；而一个数据库可以拥有多个表空间。属于"一对多"的关系
* 在PostgreSQL集群中；一个表空间可以让多个数据库使用；而一个数据库可以使用多个表空间。属于"多对多"的关系。

## 系统自带表空间

* 表空间pg_default是用来存储系统目录对象、用户表、用户表index、和临时表、临时表index、内部临时表的默认空间。对应存储目录$PADATA/base/
* 表空间pg_global用来存放系统字典表；对应存储目录$PADATA/global/

## 查看表空间
列出现有的表空间

```sql
postgres=# \db
             List of tablespaces
    Name    |  Owner   |      Location      
------------+----------+---------------------
 pg_default | postgres |
 pg_global  | postgres |
 tp_lottu   | lottu    | /data/pg_data/lottu
(3 rows)

postgres=# select oid,* from pg_tablespace;
  oid  |  spcname   | spcowner | spcacl | spcoptions
-------+------------+----------+--------+------------
  1663 | pg_default |       10 |        |
  1664 | pg_global  |       10 |        |
 16385 | tp_lottu   |    16384 |        |(3 rows)

```

## 6. 创建表空间

Syntax:
CREATE TABLESPACE tablespace_name [ OWNER { new_owner | CURRENT_USER | SESSION_USER } ] LOCATION 'directory'
示例如下：

CREATE TABLESPACE tsp01 OWNER lottu LOCATION '/data/pg_data/tsp';
CREATE TABLESPACE
目录"/data/pg_data/tsp"必须是一个已有的空目录，并且属于PostgreSQL操作系统用户

$ mkdir -p /data/pg_data/tsp
$ chown -R postgres:postgres /data/pg_data/tsp

## 权限分配

表空间的创建本身必须作为一个数据库超级用户完成，但在创建完之后之后你可以允许普通数据库用户来使用它.要这样做，给数据库普通用户授予表空间上的CREATE权限。表、索引和整个数据库都可以被分配到特定的表空间.

示例用户"rax":为普通用户。

```sql
GRANT CREATE ON TABLESPACE tsp01 TO rax;

```

## 为数据库指定默认表空间

Syntax:
ALTER DATABASE name SET TABLESPACE new_tablespace
以数据库lottu01为例:

ALTER DATABASE lottu01 SET TABLESPACE tsp01;
lottu01=> \c lottu01 lottu
You are now connected to database "lottu01" as user "lottu".

注意1：执行该操作；不能连着对应数据库操作

lottu01=# ALTER DATABASE lottu01 SET TABLESPACE tsp01;
ERROR:  cannot change the tablespace of the currently open database
lottu01=# \c postgres postgres
You are now connected to database "postgres" as user "postgres".

注意2：执行该操作；对应的数据库不能存在表或者索引已经指定默认的表空间

postgres=# ALTER DATABASE lottu01 SET TABLESPACE tsp01;
ERROR:  some relations of database "lottu01" are already in tablespace "tsp01"
HINT:  You must move them back to the database's default tablespace before using this command.
postgres=# \c lottu01
You are now connected to database "lottu01" as user "postgres".
lottu01=# drop table test_tsp ;
DROP TABLE
lottu01=# create table test_tsp(id int);
CREATE TABLE
lottu01=# \c postgres postgres
You are now connected to database "postgres" as user "postgres".

注意3：执行该操作；必须是没有人连着对应的数据库

postgres=# ALTER DATABASE lottu01 SET TABLESPACE tsp01;
ERROR:  database "lottu01" is being accessed by other users
DETAIL:  There is 1 other session using the database.
postgres=# ALTER DATABASE lottu01 SET TABLESPACE tsp01;
ALTER DATABASE

查看数据库默认表空间

lottu01=# select d.datname,p.spcname from pg_database d, pg_tablespace p where d.datname='lottu01' and p.oid = d.dattablespace;
 datname | spcname
---------+---------
 lottu01 | tsp01
(1 row)

9. 如何将表从一个表空间移到另一个表空间。
我们知道表空间pg_default是用来存储系统目录对象、用户表、用户表index、和临时表、临时表index、内部临时表的默认空间。若没指定默认表空间；表就所属的表空间就是pg_default。"当然也可以通过参数设置"。而不是数据库默认的表空间。这个时候我们可以将表移到默认的表空间
Syntax:
ALTER TABLE name SET TABLESPACE new_tablespace
将表从一个表空间移到另一个表空间

lottu01=# create table test_tsp03(id int) tablespace tp_lottu;
CREATE TABLE
lottu01=# alter table test_tsp03 set tablespace tsp01;
ALTER TABLE
注意：该操作时会锁表。
10. 临时表空间
PostgreSQL的临时表空间，通过参数temp_tablespaces进行配置，PostgreSQL允许用户配置多个临时表空间。配置多个临时表空间时，使用逗号隔开。如果没有配置temp_tablespaces 参数，临时表空间对应的是默认的表空间pg_default。PostgreSQL的临时表空间用来存储临时表或临时表的索引，以及执行SQL时可能产生的临时文件例如排序，聚合，哈希等。为了提高性能，一般建议将临时表空间放在SSD或者IOPS，以及吞吐量较高的分区中。

$ mkdir -p /data/pg_data/temp_tsp
$ chown -R postgres:postgres /data/pg_data/temp_tsp
postgres=# CREATE TABLESPACE temp01 LOCATION '/data/pg_data/temp_tsp';
CREATE TABLESPACE
postgres=# show temp_tablespaces ;
 temp_tablespaces
------------------
 
(1 row)
设置临时表空间
	* 
会话级生效



postgres=# set temp_tablespaces = 'temp01';
SET
	* 
永久生效


	1. 
修改参数文件postgresql.conf
	2. 
执行pg_ctl reload



[postgres@Postgres201 data]$ grep "temp_tablespace" postgresql.conf
temp_tablespaces = 'temp01'     # a list of tablespace names, '' uses
查看临时表空间

postgres=# show temp_tablespaces ;
 temp_tablespaces
------------------
 temp01
(1 row)
 
来自 <https://www.cnblogs.com/lottu/p/9239535.html>
 
 
 
The pg_default tablespace is not accessed through pg_tblspc, but corresponds to PGDATA/base. Similarly, the pg_global tablespace is not accessed through pg_tblspc, but corresponds to PGDATA/global.
 
From <https://www.postgresql.org/docs/10/storage-file-layout.html>

查询表所在的表空间

select c.relname,t.spcname from pg_class c,pg_tablespace t where c.reltablespace=t.oid and reltablespace not in (0,1664,1663);