# hghac

**作者**

chrisx

**日期**

2021-12-14

**内容**

hahac常用操作命令

----

[toc]

## 安装前的配置

### hostname

```sh
# add by highgo 20211209
xxx      xxx
xxx      xxx
xxx      xxx
xxx      hg-vip


```

### ntp

ref [ntp](./../os/ntp.md)

### 防火墙

关闭防火墙或开放端口号  2379，2380，5866，8008，5888

```sh
etcd：
firewall-cmd --permanent --add-port=2379/tcp
firewall-cmd --add-port=2379/tcp
firewall-cmd --permanent --add-port=2380/tcp
firewall-cmd --add-port=2380/tcp
db
firewall-cmd --permanent --add-port=5866/tcp
firewall-cmd --add-port=5866/tcp
Hghac
firewall-cmd --permanent --add-port=8008/tcp
firewall-cmd --add-port=8008/tcp
Hgproxy
firewall-cmd --permanent --add-port=5888/tcp
firewall-cmd --add-port=5888/tcp

firewall-cmd --list-ports

```

## 安装配置数据库（主从节点）

### 1. install database

```sh
# rpm -ivh hgdb4.5.7-see-centos7-x86-64-20210804.rpm 
准备中...                          ################################# [100%]
正在升级/安装...
   1:hgdb-see-4.5.7-1.el7.centos      ################################# [100%]
/
Created symlink from /etc/systemd/system/multi-user.target.wants/hgdb-see-4.5.7.service to /usr/lib/systemd/system/hgdb-see-4.5.7.service.
Created symlink from /etc/systemd/system/graphical.target.wants/hgdb-see-4.5.7.service to /usr/lib/systemd/system/hgdb-see-4.5.7.service.


```

### 2. env

```sh
#add by hgdb 20211209
#source /opt/HighGo4.5.7-see/etc/highgodb.env

export PGHOME=/opt/HighGo4.5.7-see
export PGDATA=/data/highgo/data
export PATH=$HGDB_HOME/bin:/opt/HighGo/tools/hghac/etcd/amd64:/opt/HighGo/tools/hghac:$PATH
export LD_LIBRARY_PATH=/opt/HighGo4.5.7-see/lib:/usr/lib64:$LD_LIBRARY_PATH
export PATRONICTL_CONFIG_FILE=/opt/HighGo/tools/hghac/hghac-see.yaml
export ETCDCTL_ENDPOINTS=http://xxx:2379,http://xxx:2379,http://xxx:2379


```

### 3. init

```sh
initdb -D $PGDATA
Hello@123
cp $PGHOME/etc/server* $PGDATA
chmod 0600 $PGDATA/server*

```

### 4. 修改数据库参数

```sh
mkdir /data/archive

```

```sql
\c highgo syssso
select show_secure_param();
select set_secure_param('hg_idcheck.pwdpolicy','high');
select set_secure_param('hg_macontrol','min');
select set_secure_param('hg_rowsecure','off');
select set_secure_param('hg_idcheck.pwdvaliduntil','0');
select set_secure_param('hg_showlogininfo','off');
select set_secure_param('hg_clientnoinput','0');
alter user syssso with password 'xxx';

\c highgo syssao
select set_audit_param('hg_audit','off');
alter user syssao with password 'Bdc@Zrzyb1@25';

\c highgo sysdba
alter system set listen_addresses = '*';
alter system set max_connections = 2000;

alter system set shared_buffers = '128GB';
alter system set effective_cache_size = '130GB';
alter system set maintenance_work_mem='2GB';
alter system set work_mem='50MB';
alter system set wal_buffers='32MB';

alter system set min_wal_size ='5GB';
alter system set max_wal_size ='50GB';
alter system set wal_keep_segments=100;
alter system set wal_level=replica;
alter system set wal_log_hints = 'on';

alter system set checkpoint_completion_target = 0.8;
alter system set checkpoint_timeout='30min';

alter system set log_destination = 'csvlog';
alter system set logging_collector = on;
alter system set log_directory = 'hgdb_log';
alter system set log_filename = 'highgodb_%d.log';
alter system set log_rotation_age = '1d';
alter system set log_rotation_size = 0;
alter system set log_truncate_on_rotation = on;
alter system set log_statement = 'ddl';
alter system set log_connections=on;
alter system set log_disconnections=on;

alter system set max_wal_senders = 40;
alter system set max_replication_slots = 40;

alter system set compatible_db = 'oracle';

alter system set archive_mode = on;
alter system set archive_command = 'cp %p /data/archive/%f';
alter system set archive_timeout = '30min';

alter system set temp_buffers='1GB';
alter system set log_temp_files='5GB';

alter system set ssl='on';
alter system set ssl_cert_file='/data/highgo/data/server.crt';
alter system set ssl_key_file='/data/highgo/data/server.key';

alter user sysdba with password 'xxx';

```

