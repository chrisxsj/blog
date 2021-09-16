# large object

参考[Large Objects](https://www.postgresql.org/docs/current/lo-interfaces.html#LO-CREATE)

1、查看大对象的视图

Pg中的大对象是通过内置函数单独创建的，由表对象引用。通过postgreSQL 的 libpq 客户端接口库对大对象进行访问。
pg_largeobject_metadata：large object的元数据表，记录每个large object的OID（对象标识符）、属主、访问权限。
Pg_largeobject：具体存储large object的表

```bash
postgres=# select * from pg_largeobject_metadata;
 lomowner | lomacl
----------+--------
(0 rows)

postgres=# select * from pg_largeobject;
 loid | pageno | data
------+--------+------
(0 rows)
```

2、创建lo对象

```bash
postgres=# selec tlo_create(tlo);
 lo_create
-----------
      6000
(1 row)

postgres=# select oid,* from pg_largeobject_metadata;
 oid  | lomowner | lomacl
------+----------+--------
 6000 |       10 |
(1 row)

postgres=# select * from pg_largeobject;
 loid | pageno | data
------+--------+------
(0 rows)
```

3、打开lo，先begin

```bash
postgres=# begin;
BEGIN
postgres=# select pg_catalog.lo_open(6000,393216);
 lo_open
---------
       0
(1 row)
```

4、写入lo，后commit

```bash
postgres=# select lowrite(0,'sdjfkasjkdfjsldf');
 lowrite
---------
      16
(1 row)

postgres=# commit;
COMMIT


postgres=# select oid,* from pg_largeobject_metadata;
 oid  | lomowner | lomacl
------+----------+--------
 6000 |       10 |
(1 row)

postgres=# select * from pg_largeobject;
 loid | pageno |                data               
------+--------+------------------------------------
 6000 |      0 | \x73646a666b61736a6b64666a736c6466
(1 row)
```

5、引用

```bash
postgres=# create table test_lo(lo oid);
CREATE TABLE
postgres=# insert into test_lo values ('6000');
INSERT 0 1
postgres=#
```

6、查看

```bash
postgres=# select * from test_lo;
  lo 
------
 6000
(1 row)

只能查看到引用值。
在postgresql中，对large object 的使用需要使用专门的方法，不能直接使用引用字段的方式来查看、使用。
```