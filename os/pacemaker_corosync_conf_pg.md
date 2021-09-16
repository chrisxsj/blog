# pacemaker corosync conf pg

**作者**

chrisx

**日期**

2021-04-02

**内容**

pacemaker+corosync+pcs+postgresql

---

[toc]

## install PostgresQL

ref [pg_installation](../postgresql/pg_installation.md)

## 配置PG stream

ref [High Availability Load Balancing and Replication](../postgresql/High%20Availability%20Load%20Balancing%20and%20Replication.md)

## 安装pacemaker和corosync

ref [pacemaker and corosync installation](../postgresql/../os/pacemaker_and_corosync_installation.md)

## 创建集群资源

检查配置

```shell
# pcs status   #查看现有集群状态
# pcs config   #查看现有集群配置
# pcs cluster cib #查看CIB
# crm_verify -L -V   #测试环境需要禁用STONITH

```

添加资源

1. 创建第一个资源，浮动IP地址。每30s检查是否运行

```shell
pcs resource create ClusterIP ocf:heartbeat:IPaddr2 ip=192.168.122.120 cidr_netmask=32 op monitor interval=30s
ocf:heartbeat:IPaddr2

```

2. 创建数据库资源

将以下pcs创建资源的命令写入脚本 cluster.sh

:warning: 注意：先关闭两节点的pg

```shell
#########BEGIN###########################
# 将cib配置保存到文件
pcs cluster cib pgsql_cfg                                                                   
# 在pacemaker级别忽略quorum
pcs -f pgsql_cfg property set no-quorum-policy="ignore"        
# 禁用STONITH           
pcs -f pgsql_cfg property set stonith-enabled="false"                    
# 设置资源粘性，防止节点在故障恢复后发生迁移     
pcs -f pgsql_cfg resource defaults resource-stickiness="INFINITY"       
# 设置多少次失败后迁移
pcs -f pgsql_cfg resource defaults migration-threshold="3"                 
# 设置master节点虚ip     
pcs -f pgsql_cfg resource create vip-master ocf:heartbeat:IPaddr2 ip="192.168.6.151" cidr_netmask="24" \
op start  timeout="60s" interval="0s"  on-fail="restart"    \
op monitor timeout="60s" interval="10s" on-fail="restart"    \
op stop    timeout="60s" interval="0s"  on-fail="block" 
                   
# 设置slave节点虚ip                       
pcs -f pgsql_cfg resource create vip-slave ocf:heartbeat:IPaddr2 ip="192.168.6.152" cidr_netmask="24" \
op start   timeout="60s" interval="0s"  on-fail="restart"    \
op monitor timeout="60s" interval="10s" on-fail="restart"    \
op stop    timeout="60s" interval="0s"  on-fail="block" 
                                                   
# 设置pgsql集群资源
# pgctl、psql、pgdata和config等配置根据自己的环境修改,node list填写节点的hostname，master_ip填写虚master_ip
pcs resource create pgsql ocf:heartbeat:pgsql \
pgctl="/opt/pg106/bin/pg_ctl" \
psql="/opt/pg106/bin/psql" \
pgdata="/opt/pg106/data/" \
config="/opt/pg106/data/postgresql.conf" \
pgdba="pg106" \
pgport="5970" \
rep_mode="async" node_list="db db2" master_ip="192.168.6.151"  \
repuser="repuser" \
primary_conninfo_opt="password=repuser \
keepalives_idle=60 keepalives_interval=5 keepalives_count=5" \
restart_on_promote='true' \
op start   timeout="60s" interval="0s"  on-fail="restart" \
op monitor timeout="60s" interval="4s" on-fail="restart" \
op monitor timeout="60s" interval="3s" on-fail="restart" role="Master" \
op promote timeout="60s" interval="0s"  on-fail="restart" \
op demote  timeout="60s" interval="0s"  on-fail="stop" \
op stop    timeout="60s" interval="0s"  on-fail="block"  

# 设置master/slave模式，clone-max=2，两个节点
pcs -f pgsql_cfg resource master pgsql-cluster pgsql master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true                                                                       
# 配置master ip组
pcs -f pgsql_cfg resource group add master-group vip-master        
# 配置slave ip组     
pcs -f pgsql_cfg resource group add slave-group vip-slave                 
# 配置master ip组绑定master节点
pcs -f pgsql_cfg constraint colocation add master-group with Master pgsql-cluster INFINITY    
# 配置启动master节点
pcs -f pgsql_cfg constraint order promote pgsql-cluster then start master-group symmetrical=false score=INFINITY                                 
# 配置停止master节点                                                                   
pcs -f pgsql_cfg constraint order demote  pgsql-cluster then stop  master-group symmetrical=false score=0                                                                                                                
# 配置slave ip组绑定slave节点
pcs -f pgsql_cfg constraint colocation add slave-group with Slave pgsql-cluster INFINITY         
# 配置启动slave节点
pcs -f pgsql_cfg constraint order promote pgsql-cluster then start slave-group symmetrical=false score=INFINITY                               
# 配置停止slave节点                                                                         
pcs -f pgsql_cfg constraint order demote  pgsql-cluster then stop  slave-group symmetrical=false score=0                                                                                                                  
# 把配置文件push到cib
pcs cluster cib-push pgsql_cfg
################END###########################

```

