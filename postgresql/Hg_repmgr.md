
# Hg_repmgr

**作者**

chrisx

**日期**

2021-05-20

**内容**

hg repmgr配置和使用

reference [HG数据库集群高可用部署维护使用手册(repmgr版)V6.2](./)

reference [瀚高数据库企业版V5-hg_repmgr最佳实践](./)

----

[toc]

## 思考

* 为什么要使用集群？
* hg_repmgr有哪些改进？
  
## 前提工作

hg_repmgr支持linux操作系统。推荐使用centos/redhat7.0及以上版本

## 禁用selinux

ref [selinux](../os/selinux.md)

## 开放数据库端口

需要在各个节点之间开放数据库端口（5866）。

ref [firewall](../os/firewall.md)

## 配置各节点主机名

/etc/hosts

## 配置sudoers

ref [sudoers](../os/sudoers.md)

<!--注释
配置时间同步  
配置三个节点的时间同步，建议配置 NTP 时间服务器。（详细步骤略） 
 
设置互信  
在所有节点间设置 highgo 用户互信。 
安装rpm包
rpm -q make gcc gzip readline readline-devel zlib zlib-devel
yum install make gcc gzip readline* zlib*
-->

## 安装HighGo Database企业版集群数据库

在各个节点执行如下命令安装HGDB集群版数据库

```sh
rpm -i hgdb5.6.5-xxxxxx.rpm
eg:
# rpm -ivh hgdb5.6.5-cluster-rhel7.x-x86-64-20190815.rpm 
Preparing...                          ################################# [100%]
Updating / installing...
   1:hgdb-cluster-5.6.5-1.el7         ################################# [100%]
/opt/HighGo5.6.5-cluster/bin/initdb: error while loading shared libraries: libpq.so.5: cannot open shared object file: No such file or directory
Note: Forwarding request to 'systemctl enable hgdb-se5.6.5.service'.
```

注意：提示无法initdb，稍后需手动initdb。此处只安装了软件。

## 创建用户

企业版会自动创建highgo用户，并安装

## 环境变量

环境变量会自动添加到配置文件。highgo用户下的~/.bash_profile

```sh
[highgo@hgdbt2 ~]$ cat .bash_profile |grep -v '#'
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
 
PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH
export HG_BASE=/opt/HighGo5.6.5-cluster
export PGHOME=/opt/HighGo5.6.5-cluster
export HGDB_HOME=/opt/HighGo5.6.5-cluster
export PGDATA=/opt/HighGo5.6.5-cluster/data
export LD_LIBRARY_PATH=/opt/HighGo5.6.5-cluster/lib:$LD_LIBRARY_PATH
export PATH=$PATH:/opt/HighGo5.6.5-cluster/bin
```

## 检查自启动服务

集群各节点的自启动是由systemd来控制的，在安装完集群后，需要检查确认hgdb5.6.5-x.service服务是否已经enable。

```sh
$ systemctl status hgdb5.6.5-x.service
hgdb5.6.5-x.service - hgdb5.6.5-x
Loaded: loaded (/usr/lib/systemd/system/hgdb5.6.5-x.service; enabled; vendor preset: disabled)
```

若服务并没有被enable, 需要root用户执行
systemctl enable hgdb5.6.5-x.service
(若执行失败，请检查/usr/lib/systemd/system/hgdb5.6.5-x.service文件是否存在，若不存在须把/opt/HighGo5.6.5-X/etc/hgdb5.6.5-x.service 拷贝至/usr/lib/systemd/system/目录并执行 systemctl daemon-reload, 然后执行systemctl enable hgdb5.6.5-x.service)

## 集群部署

### 主节点node1部署

配置node1的hg_repmgr配置文件（/opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf）

