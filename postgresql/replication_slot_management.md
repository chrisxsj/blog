# Replication Slot Management

手动创建、删除物理复制槽

```sql
主库创建流复制使用的物理复制槽
select * from pg_create_physical_replication_slot('pslot1');

查看复制槽
select * from pg_replication_slots;

删除复制槽语句
SELECT * FROM pg_drop_replication_slot('node_a_slot');
```

=====================
逻辑解码？？？？

参考官方文档[第 49 章 逻辑解码-部分 V. 服务器编程]()

复制槽提供了一种自动化的方法来确保主控机在所有的后备机收到 WAL 段 之前不会移除它们的机制。包括物理和逻辑。  

手动创建、删除逻辑复制槽

```sql
select pg_create_logical_replication_slot('logical_slot1','test_decoding');
select slot_name,plugin,slot_type,database,active,restart_lsn from pg_replication_slots;    --不能为active状态，备库去掉使用复制槽的参数
SELECT pg_drop_replication_slot('test_slot');
```

> 注,test_decode 是 pg 内置的一个逻辑 decode 插件



```sql
select * from pg_logical_slot_get_changes('logical_slot1',null,null);
lsn | xid | data
-----+-----+------
(0 rows)
```

> 注意,此函数捕获数据后，数据将被消耗掉，因此此函数查询仅能显示一次。 pg_logical_slot_peek_changes 函数可获取逻辑复制槽所有解析的数据，但只能显示 pg_logical_slot_get_changes 没有消耗的数据。也可使用 pg_recvlogical 捕获数据变化

```sql
pg_recvlogical -d postgres --slot logical_slot1 --start -f -v
```