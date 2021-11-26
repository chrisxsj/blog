# replication_delay

**作者**

Chrisx

**日期**

2021-07-07

**内容**

延迟流复制

ref[recovery_min_apply_delay](https://www.postgresql.org/docs/10/standby-settings.html)

---

[toc]

## 延迟流复制介绍

* 默认情况下，一个后备服务器会尽快恢复来自于主服务器的 WAL 记录。有一份数据的延时拷贝是有用的，它能提供机会纠正数据丢失错误。这个参数允许你将恢复延迟一段固定的时间，如果没有指定单位则以毫秒为单位。例如，如果你设置这个参数为5min，对于一个事务提交，只有当后备机上的系统时钟超过主服务器报告的提交时间至少 5分钟时，后备机才会重放该事务。
  
:warninig: 注意，如果主库的时间早于备库，则可能造成备库立即应用日志。（主库3:00<备库5:00,备库延迟1h，也是4:00应用，因此，此时备库5:00会立即应用日志）

* 延迟仅发生在事务提交的WAL记录上。其他记录会尽快重放，这不是问题，因为MVCC可见性规则确保在应用相应的提交记录之前其效果不可见。也就是说，延迟仅是wal应用延迟，备库依然及时接收主库发送的wal日志流。因此recovery_min_apply_delay 参数设置过大会使备库的 pg_wal 日志因保留过多的 WAL 日志文件而占用较大硬盘空间。

## 配置

在 recovery.conf 配置文件中配置参数 recovery_min_apply_delay, 支持 ms ，s , min ，h ，d

```sql
recovery_min_apply_delay='30min'
```

需要重启备库生效

观察应用延迟状态

```sql
postgres=# select * from pg_stat_replication ;
-[ RECORD 1 ]----+------------------------------
pid              | 2282
usesysid         | 16390
usename          | repuser
application_name | 141
client_addr      | 192.168.6.142
client_hostname  |
client_port      | 49808
backend_start    | 2020-10-16 11:12:35.862371+08
backend_xmin     |
state            | streaming
sent_lsn         | 0/4000518
write_lsn        | 0/4000518
flush_lsn        | 0/4000518
replay_lsn       | 0/40004B0
write_lag        | 00:00:00.000867
flush_lag        | 00:00:00.001785
replay_lag       | 00:14:36.063253
sync_priority    | 0
sync_state       | async


```

The delay occurs once the database in recovery has reached a consistent state, until the standby is promoted or triggered. After that the standby will end recovery without further waiting.
恢复中的数据库达到一致状态后，将发生延迟，直到转换备库角色。之后，备用服务器将恢复所有延迟，无需进一步等待。
