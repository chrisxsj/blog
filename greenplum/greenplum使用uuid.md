
# greenplum中增加uuid函数

python

ref[Greenplum PL/Python语言扩展](http://47.92.231.67:8080/6-0/ref_guide/extensions/pl_python.html)
ref[PL/Python Language](https://gpdb.docs.pivotal.io/6-10/analytics/pl_python.html)

## 1在$GPHOME/ext/中创建命名为 python的文件夹

```bash
cd $GPHOME
ls
bin  docs  etc  ext  greenplum_path.sh  include  lib  pxf  sbin  share

cd ext
mkdir python

```

> 注意，先保证$GPHOME/ext/中包含python文件夹，否则无法增加python扩展

## 2在Shell中执行扩展命令

```bash
$ psql -d hgdw -U hgadmin -c 'CREATE EXTENSION plpythonu;'
```

> Note: Using the deprecated createlang command to enable PL/Python generates an error.

## 3，创建函数uuid1( 生成的UUID中包括-）

```sql
create or replace function public.uuid_python() returns varchar(36)
AS $$
    import uuid
    return uuid.uuid1()
$$ LANGUAGE plpythonu;
```

## 4，创建函数uuid(生成的UUID中不包括-）

```sql
CREATE OR REPLACE FUNCTION "public"."uuid"() RETURNS "pg_catalog"."varchar"
AS $BODY$
    DECLARE
    BEGIN RETURN REPLACE (
    public.uuid_python() :: VARCHAR, '-', '' ) ;
    END ;
$BODY$ LANGUAGE 'plpgsql' VOLATILE;
```

## 5使用

```sql
hgdw=# select uuid_python();
             uuid_python              
--------------------------------------
 b3e717fc-7251-11ea-aafa-0800277a276e
(1 row)

hgdw=# select uuid_python();
             uuid_python              
--------------------------------------
 b57e30f0-7251-11ea-aafa-0800277a276e
(1 row)

hgdw=# select uuid();
               uuid               
----------------------------------
 d6499274725211eaaafa0800277a276e
(1 row)


```