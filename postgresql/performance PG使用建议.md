一、命名规范
1. DB object: database,  schema,  table,  view,  index,  function,  trigger等名称
(1) 建议使用小写字母、数字、下划线的组合
(2) 建议不使用双引号即"包围，除非必须包含大写字母或空格等特殊字符
(3) 长度不能超过63个字符
(4) 禁止使用 SQL 关键字，例如 type,  order 等
2. table能包含的column数目, 根据字段类型的不同，数目在 250 到 1600 之间
3. 临时或备份的DB object:table, view 等, 建议加上日期, 如table_xxx_20150826
4. index命名规则为: 表名_列名_idx, 如student_name_idx,  建议不显式给出index name, 使用DBMS系统默认给出的index name,  如create index ON student (name); 则默认给出student_name_idx
二、Column设计
1. 建议能用varchar(N) 就不用char(N), 以利于节省存储空间
2. 建议能用varchar(N) 就不用text, varchar
3. 建议使用default NULL, 而不用default '', 以节省存储空间, 
4. 建议使用ip4, ip4r, ip6, ip6r, ipaddress, iprange 来存储IP, IP范围；使用macaddr来存储MAC (Media Access Control) address
5. 建议使用timestamp with time zone(timestamptz), 而不用timestamp without time zone, 避免时间函数在对于不同时区的时间点返回值不同, 也为业务国际化扫清障碍
6. 建议使用NUMERIC(precision,  scale)来存储货币金额和其它要求精确计算的数值,  而不建议使用real,  double precision
7. 建议使用hstore 来存储非结构化, key-value 键值型, 对数不定的数据
8. 建议使用ltree 来存储 Top. 中国. 北京. 天安门 这种树状层次结构 数据
9. 建议使用json 来存储JSON (JavaScript Object Notation) data
10. 建议使用Geometric Types 结合PostGIS来实现地理信息数据存储及操作
11. 建议使用如下range类型代替字符串或多列来实现范围的存储
三、Constraints设计
1. 建议每个table都有主键; 
2. 建议不要用有业务含义的名称作为主键, 比如身份证或者国家名称, 尽管其是unique的
3. 建议主键的一步到位的写法:id serial primary key 或id bigserial primary key
四、Index设计
1. PostgreSQL 提供的index类型: B-tree,  Hash,  GiST (Generalized Search Tree),  SP-GiST (space-partitioned GiST) and GIN (Generalized Inverted Index), 目前不建议使用Hash,  SP-GiST
2. 建议create 或 drop index 时, 加 CONCURRENTLY参数, 这是个好习惯，达到与写入数据并发的效果
3. 建议对于频繁update,  delete的包含于index 定义中的column的table,  用create index CONCURRENTLY ,  drop index CONCURRENTLY 的方式进行维护其对应index
4. 建议用unique index 代替unique constraints, 便于后续维护
5. 建议不要建过多index，一般不要超过6个，核心table（产品，订单）可适当增加index个数
五、关于NULL
1. NULL 的判断：IS NULL ，IS NOT NULL
2. 注意boolean 类型取值 true，false， NULL
3. 小心NOT IN 集合中带有NULL元素
postgres=# SELECT * FROM (VALUES(1), (2)) v(a) ; 
 a
 --- 
 1 
 2
 (2 rows)  
postgres=# select 1 NOT IN (1, NULL); 
 ?column?
 ---------- 
 f
 (1 row)  
postgres=# select 2 NOT IN (1, NULL); 
 ?column?
 ---------- 
 
(1 row) 
postgres=# SELECT * FROM (VALUES(1), (2)) v(a) WHERE a NOT IN (1, NULL); 
 a
 ---
(0 rows)
可见，出现这种情况的根本原因在于SELECT只返回WHERE中判断条件结果为true的数据
4. 建议对字符串型NULL值处理后，进行 || 操作
postgres=# select NULL||'PostgreSQL'; 
 ?column?
 ---------- 
 
 (1 row) 
postgres=# select coalesce(NULL, '')||'PostgreSQL'; 
 ?column?
 ------------ 
 PostgreSQL
 (1 row)

5. 建议对hstore 类型进行处理后，进行 || 操作，避免被NULL吃掉
postgres=# select  NULL::hstore || ('key=>value') ; 
 ?column?
 ---------- 
 
 (1 row) 
postgres=# select  coalesce(NULL::hstore, hstore(array[]::varchar[])) || ('key=>value') ; 
?column?
----------------
 "key"=>"value"
 (1 row) 
postgres=# select  coalesce(NULL::hstore, ''::hstore) || ('key=>value') ; 
 ?column?    
 ----------------
  "key"=>"value"
  (1 row)

六、其他注意事项
1. 建议对DB object 尤其是COLUMN 加COMMENT，便于后续维护
2. 建议非必须时避免select *, 只取所需字段，以减少网络带宽消耗，避免表结构变更对程序的影响
3. 建议update 时尽量做 <> 判断, 比如update table_a set column_b = c where column_b <> c
4. 建议将单个事务的多条SQL操作, 分解、拆分，或者不放在一个事务里，让每个事务的粒度尽可能小，尽量lock少的资源，避免lock 、dead lock的产生
5. 建议向大size的table中add column时，将 alter table t add column col datatype not null default xxx；分解为如下，避免填充default值导致的过长时间锁表
alter table t add column col datatype ； 
alter table t alter column col set default xxx； 
update t set column = default where id = 1; 
.................. 
update t set column = default where id = N; 
------此处, 可以用先进的\watch来刷------即 
update table t  set column= DEFAULT where id in ( select id from t where column is null limit 1000 ) ; \watch 3 
alter table t alter column col set not null；
6. 建议执行DDL, 比如CRAETE, DROP, ALTER 等,  不要显式的开transaction,  因为加lock的mode非常高, 极易产生deadlock
7. 建议复杂的统计查询可以尝试窗口函数 Window Functions
8. 建议发给PostgrSQL DBA review 及 执行的SQL，无论是使用pgadmin这种图形化工具，还是pg_dump 这种命令行工具生成的SQL，都去掉注释(--之后的部分)，双引号"及alter owner等冗余或不应该带到线上生产的dev/beta DB中的信息


Parallel create index

Hgdb561 测试
 
highgo=> \d+ test_parallel
                                             Table "test.test_parallel"
   Column    |            Type             | Collation | Nullable | Default | Storage  | Stats target | Description
-------------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
 id          | integer                     |           |          |         | plain    |              |
 name        | character varying(32)       |           |          |         | extended |              |
 create_time | timestamp without time zone |           |          |         | plain    |              |
 
highgo=> set max_parallel_maintenance_workers =4;
SET
 
INSERT INTO test_parallel SELECT generate_series(1,10000000),md5(random()::text),clock_timestamp();
 
CREATE INDEX idx_test_parallel ON test_parallel USING BTREE(create_time);
 
[highgo@dbrs ~]$ ps -ef |grep post
......
postfix   1523  1520  0 09:32 ?        00:00:00 qmgr -l -t unix -u
highgo    2195  1173  3 09:56 ?        00:01:37 postgres: test highgo [local] CREATE INDEX
highgo    3257  1173 39 10:38 ?        00:00:07 postgres: parallel worker for PID 2195  
highgo    3277  2274  0 10:38 pts/1    00:00:00 grep --color=auto post
[highgo@dbrs ~]$