执行脚本

```shell
[root@pgha1 software]# sh cluster.sh
Warning: Defaults do not apply to resources which override them with their own defined values
Warning: Defaults do not apply to resources which override them with their own defined values
Assumed agent name 'ocf:heartbeat:IPaddr2' (deduced from 'IPaddr2')
Assumed agent name 'ocf:heartbeat:IPaddr2' (deduced from 'IPaddr2')
Assumed agent name 'ocf:heartbeat:pgsql' (deduced from 'pgsql')
Adding msPostgresql master-group (score: INFINITY) (Options: first-action=promote then-action=start symmetrical=false)
Adding msPostgresql master-group (score: 0) (Options: first-action=demote then-action=stop symmetrical=false)
CIB updated
[root@pgha1 software]#

```

查看资源状态

```shell
[root@db heartbeat]# pcs status
Cluster name: mycluster
Stack: corosync
Current DC: db2 (version 1.1.21-4.el7-f14e36fd43) - partition with quorum
Last updated: Tue Apr  6 20:07:53 2021
Last change: Tue Apr  6 20:07:47 2021 by hacluster via crmd on db

2 nodes configured
5 resources configured

Online: [ db db2 ]

Full list of resources:

 ClusterIP      (ocf::heartbeat:IPaddr2):       Started db
 Master/Slave Set: pgsql-cluster [pgsql]
     Masters: [ db ]
     Slaves: [ db2 ]
 Resource Group: master-group
     vip-master (ocf::heartbeat:IPaddr2):       Started db
 Resource Group: slave-group
     vip-slave  (ocf::heartbeat:IPaddr2):       Started db2

Daemon Status:
  corosync: active/enabled
  pacemaker: active/enabled
  pcsd: active/enabled
[root@db heartbeat]#


```

常用命令

```shell
#修改资源
pcs resource update pgsql master_ip="192.168.80.105"
pcs resource update pgsql restore_command="cp /arch/%f %p"
pcs resource update pgsql restore_command=""
pcs resource update vip-master ip=192.168.80.105
#删除资源
pcs resource delete master-group
pcs resource delete slave-group
pcs resource delete msPostgresql
#强制重启
pcs cluster stop --force
#查看配置、property、资源信息
crm_mon -Afr -1
pcs config
pcs property list
pcs constraint
pcs resource show
pcs resource show pgsql
pcs resource defaults
pcs resource cleanup xx #xx表示虚拟资源名称，当集群有资源处于unmanaged的状态时，可以用这个命令清理掉失败的信息，然后重置资源状态
pcs resource describe pgsql #Resource script for PostgreSQL. It manages a PostgreSQL as an HA resource.
```