### 5. 网络访问配置文件

pg_hba.conf

```sh
# add by highgo 20211209
host    all             all             0.0.0.0/0              sm3
host    replication             all             0.0.0.0/0              sm3

```

### 6. 密码文件

```sh
pgpass  0600
#hostname:port:database:username:password
localhost:5866:highgo:sysdba:xxx
localhost:5866:highgo:syssso:xxx
localhost:5866:highgo:syssao:xxx

```

### 7. lic

### 8. 关闭数据库

```sh
pg_ctl stop

```

### 流复制

流复制可提前手动配置，也可以通过patroni自动配置。本次使用patroni自动配置

## etcd安装配置（所有节点）

### install

```sh
# rpm -ivh hghac4.0.2-centos7-x86-64-20211028.rpm
准备中...                          ################################# [100%]
正在升级/安装...
   1:hghac-4.0.2-1.el7.centos         ################################# [100%]
Created symlink from /etc/systemd/system/multi-user.target.wants/hghac.service to /etc/systemd/system/hghac.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/hghac-vip.service to /etc/systemd/system/hghac-vip.service.

```

### 创建etcd配置文件

```sh
mkdir /opt/HighGo/etcd_data

vi /opt/HighGo/tools/hghac/etcd/amd64/etcd.yaml

debug: false
name: etcd25
data-dir: /opt/HighGo/etcd_data
listen-peer-urls: http://10.8.72.25:2380
listen-client-urls: http://10.8.72.25:2379                     
initial-advertise-peer-urls: http://10.8.72.25:2380
advertise-client-urls: http://10.8.72.25:2379
initial-cluster-token: etcd-cluster
initial-cluster: etcd25=http://10.8.72.25:2380,etcd27=http://10.8.72.27:2380,etcd117=http://10.8.72.117:2380
initial-cluster-state: new
enable-v2: true

```

参数解释参考 [patroni_and_etcd_installation-编写etcd配置文件](./../os/patroni_and_etcd_installation.md)

配置文件再所有节点全部配置完成再执行下面的操作

### 服务文件配置

copy一个配置文件

```sh
cp /opt/HighGo/tools/hghac/etcd/amd64/etcd.service /etc/systemd/system/
chmod u+x /etc/systemd/system/etcd.service

```

设置配置文件参数

vi /etc/systemd/system/etcd.service

```sh
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
#WorkingDirectory=__INSTALLPATH__/etcd/
WorkingDirectory=/opt/HighGo/tools/hghac/etcd
User=root
#ExecStart=__INSTALLPATH__/etcd/etcd --config-file=__INSTALLPATH__/etcd/etcd.yaml
ExecStart=/opt/HighGo/tools/hghac/etcd/amd64/etcd --config-file=/opt/HighGo/tools/hghac/etcd/amd64/etcd.yaml
Restart=on-failure
LimitNOFILE=65536
TimeoutSec=30
Environment=ETCD_UNSUPPORTED_ARCH=amd64

[Install]
WantedBy=multi-user.target

```

:warning: WorkingDirectory、ExecStart参数值需根据实际情况修改

开启自启

```sh
systemctl daemon-reload
systemctl start etcd.service

```

3个节点启动服务后检查状态


/opt/HighGo/tools/hghac/etcd/amd64/etcdctl  --endpoints=http://10.8.72.35:2379,http://10.8.72.36:2379,http://10.8.72.239:2379 endpoint status --write-out=table
如有环境变量会报错

2021-12-08 19:43:15.570838 C | pkg/flags: conflicting environment variable "ETCDCTL_ENDPOINTS" is shadowed by corresponding command-line flag (either unset environment variable or disable flag)

解决方案
1. unset ETCDCTL_ENDPOINTS
2. 修改环境变量 
export ETCDCTL_ENDPOINTS=http://10.8.72.35:2379,http://10.8.72.36:2379,http://10.8.72.239:2379
命令不带 --endpoints

/opt/HighGo/tools/hghac/etcd/amd64/etcdctl  endpoint status --write-out=table member list

etcdctl endpoint status -w table
root@db25 HighGo]# etcdctl endpoint status -w table
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|        ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|  http://10.8.72.25:2379 | 8d53b3091da3504e |  3.4.15 |   16 kB |      true |      false |         9 |          9 |                  9 |        |
|  http://10.8.72.27:2379 | 3794ee135e8efda4 |  3.4.15 |   16 kB |     false |      false |         9 |          9 |                  9 |        |
| http://10.8.72.117:2379 | 460e76e166b84fb1 |  3.4.15 |   16 kB |     false |      false |         9 |          9 |                  9 |        |
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
[root@db25 HighGo]# 

