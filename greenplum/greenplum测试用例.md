# gp 测试用例

## 模拟测试数据
```sql
创建测试表
create table test_tbl (id int primary key,num int,info text,c_time timestamp) distributed by (id);

插入100万条数据
insert into test_tbl  select generate_series(1,1000000),1000000,md5(random()::text),clock_timestamp();  
 
```

## 功能性测试

### 数据一致性测试。

```sql
1查询数据库表中约10万条结果，确定返回结果的条数正常，每条数据内容正确。

\timing on
select * from test_tbl where id between 1 and 100000;

2更新数据库表中10万条结果，在执行完成后1分钟内进行查询操作（查询结果需要包含已更新的数据），确定返回结果的条数正常，每条内容正确。

\timing on
update test_tbl set num = num+1 where id between 1 and 1000000;
select * from test_tbl where id between 1 and 100000;

3删除数据库表中10万条结果，在执行完成后1分钟内进行查询操作（查询结果应涉及已删除的数据），确定返回结果的条数正常，每条内容正确。
\timing on
delete  from test_tbl where id between 1 and 100000;
select * from test_tbl where  id between 1 and 100000;
```

### 数据同步测试。

选择集群中一半节点断网60分钟，部分节点断网后删除1亿条数据、修改1亿条数据、新增1亿条数据，然后恢复网络。待集群开始自动同步后，通过数据查询服务来验证各节点数据表数据一致同步情况。其中，查询不低于10批次，每批次不低于20万条数据查询，确定查询结果正常。
```sql

select count(*) from test_tbl ;

gp4
shutdown -h now


delete from test_tbl where id between 100001 and 200000;
select count(*) from test_tbl ;
update test_tbl set num = num+1 where id between 1 and 100000;
insert into test_tbl  select 
generate_series(1,100000),100000,md5(random()::text),clock_timestamp();


gp4
startup
从Master主机执行gprecoverseg 命令恢复失败的Instance
修复好了后，需要恢复所有Instance到原有角色


select count(*) from tbl_test ;


```
### 数据增、删、改测试。

```sql
1分别插入、更新、删除1亿条数据，记录操作总耗时。

插入100w
\timing on
insert into test_tbl  select generate_series(1,1000000),1000000,md5(random()::text),clock_timestamp();  

更新100w
update test_tbl set num = num+1 where id between 1 and 1000000;


删除100w
delete * from test_tbl where id between 1 and 1000000;


2分别插入、更新、删除1000万条数据，并在操作过程中同步进行查询操作，确定数据库不会死锁。

插入30万条数据，同步执行查询操作，数据库没有锁死
insert into tbl_test select generate_series(1,300000),300000,md5(random()::text);
select  * from test_t1 limit 100;

update test_tbl set num = num+1 where id between 1 and 1000000;
select  * from test_t1 limit 100;

delete  from test_tbl where id between 100001 and 200000;
select  * from test_t1 limit 100;
select *  from test_tbl  limit 1000;


```

### 数据筛选查询测试。

```sql
从数据库1亿条数据中筛选100万条查询结果，测试结果返回时间。
--注意，表上要有索引

select * from test_tbl where id between 1 and 100000;

```

### 数据关联查询测试。

```sql

从数据库中选择100万条数据与100万条数据关联，其中关联结果不少于10万条，测试关联结果返回时间。


1、创建测试表
create table test_join (id int,num int default 100,message text);
2、插入100万条数据
insert into test_join select generate_series(1,1000000),100,md5(random()::text);  
3.关联查询
左外连接
select * from test_tbl as a left join test_join as b on a.id=b.id;
select count(*) from test_tbl as a left join test_join as b on a.id=b.id;

右外连接

select * from test_tbl as a right join test_join as b on a.id=b.id;
select count(*) from test_tbl as a right join test_join as b on a.id=b.id;




```

### 非结构化数据读写测试。