## test

1 kill master postgres主进程  --？
2 关闭master服务器  --正常切换
3 阻断master和slave心跳网络 --？
4 ？

## 遇到的问题

问题
1 cluster start faild
Failed Actions:
* pgsql_start_0 on pgha2 'unknown error' (1): call=15, status=complete, exitreason='My data may be inconsistent. You have to remove /var/lib/pgsql/tmp/PGSQL.lock file to force start.',
    last-rc-change='Sun Aug 26 11:50:56 2018', queued=0ms, exec=333ms

针对没启动的那个节点，删除文件/var/lib/pgsql/tmp/PGSQL.lock，然后清理资源

[root@db2 ~]# rm /var/lib/pgsql/tmp/PGSQL.lock
rm: remove regular empty file ‘/var/lib/pgsql/tmp/PGSQL.lock’? y
[root@db2 ~]# pcs resource cleanup
Cleaned up all resources on all nodes
Waiting for 1 reply from the CRMd. OK
[root@db2 ~]#


## PGbench 压力测试

```shell
[postgres@pgha2 data]$ pgbench -h 192.168.80.105 -p 5432 postgres -r -j2 -c190 -T1800 -l /home/postgres/pgbench --progress-timestamp
Password:
starting vacuum...end.
connection to database "postgres" failed:
FATAL:  sorry, too many clients already
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 190
number of threads: 2
duration: 1800 s
number of transactions actually processed: 371888
latency average = 920.194 ms
tps = 206.478220 (including connections establishing)
tps = 206.479010 (excluding connections establishing)
script statistics:
- statement latencies in milliseconds:
         0.020  \set aid random(1, 100000 * :scale)
         0.001  \set bid random(1, 1 * :scale)
         0.001  \set tid random(1, 10 * :scale)
         0.001  \set delta random(-5000, 5000)
         2.035  BEGIN;
         1.743  UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;
         3.106  SELECT abalance FROM pgbench_accounts WHERE aid = :aid;
       405.172  UPDATE pgbench_tellers SET tbalance = tbalance + :delta WHERE tid = :tid;
        43.586  UPDATE pgbench_branches SET bbalance = bbalance + :delta WHERE bid = :bid;
         1.022  INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, :delta, CURRENT_TIMESTAMP);
         2.938  END;
[postgres@pgha2 data]$
20180828 14:40  no ha cluster!!!!!!!!!!!
pgbench -h 192.168.80.101 -p 5432 postgres -r -j2 -c190 -T1800 -l /home/postgres/pgbench --progress-timestamp  
 
[postgres@pgha2 data]$ pgbench -h 192.168.80.101 -p 5432 postgres -r -j2 -c190 -T1800 -l /home/postgres/pgbench --progress-timestamp
Password:
starting vacuum...end.
connection to database "postgres" failed:
FATAL:  sorry, too many clients already
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 190
number of threads: 2
duration: 1800 s
number of transactions actually processed: 398220
latency average = 859.306 ms
tps = 221.108720 (including connections establishing)
tps = 221.109408 (excluding connections establishing)
script statistics:
- statement latencies in milliseconds:
         0.022  \set aid random(1, 100000 * :scale)
         0.001  \set bid random(1, 1 * :scale)
         0.001  \set tid random(1, 10 * :scale)
         0.001  \set delta random(-5000, 5000)
         2.130  BEGIN;
         1.992  UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;
         4.566  SELECT abalance FROM pgbench_accounts WHERE aid = :aid;
       376.045  UPDATE pgbench_tellers SET tbalance = tbalance + :delta WHERE tid = :tid;
        40.908  UPDATE pgbench_branches SET bbalance = bbalance + :delta WHERE bid = :bid;
         0.934  INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, :delta, CURRENT_TIMESTAMP);
         2.685  END;
[postgres@pgha2 data]$

```