+++++++++++++++++++++++++++++++++++++++++++++++++

hghac

mkdir /opt/HighGo/hghac_log

mv /opt/HighGo/tools/hghac/hghac-see.yaml /opt/HighGo/tools/hghac/hghac-see.yaml.bak
vi /opt/HighGo/tools/hghac/hghac-see.yaml

restapi:
  connect_address: 10.8.72.25:8008
  listen: 0.0.0.0:8008
etcd:
  hosts: 10.8.72.25:2379,10.8.72.27:2379,10.8.72.117:2379
proxy:
  weight: 1
  streaming_replication_delay_time: 5000
name: db25
namespace: hghac
scope: hg
bootstrap:                                       
#  initdb:
#  - encoding: UTF8
#  - locale: en_US.UTF-8
#  - data-checksums
#  - auth: md5
  # 如果需要创建账号
  # users:
  #   admin:
  #     password: Hello@123
  dcs:
    loop_wait: 10
    maximum_lag_on_failover: 33554432
    retry_timeout: 10
    ttl: 30
    postgresql:
      use_pg_rewind: true
      use_slots: true
      parameters:
postgresql:
  database: highgo
  bin_dir: /opt/HighGo4.5.7-see/bin
  data_dir: /data/highgo/data
  connect_address:  10.8.72.25:5866
  listen: 0.0.0.0:5866
  callbacks:
    on_start: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
    on_restart: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
    on_role_change: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
  authentication:
    replication:
      password: Bdc@Zrzyb1!25
      username: sysdba
    rewind:
      password: Bdc@Zrzyb1!25
      username: sysdba
    sysdba:
      password: Bdc@Zrzyb1!25
    syssso:
      password: Bdc@Zrzyb1#25
    syssao:
      password: Bdc@Zrzyb1@25
  parameters:
log:
  level: INFO
  dir: /opt/HighGo/hghac_log
  
  
vi /etc/systemd/system/hghac-vip.service
 
[Unit]
Description=hghac
After=syslog.target network.target

[Service]
Type=simple

User=root
Group=root

# Start the patroni process
#EnvironmentFile=/opt/hghac/vip.env
EnvironmentFile=/opt/HighGo/tools/hghac/vip.env
#ExecStart=/opt/hghac/hghac /etc/hghac/default/hghac.yaml
ExecStart=/opt/HighGo/tools/hghac/hghac /opt/HighGo/tools/hghac/hghac-see.yaml

# Send HUP to reload from patroni.yml
ExecReload=/bin/kill -s HUP $MAINPID

# only kill the patroni process, not it's children, so it will gracefully stop postgres
KillMode=process

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=30

# Do not restart the service if it crashes, we want to manually inspect database on failure
Restart=yes

[Install]
WantedBy=multi-user.target


mv /opt/HighGo/tools/hghac/vip.env /opt/HighGo/tools/hghac/vip.env.bak

vi /opt/HighGo/tools/hghac/vip.env

VIP=10.8.72.26
GATEWAY=10.8.72.254
DEV=enp6s0f0
MASK=24


systemctl daemon-reload
systemctl start hghac-vip.service 


备节点也需要做

vi /opt/HighGo/tools/hghac/hghac-see.yaml

restapi:
  connect_address: 10.8.72.27:8008
  listen: 0.0.0.0:8008
etcd:
  hosts: 10.8.72.25:2379,10.8.72.27:2379,10.8.72.117:2379
proxy:
  weight: 1
  streaming_replication_delay_time: 5000
name: db27
namespace: hghac
scope: hg
bootstrap:                                       
#  initdb:
#  - encoding: UTF8
#  - locale: en_US.UTF-8
#  - data-checksums
#  - auth: md5
  # 如果需要创建账号
  # users:
  #   admin:
  #     password: Hello@123
  dcs:
    loop_wait: 10
    maximum_lag_on_failover: 33554432
    retry_timeout: 10
    ttl: 30
    postgresql:
      use_pg_rewind: true
      use_slots: true
      parameters:
postgresql:
  database: highgo
  bin_dir: /opt/HighGo4.5.7-see/bin
  data_dir: /data/highgo/data
  connect_address:  10.8.72.27:5866
  listen: 0.0.0.0:5866
  callbacks:
    on_start: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
    on_restart: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
    on_role_change: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
  authentication:
    replication:
      password: Bdc@Zrzyb1!25
      username: sysdba
    rewind:
      password: Bdc@Zrzyb1!25
      username: sysdba
    sysdba:
      password: Bdc@Zrzyb1!25
    syssso:
      password: Bdc@Zrzyb1#25
    syssao:
      password: Bdc@Zrzyb1@25
  parameters:
