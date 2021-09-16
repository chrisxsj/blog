# pg_buffercache

**作者**

chrisx

**日期**

2021-05-13

**内容**

PostgreSQL扩展pg_buffercache

----

[toc]

## 介绍

PostgreSQL额外支持模块之pg_buffercache
pg_buffercache模块是pg内核原生支持的模块。完全编译后，其会存在于扩展目录中。pg_buffercache提供了一种实时检测共享缓冲区的方法。
这个模块提供了一个C函数：pg_buffercache_pages，它返回一个记录的集合和一个视图：pg_buffercache，它包装了这个函数来更方便的使用。
默认情况下，只有超级管理员（superusers）和角色 pg_read_all_stats的成员可以访问。也可通过grant命令授权。

```sql
test=# \d pg_buffercache;
      View "public.pg_buffercache"
      Column      |   Type   | Modifiers
------------------+----------+-----------
 bufferid         | integer  |
 relfilenode      | oid      |
 reltablespace    | oid      |
 reldatabase      | oid      |
 relforknumber    | smallint |
 relblocknumber   | bigint   |
 isdirty          | boolean  |
 usagecount       | smallint |
 pinning_backends | integer  |
```

pg_buffercache列的解释参考：

https://www.postgresql.org/docs/10/pgbuffercache.html

## 注意

共享缓存中的每个缓冲区都有一行。
未使用的缓冲区除了bufferid以外的所有列为null。
系统数据目录表（Shared system catalogs）所属数据库显示为0
 
因为缓存被所有的数据库共享使用，通常有些relation中的一些页面不属于当前的数据库。如果与pg_class做链接（join）查询，可能不会有匹配的连接行，或者甚至可能会有错误连接。如果你试图连接pg_class，一个好的办法就是将连接限制为reldatabase等于当前数据库的OID或者为零的行。
 
当访问pg_buffercache视图时，内部缓冲区管理器会锁住足够长的时间来拷贝所有这个视图会展示的缓冲区状态数据。这确保了这个视图产生一个一致的结果集，同时不会不必要的长时间阻碍正常的缓冲区活动。虽然如此，但是如果这个视图被频繁读取的话，会对数据库性能产生一些影响。
 
参考如下：
```
查询pg_buffercache信息
highgo=# select * from pg_buffercache;
 bufferid | relfilenode | reltablespace | reldatabase | relforknumber | relblocknumber | isdirty | usagecount | pinning_backends
----------+-------------+---------------+-------------+---------------+----------------+---------+------------+------------------
        1 |       13357 |          1664 |           0 |             0 |              0 | f       |          5 |                0
        2 |        1260 |          1664 |           0 |             0 |              0 | f       |          4 |                0
        3 |        1259 |          1663 |       13361 |             0 |              0 | f       |          5 |                0
        4 |        1259 |          1663 |       13361 |             0 |              1 | f       |          5 |                0
        5 |        1259 |          1663 |       13361 |             0 |              2 | f       |          5 |                0
        6 |        1249 |          1663 |       13361 |             0 |              0 | f       |          5 |                0
......
       58 |        2965 |          1664 |           0 |             0 |              0 | f       |          5 |                0
......
      411 |        2618 |          1663 |       13361 |             2 |              0 | f       |          1 |                0
      412 |        2674 |          1663 |       13361 |             0 |             41 | f       |          2 |                0
      413 |             |               |             |               |                |         |            |                
      414 |             |               |             |               |                |         |            |                
      415 |             |               |             |               |                |         |            |                
......
 
highgo=# select count(*) from pg_buffercache;
 count
-------
 32767
(1 row)
 
highgo=# select oid,relname from pg_class where oid in (1260,2965,1233);
 oid  |                 relname                
------+-----------------------------------------
 1233 | pg_shdepend_reference_index
 2965 | pg_db_role_setting_databaseid_rol_index
 1260 | pg_authid
(3 rows)
```
以上每个缓冲区都有一行，共32767行
 
## pg_buffercache应用：
 
1.查看shared buffers小大：
```
highgo=# SELECT name,setting,unit,current_setting(name) FROM pg_settings WHERE name='shared_buffers';
      name      | setting | unit | current_setting
----------------+---------+------+-----------------
 shared_buffers | 32767   | 8kB  | 262136kB
(1 row)
 
 
highgo=# select count(*) from pg_buffercache;
 count
-------
 32767
(1 row)
```
 
每一个buffer是8kB，共有32767个buffer
 
 
2.创建扩展
```
create extension pg_buffercache;
```
 
