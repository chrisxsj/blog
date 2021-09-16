# ERROR: deadlock detected

## 现象

14:07:24,000 [Thread-2] ERROR  jTPCCTData : Unexpected SQLException in NEW_ORDER
        at jTPCCTData.execute(jTPCCTData.java:95)
        at jTPCCTerminal.executeTransactions(jTPCCTerminal.java:261)
        at jTPCCTerminal.run(jTPCCTerminal.java:88)
        at java.base/java.lang.Thread.run(Thread.java:834)
14:07:24,000 [Thread-2] ERROR  jTPCCTData : ERROR: deadlock detected
  Detail: Process 12830 waits for ExclusiveLock on relation 30448 of database 30439; blocked by process 12836.
Process 12836 waits for ExclusiveLock on relation 30448 of database 30439; blocked by process 12830.
  Hint: See server log for query details.
org.postgresql.util.PSQLException: ERROR: deadlock detected
  Detail: Process 12830 waits for ExclusiveLock on relation 30448 of database 30439; blocked by process 12836.
Process 12836 waits for ExclusiveLock on relation 30448 of database 30439; blocked by process 12830.
  Hint: See server log for query details.
        at org.postgresql.core.v3.QueryExecutorImpl.receiveErrorResponse(QueryExecutorImpl.java:2468)
        at org.postgresql.core.v3.QueryExecutorImpl.processResults(QueryExecutorImpl.java:2211)
        at org.postgresql.core.v3.QueryExecutorImpl.execute(QueryExecutorImpl.java:309)
        at org.postgresql.jdbc.PgStatement.executeInternal(PgStatement.java:446)
        at org.postgresql.jdbc.PgStatement.execute(PgStatement.java:370)
        at org.postgresql.jdbc.PgPreparedStatement.executeWithFlags(PgPreparedStatement.java:149)
        at org.postgresql.jdbc.PgPreparedStatement.executeQuery(PgPreparedStatement.java:108)
        at jTPCCTData.executeNewOrder(jTPCCTData.java:362)
        at jTPCCTData.execute(jTPCCTData.java:95)
        at jTPCCTerminal.executeTransactions(jTPCCTerminal.java:261)
        at jTPCCTerminal.run(jTPCCTerminal.java:88)
        at java.base/java.lang.Thread.run(Thread.java:834)14:07:24,000 [Thread-1] ERROR  jTPCCTData : Unexpected SQLException in NEW_ORDER

可手动同步时间

主库
systemctl start ntpd
备库
systemctl stop ntpd
nptdate 192.168.1.1

后期开启ntpd自动同步

[hgadmin@node1 ~]$ gpssh -f  /home/hgadmin/hostfile_all -e 'date'
[node3] date
[node3] Mon Sep 21 14:16:04 CST 2020
[node1] date
[node1] Mon Sep 21 14:16:04 CST 2020
[node6] date
[node6] Mon Sep 21 14:16:04 CST 2020
[node5] date
[node5] Mon Sep 21 14:16:04 CST 2020
[node2] date
[node2] Mon Sep 21 14:16:05 CST 2020
[node4] date
[node4] Mon Sep 21 14:16:05 CST 2020
[hgadmin@node1 ~]$

问题分析：
全局死锁检测开关在Greenplum 6中其默认关闭，需要打开它才可以支持并发更新/删除操作；gpconfig -c gp_enable_global_deadlock_detector -v on
同时个服务器时间需一致

问题处理：
执行命令打开全局死锁检测开关，保存依然存在。参数未起作用。尝试重启等操作均无效。最后将HGDW软件替换为greenplum软件，拉起数据库后问题解决。死锁错误未再出现，参数生效。
建议使用gp最新版本。