log:
  level: INFO
  dir: /opt/HighGo/hghac_log

  
vi /etc/systemd/system/hghac-vip.service
 
[Unit]
Description=hghac
After=syslog.target network.target

[Service]
Type=simple

User=root
Group=root

# Start the patroni process
#EnvironmentFile=/opt/hghac/vip.env
EnvironmentFile=/opt/HighGo/tools/hghac/vip.env
#ExecStart=/opt/hghac/hghac /etc/hghac/default/hghac.yaml
ExecStart=/opt/HighGo/tools/hghac/hghac /opt/HighGo/tools/hghac/hghac-see.yaml

# Send HUP to reload from patroni.yml
ExecReload=/bin/kill -s HUP $MAINPID

# only kill the patroni process, not it's children, so it will gracefully stop postgres
KillMode=process

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=30

# Do not restart the service if it crashes, we want to manually inspect database on failure
Restart=yes

[Install]
WantedBy=multi-user.target
  
[root@db1 hghac]# cat /opt/HighGo/tools/hghac/vip.env
VIP=10.8.72.37
GATEWAY=10.8.72.254
DEV=ens8f0
MASK=24

systemctl daemon-reload
systemctl start hghac-vip.service 


/opt/HighGo/tools/hghac/hghactl -c /opt/HighGo/tools/hghac/hghac-see.yaml list

hghactl list

[root@db25 data]# hghactl list
+ Cluster: hg (7039584945637938737) -+---------+----+-----------+-----------------+
| Member | Host            | Role    | State   | TL | Lag in MB | Pending restart |
+--------+-----------------+---------+---------+----+-----------+-----------------+
| db25   | 10.8.72.25:5866 | Leader  | running |  1 |           |                 |
| db27   | 10.8.72.27:5866 | Replica | running |  1 |         0 | *               |
+--------+-----------------+---------+---------+----+-----------+-----------------+


+++++++++++++++++++++++++++++++++++++++++++++++++++++

hgproxy （两节点）

[root@db1 software]# rpm -ivh hgproxy-4.0.8-261feb8.x86_64.rpm
准备中...                          ################################# [100%]
正在升级/安装...
   1:hgproxy-4.0.8-261feb8            ################################# [100%]
Created symlink from /etc/systemd/system/multi-user.target.wants/hgproxy.service to /usr/lib/systemd/system/hgproxy.service.
Created symlink from /etc/systemd/system/graphical.target.wants/hgproxy.service to /usr/lib/systemd/system/hgproxy.service.
[root@db1 software]# 

mv /opt/highgo/hgproxy/etc/proxy.conf /opt/highgo/hgproxy/etc/proxy.conf.bak
mkdir /opt/highgo/hgproxy_log
vi /opt/highgo/hgproxy/etc/proxy.conf



配置hgproxy

[Log]
log_collector       = on
                    # 是否开始日志功能

log_level           = log
                    #  可选日志级别如下:
                    #  debug5
                    #  debug4
                    #  debug3
                    #  debug2
                    #  debug1
                    #  log
                    #  commerror
                    #  info
                    #  notice
                    #  warning
                    #  error
                    #  fatal
                    #  panic

log_destination     = stdout,file
                    # stdout： 标准输出
                    # stderr:  标准错误输出
                    # file:    输出到文件

log_filename        = /highgo/hglog/hgproxy.log   
                    # 日志输出文件，建议放置磁盘空间较大的路径下

log_format          = "%d %-5V [pid:%p cid:%U %F:%L] %m%n"
                    # 格式说明:
                    # %d           :时间格式(2012-01-01 17:03:12)
                    # %d(%T)       :时间格式(17:03:12.035)
                    # %d(%m-%d %T) :时间格式(01-01 17:03:12)
                    # %m           :用户日志(必须)
                    # %n           :换行符(必须)
                    # %p           :进程id
                    # %t           :线程id
                    # %U           :协程id
                    # %V           :日志级别,大写
                    # %v           :日志级别,小写
                    # %F           :源代码文件名
                    # %L           :源代码行数

log_rotation_size   = 500MB
                    # 日志文件自动转存.
                    # 设置为0, 则关闭此功能.

[Proxy]
listen_addresses    = *
port                = 5888
socket_dir          = /tmp

process_nums        = 6             
                    # 创建的进程个数,建议与cpu个数保持一致
