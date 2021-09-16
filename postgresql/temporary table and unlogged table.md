# pg temporary table and unlogged table

## TEMPORARY|TEMP TABLE

会话级或事务级的临时表，临时表在会话结束或事物结束自动删除，任何在临时表上创建的索引也会被自动删除。除非用模式修饰的名字引用，否则现有的同名永久表在临时表存在期间，在本会话或事务中是不可见的。另外临时表对其他会话也是不可见的，但是会话级的临时表也可以使用临时表所在模式修饰的名字引用。

创建临时表的语法：

```sql
CREATE TEMP tbl_name()ON COMMIT{PRESERVE ROWS|DELETE ROWS|DROP};

PRESERVE ROWS：默认值，事务提交后保留临时表和数据
DELETE ROWS：事务提交后删除数据，保留临时表
DROP：事务提交后删除表
```

## UNLOGGED TABLE

unlogged table是为临时数据设计的，写入性能较高，但是当postgresql进程崩溃时会丢失数据。
创建一张普通表test和一张unlogged表test，测试性能情况

普通表：

```sql
test=# create table test(a int);
CREATE TABLE
test=# \timing
Timing is on.
test=# insert into test select generate_series(1,1000000);
INSERT 0 1000000
Time: 3603.715 ms
```
unlogged表

```sql
test=# create unlogged table testu(a int);
CREATE TABLE
Time: 12.920 ms
test=# insert into testu select generate_series(1,1000000);
INSERT 0 1000000
Time: 801.376 ms
比较以上两个结果，unlogged表的写性能是普通表的4.5倍。
```
