# logical_replication_replica_identity

**作者**

chrisx

**日期**

2021-03-30

**内容**

逻辑复制-更改复制标识

----

[toc]

## 复制标识介绍

逻辑复制是一种基于数据对象的`复制标识`（通常是主键）复制数据对象及其更改的方法。

也就是说复制标识是逻辑复制的一个基础

以下为复制标识的知识点

* 为了能够复制UPDATE和DELETE操作，被发布的表必须配置有一个`复制标识`，这样在订阅者那一端才能标识对于更新或删除合适的行。
* 默认情况下，复制标识就是主键（如果有主键）。也可以在复制标识上设置另一个唯一索引（有特定的额外要求）。如果表没有合适的键，那么可以设置成复制标识“full”，它表示整个行都成为那个键。不过，这样做效率很低，只有在没有其他方案的情况下才应该使用。
* 如果在发布者端设置了“full”之外的复制标识，在订阅者端也必须设置一个复制标识，它应该由相同的或者少一些的列组成。
* 如果在复制UPDATE或DELETE操作的发布中加入了没有复制标识的表，那么订阅者上后续的UPDATE或DELETE操作将导致错误。不管有没有复制标识，INSERT操作都能继续下去。

## 更改复制标识

默认复制标识使用的是主键，如果需要主键需要删除、更换、重建等变动时，就需要更换复制标识。

如：主键的重建操作会影响业务。需要规划空闲窗口。因为主键重建过程中，主库是无法进行delete和update操作的。此时更换一个复制标识代，使用唯一索引代替主键，作为一个中转。即可减少业务的影响。主键重建完成后再修改回来即可。

1. 语法如下

```sql
ALTER TABLE [ IF EXISTS ] [ ONLY ] name [ * ]
    action [, ... ]
...

其中action 是以下之一：
    ...
    REPLICA IDENTITY { DEFAULT | USING INDEX index_name | FULL | NOTHING }

```

ref [REPLICA IDENTITY](https://www.postgresql.org/docs/13/sql-altertable.html#SQL-CREATETABLE-REPLICA-IDENTITY)

2. 更改复制标识

（1）查询表当前复制标识

```sql
test=# select relreplident from pg_class where relname='product';
 relreplident
--------------
 d
(1 row)

d = 默认 (主键，如果存在),
n = 无,
f = 所有列
i = 索引的indisreplident被设置或者为默认

```

（2）更改复制标识

```sql
create Unique Index p_name_idx_unq On product(product_name);    --创建唯一索引;
alter table product REPLICA IDENTITY USING INDEX p_name_idx_unq;    --更改复制标识为唯一索引

```

（3）重建主键，并将复制标识改为主键

```sql
alter table test.product drop constraint product_id_pk; --删除主键
alter table test.product add constraint product_id_pk_re PRIMARY KEY (product_id);  --新建主键
alter table product REPLICA IDENTITY default;   -将复制标识指向主键

```

:warning: 注意，在订阅者端也必须设置一个复制标识，它应该由相同的或者少一些的列组成。

## 问题

订阅端没有复制标识，或复制标识不一致情况会导致报错

```shell
2021-03-29 15:26:54.880 CST,,,11861,,6061813e.2e55,2,,2021-03-29 15:26:54 CST,3/706,0,ERROR,55000,"publisher did not send replica identity column expected by the logical replication target relation ""test.product""",,,,,,,,,"","logical replication worker"

```

解决方案

在订阅端执行主库修改复制标识的操作。
