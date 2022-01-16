# index

## 分析优化索引

通过分析执行计划确定相关表是否走索引(Index关键字)，还有走索引之后效率如何(COST)，找出影响效率的表列进行如下调整：
1、对于缺少索引并且数据量比较大的表建立索引；
2、对于查询条件较多的表使用多列索引(具体包含哪几列根据具体情况)；
3、索引列与条件列格式一致，例如：包含substr，date_part等表达式的条件，在索引中也包含相应表达式。

创建索引语法：

```sql
CREATE  INDEX  [CONCURRENTLY] 索引名 ON 表名 (列名，列名…….)

```

## 重建索引reindex

REINDEX使用指定索引对应的表里存储的数据重建一个索引， 并且替换该索引的旧拷贝。

语法：

```sql
REINDEX [ ( VERBOSE ) ] { INDEX | TABLE | SCHEMA | DATABASE | SYSTEM } [ CONCURRENTLY ] name ;

```

1、INDEX name：重建指定的索引；
2、TABLE name ：重建指定表的所有索引。如果该表有一个二级 “TOAST”表，它的索引会被重建；
3、SCHEMA name ：重建指定模式的所有索引；
4、DATABASE name ：重建当前数据库内的所有索引。共享的系统目录上的索引也会被处理；
5、SYSTEM name ：重建当前数据库中在系统目录上的所有索引，共享系统目录上的索引也被包括在内，用户表上的索引则不会被处理；
6、VERBOSE：在每个索引被重建时打印进度报告。

:warning: CONCURRENTLY在线创建索引

## 索引进度监控

```sql
pg_stat_progress_create_index   --pg12及以后
```