process_cpu_mode    = hgproxy

max_connection      = 2000
                    # 限制客户端最大连接数

extension_module    = librwsplit.so
                    # hgproxy扩展模块, 目前只有读写分离模块，默认即可

[BackendNode]
node_num            = 3
                    # 后端节点数量

load_balancing_mode = 1
                    # 负载均衡模式（目前只有一种模式，默认即可）
                    # 1：权重模式

hostname0           = 192.168.197.11
port0               = 5866
backend_weigh0      = 1
                    # hostnameN        第N个节点IP
                    # portN            第N个节点端口
                    # backend_weightN  第N个节点权重比

hostname1           = 192.168.197.12
port1               = 5866
backend_weigh1      = 1

hostname2           = 192.168.197.13
port2               = 5866
backend_weigh2      = 1

[Replication]
streaming_replication_switch        = on    #建议开启此参数
                                    #流复制延时开关

streaming_replication_delay_time    = 8000
                                    # 流复制延迟检测, 单位: 微秒

[DatabaseCheck]

lifecheck_user      = sysdba
                    # 用于检测时的用户名

lifecheck_dbname    = highgo
                    # 用于检测时的数据库

lifecheck_time      = 30
                    # 连接间隔时间，取值范围 1 - 3600, 单位：秒

lifecheck_num       = 3
                    # 连续连接失败指定次数，达到该次数，节点将置为异常, 取值范围 1 - 10

[BlackList]
black_regex_token_list          =
                                # 匹配到了发往主节点

white_regex_token_list          =
                                # 匹配成功发往备节点

object_relationship_list        = /opt/HighGo/tools/hgproxy/etc/object_relationship_list.json

[SSL]
ssl_switch                = on    #安全版数据库需开启ssl，企业版默认关闭

ssl_cert                  = /opt/HighGo/tools/hgproxy/etc/server.crt
ssl_key                   = /opt/HighGo/tools/hgproxy/etc/server.key
ssl_ca_cert               = /opt/HighGo/tools/hgproxy/etc/root.crt
ssl_ca_cert_dir           = /opt/HighGo/tools/hgproxy/etc

ssl_ciphers               = HIGH:MEDIUM:+3DES:!aNULL
ssl_prefer_server_ciphers = on
ssl_ecdh_curve            = prime256v1
ssl_dh_params_file        =

[RAFT]
raft_switch     = off        #因目前proxy不支持raft集群形式，如组件raft集群此参数可不开启
raft_hostname   = 127.0.0.1
raft_port       = 2379
raft_key        = '/service'
raft_server     = 'http://127.0.0.1:2379'



[Log]
log_collector =on
log_level =log
log_destination =stdout,file
log_filename =/opt/highgo/hgproxy_log/hgproxy.log
log_format ="%d %-5V [pid:%p cid:%U %F:%L] %m%n"
log_rotation_size =500MB
[Proxy]
listen_addresses =*
port =5888
socket_dir =/tmp
process_nums =96
process_cpu_mode =hgproxy
max_connection =2000
extension_module =librwsplit.so
[BackendNode]
node_num =2
load_balancing_mode =1
hostname0 =10.8.72.25
port0 =5866
backend_weigh0 =1
hostname1 =10.8.72.27
port1 =5866
backend_weigh1 =1
[Replication]
streaming_replication_switch =on
streaming_replication_delay_time =80000
[DatabaseCheck]
lifecheck_user =sysdba
lifecheck_dbname =highgo
lifecheck_time =60
lifecheck_num =3
[BlackList]
black_regex_token_list =
white_regex_token_list =
object_relationship_list=/opt/highgo/hgproxy/etc/object_relationship_list.json
[SSL]
ssl_switch =on
ssl_cert =/opt/highgo/hgproxy/etc/server.crt
ssl_key =/opt/highgo/hgproxy/etc/server.key
ssl_ca_cert =/opt/highgo/hgproxy/etc/root.crt
ssl_ca_cert_dir =/opt/highgo/hgproxy/etc
ssl_ciphers =HIGH:MEDIUM:+3DES:!aNULL
ssl_prefer_server_ciphers =on
ssl_ecdh_curve =prime256v1
ssl_dh_params_file =


生成需要的ssl_ca_cert =/opt/highgo/hgproxy/etc/root.crt文件 
/opt/HighGo4.5.7-see/bin/hg_sslkeygen.sh /data/highgo/data


[root@db1 bin]# ls -atl /data/highgo/data/root.*
-rw-------. 1 root root 1338 12月  8 22:05 /data/highgo/data/root.crt

