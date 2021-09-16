# pg_waldump

**作者**

Chrisx

**日期**

2021-05-25

**内容**

把PG数据库集群的 wal 日志翻译成人为可阅读的信息,该工具要求访问数据库 data 目录权限,主要用于展示和debug的目的

ref [pg_waldump](https://www.postgresql.org/docs/13/pgwaldump.html)

ref [Reliability and the Write-Ahead Log](https://www.postgresql.org/docs/13/wal.html)

---

[toc]

## 资源管理名称

```sh
pg_waldump --rmgr=list
```

## wal内容

展示 STARTSEG 到 ENDSEG 的事务日志

```sh
pg_waldump 000000010000000000000001 000000010000000000000002
```

rmgr : 资源名称
lsn: 0/0162D3F0 日志编号
prev 0/0162D3B8
desc ： 对日志详细信息的描述
xid 事务id

执行insert、update、delete、checkpoint查看wal日志变化。


```sh
pg_waldump 00000001000000000000000C


rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0C025A38, prev 0/0C0259A0, desc: RUNNING_XACTS nextXid 516 latestCompletedXid 515 oldestRunningXid 516
rmgr: Heap        len (rec/tot):     92/    92, tx:        516, lsn: 0/0C025A70, prev 0/0C025A38, desc: INSERT off 2 flags 0x08, blkref #0: rel 1663/12674/24586 blk 0
rmgr: Transaction len (rec/tot):     46/    46, tx:        516, lsn: 0/0C025AD0, prev 0/0C025A70, desc: COMMIT 2021-05-25 17:29:04.654531 CST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0C025B00, prev 0/0C025AD0, desc: RUNNING_XACTS nextXid 517 latestCompletedXid 516 oldestRunningXid 517
rmgr: Heap2       len (rec/tot):     60/    60, tx:        517, lsn: 0/0C025B38, prev 0/0C025B00, desc: NEW_CID rel 1663/12674/1259; tid 0/10; cmin: 4294967295, cmax: 0, combo: 4294967295
rmgr: Heap2       len (rec/tot):     60/    60, tx:        517, lsn: 0/0C025B78, prev 0/0C025B38, desc: NEW_CID rel 1663/12674/1259; tid 0/11; cmin: 0, cmax: 4294967295, combo: 4294967295
rmgr: Heap        len (rec/tot):     79/    79, tx:        517, lsn: 0/0C025BB8, prev 0/0C025B78, desc: HOT_UPDATE off 10 xmax 517 flags 0x60 ; new off 11 xmax 0, blkref #0: rel 1663/12674/1259 blk 0
rmgr: Transaction len (rec/tot):     98/    98, tx:        517, lsn: 0/0C025C08, prev 0/0C025BB8, desc: COMMIT 2021-05-25 17:33:35.304486 CST; inval msgs: catcache 50 catcache 49 relcache 24586
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0C025C70, prev 0/0C025C08, desc: RUNNING_XACTS nextXid 518 latestCompletedXid 517 oldestRunningXid 518
rmgr: Heap        len (rec/tot):     54/    54, tx:        518, lsn: 0/0C025CA8, prev 0/0C025C70, desc: DELETE off 2 flags 0x00 KEYS_UPDATED , blkref #0: rel 1663/12674/24586 blk 0
rmgr: Transaction len (rec/tot):     46/    46, tx:        518, lsn: 0/0C025CE0, prev 0/0C025CA8, desc: COMMIT 2021-05-25 17:34:46.580178 CST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0C025D10, prev 0/0C025CE0, desc: RUNNING_XACTS nextXid 519 latestCompletedXid 518 oldestRunningXid 519
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0C025D48, prev 0/0C025D10, desc: RUNNING_XACTS nextXid 519 latestCompletedXid 518 oldestRunningXid 519
rmgr: XLOG        len (rec/tot):    114/   114, tx:          0, lsn: 0/0C025D80, prev 0/0C025D48, desc: CHECKPOINT_ONLINE redo 0/C025D48; tli 1; prev tli 1; fpw true; xid 0:519; oid 32772; multi 1; offset 0; oldest xid 480 in DB 1; oldest multi 1 in DB 1; oldest/newest commit timestamp xid: 0/0; oldest running xid 519; online
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0C025DF8, prev 0/0C025D80, desc: RUNNING_XACTS nextXid 519 latestCompletedXid 518 oldestRunningXid 519

```
