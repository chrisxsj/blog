# pg12新特性-copy_from支持where条件过滤

## 官方文档描述

E.5. Release 12
E.5.3. Changes
E.5.3.3. Utility Commands

Add a WHERE clause to COPY FROM to control which rows are accepted (Surafel Temesgen)

This provides a simple way to filter incoming data.

ref[Release 12](https://www.postgresql.org/docs/12/release-12.html#id-1.11.6.9.3)

## 示例

创建测试表

```sql
CREATE TABLE test_copy(id int ,name varchar,insert_time timestamp(0) without time zone default clock_timestamp());
INSERT INTO  test_copy(id,name)  select n,n||'_test'  from generate_series(1,1000) n;  
ALTER TABLE test_copy ADD PRIMARY KEY (id);

```

导出表数据

```sql
COPY (SELECT * FROM test_copy WHERE id < 101) TO '/tmp/test_copy_100';
```

创建目标表

```sql
CREATE TABLE test_copy2 (like test_copy);

```

导入数据（使用where限定）

```sql
COPY test_copy2 from '/tmp/test_copy_100' where id<10;
```