[root@db1 etcd]# ls -atl /data/highgo/data/server.*
-rw-------. 1 root root 4317 12月  8 15:14 /data/highgo/data/server.crt
-rw-------. 1 root root 1675 12月  8 15:14 /data/highgo/data/server.key

拷贝ssl相关文件至指定路径（proxy.conf文件中ssl_ca_cert_dir）


scp /data/highgo/data/server.* 10.8.72.27:/data/highgo/data
scp /data/highgo/data/root.crt 10.8.72.27:/data/highgo/data
cp /data/highgo/data/server.* /opt/highgo/hgproxy/etc
cp /data/highgo/data/root.crt /opt/highgo/hgproxy/etc



修改参数两个节点都要做
alter system set ssl_cert_file='/data/highgo/data/server.crt';
alter system set ssl_key_file='/data/highgo/data/server.key';

select pg_reload_conf();

初始化proxy
/opt/highgo/hgproxy/bin/proxy_ctl  init -h 10.8.72.25 -p 5866 -U sysdba -d highgo



/usr/lib/systemd/system/hgproxy.service


开启服务
systemctl start hgproxy.service

尝试连接数据库

psql -U sysdba -d highgo -h 10.8.72.25  -p 5888

如果不正常。就重来一遍，重启数据库。

然后重启数据库

[root@db25 data]# systemctl stop hgproxy.service
[root@db25 data]# hghactl restart hg db25
+ Cluster: hg (7039584945637938737) -+---------+----+-----------+-----------------+
| Member | Host            | Role    | State   | TL | Lag in MB | Pending restart |
+--------+-----------------+---------+---------+----+-----------+-----------------+
| db25   | 10.8.72.25:5866 | Leader  | running |  1 |           |                 |
| db27   | 10.8.72.27:5866 | Replica | running |  1 |         0 | *               |
+--------+-----------------+---------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2021-12-09T17:11)  [now]: 
Are you sure you want to restart members db25? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []: 
Success: restart on member db25
[root@db25 data]# hghactl restart hg db27
+ Cluster: hg (7039584945637938737) -+---------+----+-----------+-----------------+
| Member | Host            | Role    | State   | TL | Lag in MB | Pending restart |
+--------+-----------------+---------+---------+----+-----------+-----------------+
| db25   | 10.8.72.25:5866 | Leader  | running |  1 |           |                 |
| db27   | 10.8.72.27:5866 | Replica | running |  1 |         0 | *               |
+--------+-----------------+---------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2021-12-09T17:11)  [now]: 
Are you sure you want to restart members db27? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []: 
Success: restart on member db27
[root@db25 data]# systemctl start hgproxy.service
[root@db25 data]# 


以上在所有节点操作！！！！！！！！！！！！


[Log]
log_collector =on
log_level =log
log_destination =stdout,file
log_filename =/opt/highgo/hgproxy_log/hgproxy.log
log_format ="%d %-5V [pid:%p cid:%U %F:%L] %m%n"
log_rotation_size =500MB
[Proxy]
listen_addresses =*
port =5888
socket_dir =/tmp
process_nums =96
process_cpu_mode =hgproxy
max_connection =5000
extension_module =librwsplit.so
[BackendNode]
node_num =2
load_balancing_mode =1
hostname0 =10.8.72.25
port0 =5866
backend_weigh0 =1
hostname1 =10.8.72.27
port1 =5866
backend_weigh1 =1
[Replication]
streaming_replication_switch =on
streaming_replication_delay_time =80000
[DatabaseCheck]
lifecheck_user =sysdba
lifecheck_dbname =highgo
lifecheck_time =60
lifecheck_num =3
[BlackList]
black_regex_token_list =
white_regex_token_list =
object_relationship_list=/opt/highgo/hgproxy/etc/object_relationship_list.json
[SSL]
ssl_switch =on
ssl_cert =/opt/highgo/hgproxy/etc/server.crt
ssl_key =/opt/highgo/hgproxy/etc/server.key
ssl_ca_cert =/opt/highgo/hgproxy/etc/root.crt
ssl_ca_cert_dir =/opt/highgo/hgproxy/etc
ssl_ciphers =HIGH:MEDIUM:+3DES:!aNULL
ssl_prefer_server_ciphers =on
ssl_ecdh_curve =prime256v1
ssl_dh_params_file =


cp /data/highgo/data/server.* /opt/highgo/hgproxy/etc
cp /data/highgo/data/root.crt /opt/highgo/hgproxy/etc

/opt/highgo/hgproxy/bin/proxy_ctl  init -h 10.8.72.27 -p 5866 -U sysdba -d highgo

开启服务
systemctl start hgproxy.service

尝试连接数据库

