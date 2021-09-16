# constriant and index

## 创建索引

highgo=# create table test_t1(id int,name text,salary int);  
CREATE TABLE
highgo=# alter table test_t1 add primary key (id);
ALTER TABLE
highgo=#
highgo=# ALTER TABLE test_t1 ADD CONSTRAINT test_t1_check CHECK (salary>1000);
ALTER TABLE
highgo=#
highgo=# create index test_t1_idx on test_t1(salary);
CREATE INDEX
 
查询约束
highgo=# select conname,contype from pg_constraint where conname like 'test%';
    conname    | contype
---------------+---------
 test_t1_pkey  | p
 test_t1_check | c
(2 rows)
 
 
主键和唯一键会创建唯一索引
highgo=# select * from pg_indexes where tablename='test_t1';
 schemaname | tablename |  indexname   | tablespace |                              indexdef                              
------------+-----------+--------------+------------+---------------------------------------------------------------------
 public     | test_t1   | test_t1_pkey |            | CREATE UNIQUE INDEX test_t1_pkey ON public.test_t1 USING btree (id)
 public     | test_t1   | test_t1_idx  |            | CREATE INDEX test_t1_idx ON public.test_t1 USING btree (salary)
(2 rows)
 
highgo=#
 
 
 
 
过滤主键和唯一键索引
select * from pg_indexes where schemaname = 'public' and (tablename,indexname) not in (select tablename,constraint_name from information_schema.table_constraints where constraint_schema = 'public') ;


## pg部分索引

针对列值中常用的占比较小的值设置索引，而不是对整个列设置索引。
测试数据
create table tbl_partial_index(id bigint,alarm_time timestamp without time zone,level varchar(12),alarm_desc varchar(100));
create table tbl_partial_index1(id bigint,alarm_time timestamp without time zone,level varchar(12),alarm_desc varchar(100));

insert into tbl_partial_index(id,alarm_time,level,alarm_desc)
select generate_series(1,9000),clock_timestamp()::timestamp without time zone,'green','正常';
insert into tbl_partial_index(id,alarm_time,level,alarm_desc)
select generate_series(9000,9200),clock_timestamp()::timestamp without time zone,'red','攻击';
create index idx_tbl_partial_index_level on tbl_partial_index using btree (level);-----------》》》

 insert into tbl_partial_index1(id,alarm_time,level,alarm_desc)
select generate_series(1,9000),clock_timestamp()::timestamp without time zone,'green','正常';
 insert into tbl_partial_index1(id,alarm_time,level,alarm_desc)
select generate_series(9000,9200),clock_timestamp()::timestamp without time zone,'red','攻击';
create index idx_tbl_partial_index1_level on tbl_partial_index1(level) where level = ‘red’;-----》》》部分行的索引

验证
查看索引大小（占用空间大小）
执行sql，查看执行计划时间，索引扫描时间（时间长短）

## pg表达式索引

正常情况，where中带有表达式，会不走索引的。针对带有表达式的情况，需要单独创建表达式索引。
测试数据
create table tbl_expression(a varchar(32), b varchar(32));
insert into tbl_expression select concat('test',x),concat('you',x) from generate_series(1,10000) x;
create index idx_tbl_expression_a on tbl_expression (a);
explain analyze select * from tbl_expression where upper(a) = 'TEST';
create index idx_tbl_expression_a_b on tbl_expression (upper(a));--Seq Scan  = oracle的full table scan

验证
使用where带有对应的表达式。查看执行计划，使全表扫描还是走索引



## HGDB 索引管理—建立索引时的必用关键字
Concurrently作用是create index时，不影响表的DML操作
？？最终还是会影响，在替换索引的时候。时间比较短。以空间换时间。？？
 
## HGDB 索引管理—索引定义查询
pg_indexes.indexdef--索引定义
pg_indexes.tablename--表名，限定表名，查看表上的所有索引