3.可以通过isdirty字段询查脏块数个数或数据量,
```
select count(*) from pg_buffercache where isdirty is true;
select count(*)*8/1024 || 'MB' from pg_buffercache where isdirty is true;
```
4.如果是未应用的buffer，那么除了bufferid，其他字段都为空值。可以查询未使用buffer的个数或数据量
```
select count(*)*8/1024||'MB' from pg_buffercache where relfilenode is null and reltablespace is null and reldatabase is null and relforknumber is null and relblocknumber is null and isdirty is null and usagecount is null;
```
 
 
 
5.查看数据库对象所占用buffer个数排名情况：
```
SELECT c.relname, count(*) AS buffers
FROM pg_buffercache b INNER JOIN pg_class c
ON b.relfilenode = pg_relation_filenode(c.oid) AND
   b.reldatabase IN (0, (SELECT oid FROM pg_database
                         WHERE datname = current_database()))
GROUP BY c.relname
ORDER BY 2 DESC
LIMIT 10;
 
             relname             | buffers
---------------------------------+---------
 pg_attribute                    |      27
 pg_proc                         |      20
 pg_class                        |      17
 pg_operator                     |      14
 pg_depend_reference_index       |      12
 pg_depend                       |      11
 pg_type                         |      10
 pg_proc_oid_index               |       9
 pg_rewrite                      |       7
 pg_attribute_relid_attnum_index |       7
(10 rows)
```
 
 
6.查看buffercache对象的应用小大以及百分比
```
SELECT
c.relname,
pg_size_pretty(count(*) * 8192) as buffered,
round(100.0 * count(*) /
(SELECT setting FROM pg_settings
WHERE name='shared_buffers')::integer,1)
AS buffers_percent,
round(100.0 * count(*) * 8192 /
pg_relation_size(c.oid),1)
AS percent_of_relation
FROM pg_class c
INNER JOIN pg_buffercache b
ON b.relfilenode = c.relfilenode
INNER JOIN pg_database d
ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.oid,c.relname
ORDER BY 3 DESC
LIMIT 10;
 
             relname              |  buffered  | buffers_percent | percent_of_relation
----------------------------------+------------+-----------------+---------------------
 pg_operator_oid_index            | 32 kB      |             0.0 |                80.0
 pg_opclass_oid_index             | 16 kB      |             0.0 |               100.0
 pg_transform_type_lang_index     | 8192 bytes |             0.0 |               100.0
 pg_statistic_relid_att_inh_index | 16 kB      |             0.0 |               100.0
 pg_namespace_oid_index           | 16 kB      |             0.0 |               100.0
 pg_depend                        | 88 kB      |             0.0 |                19.0
 pg_index_indrelid_index          | 16 kB      |             0.0 |               100.0
 pg_depend_reference_index        | 96 kB      |             0.0 |                24.0
 pg_depend_depender_index         | 40 kB      |             0.0 |                11.6
 pg_extension_oid_index           | 16 kB      |             0.0 |               100.0
(10 rows)
```
 
7.缓冲区应用分布：
```
SELECT
c.relname, count(*) AS buffers,usagecount
FROM pg_class c
INNER JOIN pg_buffercache b
ON b.relfilenode = c.relfilenode
INNER JOIN pg_database d
ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.relname,usagecount
ORDER BY c.relname,usagecount;
             relname              | buffers | usagecount 
-----------------------------------+---------+------------
 pg_aggregate                      |       1 |          5
 pg_aggregate_fnoid_index          |       1 |          4
 pg_aggregate_fnoid_index          |       1 |          5
 pg_am                             |       1 |          5
 pg_amop                           |       3 |          5
 pg_amop_fam_strat_index           |       1 |          1
 pg_amop_fam_strat_index           |       3 |          5
 pg_amop_opr_fam_index             |       3 |          5
 pg_amproc                         |       1 |          4
 pg_amproc                         |       1 |          5
 pg_amproc_fam_proc_index          |       2 |          5
 pg_attrdef                        |       1 |          3
 pg_attrdef_adrelid_adnum_index    |       2 |          3
 pg_attrdef_oid_index              |       1 |          1
 pg_attrdef_oid_index              |       1 |          2
 pg_cast                           |       2 |          5
 pg_cast_source_target_index       |       2 |          5
......
```
 
8.查询单个表占用的buffer情况
```
select
c.relname,
count(*) as buffers
from pg_class c
join pg_buffercache b
on b.relfilenode = c.relfilenode
inner join pg_database d
on (b.reldatabase = d.oid and d.datname = current_database())
where c.relname like 'test%'
group by c.relname
order by 2 desc;
 
 
 relname | buffers
---------+---------
 test_t1 |       1
(1 row)
```
