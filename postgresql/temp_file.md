# temp_file

**作者**

Chrisx

**日期**

2021-11-23

**内容**

临时文件的使用。
临时文件暴增，大量占用空间。

----

[toc]

## 临时文件相关参数

临时文件相关的数据库参数介绍

* temp_buffers (integer)
设置每个数据库会话使用的临时缓冲区的最大数目。这些都是会话的本地缓冲区，只用于访问临时表。默认是 8 兆字节（8MB）。
* temp_file_limit (integer)
指定一个进程能用于临时文件（如排序和哈希临时文件，或者用于保持游标的存储文件）的最大磁盘空间量。一个试图超过这个限制的事务将被取消。这个值以千字节计，并且-1（默认值）意味着没有限制。只有超级用户能够修改这个设置。
* log_temp_files (integer)
控制记录临时文件名和尺寸。临时文件可以被创建用来排序、哈希和存储临时查询结果。当每一个临时文件被删除时都会制作一个日志项。一个零值记录所有临时文件信息，而正值只记录尺寸大于或等于指定千字节数的文件。默认设置为 -1，它禁用这种记录。
* temp_tablespaces (string)
这个变量指定当一个CREATE命令没有显式指定一个表空间时，创建临时对象（临时表和临时表上的索引）的默认表空间。用于排序大型数据集的临时文件也被创建在这些表空间中。
默认值是一个空字符串，它使得所有临时对象被创建在当前数据库的默认表空间中。
* work_mem (integer)
指定在写到临时磁盘文件之前被内部排序操作和哈希表使用的内存量。该值默认为四兆字节（4MB）

当一些Query的操作，使用的`work_mem`内存量大于指定阈值时，就会触发使用临时文件（包括排序，IDSTINCT，MERGE JOIN，HASH JOIN，哈希聚合，分组聚合，递归查询 等操作），临时文件产生在`temp_tablespaces`中，通常就是数据库默认表空间中。产生临时文件的大小可以用`temp_file_limit`限定。临时文件的清理可以通过参数`log_temp_files`记录到日志中。

临时文件会在QUERY结束后自动清理。数据库启动时，startup进程也会清理temp文件。

## 临时文件大量占用磁盘空间问题

PostgreSQL提供递归查询，但是如果参与递归查询的数据集有问题，导致递归死循环，可能导致临时文件暴增，把空间占满，导致数据库宕机。

示例

```sql
CREATE TABLE "public"."department" (
  "id" int4 NOT NULL,
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "parent_id" int4,
  CONSTRAINT "department_pkey" PRIMARY KEY ("id")
);

INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (1, '顶级部门', 1);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (2, '一级部门1', 1);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (3, '一级部门2', 1);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (4, '一级部门3', 1);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (5, '二级部门1', 2);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (6, '二级部门2', 2);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (7, '二级部门3', 2);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (8, '二级部门4', 3);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (9, '二级部门5', 4);
INSERT INTO "public"."department"("id", "name", "parent_id") VALUES (10, '三级部门1', 5);

with recursive tree as (
    select dep.id,dep.name,dep.parent_id from department dep where dep.id =7
    union all
    select dep.id,dep.name,dep.parent_id from department dep inner join tree on tree.parent_id = dep.id
) select * from tree;

```

以上是一个递归死循环。在临时表空中，可以看到不停增长的临时文件。

```sh
# cd $PGDATA/base/pgsql_tmp
# ll
total 1048512
-rw-------. 1 root root 556294144 Nov 23 15:09 pgsql_tmp2118.1

# 其中2118是进程ip号（pid）

```

临时文件会一直增长，直到占满磁盘空间，如何解决死循环的问题呢？pg没有跳出循环的功能，只能限制循环产生

1. 调整业务逻辑，调整存储的数据，避免循环产生。
2. 设置temp_file_limit,限制所有的sql。超出限制sql会报错
ERROR:  temporary file size exceeds temp_file_limit (1048576kB)

:warning: temp_file_limit可在会话级别设置

3. 使用pg_hint_plan，限制单个sql。超出限制sql会报错

ref [pg_hint_plan](./pg_hint_plan.md)