```sql
向非结构化数据库写入音频/视频、图片、HTML、报表等非结构化数据1TB，测试数据写入时间，以及写入后读取时间。

1、单张图片数据导入，lo_import函数只能在超级用户下执行

CREATE OR REPLACE FUNCTION bytea_import(p_path text, p_result out bytea) 
LANGUAGE plpgsql AS $$

DECLARE
    l_oid oid;
    rec record;
BEGIN
    p_result := '';
  select lo_import(p_path) into l_oid;
  for rec in ( select data from pg_largeobject where loid = l_oid order 
by pageno )
  loop
        p_result = p_result || rec.data;
    end loop;
    perform lo_unlink(l_oid);
END; $$ ;

create table test_typea(zjhm varchar(100), tp bytea);
insert into test_typea(zjhm, tp) values ('362232',(select bytea_import('/home/gpadmin/1.png') ) );

select * from test_typea;


批量导入（存储过程）图片文件夹 ，lo_import函数只能在超级用户下执行

1图片存放地址

/home/gpadmin/pic    里面存放1.png 2.png 3.png 4.jpg四张图片

2将图片名称截取到list1.txt里面

ll | tr -s " " | cut -d" " -f9 | grep -v "^$" > /home/gpadmin/list1.txt

3创建list表及pic表   list里面存放图片名称   pic存放图片绝对路径

create table list(name varchar(100));
\copy list from '/home/gpadmin/list1.txt';
create table pic(name varchar(100));
insert into pic select '/home/gpadmin/pic/'||name from list;
select * from pic;

create table test_typea2(tp bytea);


4创建tp_import函数  ---获取要插入的图片的二进制数据

CREATE OR REPLACE FUNCTION tp_import(p_path text,p_result out bytea) 
LANGUAGE plpgsql AS $$

DECLARE
    l_oid oid;
    rec record;
BEGIN
    p_result := '';
    select lo_import(p_path) into l_oid;
  for rec in ( select data from pg_largeobject where loid = l_oid order 
by pageno )
  loop
        p_result = p_result || rec.data;
    end loop;
    perform lo_unlink(l_oid);
END; $$ ;

调用此函数，成功

insert into test_typea2                                     
select tp_import('/home/gpadmin/pic/1.png');

select count(*) from test_typea2;
truncate test_typea2;

5创建xxx函数   ----执行tp_import函数，循环去表里读取图片的实际路径，循环插入。

CREATE OR REPLACE FUNCTION xxx(num out int) LANGUAGE plpgsql AS $$
DECLARE
    pic_path text;
    curs cursor for select name from yuxiao.pic;
BEGIN
    num := 0;
    open curs;
    loop
        fetch curs into pic_path;
        exit when not found;
        insert into yuxiao.test2 select tp_import(pic_path);
        num := num+1;
    end loop;
    close curs;
END; $$ ;


6测试插入数据，成功

select xxx();

select count(*) from yuxiao.test2;



```

## 1数据库节点可扩展。
```bash
1.修改hosts文件，系统配置。
2.在已经存在的集群的一个节点执行scp将安装目录拷贝至新节点相同位置。
3.创建软链接，创建newhosts。
4.source path.sh
5.gpseginstall -f newhosts -u gpadmin -p xxxxxx
6.互信
7. gpexpand -f newhosts
8. gpexpand -i gpexpand_inputfile -D newdatadirectory
9. SELECT * from gp_segment_configuration;


```

## 2数据库表可修改。

```sql
create table test_alter (id int,name varchar(10)) distributed by (id);
ALTER TABLE test_alter ALTER COLUMN name TYPE varchar(20);
ALTER TABLE test_alter ADD phone int;
select * from test_alter;
```
## 3数据表字段可添加说明、昵称。
```sql

comment on table test_alter IS 'card_table';
comment on column test_alter.phone IS 'work_phone_number';

\d+ test_alter 
\d+
```
## 4支持数据库存储过程。

```sql

create or replace function proc_insert_test_alter(in par1 numeric)
returns void as $$ 
begin
INSERT INTO test_alter VALUES (par1);
end;
$$ language plpgsql;

SELECT proc_insert_test_alter(11);
SELECT * from test_alter;

select proname,prosrc from pg_proc where proname='proc_insert_test_alter';

```

## 支持数据分区表。

```sql
 CREATE TABLE test_partition
 (
   date_id integer,
   order_id character varying(22),
   product_id character varying(50),
   send_date timestamp without time zone,
   shop_id numeric
 )
 DISTRIBUTED BY (order_id)
 PARTITION BY RANGE(send_date)
 (
PARTITION p_order_detail_2019 START ('2019-01-01 00:00:00'::timestamp without time zone) END ('2020-01-01 00:00:00'::timestamp without time zone),
PARTITION p_order_detail_2020 START ('2020-01-01 00:00:00'::timestamp without time zone) END ('2021-01-01 00:00:00'::timestamp without time zone)
);


\d+ test_partition;


```