```sh
Highgo用户
/*repmgr基本信息设置*/
node_id=1   //节点ID
node_name='node1'   //节点名称，配置和主机名一致
conninfo='host=node1 user=sysdba dbname=highgo port=5866 connect_timeout=2'
//repmgr或repmgrd命令连接数据库的连接串
data_directory='/opt/HighGo5.6.5-X/data'
/*repmgr日志设置*/
log_level=INFO   
log_facility=STDERR        
log_file='/opt/HighGo5.6.5-X/repmgr.log'
pg_bindir='/opt/HighGo5.6.5-X/bin' 
/*集群failover设置*/
failover=automatic
promote_command='repmgr standby promote -f 
/opt/HighGo5.6.5-X/conf/hg_repmgr.conf --log-to-file'
follow_command='repmgr standby follow -f 
/opt/HighGo5.6.5-X/conf/hg_repmgr.conf --log-to-file'
/*虚拟ip设置*/
virtual_ip = '192.168.90.96'        //配置虚拟ip
network_card = 'ens33'      //配置虚拟ip绑定的网卡
/* 配置repmgr daemon stop/start 调用命令 */
repmgrd_service_stop_command=pkill -F /tmp/repmgrd.pid
repmgrd_service_start_command=repmgrd -d
```

eg:

```
$ cat /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf |grep -v '#' |grep -v ^$
node_id=1
node_name='hgdbt1'
conninfo='host=hgdbt1 user=highgo dbname=highgo port=5866 connect_timeout=5'
data_directory='/opt/HighGo5.6.5-cluster/data'
log_level=INFO   
log_facility=STDERR        
log_file='/opt/HighGo5.6.5-cluster/repmgr.log'
pg_bindir='/opt/HighGo5.6.5-cluster/bin' 
failover=automatic
promote_command='repmgr standby promote -f /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf --log-to-file'
follow_command='repmgr standby follow -f /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf --log-to-file'
virtual_ip = '192.168.6.9'
network_card = 'enp0s3'
repmgrd_service_stop_command=pkill -F /tmp/repmgrd.pid
repmgrd_service_start_command=repmgrd -d
```

### 初始化数据库

执行以下命令对主节点数据库进行初始化

```sh
Initdb
$ psql -U sysdba -d highgo
highgo=# alter role highgo with password 'highgo@123';
ALTER ROLE
```

### 配置密码环境变量

配置该变量的目的是为了repmgr命令以及repmgrd守护进程能够免密连接数据库。
配置密码文件（highgo）

ref [.pgpass](./pgpass.md)

### 配置数据库并启动数据库

postgresql.conf （根据需要配置）
pg_hba.conf文件（根据需要配置）

ref [pg_installation](./pg_installation.md)

### 注册主节点repmgr

```sh
repmgr primary register
```

注册主节点后，配置的虚拟ip会绑定到配置的网卡上，应用程序可以通过
该IP连接到主节点服务器。

### 检查集群状态

执行以下命令，检查集群状态

```sh
repmgr cluster show
```

eg:

```sh
$ repmgr primary register
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
INFO: connecting to primary database...
NOTICE: attempting to install extension "repmgr"
NOTICE: "repmgr" extension successfully installed
```

## 备节点node2部署

### 配置node2的hg_repmgr配置文件

```sh
/*repmgr基本信息设置*/
node_id=2   //节点ID
node_name='node2'   //节点名称，配置和主机名一致
conninfo='host=node2 user=sysdba dbname=highgo port=5866 connect_timeout=2'
//repmgr或repmgrd命令连接数据库的连接串
data_directory='/opt/HighGo5.6.5-X/data'
/*repmgr日志设置*/
log_level=INFO   
log_facility=STDERR        
log_file='/opt/HighGo5.6.5-X/repmgr.log'
pg_bindir='/opt/HighGo5.6.5-X/bin' 
/*集群failover设置*/
failover=automatic
promote_command='repmgr standby promote -f 
/opt/HighGo5.6.5-X/conf/hg_repmgr.conf --log-to-file'
follow_command='repmgr standby follow -f 
/opt/HighGo5.6.5-X/conf/hg_repmgr.conf --log-to-file'
/*虚拟ip设置*/
virtual_ip = '192.168.90.96'        //配置虚拟ip
network_card = 'ens33'      //配置虚拟ip绑定的网卡
/* 配置repmgr daemon stop/start 调用命令 */
repmgrd_service_stop_command=pkill -F /tmp/repmgrd.pid
repmgrd_service_start_command=repmgrd -d
```

eg:

```sh
$ cat /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf |grep -v '#' |grep -v ^$
node_id=2
node_name='hgdbt2'
conninfo='host=hgdbt2 user=highgo dbname=highgo port=5866 connect_timeout=5'
data_directory='/opt/HighGo5.6.5-cluster/data'
log_level=INFO   
log_facility=STDERR        
log_file='/opt/HighGo5.6.5-cluster/repmgr.log'
pg_bindir='/opt/HighGo5.6.5-cluster/bin' 
failover=automatic
promote_command='repmgr standby promote -f /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf --log-to-file'
follow_command='repmgr standby follow -f /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf --log-to-file'
virtual_ip = '192.168.6.9'
network_card = 'enp0s3'
repmgrd_service_stop_command=pkill -F /tmp/repmgrd.pid
repmgrd_service_start_command=repmgrd -d
```

### 配置备节点的密码环境变量

密码同主节点
配置密码文件（highgo）

### 从主节点node1 克隆一个基础备份

```sh
repmgr -h node1 -U highgo -d highgo standby clone
```

eg:

```sh
$ repmgr -h 192.168.6.10 -U highgo -d highgo standby clone
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
NOTICE: destination directory "/opt/HighGo5.6.5-cluster/data" provided
INFO: connecting to source node
DETAIL: connection string is: host=192.168.6.10 user=highgo dbname=highgo
DETAIL: current installation size is 24 MB
INFO: creating directory "/opt/HighGo5.6.5-cluster/data"...
NOTICE: starting backup (using pg_basebackup)...
HINT: this may take some time; consider using the -c/--fast-checkpoint option
INFO: executing:
  /opt/HighGo5.6.5-cluster/bin/pg_basebackup -l "repmgr base backup"  -D /opt/HighGo5.6.5-cluster/data -h 192.168.6.10 -p 5866 -U highgo -X stream 
NOTICE: standby clone (using pg_basebackup) complete
NOTICE: you can now start your PostgreSQL server
HINT: for example: pg_ctl -D /opt/HighGo5.6.5-cluster/data start
HINT: after starting the server, you need to register this standby with "repmgr standby register"
[highgo@hgdbt2 conf]$ 
```

### 启动数据库

```sh
pg_ctl -D /opt/HighGo5.6.5-X/data -l logfile start

psql 'host=dbrs user=hgrepmgr dbname=hgrepmgr connect_timeout=2'  #测试主端数据库是否可达（所有备节点）  
```

### 注册备节点库

```sh
repmgr standby register

Eg:
$ repmgr standby register
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
INFO: connecting to local node "hgdbt2" (ID: 2)
INFO: connecting to primary database
WARNING: --upstream-node-id not supplied, assuming upstream node is primary (node ID 1)
INFO: standby registration complete
NOTICE: standby node "hgdbt2" (id: 2) successfully registered
[highgo@hgdbt2 conf]$ 
```

### 检查集群状态

```sh
repmgr cluster show
Eg:
$ repmgr cluster show
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
WARNING: /opt/HighGo5.6.5-cluster/conf/hg_repmgr.conf--log-to-file'/2: unknown name/value pair provided; ignoring
 ID | Name   | Role    | Status    | Upstream | Location | Priority | Replication lag | Last replayed LSN
----+--------+---------+-----------+----------+----------+----------+-----------------+-------------------
 1  | hgdbt1 | primary | * running |          | default  | 100      | n/a             | none             
 2  | hgdbt2 | standby |   running | hgdbt1   | default  | 100      | 0 bytes         | 0/30006E0   
```