psql -U sysdba -d highgo -h 10.8.72.27  -p 5888

++++++++++++++++++++++++++++++++++++++++++++

设为自启动，如果客户没有必须要求，建议手启动，自启如果多台服务器重启
间隔时间很短，则容易导致时间线不一致问题。

 --务必设置数据库服务非自启！
systemctl disable hgdb-see-4.5.7.service
systemctl enable etcd.service
systemctl enable hghac-vip.service
systemctl enable hgproxy.service

以上在所有节点操作！！！！！！！！！！！！

[root@db25 data]# systemctl list-unit-files |grep etcd
etcd.service                                  enabled 
[root@db25 data]# systemctl list-unit-files |grep hg
hgdb-see-4.5.7.service                        disabled
hghac-vip.service                             enabled 
hghac.service                                 enabled 
hgproxy.service                               enabled 
[root@db25 data]# 


[root@db27 data]# systemctl list-unit-files |grep etcd
etcd.service                                  enabled 
[root@db27 data]# systemctl list-unit-files |grep hg
hgdb-see-4.5.7.service                        disabled
hghac-vip.service                             enabled 
hghac.service                                 enabled 
hgproxy.service                               enabled 
[root@db27 data]# 

[root@db117 ~]# 
[root@db117 ~]# systemctl list-unit-files |grep etcd
etcd.service                                  enabled 
[root@db117 ~]# systemctl list-unit-files |grep hg
hghac-vip.service                             enabled 
hghac.service                                 enabled 
[root@db117 ~]# 



++++++++++++++++++++++++++++++++++++++++

[root@db25 highgo]# pg_controldata 
pg_control 版本:                      1201
Catalog 版本:                         201909212
数据库系统标识符:                     7039584945637938737
数据库簇状态:                         在运行中
pg_control 最后修改:                  2021年12月09日 星期四 14时49分02秒
最新检查点位置:                       0/19FAA90
最新检查点的 REDO 位置:               0/19FAA90
最新检查点的重做日志文件: 000000010000000000000001
最新检查点的 TimeLineID:              1
最新检查点的PrevTimeLineID: 1
最新检查点的full_page_writes: 开启
最新检查点的NextXID:          0:522
最新检查点的 NextOID:                 15290
最新检查点的NextMultiXactId: 1
最新检查点的NextMultiOffsetD: 0
最新检查点的oldestXID:            512
最新检查点的oldestXID所在的数据库：1
最新检查点的oldestActiveXID:  0
最新检查点的oldestMultiXid:  1
最新检查点的oldestMulti所在的数据库：1
最新检查点的oldestCommitTsXid:0
最新检查点的newestCommitTsXid:0
最新检查点的时间:                     2021年12月09日 星期四 14时44分39秒
不带日志的关系: 0/3E8使用虚假的LSN计数器
最小恢复结束位置: 0/0
最小恢复结束位置时间表: 0
开始进行备份的点位置:                       0/0
备份的最终位置:                  0/0
需要终止备份的记录:        否
wal_level设置：                    replica
wal_log_hints设置：        开启
max_connections设置：   2000
max_worker_processes设置：   8
max_wal_senders设置:              40
max_prepared_xacts设置：   0
max_locks_per_xact设置：   64
track_commit_timestamp设置:        关闭
最大数据校准:     8
数据库块大小:                         8192
大关系的每段块数:                     131072
WAL的块大小:    8192
每一个 WAL 段字节数:                  16777216
标识符的最大长度:                     64
在索引中可允许使用最大的列数:    32
TOAST区块的最大长度:                1988
大对象区块的大小:         2048
日期/时间 类型存储:                   64位整数
正在传递Flloat4类型的参数:           由值
正在传递Flloat8类型的参数:                   由值
数据页校验和版本:  0
Data encryption:                      关闭
当前身份验证:            6afa4dce57a1643782ce1fd37f72fd9aaf7e0958e85bc5e9bc482ba9cb10d627
Data encryption cipher:               off
[root@db25 highgo]# 


====================================

backup

mkdir /data/backup

