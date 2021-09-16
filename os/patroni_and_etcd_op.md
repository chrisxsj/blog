
# patroni_and_etcd_op

**作者**

Chrisx

**日期**

2021-09-03

**内容**

patroni+etcd+postgreql 集群运维操作

----

[TOC]

## 介绍

高可用集群由 数据库，patroni，etcd存储组成。 etcd（dcs） 存储集群来存储信息、主备状态与配置,通过 patroni 来检测并且实现主备库自动切换。可通过套模板化的配置文件来自动搭建初始化数据库流复制集群，以及配置数据库。

高可用集群通过etcd中的信息进行更新、读取来判断集群的健康状态。在主备切换或者做恢复时通过向etcd存储读取主备信息来判断各节点的状态进行切换.

<!--
$PGDATA/patroni.dynamic.json #dcs信息
-->

## 切换

### 1. switchover 手动提升主库

切换命令

```sh
patronictl -c /opt/patroni_data/pg1.yml switchover

```

操作

```sh

[pg@t1 ~]$ patronictl -c /opt/patroni_data/pg1.yml switchover
Master [p1]:
Candidate ['p2'] []:
When should the switchover take place (e.g. 2021-09-03T18:26 )  [now]:
Current cluster topology
+--------+---------------------+---------+---------+----+-----------+-----------------+
| Member | Host                | Role    | State   | TL | Lag in MB | Pending restart |
+ Cluster: clusterp (7003596923147038756) ---------+----+-----------+-----------------+
| p1     | 192.168.80.141:5433 | Leader  | running |  4 |           | *               |
| p2     | 192.168.80.142:5433 | Replica | running |  4 |         0 | *               |
+--------+---------------------+---------+---------+----+-----------+-----------------+
Are you sure you want to switchover cluster clusterp, demoting current master p1? [y/N]: y
2021-09-03 17:26:54.07076 Successfully switched over to "p2"
+--------+---------------------+---------+---------+----+-----------+-----------------+
| Member | Host                | Role    | State   | TL | Lag in MB | Pending restart |
+ Cluster: clusterp (7003596923147038756) ---------+----+-----------+-----------------+
| p1     | 192.168.80.141:5433 | Replica | stopped |    |   unknown | *               |
| p2     | 192.168.80.142:5433 | Leader  | running |  4 |           | *               |
+--------+---------------------+---------+---------+----+-----------+-----------------+
[pg@t1 ~]$


[pg@t1 ~]$ patronictl -c /opt/patroni_data/pg1.yml list
+--------+---------------------+---------+---------+----+-----------+-----------------+
| Member | Host                | Role    | State   | TL | Lag in MB | Pending restart |
+ Cluster: clusterp (7003596923147038756) ---------+----+-----------+-----------------+
| p1     | 192.168.80.141:5433 | Replica | running |  5 |         0 | *               |
| p2     | 192.168.80.142:5433 | Leader  | running |  5 |           | *               |
+--------+---------------------+---------+---------+----+-----------+-----------------+
[pg@t1 ~]$

```

### 2. autofailover 自动切换

patroni可实现autofailover，当主库出现故障时，会自动选取一个最健康的备机将其提升为主机，如果再次启动主库，他会自动做pg_rewind的相关操作，将自己作为备机跟随新主库。

操作

1. 关闭主节点服务器
2. 自动切换，备节点切换为leader

```sh
[pg@t1 ~]$ patronictl -c /opt/patroni_data/pg1.yml list
2021-09-03 17:40:06,688 - ERROR - Request to server http://192.168.80.142:2379 failed: MaxRetryError("HTTPConnectionPool(host='192.168.80.142', port=2379): Max retries exceeded with url: /v2/keys/nsp/clusterp/?recursive=true (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f51c16b1910>: Failed to establish a new connection: [Errno 111] Connection refused'))")
+--------+---------------------+--------+---------+----+-----------+-----------------+
| Member | Host                | Role   | State   | TL | Lag in MB | Pending restart |
+ Cluster: clusterp (7003596923147038756) --------+----+-----------+-----------------+
| p1     | 192.168.80.141:5433 | Leader | running |  6 |           | *               |
+--------+---------------------+--------+---------+----+-----------+-----------------+
[pg@t1 ~]$

```

日志

```sh
2021-09-03 17:37:05,716 INFO: no action. I am a secondary (p1) and following a leader (p2)
2021-09-03 17:37:15,727 INFO: no action. I am a secondary (p1) and following a leader (p2)
2021-09-03 17:37:18,574 WARNING: Request failed to p2: GET http://192.168.80.142:8008/patroni (HTTPConnectionPool(host='192.168.80.142', port=8008): Max retries exceeded with url: /patroni (Caused by ProtocolError('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))))
2021-09-03 17:37:18,578 WARNING: Could not activate Linux watchdog device: "Can't open watchdog device: [Errno 2] No such file or directory: '/dev/watchdog'"
2021-09-03 17:37:18,580 INFO: promoted self to leader by acquiring session lock
2021-09-03 17:37:18,582 INFO: cleared rewind state after becoming the leader
2021-09-03 17:37:19,613 INFO: no action. I am (p1) the leader with the lock
2021-09-03 17:37:19,625 INFO: no action. I am (p1) the leader with the lock
2021-09-03 17:37:29,646 INFO: no action. I am (p1) the leader with the lock

```

可以看到检测很快，3s就切换了节点。

:warning: patroni会自动拉起宕机的数据库，因此停止数据库无法模拟autofailover

## 连接配置

连接串

主库：haproxy服务器ip:pgReadWrite端口/数据库名
备库：haproxy服务器ip:pgReadOnly端口/数据库名,haproxy服务器ip:pgReadOnly端口/数据库名

## 节点增加与删除

ref [patroni_and_etcd_installation](./patroni_and_etcd_installation.md)

增加节点

1. 新结点配置好流复制备库
2. 新节点安装配置patroni
3. 新结点安装配置etcd
4. 新结点配置集群yml配置文件

删除节点

1. 停止节点patroni
2. 停止节点etcd
3. 删除流复制备库