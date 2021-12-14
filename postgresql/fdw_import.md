# fdw_import

**作者**

Chrisx

**日期**

2021-11-23

**内容**

IMPORT FOREIGN SCHEMA

Import only foreign tables matching one of the given table names. 

fdw批量导入外部表. ref [importforeignschema](https://www.postgresql.org/docs/13/sql-importforeignschema.html)

----

[toc]

## fdw批量导入外部表

1. 创建fdw扩展

```sql
CREATE EXTENSION postgres_fdw;
```

2. 创建远程服务

```sql
CREATE SERVER ser_postgres_fdw  
        FOREIGN DATA WRAPPER postgres_fdw  
        OPTIONS (host '192.168.6.142', port '5966', dbname 'test');

--OPTIONS (host '192.168.6.142', port '5966', dbname 'test') 是远程数据库连接信息


```

3. 配置远程访问用户密码-mapping

```sql
CREATE USER MAPPING FOR highgo  
        SERVER ser_postgres_fdw  
        OPTIONS (user 'test', password 'test');

--highgo，要映射到外部服务器的一个现有用户的名称。也就是本地用户名
--OPTIONS (user 'test', password 'test')，定义该映射实际的用户名和口令，也就是远程连接使用的用户名口令，也就是远程服务器上存在的用户名口令

```

4. 批量导入外部表

```sql
\c highgo highgo
IMPORT FOREIGN SCHEMA public LIMIT TO (employee,department) FROM SERVER ser_postgres_fdw INTO highgo; --employee,department为表名.(从服务器film_server上的远程模式foreign_films 中导入表定义，把外部表创建在本地模式films中)
ALTER FOREIGN TABLE zadminrole rename to zadminrole_fdw;        --重命名表
ALTER FOREIGN TABLE zadmin rename to zadmin_fdw;

```

5. 查询外部表

```sql
select * from test_postgres_fdw ;

```