[root@db25 backup]# 
[root@db25 backup]# head -n 50 hgdb_backup.sh 
#!/bin/bash
#############################################################################################
# 1、备份改用pg_basebackup
# 2、支持对备份进行打包或压缩
# 3、SM机把第一行再加个“#”
# 4、脚本不支持dash，如系统是Ubuntu、Deepin、UOS等系统，使用下面两种方式运行脚本:
#    (1)sudo dpkg-reconfigure dash  选择no。这样会修改为bash为默认shell
#    (2)直接使用bash 脚本名调用
# 5、调整检测逻辑，在流复制备机运行时，不创建任何文件
# 6、调整读取密码文件逻辑，密码文件同一个用户有多行时，进取一行
# 7、增加冗余备份功能，修正非默认表空间的备份路径
#############################################################################################
source ~/.bash_profile
#需要修改的参数
hguser=sysdba                                       #安全版换成sysdba或其他权限足够的用户
defdb=highgo                                        #备份使用的数据库名称，默认使用highgo
PORT=5866                                           #数据库端口
num=1                                               #备份保留数量
archdir=/data/archive                  #归档文件存放路径
PGHOME=/opt/HighGo4.5.7-see                     #数据库安装目录，末尾不要带“/”
master_db_cluster=/data/highgo/data     #数据文件路径，默认指向$PGHOME/data
backup_db_cluster=/data/backup          #备份存放路径
bakhost=localhost                                   #服务器ip，本地使用localhost即可
issm=no                                             #是否为SM机环境，如果不是，且crontab可用，此处填写no
baktime=16:26                                       #如果issm是no，这个不生效
istar=no                                            #是否将备份打包为tar包
iscompressed=no                                     #是否将备份进行压缩，需要先设置istar为yes，使用gz压缩
#冗余备份选项
re_bak=no                                          #是否启用冗余备份，yes/no
rebak_dir=/rebak/dbbak                              #备份文件存放路径，本地及远程存储均按实际路径填写
rearch_dir=/rebak/arch                              #冗余归档目录
rebak_num=4                                         #冗余备份保留份数

#################################################################################以下内容不要修改##########################################################################################
bakdate=`date +%Y%m%d`
olddate=`date +%Y%m%d --date="-$num day"`
reolddate=`date +%Y%m%d --date="-$rebak_num day"`
[ -d $backup_db_cluster ] || mkdir -p $backup_db_cluster
if [ -d $backup_db_cluster ] ;then
    cd $backup_db_cluster
    if [ `ls -l $backup_db_cluster/ |grep '^d'|grep $bakdate|wc -l` -gt 0 ];then
        tmp=`ls -l $backup_db_cluster/ |grep '^d'|grep $bakdate|awk '{print $9}'|sort -nr -k 3 -t'_'|head -1|awk -F '_' '{print $3}'`
        bh=$((tmp + 1))
    else
        bh=1
    fi
    bakname="hgdbbak_"$bakdate"_"$bh
    logfile="hgdbbak_"$bakdate"_"$bh".log"
    test_write_file="test_write_file"`date +%Y%m%d%H%S`.tmp
    touch $backup_db_cluster/$test_write_file
[root@db25 backup]# 



[root@db25 backup]# cat hgdbbak_20211209_2.log 
2021-12-09 17:08:43	Database is not recovering and can be connected , so can be backup now.
2021-12-09 17:08:43 pg_basebackup will go now
2021-12-09 17:08:43 There do not have tablespace out of /data/highgo/data in this cluster ......
pg_basebackup: 开始基础备份，等待检查点完成
pg_basebackup: 已完成检查点
pg_basebackup: 预写日志起始于时间点: 0/8000028, 基于时间轴1
pg_basebackup: 启动后台 WAL 接收进程
pg_basebackup: 已创建临时复制槽"pg_basebackup_25322"
    0/31612 kB (0%), 0/1 表空间 (.../hgdbbak_20211209_2/backup_label)
31622/31622 kB (100%), 0/1 表空间 (...bak_20211209_2/global/pg_control)
31622/31622 kB (100%), 1/1 表空间                                         
pg_basebackup: 预写日志结束点: 0/8000100
pg_basebackup: 等待后台进程结束流操作...
pg_basebackup: 同步数据到磁盘...
pg_basebackup: 基础备份已完成
2021-12-09 17:08:44 The name of the backup file is :hgdbbak_20211209_2,the name of the archive is:
2021-12-09 17:08:44 There are no archives to be deleted. 
2021-12-09 17:08:44 Deleting backup file /data/backup/hgdbbak_20211209_1
2021-12-09 17:08:45 Deleting backup log /data/backup/hgdbbak_20211209_1.log
[root@db25 backup]# 


[root@db25 backup]# crontab -l
10 0 * * 6 /data/backup/hgdb_backup.sh


27

[root@db27 backup]# cat hgdbbak_20211209_1.log 
2021-12-09 17:12:24	Recovering or database is not running ,backup failed,the shell will exit now.
2021-12-09 17:12:56	Recovering or database is not running ,backup failed,the shell will exit now.
[root@db27 backup]# 
[root@db27 backup]# crontab -l
10 0 * * 6 /data/backup/hgdb_backup.sh
[root@db27 backup]# 

