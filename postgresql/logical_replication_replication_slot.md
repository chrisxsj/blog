# logical_replication_replication_slot

**作者**

chrisx

**日期**

2021-03-30

**内容**

逻辑复制-复制槽管理，取消关联复制槽，单独删除订阅或复制槽，

---

[toc]

## 删除订阅报错

删除订阅报错

```sql
test=# drop subscription test_slot_sub ;
ERROR:  could not connect to publisher when attempting to drop the replication slot "test_slot_sub"
DETAIL:  The error was: could not connect to server: Connection refused
        Is the server running on host "127.0.0.1" and accepting
        TCP/IP connections on port 5433?
HINT:  Use ALTER SUBSCRIPTION ... SET (slot_name = NONE) to disassociate the subscription from the slot.
test=#

```

或者

```sql
test=# drop subscription test_slot_sub ;
ERROR:  could not drop the replication slot "test_slot_sub" on publisher
DETAIL:  The error was: ERROR:  replication slot "test_slot_sub" does not exist
test=#

```

* 当删除与远程主机（正常状态）上的复制槽相关联的订阅时，DROP SUBSCRIPTION 将连接到远程主机，并尝试删除该复制槽，作为其操作的一部分。这是必要的， 以便释放远程主机上为订阅分配的资源。如果失败，因为远程主机不可访问， 或者因为远程复制槽不能被删除，或者复制槽不存在， 则DROP SUBSCRIPTION命令将失败。要在这种情况下继续， 请执行ALTER SUBSCRIPTION ... SET (slot_name = NONE) 来解除复制槽与订阅的关联。之后，DROP SUBSCRIPTION 将不再尝试对远程主机执行任何操作。请注意，如果远程复制槽仍然存在， 则应手动删除该插槽；否则将继续保留WAL，最终可能导致磁盘空间不足

解除复制槽与订阅的关联，然后删除。

```sql
alter subscription test_slot_sub disable;
ALTER SUBSCRIPTION test_slot_sub SET (slot_name = NONE);
drop subscription test_slot_sub ;

```

## 复制槽管理说明

每一个（活跃的）订阅会从远（发布）端上的一个复制槽接收更改。通常，远程复制槽是在使用CREATE SUBSCRIPTION创建订阅是自动创建的，并且在使用DROP SUBSCRIPTION删除订阅时，复制槽也会自动被删除。不过，在一些情况下，有必要`单独`操纵订阅以及其底层的复制槽。如下场景：

    在删除一个订阅是，远程主机不可达。在这种情况下，可以在尝试删除该订阅之前，使用ALTER SUBSCRIPTION将复制槽解除关联。如果远程数据库实例不再存在，那么不需要进一步的行动。不过，如果远程数据库实例只是不可达，那么复制槽应该被手动删除。否则它将会继续保留WAL并且最终可能会导致磁盘被填满。这种情况应该要仔细地研究。

```sh
select pg_drop_replication_slot(slot_name); --删除

```

ref [Replication Slot Management](https://www.postgresql.org/docs/13/logical-replication-subscription.html#LOGICAL-REPLICATION-SUBSCRIPTION-SLOT)
ref [复制槽管理](http://www.postgres.cn/docs/13/logical-replication-subscription.html)