## 6支持内存数据表。

```sql
root
source /opt/gp/greenplum/greenplum_path.sh

vi /home/gpadmin/hostfile_gpssh_all
gp1
gp2
gp3
gp4

gpssh -f /home/gpadmin/hostfile_gpssh_masteronly -e 'mkdir /pgRAM'
gpssh -f /home/gpadmin/hostfile_gpssh_masteronly -e 'mount -t tmpfs -o size=200M  tmpfs /pgRAM'

=============
 [gpadmin@gp1 uuid-1.6.1]$  gpfilespace -o conf
20200330:17:32:51:011033 gpfilespace:gp1:gpadmin-[INFO]:-
A tablespace requires a file system location to store its database
files. A filespace is a collection of file system locations for all components
in a Greenplum system (primary segment, mirror segment and master instances).
Once a filespace is created, it can be used by one or more tablespaces.


20200330:17:32:51:011033 gpfilespace:gp1:gpadmin-[INFO]:-getting config
Enter a name for this filespace
> gpram

Checking your configuration:
Your system has 2 hosts with 1 primary and 1 mirror segments per host.
Your system has 2 hosts with 0 primary and 0 mirror segments per host.

Configuring hosts: [gp4, gp3]

Please specify 1 locations for the primary segments, one per line:
primary location 1> /pgRAM

Please specify 1 locations for the mirror segments, one per line:
mirror location 1> /pgRAM

Configuring hosts: [gp1, gp2]

Enter a file system location for the master
master location> /pgRAM
20200330:17:33:14:011033 gpfilespace:gp1:gpadmin-[INFO]:-Creating configuration file...
20200330:17:33:14:011033 gpfilespace:gp1:gpadmin-[INFO]:-[created]
20200330:17:33:14:011033 gpfilespace:gp1:gpadmin-[INFO]:-
To add this filespace to the database please run the command:
   gpfilespace --config /opt/software/uuid-1.6.1/conf

[gpadmin@gp1 uuid-1.6.1]$ 

=============
[gpadmin@gp1 ~]$ gpfilespace --config /home/gpadmin/conf
20200329:22:28:01:019831 gpfilespace:gp1:gpadmin-[INFO]:-
A tablespace requires a file system location to store its database
files. A filespace is a collection of file system locations for all components
in a Greenplum system (primary segment, mirror segment and master instances).
Once a filespace is created, it can be used by one or more tablespaces.


20200329:22:28:02:019831 gpfilespace:gp1:gpadmin-[INFO]:-getting config
Reading Configuration file: '/home/gpadmin/conf'
20200329:22:28:02:019831 gpfilespace:gp1:gpadmin-[INFO]:-Performing validation on paths
..............................................................................

20200329:22:28:03:019831 gpfilespace:gp1:gpadmin-[INFO]:-Connecting to database
20200329:22:28:03:019831 gpfilespace:gp1:gpadmin-[INFO]:-Filespace "gpRAM" successfully created

===============
CREATE TABLESPACE pgRAM OWNER xuyunhe FILESPACE gpRAM;
CREATE TABLE test_ram (id int) tablespace pgRAM;


insert into test_ram select generate_series(1,100);

select * from test_ram;

```

## 支持自定义表变量.

???

## 支持列存储索引。
```sql

CREATE TABLE test_col (a int, b text) WITH (appendonly=true,orientation=column) DISTRIBUTED BY (a);

CREATE INDEX test_col_idx ON test_col (a);


\d+ test_col



```



## 9支持行存储索引。

```sql

CREATE TABLE test_row (a int, b text) DISTRIBUTED BY (a);
CREATE INDEX test_row_idx  ON test_row USING btree (a)  ;
 \d+ test_row 


```

## 10支持多字段联合主键。

```sql

CREATE TABLE test_idx(
    id int,
    length integer,
    weight integer,
    CONSTRAINT PK_fish PRIMARY KEY (id,length)
);

 \d+ test_idx

```



## 11支持多字段联合主键。

