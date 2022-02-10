# patroni_and_etcd_installation

**作者**

Chrisx

**日期**

2021-09-03

**内容**

patroni+etcd+postgreql 集群搭建，可以实现一些集群功能，autofailover，switchover，配和haproxy实现单点介入等。其本质还是流复制。

ref [etcd](https://etcd.io/docs/latest)

ref [patroni](https://github.com/zalando/patroni)

----

[TOC]

## 环境配置

1. 关闭防火墙

```sh
systemctl stop SuSEfirewall2.service  #suse12
systemctl disable SuSEfirewall2.service #suse12

```

or

ref [firwall](./../os/firewall.md)

2. selinux 默认不开启

ref [selinux](./../os/selinux.md)

3. NetworkManager

```sh
systemctl stop NetworkManager
systemctl disable NetworkManager

#suse默认关闭，无需操作

```

4. 设置hostname

```shell
set-hostname NAME      Set system hostname

hostnamectl set-hostname t1
hostnamectl set-hostname t2
hostnamectl set-hostname t3

```

/etc/hosts

```shell
# cus
192.168.80.141  t1
192.168.80.142  t2
192.168.80.143  t3


```

## 数据库集群安装配置

（不需要配置集群。patroni自动配置集群）

:warning: 虽然Patroni支持自动化初始化PostgreSQL数据库并部署流复制，但这两块内容写到yml文件比较复杂，建议还是手工来做比较好。此外数据库配置参数也可以写到patroni的yml文件中，但参数会受patroni控制，不灵活，不建议。

数据库安装 ref [pg_installation](./../postgresql/pg_installation.md)
流复制集群配置 ref [Replication](./../postgresql/Replication.md)

使用pg用户安装（不能使用root用户）

```sh
# pg
export PGUSER=postgres
export PGDATABASE=postgres
export PGPORT=5433
export PGHOME=/opt/pg133
export PGDATA=$PGHOME/data
export MANPATH=$PGHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PATH:$PGHOME/bin

```

流复制正常

```sql
postgres=# select * from pg_stat_replication ;
-[ RECORD 1 ]----+------------------------------
pid              | 22073
usesysid         | 16384
usename          | repuser
application_name | p2
client_addr      | 192.168.80.142
client_hostname  |
client_port      | 44404
backend_start    | 2021-09-03 16:30:29.200136+08
backend_xmin     |
state            | streaming
sent_lsn         | 0/6000268
write_lsn        | 0/6000268
flush_lsn        | 0/6000268
replay_lsn       | 0/6000268
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 0
sync_state       | async
reply_time       | 2021-09-03 16:35:20.716193+08

```

## etcd集群安装配置

集群正常需要存活节点存活节点n/2+1（去掉小数位）

目前看etcd 6节点和5节点在仲裁上能力是一样的。

download [etcd](https://github.com/etcd-io/etcd)。安装 ref [etcd docs](https://etcd.io/docs/latest)

解压后可阅读README(README-etcdctl.md  README.md  READMEv2-etcdctl.md)

root用户安装即可，可安装etcd单节点也可以安装etcd集群。

### 安装Install pre-built binaries(安装预构建的二进制文件)

```shell
tar -xvf etcd-v3.5.0-linux-amd64.tar.gz
cd 
./etcd --version


```

### 运行测试Running etcd

```sh
nohup ./etcd &
This will bring up etcd listening on port 2379 for client communication and on port 2380 for server-to-server communication.

Next, let is set a single key, and then retrieve it:

./etcdctl put mykey "this is awesome"
./etcdctl get mykey
```

### 编写etcd配置文件

配置etcd集群 ref [Configuration flags](https://etcd.io/docs/v3.5/op-guide/configuration/)

一个可重用的配置文件是一个YaML文件，具有下面描述的一个或多个命令行标志的名称和对应值。使用了配置文件，其他命令行标识和环境变量将被忽略。

--my-flag参数对应的环境变量是ETCD_MY_FLAG。适用于所有的参数。

第一个节点 etcd.yml

```sh
# Member flags
#集群中成员的名字
name: etcd141
#etcd数据目录
data-dir: /opt/etcd-v3.5.0-linux-amd64/data
#心跳间隔时间，单位毫秒，默认100
heartbeat-interval: 250
#选举的超时时间，单位毫秒,默认1000
election-timeout: 5000
#要侦听对等通信的URL列表。接收来自对等方的传入请求
listen-peer-urls: http://192.168.80.141:2380
#要侦听客户端流量的URL列表。接收来自客户端的传入请求
listen-client-urls: http://192.168.80.141:2379,http://127.0.0.1:2379

# Clustering flags
#本机内部通信URL，用于向集群的其它成员广播，这些地址用于在集群中传输etcd数据
initial-advertise-peer-urls: http://192.168.80.141:2380
#用于引导的初始群集配置。
initial-cluster: etcd141=http://192.168.80.141:2380,etcd142=http://192.168.80.142:2380,etcd143=http://192.168.80.143:2380
#初始集群状态，new为新建集群,成员添加设置为existing
initial-cluster-state: new
#etcd 集群的初始化集群标记
initial-cluster-token: etcd-cluster
#本机客户端URL，用于向集群的其它成员广播
advertise-client-urls: http://192.168.80.141:2379
#开启etcdv2支持
enable-v2: true 

# Logging flags
#log-level: info
#logger: zap
#log-outputs: ./etcdlog



```

:warning: name不能是数字或数字开头

### etcd集群配置

静态启动etcd集群需要每个成员都知道集群中的另一个成员。

可以通过设置参数 initial-cluster 标识

第二三个节点配置类似，注意修改ip地址

以配置文件启动

```sh
nohup ./etcd --config-file ./etcd.yml > start_etcd.log 2>&1 &
```

验证etcd

```shell
./etcdctl --write-out=table member list
./etcdctl endpoint status -w table

[root@t2 etcd-v3.5.0-linux-amd64]# ./etcdctl --write-out=table member list
+------------------+---------+---------+----------------------------+----------------------------+------------+
|        ID        | STATUS  |  NAME   |         PEER ADDRS         |        CLIENT ADDRS        | IS LEARNER |
+------------------+---------+---------+----------------------------+----------------------------+------------+
|  2f477b081f877ca | started | etcd142 | http://192.168.80.142:2380 | http://192.168.80.142:2379 |      false |
| 1d9caaa96b82c2a1 | started | etcd141 | http://192.168.80.141:2380 | http://192.168.80.141:2379 |      false |
| e16a54f0b1466abc | started | etcd143 | http://192.168.80.143:2380 | http://192.168.80.143:2379 |      false |
+------------------+---------+---------+----------------------------+----------------------------+------------+


[root@t2 etcd-v3.5.0-linux-amd64]# ./etcdctl endpoint --cluster health
http://192.168.80.141:2379 is healthy: successfully committed proposal: took = 14.421752ms
http://192.168.80.142:2379 is healthy: successfully committed proposal: took = 14.966856ms
http://192.168.80.143:2379 is healthy: successfully committed proposal: took = 15.864007ms
[root@t2 etcd-v3.5.0-linux-amd64]#



[root@t2 etcd-v3.5.0-linux-amd64]# ./etcdctl -w table endpoint --cluster status
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://192.168.80.142:2379 |  2f477b081f877ca |   3.5.0 |   20 kB |     false |      false |         2 |         12 |                 12 |        |
| http://192.168.80.141:2379 | 1d9caaa96b82c2a1 |   3.5.0 |   20 kB |      true |      false |         2 |         12 |                 12 |        |
| http://192.168.80.143:2379 | e16a54f0b1466abc |   3.5.0 |   20 kB |     false |      false |         2 |         12 |                 12 |        |
+----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
[root@t2 etcd-v3.5.0-linux-amd64]#


```

<!--
t1:/opt/etcd # ./etcdctl --write-out=table member list
{"level":"warn","ts":"2021-08-18T14:15:03.674+0800","logger":"etcd-client","caller":"v3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0002dca80/#initially=[127.0.0.1:2379]","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = context deadline exceeded"}
Error: context deadline exceeded

t1:/opt/etcd # ./etcdctl -w table endpoint --cluster status
{"level":"warn","ts":"2021-08-18T16:00:18.954+0800","logger":"etcd-client","caller":"v3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0002dcc40/#initially=[127.0.0.1:2379]","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = context deadline exceeded"}
Error: failed to fetch endpoints from etcd cluster member list: context deadline exceeded

以上表示其他节点的etcd服务没有启动

curl http://192.168.80.141:2379/v2/keys/    #查看状态
ETCDCTL_API=2 ./etcdctl ls  #修改etcd内容

 /<namespace>/<scope>/config
-->

## patroni集群安装配置

在所有数据库节点安装

### 安装patroni

需要提前安装psycopg2（Patroni requires psycopg2>=2.5.4）or psycopg2-binary，建议使用psycopg2-binary，这样不需要从源码编译。

需要配置python和pip ref [pip](./pip.md)

pip网络安装 或 下载[patroni安装编译包](https://pypi.org/project/patroni/#files)本地安装

```sh
python3 -m pip install psycopg2-binary -i https://pypi.douban.com/simple --trusted-host pypi.douban.com  #网络安装
# python3 -m pip install /opt/software/patroni-2.1.1-py3-none-any.whl #本地压缩包安装
python3 -m pip install patroni[etcd] -i https://pypi.douban.com/simple --trusted-host pypi.douban.com #网络安装

```

<!--
[root@t2 Python-3.9.6]# python3 -m pip install /opt/software/patroni-2.1.1-py3-none-any.whl
Processing /opt/software/patroni-2.1.1-py3-none-any.whl
Collecting ydiff>=1.2.0
  Downloading ydiff-1.2.tar.gz (42 kB)
     |████████████████████████████████| 42 kB 248 kB/s
Collecting PyYAML
  Downloading PyYAML-5.4.1-cp39-cp39-manylinux1_x86_64.whl (630 kB)
     |████████████████████████████████| 630 kB 31 kB/s
Collecting prettytable>=0.7
  Downloading prettytable-2.2.0-py3-none-any.whl (23 kB)
Collecting python-dateutil
  Downloading python_dateutil-2.8.2-py2.py3-none-any.whl (247 kB)
     |████████████████████████████████| 247 kB 42 kB/s
Collecting six>=1.7
  Downloading six-1.16.0-py2.py3-none-any.whl (11 kB)
Collecting click>=4.1
  Downloading click-8.0.1-py3-none-any.whl (97 kB)
     |████████████████████████████████| 97 kB 41 kB/s
Collecting psutil>=2.0.0
  Downloading psutil-5.8.0-cp39-cp39-manylinux2010_x86_64.whl (293 kB)
     |████████████████████████████████| 293 kB 34 kB/s
Collecting urllib3!=1.21,>=1.19.1
  Downloading urllib3-1.26.6-py2.py3-none-any.whl (138 kB)
     |████████████████████████████████| 138 kB 23 kB/s
Collecting wcwidth
  Downloading wcwidth-0.2.5-py2.py3-none-any.whl (30 kB)
Using legacy 'setup.py install' for ydiff, since package 'wheel' is not installed.
Installing collected packages: wcwidth, six, ydiff, urllib3, PyYAML, python-dateutil, psutil, prettytable, click, patroni
    Running setup.py install for ydiff ... done
Successfully installed PyYAML-5.4.1 click-8.0.1 patroni-2.1.1 prettytable-2.2.0 psutil-5.8.0 python-dateutil-2.8.2 six-1.16.0 urllib3-1.26.6 wcwidth-0.2.5 ydiff-1.2
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
[root@t2 Python-3.9.6]#

-->

查看版本号

```sh
# patroni --version
patroni 2.1.1

```

### 编写patroni配置文件YAML Configuration

提前创建需要的路径

```sh
mkdir /opt/patroni_data #创建namespace
mkdir /opt/archive    #归档路径
```

* ref [YAML Configuration Settings](https://github.com/zalando/patroni/blob/master/docs/SETTINGS.rst)
* ref [postgres0.yml](https://github.com/zalando/patroni/blob/master/postgres0.yml)

以下为总结的模板，供参考

```sh
cat pg1.yml

```

```yml
#Global/Universal
#cluster名称
scope: clusterp
#命名空间目录（一级目录名/<namespace>/<scope>/config）
namespace: nsp
#节点名称
name: p1

#log
log:  
  level: INFO
  dir: /opt/patroni_data
  file_num: 4
  file_size: 25000000

#bootstrap:
  dcs:
    ttl: 30 #
    loop_wait: 10
    retry_timeouts: 10
    maximum_lag_on_failover: 33554432
    max_timelines_history: 0
    check_timeline: true
#patroni进程每隔10秒(loop_wait)都会更新Leader key和TTL，如果Leader节点异常patroni进程无法及时更新Leader key，则会重新进行10s尝试retry_timeout）。直到时间超过30s（ttl）会触发新的leader选举，选取wal_position lsn最新的为新leader，如果wal_position一直，则进行争抢，谁先创建了leader key，谁就是新leader
    postgresql:
      use_slots: true
      use_pg_rewind: true
#etcd
etcd:
  hosts: 192.168.80.141:2379,192.168.80.142:2379,192.168.80.143:2379

#REST API
restapi:
  connect_address: 192.168.80.141:8008
  listen: 0.0.0.0:8008

#proxy:
#  weight: 1
#  streaming_replication_delay_time: 5000

postgresql:
  database: postgres
  bin_dir: /opt/pg133/bin
  data_dir: /opt/pg133/data
  connect_address:  192.168.80.141:5433
  listen: 0.0.0.0:5433
  authentication:
    superuser:
      username: postgres
      password: postgres
    replication:
      password: repuser
      username: repuser
    rewind:
      password: repuser
      username: repuser
  parameters:
    #支持优化参数配置

#watchdog:
#  mode: off # off | automatic | required
#  driver: 'default'
#  safety_margin: 5

```

:warning1: 其他节点参考配置，如需要使用patroni自动初始化数据库和配置集群，请参考
:warning2: 次用例中只是配置了数据库的连接信息，用于patroni管理db，没有配置参数，参数均由数据库自己管理。

### patroni集群配置

普通用户pg，启动patroni集群

```sh
$ nohup patroni pg1.yml &
$ nohup patroni pg2.yml &

```

查看状态

```sh
patronictl -c /opt/patroni_data/pg1.yml list

[pg@t1 patroni_data]$ patronictl -c pg1.yml list
+--------+---------------------+---------+---------+----+-----------+-----------------+
| Member | Host                | Role    | State   | TL | Lag in MB | Pending restart |
+ Cluster: clusterp (7003596923147038756) ---------+----+-----------+-----------------+
| p1     | 192.168.80.141:5433 | Leader  | running |  3 |           | *               |
| p2     | 192.168.80.142:5433 | Replica | running |  3 |         0 | *               |
+--------+---------------------+---------+---------+----+-----------+-----------------+
[pg@t1 patroni_data]$


```

patroni 启动报错

```sh
[root@t1 patroni_data]# patroni pg1.yml
Traceback (most recent call last):
  File "/opt/python/bin/patroni", line 8, in <module>
    sys.exit(main())
  File "/opt/python/lib/python3.9/site-packages/patroni/__init__.py", line 171, in main
    return patroni_main()
  File "/opt/python/lib/python3.9/site-packages/patroni/__init__.py", line 139, in patroni_main
    abstract_main(Patroni, schema)
  File "/opt/python/lib/python3.9/site-packages/patroni/daemon.py", line 98, in abstract_main
    controller = cls(config)
  File "/opt/python/lib/python3.9/site-packages/patroni/__init__.py", line 29, in __init__
    self.dcs = get_dcs(self.config)
  File "/opt/python/lib/python3.9/site-packages/patroni/dcs/__init__.py", line 110, in get_dcs
    raise PatroniFatalException("""Can not find suitable configuration of distributed configuration store
patroni.exceptions.PatroniFatalException: 'Can not find suitable configuration of distributed configuration store\nAvailable implementations: kubernetes'

```

解决方案

```sh
[root@t1 patroni_data]# python3 -m pip install patroni[etcd] -i https://pypi.douban.com/simple --trusted-host pypi.douban.com
Looking in indexes: https://pypi.douban.com/simple
Requirement already satisfied: patroni[etcd] in /opt/python/lib/python3.9/site-packages (2.1.1)
Requirement already satisfied: ydiff>=1.2.0 in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (1.2)
Requirement already satisfied: urllib3!=1.21,>=1.19.1 in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (1.26.6)
Requirement already satisfied: prettytable>=0.7 in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (2.2.0)
Requirement already satisfied: click>=4.1 in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (8.0.1)
Requirement already satisfied: six>=1.7 in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (1.16.0)
Requirement already satisfied: psutil>=2.0.0 in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (5.8.0)
Requirement already satisfied: PyYAML in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (5.4.1)
Requirement already satisfied: python-dateutil in /opt/python/lib/python3.9/site-packages (from patroni[etcd]) (2.8.2)
Collecting python-etcd<0.5,>=0.4.3
  Downloading https://pypi.doubanio.com/packages/a1/da/616a4d073642da5dd432e5289b7c1cb0963cc5dde23d1ecb8d726821ab41/python-etcd-0.4.5.tar.gz (37 kB)
Requirement already satisfied: wcwidth in /opt/python/lib/python3.9/site-packages (from prettytable>=0.7->patroni[etcd]) (0.2.5)
Collecting dnspython>=1.13.0
  Downloading https://pypi.doubanio.com/packages/f5/2d/ae9e172b4e5e72fa4b3cfc2517f38b602cc9ba31355f9669c502b4e9c458/dnspython-2.1.0-py3-none-any.whl (241 kB)
     |████████████████████████████████| 241 kB 3.6 MB/s
Building wheels for collected packages: python-etcd
  Building wheel for python-etcd (setup.py) ... done
  Created wheel for python-etcd: filename=python_etcd-0.4.5-py3-none-any.whl size=38500 sha256=ed298b8d00ffb58048f1e0a25a86a31ff761a9319802daf22396cd7f254a39b2
  Stored in directory: /root/.cache/pip/wheels/fa/eb/c8/f59f4849b9210e89561978fe7df6f189fdd82104a1506e80ea
Successfully built python-etcd
Installing collected packages: dnspython, python-etcd
Successfully installed dnspython-2.1.0 python-etcd-0.4.5 《《《《《《《《《《《《《《
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
WARNING: You are using pip version 21.1.3; however, version 21.2.4 is available.
You should consider upgrading via the '/opt/python/bin/python3 -m pip install --upgrade pip' command.
[root@t1 patroni_data]#

```

<!--
主节点日志
2021-09-03 17:13:43,963 INFO: no action. I am (p1) the leader with the lock
2021-09-03 17:13:53,956 INFO: no action. I am (p1) the leader with the lock
2021-09-03 17:14:03,978 INFO: no action. I am (p1) the leader with the lock
2021-09-03 17:14:13,967 INFO: no action. I am (p1) the leader with the lock
2021-09-03 17:14:23,985 INFO: no action. I am (p1) the leader with the lock

默认每10s检查一次

备节点日志
2021-09-03 17:14:45,084 INFO: no action. I am a secondary (p2) and following a leader (p1)
2021-09-03 17:14:55,079 INFO: no action. I am a secondary (p2) and following a leader (p1)
2021-09-03 17:15:05,112 INFO: no action. I am a secondary (p2) and following a leader (p1)
2021-09-03 17:15:15,083 INFO: no action. I am a secondary (p2) and following a leader (p1)

默认每10s检查一次
-->

## haproxy

ref [haproxy](./haproxy.md)

## 问题

etcd和patroni需要做成服务，以备服务器重启后能自动启动。
