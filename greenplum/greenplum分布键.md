Greenplum创建表--分布键
 
Greenplum是分布式系统，创建表时需要指定分布键（创建表需要CREATEDBA权限），目的在于将数据平均分布到各个segment。选择分布键非常重要，选择错了会导致数据不唯一，更严重的是会造成SQL性能急剧下降。
Greenplum有两种分布策略：
1、hash分布。
Greenplum默认使用hash分布策略。该策略可选一个或者多个列作为分布键（distribution key，简称DK）。分布键做hash算法来确认数据存放到对应的segment上。相同分布键值会hash到相同的segment上。表上最好有唯一键或者主键，这样能保证数据均衡分不到各个segment上。语法，distributed by。
如果没有主键或者唯一键，默认选择第一列作为分布键。增加主键
 
 
2、随机（randomly）分布。
数据会被随机分不到segment上，相同记录可能会存放在不同的segment上。随机分布可以保证数据平均，但是Greenplum没有跨节点的唯一键约束数据，所以无法保证数据唯一。基于唯一性和性能考虑，推荐使用hash分布，性能部分会另开一篇文档详细介绍。语法，distributed randomly。
 
来自 <http://blog.chinaunix.net/uid-23284114-id-5601403.html>
 
 
Eg
 
1、初始环境
创建用户
postgres=# create role test with login password 'test';
NOTICE:  resource queue required -- using default resource queue "pg_default"
CREATE ROLE
postgres=# select * from pg_user;
 usename | usesysid | usecreatedb | usesuper | usecatupd |  passwd  | valuntil | useconfig
---------+----------+-------------+----------+-----------+----------+----------+-----------
 gpadmin |       10 | t           | t        | t         | ******** |          |
 test    |    16892 | f           | f        | f         | ******** |          |
(2 rows)
 
postgres=#
 
创建schema
postgres=# create schema test AUTHORIZATION test;
ERROR:  permission denied for database postgres  (seg1 192.168.100.113:25433 pid=44950)--提示在postgres数据库中权限拒绝
postgres=#
postgres=# grant all on database postgres to test;--将数据库所有权限授予test用户
GRANT
postgres=#
postgres=# create schema test AUTHORIZATION test;
CREATE SCHEMA
postgres=#
 
创建表
[gpadmin@ps1 ~]$ psql -U test -h 127.0.0.1 -d postgres
Password for user test:
psql (8.3.23)
Type "help" for help.
 
postgres=> create table test_jason(id int,name varchar(50)) distributed by (id);
CREATE TABLE
postgres=> \d
               List of relations
 Schema |    Name    | Type  | Owner | Storage
--------+------------+-------+-------+---------
 test   | test_jason | table | test  | heap
(1 row)
 
 
postgres=> \d test_jason
          Table "test.test_jason"
 Column |         Type          | Modifiers
--------+-----------------------+-----------
 id     | integer               |
 name   | character varying(50) |
 
 
postgres=> alter table test_jason add primary key (name);
NOTICE:  updating distribution policy to match new primary key
NOTICE:  ALTER TABLE / ADD PRIMARY KEY will create implicit index "test_jason_pkey" for table "test_jason"
ALTER TABLE
postgres=>
 
postgres=> \d test_jason;
          Table "test.test_jason"
 Column |         Type          | Modifiers
--------+-----------------------+-----------
 id     | integer               |
 name   | character varying(50) | not null
Indexes:
    "test_jason_pkey" PRIMARY KEY, btree (name)
Distributed by: (name)
 
postgres=>
 
postgres=>
postgres=> insert into test_jason values (1,'aaa');
INSERT 0 1
postgres=> insert into test_jason values (1,'bbb');
INSERT 0 1
postgres=> insert into test_jason values (1,'bbb');
ERROR:  duplicate key value violates unique constraint "test_jason_pkey"  (seg3 192.168.100.113:25435 pid=48088)
DETAIL:  Key (name)=(bbb) already exists.
postgres=>
 
=============================
查看greenplum库各个节点数据的分布情况
postgres=> select gp_segment_id,count(*) from test_jason group by gp_segment_id;
 gp_segment_id | count
---------------+-------
             3 |     1
             0 |     1
(2 rows)
 
 
===========================
更改分布键
zwcdb=# alter table tab01 set distributed by(name);  
 