<!--
备节点node3部署
配置node3的hg_repmgr.conf配置文件
/*repmgr基本信息设置*/
node_id=3   //节点ID
node_name='node3'   //节点名称，配置和主机名一致
conninfo='host=node3 user=sysdba dbname=highgo port=5866 connect_timeout=2'
//repmgr或repmgrd命令连接数据库的连接串
data_directory='/opt/HighGo5.6.5-X/data'
/*repmgr日志设置*/
log_level=INFO   
log_facility=STDERR        
log_file='/opt/HighGo5.6.5-X/repmgr.log'
pg_bindir='/opt/HighGo5.6.5-X/bin' 
/*集群failover设置*/
failover=automatic
promote_command='repmgr standby promote -f 
/opt/HighGo5.6.5-X/conf/hg_repmgr.conf --log-to-file'
follow_command='repmgr standby follow -f 
/opt/HighGo5.6.5-X/conf/hg_repmgr.conf --log-to-file'
/*虚拟ip设置*/
virtual_ip = '192.168.90.96'        //配置虚拟ip
network_card = 'ens33'      //配置虚拟ip的网卡
/* 配置repmgr daemon stop/start 调用命令 */
repmgrd_service_stop_command=pkill -F /tmp/repmgrd.pid
repmgrd_service_start_command=repmgrd -d
 
从主节点node1 克隆一个基础备份
repmgr -h node1 -U highgo -d highgo standby clone
配置备节点的密码环境变量
export PGPASSWORD=***
密码同主节点
启动数据库
pg_ctl -D /opt/HighGo5.6.5-X/data -l logfile start
注册备节点库
repmgr standby register
检查集群状态
repmgr cluster show
-->  

## 依次在主次节点启动repmgrd守护进程

```

shared_preload_libraries = 'repmgr'

主节点
repmgrd -d
Node2节点
repmgrd -d
```

<!--
Node3主节点
repmgrd -d
-->
通过ps -ef | grep repmgrd 检查repmgrd守护进程是否启动成功。
注意：为保证各节点上的repmgrd进程能在启动第一时间识别到所有节点，请在部署时在将所有注册节点注册完毕后再统一启动各节点上的repmgrd
至此，一主两备的流复制集群已经通过Repmgr流复制管理工具搭建完成，各个节点开启的repmgrd守护进程能够实时监控集群状态，并对一些突发情况作出相应的处理。

## 同步测试

```sql
主库创建
highgo=# create table t1 (id int);
CREATE TABLE
highgo=# insert into t1 values (1);
INSERT 0 1
highgo=# select * from t1;
 id 
----
  1
(1 row)
备库查询
highgo=# select * from t1;
 id 
----
  1
(1 row)
```

## HG_jdbc负载均衡器

使用HG_JDBC
负载均衡开关：
连接配置参数为loadBalanceHosts，当该参数为true时，打开负载均衡功能；当该参数为false时，关闭负载均衡功能。
使用方法：
JDBC的所有配置都是通过URL完成，如下：
jdbc:highgo://primary-node:port/dbname?loadBalanceHosts=true
其中primary-node就是主节点的ip信息，可配成集群的Virtual IP。
loadBalanceHosts参数为true，所以此时负载均衡参数为开启状态。
如果为单机系统，则需要设置为false。

## DML转发功能（企业版集群不支持）

## Virtual IP的管理

如果要使用集群的Virtual IP功能，需要在每个节点的hg_repmgr.conf文件配置如下参数：

```sh
virtual_ip=’192.168.90.96’
network_card=’ens33’
Virtual IP会随着主节点漂移
```

## 高可用的管理

手动failover
手动switchover
自动failover
promote
follow
rejoin

## repmgr切换时间

修改 repmgr 切换时间为5分钟，是调整哪个参数

```sh
1.节点可用性方面
#promote_check_timeout=60
#promote_check_interval=5
2.网络可用性方面
reconnect_attempts = 60
reconnect_interval = 5
3.磁盘可用性方面
#device_check_timeout=60
#device_check_times=5


```

这三组都调整方可保证各类故障的切换时间均为5分钟

## rejoin

<!--
脑裂后的解决方式

repmgr node rejoin -d 'host=172.16.56.184 user=sysdba dbname=highgo' --force-rewind --verbose

主节点

repmgr primary register -F一下

-->

## 重做备节点步骤

1. 确认主节点（repmgr cluster show）
2. 关闭备节点（pg_ctl stop）
3. 备节点，mv $PGDATA到其他目录
4. 克隆备节点（repmgr -h 主节点IP -U hgrepmgr -d highgo -p 5433 standby clone）
5. 启动备节点（pg_ctl start）
6. 注册备节点（repmgr standby register -F）
7. 确认集群信息（repmgr cluster show）
