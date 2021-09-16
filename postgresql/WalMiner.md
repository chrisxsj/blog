# WalMiner

[TOC]

:warning:highgo开源项目

WalMiner是PostgreSQL的WAL(write ahead logs)日志的解析工具，旨在挖掘wal日志所有的有用信息，从而提供PG的数据恢复支持。目前主要有如下功能：

* 从waL日志中解析出SQL，包括DML和少量DDL
  解析出执行的SQL语句的工具，并能生成对应的undo SQL语句。与传统的logical decode插件相比，walminer不要求logical日志级别且解析方式较为灵活。

* 数据页挽回
  当数据库被执行了TRUNCATE等不被wal记录的数据清除操作，或者发生磁盘页损坏，可以使用此功能从wal日志中搜索数据，以期尽量挽回数据。

reference[XlogMiner renamed to WalMiner](https://www.postgresql.org/about/news/1919/)
XlogMiner Enhancements Released and Renamed to WalMinerPosted on 2019-02-22 by Highgo Software

reference [XLogMiner](https://github.com/HighgoSoftware/XLogMiner)
reference [WalMiner](https://gitee.com/movead/XLogMiner)

:warning: 注意：不支持加密存储环境

## walminer安装

reference [WalMiner](https://gitee.com/movead/XLogMiner)

### 1 配置要求

需要将数据库日志级别配置需要大于minimal

创建归档路径

```bash
mkdir /home/hgdb565/archive/ -p
```

必须设置如下三个参数，据库日志级别配置需要大于minimal
wal_level minimal, replica or logical ，若想做最完整的日志挖掘，建议设置为logical。

```sql
alter system set wal_level = 'logical';
alter system set archive_mode = on;
alter system set archive_directory = '/home/hgdb565/archive';
```

修改后重启数据库生效。

### 2 版本查看

查看本机环境数据库版本

```sql
select version();
```

PG版本支持
walminer3.0支持PostgreSQL 10及其以上版本。（此版本放弃对9.x的支持）

### 3 编译安装

download and README [WalMiner](https://gitee.com/movead/XLogMiner)
<!--
(https://gitee.com/movead/XLogMiner/blob/WalMiner_10_0_1/README.md)
-->

**编译一：PG源码编译**
如果你从编译pg数据库开始

1. 将walminer目录放置到编译通过的PG工程的"../contrib/"目录下
2. 进入walminer目录
3. 执行命令

   ```bash
   make && make install
   ```

**编译二：依据PG安装编译**
如果你使用yum或者pg安装包安装了pg

1. 配置pg的bin路径至环境变量

   ```bash
   export PATH=/h2/pg_install/bin:$PATH
   ```

2. 进入walminer代码路径
3. 执行编译安装

   ```bash
   USE_PGXS=1 MAJORVERSION=12 make
   #MAJORVERSION支持‘10’,‘11’,‘12’,‘13’
   USE_PGXS=1 MAJORVERSION=12 make install
   ```

<!--
[pg131@db walminer]$ USE_PGXS=1 MAJORVERSION=13 make
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o walminer.o walminer.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o wm_utils.o wm_utils.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o datadictionary.o datadictionary.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o fetchcatalogtable.o fetchcatalogtable.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o wallist.o wallist.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o walreader.o walreader.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o walminer_decode.o walminer_decode.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o imagemanage.o imagemanage.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o wal2sql.o wal2sql.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o walminer_contents.o walminer_contents.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o walminer_thread.o walminer_thread.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o wal2sql_spi.o wal2sql_spi.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o wal2sql_ddl.o wal2sql_ddl.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -DPG_VERSION_13 -I. -I./ -I/opt/pg131/include/postgresql/server -I/opt/pg131/include/postgresql/internal  -D_GNU_SOURCE   -c -o pagecollect.o pagecollect.c
gcc -std=gnu99 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -O2 -fPIC -shared -o walminer.so walminer.o wm_utils.o datadictionary.o fetchcatalogtable.o wallist.o walreader.o walminer_decode.o imagemanage.o wal2sql.o walminer_contents.o walminer_thread.o wal2sql_spi.o wal2sql_ddl.o pagecollect.o -L/opt/pg131/lib    -Wl,--as-needed -Wl,-rpath,'/opt/pg131/lib',--enable-new-dtags
[pg131@db walminer]$ USE_PGXS=1 MAJORVERSION=13 make install
/bin/mkdir -p '/opt/pg131/lib/postgresql'
/bin/mkdir -p '/opt/pg131/share/postgresql/extension'
/bin/mkdir -p '/opt/pg131/share/postgresql/extension'
/bin/install -c -m 755  walminer.so '/opt/pg131/lib/postgresql/walminer.so'
/bin/install -c -m 644 .//walminer.control '/opt/pg131/share/postgresql/extension/'
/bin/install -c -m 644 .//walminer--3.0.sql  '/opt/pg131/share/postgresql/extension/'
[pg131@db walminer]$

-->

## 使用方法-SQL解析

read [online README.md](https://gitee.com/movead/XLogMiner)

### 场景一：从WAL日志产生的数据库中直接执行解析

测试

5.1 普通解析

```sql

create extension walminer;    --创建扩展
select walminer_wal_add('/opt/pg131/data/pg_wal'); --添加wal文件：参数可以为目录或者文件
select walminer_wal_remove('/opt/pg131/data/pg_wal');    --移除wal文件：参数可以为目录或者文件
select walminer_wal_list();   --列出wal文件

select walminer_all();  --解析add的全部wal日志

select * from walminer_contents;    --解析结果查看

-- 表walminer_contents 
(
 sqlno int, 		--本条sql在其事务内的序号
 xid bigint,		--事务ID
 topxid bigint,		--如果为子事务，这是是其父事务；否则为0
 sqlkind int,		--sql类型1->insert;2->update;3->delete(待优化项目)
 minerd bool,		--解析结果是否完整(缺失checkpoint情况下可能无法解析出正确结果)
 timestamp timestampTz, --这个SQL所在事务提交的时间
 op_text text,		--sql
 undo_text text,	--undo sql
 complete bool,		--如果为false，说明有可能这个sql所在的事务是不完整解析的
 schema text,		--目标表所在的模式
 relation text,		--目标表表名
 start_lsn pg_lsn,	--这个记录的开始LSN
 commit_lsn pg_lsn	--这个事务的提交LSN
)

select walminer_stop(); --结束walminer操作。该函数作用为释放内存，结束日志分析，该函数没有参数
```

:warning: **注意**：walminer_contents是walminer自动生成的unlogged表(之前是临时表，由于临时表在清理上有问题，引起工具使用不便，所以改为unlogged表)，在一次解析开始会首先创建或truncate walminer_contents表。

<!--
create table test_product2 as select * from product ;
select pg_switch_wal();
delete from test_product2 where product_id >'0006';
select pg_switch_wal();
update test_product2 set sale_price='1100' where product_id='0001';
select pg_switch_wal();

select walminer_wal_add('/opt/pg131/data/pg_wal');
select walminer_all();


postgres=# select * from walminer_contents;
 sqlno | xid | topxid | sqlkind | minerd |           timestamp           |                                                                                                       op_text
                                                                                   |                                                                                                 undo_text
                                                                                    | complete | schema |   relation    | start_lsn  | commit_lsn
-------+-----+--------+---------+--------+-------------------------------+----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------+----------+--------+---------------+------------+------------
     1 | 541 |      0 |       3 | t      | 2021-02-07 15:33:30.669396+08 | DELETE FROM public.test_product2 WHERE product_id='0007' AND product_name='擦菜板' AND product_type='厨房用具' AND sale_price=880
 AND purchase_price=790 AND regist_date='2008-04-28' AND product_name_pinyin=null  | INSERT INTO public.test_product2(product_id ,product_name ,product_type ,sale_price ,purchase_price ,regist_date ,produ
ct_name_pinyin) VALUES('0007' ,'擦菜板' ,'厨房用具' ,880 ,790 ,'2008-04-28' ,null)  | t        | public | test_product2 | 4/BD000110 | 4/BD0003E0
     2 | 541 |      0 |       3 | t      | 2021-02-07 15:33:30.669396+08 | DELETE FROM public.test_product2 WHERE product_id='0008' AND product_name='圆珠笔' AND product_type='办公用品' AND sale_price=100
 AND purchase_price=null AND regist_date='2009-11-11' AND product_name_pinyin=null | INSERT INTO public.test_product2(product_id ,product_name ,product_type ,sale_price ,purchase_price ,regist_date ,produ
ct_name_pinyin) VALUES('0008' ,'圆珠笔' ,'办公用品' ,100 ,null ,'2009-11-11' ,null) | t        | public | test_product2 | 4/BD000378 | 4/BD0003E0
(2 rows)

-->

### 场景二：从非WAL产生的数据库中执行WAL日志解析

:warning: 要求执行解析的PostgreSQL数据库和被解析的为同一版本

生产数据库

```sql
create extension walminer;    --创建扩展
select walminer_build_dictionary('/opt/proc/store_dictionary'); --生成数据字典，参数可以为目录或者文件
```

测试数据库

```sql
create extension walminer;    --创建扩展
select walminer_load_dictionary('/opt/test/store_dictionary');  --load数据字典，参数可以为目录或者文件
select walminer_wal_add('/opt/pg131/data/pg_wal'); --添加wal文件：参数可以为目录或者文件
select walminer_wal_remove('/opt/pg131/data/pg_wal');    --移除wal文件：参数可以为目录或者文件
select walminer_wal_list();   --列出wal文件

select walminer_all();  --解析add的全部wal日志

select * from walminer_contents;  --查看结果

```

### 场景三：自apply解析（开发中的功能,慎用）

场景一和场景二中的解析结果是放到结果表中的，场景三可以将解析结果直接apply到解析数据库中。命令执行的流程与场景一和场景二相同。
**此功能可以处理主备切换延迟数据**

### 场景四：DDL解析

* 系统表变化解析

目前walminer支持解析系统表的变化。也就是说如果在PG执行了DDL语句，walminer可以分析出DDL语句引起的系统表的变化。

* DDL解析

:warning:`系统表变化解析`和`DDL解析`不共存，总是接受最新确定的状态。

:warning:walminer对DML数据的解析是要求没有系统表变化的，因此存在DDL变化时，可能导致DML解析不出来的情况。

## 使用方法-数据页挽回(坏块修复)

前期配置一致

```sql
select page_collect(relfilenode, reloid, pages);

```

<!--
walminer的构建基础是，checkpoint之后对每一个page的更改会产生全页写(FPW),因此一个checkpoint之后的所有wal日志可以完美解析。*注意checkpoint是指checkpoint开始的点，而不是checkpoint的wal记录的点，[参照说明](https://my.oschina.net/lcc1990/blog/3027718)*

普通解析会直接解析给定范围内的wal日志，因为可能没有找到之前的checkpoint点，所以会出现有些记录解析不全导致出现空的解析结果。

精确解析是指walminer程序会界定需要解析的wal范围，并在给定的wal范围之前探索一个checkpoint开始点c1，从c1点开始记录FPI，然后就可以完美解析指定的wal范围。如果在给定的wal段内没有找到c1点，那么此次解析会报错停止。
-->

