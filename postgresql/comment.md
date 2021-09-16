# comment

**作者**

Chrisx

**日期**

2021-08-06

**内容**

注释的使用和查询

----

[toc]

## 使用注释

```sql
comment on table product is 'The product table';    --表添加注释
comment on column product.sale_price is 'the sale price';   --字段添加注释
```

## 查询数据库中的注释

表注释查询

```sql
select relname,reltype,obj_description(32812,'pg_class') as comment from pg_class c where relname='product';
```

查询模式对象的表名，注释，类型,schema

```sql
select n.nspname,c.relname,relkind,obj_description(relfilenode,'pg_class') as comment from pg_class c,pg_namespace n where c.relnamespace=n.oid and n.nspname='public' limit 10;
```

查询指定schema下注释信息

```sql
select description from pg_description
join pg_class on pg_description.objoid = pg_class.oid
join pg_namespace on pg_class.relnamespace = pg_namespace.oid
where relname = '<table name>' and nspname='<schema name>';

```

表字段：表名，字段名，字段备注，字段类型，精度，字段是否可以为空

```sql
select c.relname,a.attname AS NAME,format_type ( a.atttypid, a.atttypmod ) AS type,a.attnotnull AS notnull,col_description ( a.attrelid, a.attnum ) AS COMMENT from pg_class c,pg_attribute a where c.relname = 'product' and a.attrelid = c.oid and a.attnum >0;

```

PostgresSql 中查询某张表中字段、字段类型、长度、主键、唯一、外键、null

```sql
select a.attname as 字段名称,format_type(a.atttypid,a.atttypmod) as 字段类型,
(case
when atttypmod-4>0 then atttypmod-4
else 0
end)字段长度,
(case
when (select count(*) from pg_constraint where conrelid = a.attrelid and conkey[1]=attnum and contype='p')>0  then 'Y'
else 'N'
end) as 主键,
(case
when (select count(*) from pg_constraint where conrelid = a.attrelid and conkey[1]=attnum and contype='u')>0  then 'Y'
else 'N'
end) as U,
(case
when (select count(*) from pg_constraint where conrelid = a.attrelid and conkey[1]=attnum and contype='f')>0  then 'Y'
else 'N'
end) as R,
(case
when a.attnotnull=true  then 'N'
else 'Y'
end) as 不是null,
col_description(a.attrelid,a.attnum) as comment,'XEditText' as control
from  pg_attribute a
where attstattarget=-1 and attrelid = (select oid from pg_class where relname ='product');
```

:warning: relname ='product'替换成实际的表名