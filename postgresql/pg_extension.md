# pg extension

## 1介绍

PostgreSQL被设计为易于扩展。因此，加载到数据库中的扩展功能就可以像内置的特性一样运行。与源代码一起发布的contrib/ 目录包含一些核心代码中的扩展。也有一些扩展是独立开发的，比如PostGIS，需要单独下载安装。
 
例如，pg_pool是一个受欢迎的主/备用复制解决方案，它是独立于核心项目开发的。
 
PostgreSQL引入了一种方式来安装contrib模块，称为扩展（extensions）。
此方法适用于所有使用扩展规范构建的contrib模块，包括如下：
扩展SQL文件（ extension_name.sql ）
扩展控制文件 （ extension_name.control ）
扩展库文件（extension_name.so）
 
pg核心代码中的扩展插件可以在编译时使用world选项安装。安装后通常位于目录$PGHOME目录中。其中.congrol和.sql存储在$PGHOME/share/extension中，.so文件通常位于目录$PGHOME/lib中。如果尚未安装，则目录中不会有这些插件。
 
PG源代码中包含的扩展列表参考[官方文档](https://www.postgresql.org/docs/10/contrib.html)
 
## 2查看

通过以下两个视图查看数据库可安装的扩展插件和已安装的扩展插件

**The pg_available_extensions view lists the extensions that are available for installation. See also the pg_extension catalog, which shows the extensions currently installed.**

```sql
pgaudit扩展插件可安装
select * from pg_available_extensions where name like '%crypt%';
   name   | default_version | installed_version |         comment         
----------+-----------------+-------------------+-------------------------
 pgcrypto | 1.3             |                   | cryptographic functions
(1 row)

 
已安装的扩展如下
select * from pg_extension;
      extname       | extowner | extnamespace | extrelocatable | extversion |   extconfig   | extcondition
--------------------+----------+--------------+----------------+------------+---------------+--------------
 plpgsql            |       10 |           11 | f              | 1.0        |               |
 pg_buffercache     |       10 |         2200 | t              | 1.3        |               |
 pg_pathman         |       10 |         2200 | f              | 1.5        | {98416,98427} | {"",""}
 pg_stat_statements |       10 |         2200 | t              | 1.5        |               |
 pgcrypto           |       10 |         2200 | t              | 1.3        |               |
(5 rows)

```

## 3扩展插件的维护

**修改扩展插件所属模式**
这里新添加的扩展属于public模式，另外pg_catalog这个schema是PostgreSQL默认的元数据schema，所有的元数据都在这里。创建在pg_catalog里面的扩展优先级最高，所有用户可见。
 
可以运行如下指令指定或修改扩展的所属模式：
```sql
create extension extension_name with schema pg_catalog;
alter extension extension_name set schema pg_catalog; 


alter extension pgcrypto set schema pg_catalog;

\dx
                                         List of installed extensions
        Name        | Version |       Schema       |                        Description                        
--------------------+---------+--------------------+-----------------------------------------------------------
 alter_pg_func      | 1.0     | information_schema | Compatible with oracle function
 oraftops           | 1.0     | oracle_catalog     | Functions that are compatible with the Oracle
 pg_stat_statements | 1.6     | public             | track execution statistics of all SQL statements executed
 pg_wait_sampling   | 1.1     | public             | sampling based statistics of wait events
 pgcrypto           | 1.3     | pg_catalog         | cryptographic functions
 plpgsql            | 1.0     | pg_catalog         | PL/pgSQL procedural language
 worker_pg_pdr      | 1.0     | public             | Sample background worker
(7 rows)
```


**删除扩展插件**

```sql
 drop extension pgcrypto;
```

## 手动添加扩展插件

数据库安装完成后，扩展插件没有编译到安装目录，如何后期增加扩展组件？
建议创建新的目录，使用源码编译到新目录，然后copy到home目录中。

```bash
1创建新目录
mkdir /opt/pg106
chown highgo:highgo /opt/pg106

2进入到源码目录配置config
cd /opt/software/postgresql-10.6/
./configure --prefix=/opt/pg106
3进入到contrib目录编译安装插件
cd /opt/software/postgresql-10.6/contrib
make
make install
4拷贝编译的插件到home目录中

cp /opt/pg106/share /opt/postgres/
or
cp /opt/pg106/share/postgresql/extension/pgcrypto* /opt/pg/share/postgresql/extension

```
注意：可以将整个目录拷贝，也可以只拷贝需要的插件

## 常用扩展

cube
dblink
hstore
pg_buffercache
pgcrypto
pg_prewarm
pg_stat_statements
postgis
passwordcheck
pg_pathman
postgres_fdw
file_fdw
oracle_fdw
mysql_fdw
pgaudit
pg_repack
pgstattuple
pageinspect