```sql
create table test_t1 (id int,name varchar(32)) distributed by (id);
alter table test_t1 add primary key (id);

insert into test_t1 select generate_series(1,1000),md5(random()::text);

create index test_t1_idx on test_t1 using btree (id,name);
```

## 12支持XML数据字段类型。

```sql
create table test_t2 (id int,name xml) distributed by (id);
alter table test_t2 add primary key (id);


INSERT INTO test_t2 VALUES (1,'<title>this is title</title>');

INSERT INTO test_t2 VALUES (
2, 
'<note>
 <to>chris</to>
 <from>joson</from>
 <heading>Reminder</heading>
 <body>Do not forget the meeting!</body>
 </note>'
 );

```

## 13支持GUID。

```sql


使用uuid字段类型

可以创建uuid函数

cd $GPHOME
ls
bin  docs  etc  ext  greenplum_path.sh  include  lib  pxf  sbin  share

mkdir python

createlang plpythonu -d hgdw -U hgdw

创建函数uuid(生成的UUID中不包括-）：

CREATE OR REPLACE FUNCTION "public"."uuid"() RETURNS "pg_catalog"."varchar" AS $BODY$
DECLARE
   BEGIN RETURN REPLACE (
            public.uuid_python() :: VARCHAR, '-', '' ) ;
END ;
$BODY$ LANGUAGE 'plpgsql' VOLATILE;


select uuid();
               uuid               
----------------------------------
 cef0d00e725311eabbac0800277a276e
(1 row)



可以使用uuid字段类型
create table test_uuid (id uuid,name varchar);
insert into test_uuid values ('cef0d00e725311eabbac0800277a276e','aaa');

1、使用python创建uuid函数
CREATE OR REPLACE FUNCTION "public"."uuid_python"()
  RETURNS "pg_catalog"."varchar" AS $BODY$
import uuid
return uuid.uuid1()
$BODY$
  LANGUAGE 'plpythonu' VOLATILE COST 100
;
ALTER FUNCTION "public"."uuid_python"() OWNER TO "gpadmin";
2、调用uuid函数
CREATE OR REPLACE FUNCTION "public"."get_uuid"()
  RETURNS "pg_catalog"."text" AS $BODY$BEGIN
return md5(uuid_python());
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE COST 100
;
ALTER FUNCTION "public"."get_uuid"() OWNER TO "gpadmin";

```


## 13支持二进制数据字段。

```sql

create table test_bytea (id int,name bytea) distributed by (id);
alter table test_bytea add primary key (id);
 
CREATE OR REPLACE FUNCTION bytea_import(p_path text, p_result out bytea) 
LANGUAGE plpgsql AS $$
DECLARE
    l_oid oid;
    rec record;
BEGIN
    p_result := '';
  select lo_import(p_path) into l_oid;
  for rec in ( select data from pg_largeobject where loid = l_oid order 
by pageno )
  loop
        p_result = p_result || rec.data;
    end loop;
    perform lo_unlink(l_oid);
END; $$ ;


insert into test_bytea(id, name) values ('362232',(select bytea_import('/opt/software/highgo_logo.png')));




```

## 15支持数据压缩。
```sql
normal
CREATE TABLE test_noappedoptimized (a int, b text)  distributed by (a);

compressed
6.x
CREATE TABLE test_appedoptimized (a int, b text) WITH (appendoptimized=true, compresstype=zlib, compresslevel=5) distributed by (a);

5.x
CREATE TABLE test_appedoptimized (a int, b text) WITH (APPENDONLY=true, compresstype=zlib, compresslevel=5) distributed by (a);

insert 
insert into test_noappedoptimized select generate_series(0,100),md5(random()::text);
insert into test_appedoptimized select generate_series(0,100),md5(random()::text);


select pg_size_pretty(pg_total_relation_size('test_noappedoptimized'));
select pg_size_pretty(pg_total_relation_size('test_appedoptimized'));

```

## 16支持通过系统元数据表或元数据函数获取表的行数、表中字段等信息。
```sql

select relname,relnamespace,relowner,reltuples from pg_class where relname like 'test%';
\d test_product;
```
## 17数据库具备自主知识产权。

```sql
hgdw著作权


```

## 18支持关系型数据库常见功能.

