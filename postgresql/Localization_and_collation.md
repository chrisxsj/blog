# Localization_and_collation

**作者**
chrisx

**日期**
2021-03-08

**内容**
pg中文如何按拼音排序
本地化包括数据库的字符串排序、字符归类方法、数值\日期\时间\货币的格式等。pg有本地化支持

----

[toc]

## 本地化支持

```shell
LC_COLLATE  字符串排序顺序
LC_CTYPE  字符分类（什么是一个字符？它的大写形式是否等效？）
LC_MESSAGES 消息使用的语言Language of messages
LC_MONETARY 货币数量使用的格式
LC_NUMERIC  数字的格式
LC_TIME 日期和时间的格式

```

## PostgreSQL支持字符集(encoding)

[Character Set Support](https://www.postgresql.org/docs/13/multibyte.html)

Server=Yes表示该字符集支持用于create database。否则只支持作为客户端字符集。

## 如何获取字符集支持的LC_COLLATE, LC_CTYPE信息

使用如下SQL可以查询系统表pg_collation得到字符集支持的lc_collate和lc_ctype。

其中encoding为空时，表示这个collation支持所有的字符集。

```sql

 select datname,pg_encoding_to_char(encoding) as encoding from pg_database;   --查询数据库字符集
  datname  | encoding
-----------+----------
 postgres  | UTF8
 template1 | UTF8
 template0 | UTF8
 tdb       | UTF8
(4 rows)

select pg_encoding_to_char(collencoding) as encoding,collname,collcollate,collctype from pg_collation where collcollate like '%CN%';   --查询字符集兼容的collate（中文）

 encoding |   collname   | collcollate  |  collctype
----------+--------------+--------------+--------------
 UTF8     | bo_CN        | bo_CN        | bo_CN
 UTF8     | bo_CN.utf8   | bo_CN.utf8   | bo_CN.utf8
 UTF8     | ug_CN        | ug_CN        | ug_CN
 UTF8     | ug_CN.utf8   | ug_CN.utf8   | ug_CN.utf8
 EUC_CN   | zh_CN        | zh_CN        | zh_CN
 EUC_CN   | zh_CN.gb2312 | zh_CN.gb2312 | zh_CN.gb2312
 UTF8     | zh_CN.utf8   | zh_CN.utf8   | zh_CN.utf8
 UTF8     | zh_CN        | zh_CN.utf8   | zh_CN.utf8
(8 rows)

```

在操作前，请了解清楚与您当前数据库字符集(encoding)兼容的collate

## 本土化拼音排序

设置字段的本土化(collate)  

1. 在创建表时，指定兼容当前字符集的collate，或修改列collate

```sql
CREATE TABLE test_order (  
    id varchar,
    name varchar  
);

alter table test_order alter id type text COLLATE "zh_CN";

insert into test_order (id,name) VALUES ('001', '济南');
insert into test_order (id,name) VALUES ('002', '青岛');
insert into test_order (id,name) VALUES ('003', '临沂');

select * from test_order order by name;
 id  | name
-----+------
 003 | 临沂
 001 | 济南
 002 | 青岛
(3 rows)
```

2. 使用SQL,排序时指定字段的 Collate

```sql
postgres=# select * from test_order order by name collate "zh_CN.utf8";
 id  | name
-----+------
 001 | 济南
 003 | 临沂
 002 | 青岛
(3 rows)

```

3. 修改字段本地化

```sql
alter table test_order alter name type text COLLATE "zh_CN";

```

### 注意多音字

有些多音字，例如重庆(chongqing), 编码时"重"可能是按zhong编码，影响输出。

```sql
test03=# select * from (values ('中山'),('重庆')) as a(c1) order by c1 collate "zh_CN";  
  c1    
------  
 中山  
 重庆  
(2 rows)  
```  

<!--
## Greenplum按拼音排序

greenplum不支持单列设置collate，按拼音排序有些许不同。  

在greenplum中，可以使用字符集转换，按对应二进制排序，得到拼音排序的效果。  

```sql
postgres=# select * from (values ('刘德华'), ('刘少奇')) t(id) order by byteain(textout(convert(id,'UTF8','EUC_CN')));  
   id     
--------  
 刘德华  
 刘少奇  
(2 rows)  
```
-->  

## 参考

[如何按拼音排序 - 数据库本土化特性(collate, ctype, ...)](https://github.com/digoal/blog/blob/356b2cd7a9fc8b028c08f6ec95cdfecba1252cde/201704/20170424_03.md)
[collation support](https://www.postgresql.org/docs/13/collation.html)
[排序规则支持](http://www.postgres.cn/docs/13/collation.html)

## GBK is not a valid encoding name

highgo=# CREATE DATABASE test WITH ENCODING 'GBK';
2022-01-18 03:21:34.880 UTC [946] ERROR:  GBK is not a valid encoding name at character 27
2022-01-18 03:21:34.880 UTC [946] STATEMENT:  CREATE DATABASE test WITH ENCODING 'GBK';
ERROR:  GBK is not a valid encoding name
LINE 1: CREATE DATABASE test WITH ENCODING 'GBK';
                                  ^

服务端不支持