```sql


支持事务的ACID特性

begin;
create table test_transaction(id int,name text);
insert into test_transaction values (1,'aaa');
end;

begin;
insert into test_transaction values (2,'bbb');
select * from test_transaction;
rollback;

```

## 19支持非结构化数据库常见功能。
```sql
可存储

图片、XML
等非结构化数据
```


## 20提供集中监控管理界面。
```sql
pgadmin/hgadmin


```


## 21自增字段

```sql
create table test_serial(
id serial not null,
name varchar(10),
description varchar(200),
primary key(id)
);

自动生成相应的sequence。抓取语句如下

CREATE SEQUENCE public.test_serial_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1;


insert into test_serial (name,description) values('aaa','first one');
insert into test_serial (name,description) values('bbb','second two');


```
## 22 二维三维数据字段

```bash
二维支持poin，line，cycle等字段类型



三维通过插件Postgis实现



安装完成之后，可以在相应的数据库中看到如下表spatial_ref_sys和另外2张视图， spatial_ref_sys 存储着合法的空间坐标系统：



# SELECT srid,auth_name,proj4text FROM spatial_ref_sys LIMIT 10;

 srid | auth_name |                             proj4text                             

------+-----------+-------------------------------------------------------------------

 3889 | EPSG      | +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 
+no_defs 

 4001 | EPSG      | +proj=longlat +ellps=airy +no_defs 

 4009 | EPSG      | +proj=longlat +a=6378450.047548896 +b=6356826.621488444 
+no_defs 

 4025 | EPSG      | +proj=longlat +ellps=WGS66 +no_defs 

 4033 | EPSG      | +proj=longlat +a=6378136.3 +b=6356751.616592146 
+no_defs 

 4041 | EPSG      | +proj=longlat +a=6378135 +b=6356750.304921594 +no_defs 

 4081 | EPSG      | +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 
+no_defs 

 4120 | EPSG      | +proj=longlat +ellps=bessel +no_defs 

 4128 | EPSG      | +proj=longlat +ellps=clrk66 +no_defs 

 4136 | EPSG      | +proj=longlat +ellps=clrk66 +no_defs 

(10 rows)

添加表测试：



# CREATE TABLE cities ( id int4, name varchar(50) );

NOTICE:  Table doesn't have 'DISTRIBUTED BY' clause -- Using column named 
'id' as the Greenplum Database data distribution key for this table.

HINT:  The 'DISTRIBUTED BY' clause determines the distribution of data. 
Make sure column(s) chosen are the optimal data distribution key to minimize 
skew.

CREATE TABLE

 

 

# SELECT AddGeometryColumn ('cities', 'the_geom', 4326, 'POINT', 2);

                  addgeometrycolumn                  

-----------------------------------------------------

 public.cities.the_geom SRID:4326 TYPE:POINT DIMS:2 

(1 row)

 

 

 

# SELECT * from cities;

 id | name | the_geom 

----+------+----------

(0 rows)

插入数据并查看



INSERT INTO cities (id, the_geom, name) VALUES 
(1,ST_GeomFromText('POINT(-0.1257 51.508)',4326),'London, England');

INSERT INTO cities (id, the_geom, name) VALUES 
(2,ST_GeomFromText('POINT(-81.233 42.983)',4326),'London, Ontario');

INSERT INTO cities (id, the_geom, name) VALUES 
(3,ST_GeomFromText('POINT(27.91162491 -33.01529)',4326),'East London,SA');

 

#   SELECT * FROM cities;

 id |      name       |                      the_geom                      

----+-----------------+----------------------------------------------------

  3 | East London,SA  | 0101000020E610000040AB064060E93B4059FAD005F58140C0

  1 | London, England | 0101000020E6100000BBB88D06F016C0BF1B2FDD2406C14940

  2 | London, Ontario | 0101000020E6100000F4FDD478E94E54C0E7FBA9F1D27D4540

(3 rows)

空间计算：



# SELECT p1.name,p2.name,ST_Distance_Sphere(p1.the_geom,p2.the_geom) FROM 
cities AS p1, cities AS p2 WHERE p1.id > p2.id;

      name       |      name       | st_distance_sphere 

-----------------+-----------------+--------------------

 East London,SA  | London, England |   9789680.59961472

 East London,SA  | London, Ontario |   13892208.6782928

 London, Ontario | London, England |   5875787.03777356

(3 rows)

```