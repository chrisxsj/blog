# hghac

**作者**

chrisx

**日期**

2021-12-14

**内容**

hahac配置手册

----

[toc]

## pretask安装前的配置

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

### 4. 生成ssl证书

生成需要的ssl_ca_cert

```sh
/opt/HighGo4.5.7-see/bin/hg_sslkeygen.sh /data/highgo/data


# ls -atl /data/highgo/data/root.*
-rw-------. 1 root root 1338 12月  8 22:05 /data/highgo/data/root.crt

# ls -atl /data/highgo/data/server.*
-rw-------. 1 root root 4317 12月  8 15:14 /data/highgo/data/server.crt
-rw-------. 1 root root 1675 12月  8 15:14 /data/highgo/data/server.key

```

### 5. 修改数据库参数

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

### 6. 网络访问配置文件

pg_hba.conf

```sh
# add by highgo 20211209
host    all             all             0.0.0.0/0              sm3
host    replication             all             0.0.0.0/0              sm3

```

### 7. 密码文件

```sh
pgpass  0600
#hostname:port:database:username:password
localhost:5866:highgo:sysdba:xxx
localhost:5866:highgo:syssso:xxx
localhost:5866:highgo:syssao:xxx

```

### 8. lic

### 9. 启动关闭数据库

```sh
pg_ctl start  #启动测试
pg_ctl stop

```

### 10. 流复制

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

### 启动etcd服务

```sh
systemctl daemon-reload
systemctl start etcd.service

```

3个节点启动服务后检查状态

<!--
/opt/HighGo/tools/hghac/etcd/amd64/etcdctl  --endpoints=http://10.8.72.35:2379,http://10.8.72.36:2379,http://10.8.72.239:2379 endpoint status --write-out=table
如有环境变量会报错

2021-12-08 19:43:15.570838 C | pkg/flags: conflicting environment variable "ETCDCTL_ENDPOINTS" is shadowed by corresponding command-line flag (either unset environment variable or disable flag)

解决方案
1. unset ETCDCTL_ENDPOINTS
2. 修改环境变量 
export ETCDCTL_ENDPOINTS=http://xxx:2379,http://xxx:2379,http://xxx:2379
命令不带 --endpoints
-->

```sh
/opt/HighGo/tools/hghac/etcd/amd64/etcdctl  endpoint status --write-out=table member list

etcdctl endpoint status -w table
# etcdctl endpoint status -w table
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|        ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|  http://xxx:2379 | 8d53b3091da3504e |  3.4.15 |   16 kB |      true |      false |         9 |          9 |                  9 |        |
|  http://xxx:2379 | 3794ee135e8efda4 |  3.4.15 |   16 kB |     false |      false |         9 |          9 |                  9 |        |
| http://1xxx:2379 | 460e76e166b84fb1 |  3.4.15 |   16 kB |     false |      false |         9 |          9 |                  9 |        |
+-------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+


```

## hghac安装配置（主从节点）

### hghac配置文件

copy一个配置文件

```sh
mkdir /opt/HighGo/hghac_log

mv /opt/HighGo/tools/hghac/hghac-see.yaml /opt/HighGo/tools/hghac/hghac-see.yaml.bak
vi /opt/HighGo/tools/hghac/hghac-see.yaml
```

yaml配置文件内容

```yaml
restapi:
  connect_address: xxx:8008
  listen: 0.0.0.0:8008
etcd:
  hosts: xxx:2379,xxx:2379,xxx:2379
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
  connect_address:  xxx:5866
  listen: 0.0.0.0:5866
  callbacks:
    on_start: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
    on_restart: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
    on_role_change: /bin/bash /opt/HighGo/tools/hghac/loadvip.sh
  authentication:
    replication:
      password: xxx
      username: sysdba
    rewind:
      password: xxx
      username: sysdba
    sysdba:
      password: xxx
    syssso:
      password: xxx
    syssao:
      password: xxx
  parameters:
log:
  level: INFO
  dir: /opt/HighGo/hghac_log

```

:warning: 数据库参数可在patroni配置文件中配置，也可以不配置，数据库自己管理。patroni优先级高于数据库（postgresql.conf>postgrsql.base.conf>postgresql.auto.conf）
:warning: yaml参数含义参考[patroni_and_etcd_installation-编写patroni配置文件YAML Configuration](./../os/patroni_and_etcd_installation.md)

### 服务文件配置

vi /etc/systemd/system/hghac-vip.service

```sh

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

```

:warning: EnvironmentFile和ExecStart参数值需与实际情况匹配
:warning: 使用vip时，使用配置文件hghac-vip.service

### vip配置文件

copy一个配置文件

```sh
mv /opt/HighGo/tools/hghac/vip.env /opt/HighGo/tools/hghac/vip.env.bak

vi /opt/HighGo/tools/hghac/vip.env

```

配置文件指定vip和vip绑定的网卡

```sh
VIP=xxx
GATEWAY=xxx
DEV=enp6s0f0
MASK=24

```

### 启动hghac服务

```sh
systemctl daemon-reload
systemctl start hghac-vip.service 

```

### 状态检查

```sh

/opt/HighGo/tools/hghac/hghactl -c /opt/HighGo/tools/hghac/hghac-see.yaml list

hghactl -c $HGHAC_CONF list

hghactl list

[root@db25 data]# hghactl list
+ Cluster: hg (7039584945637938737) -+---------+----+-----------+-----------------+
| Member | Host            | Role    | State   | TL | Lag in MB | Pending restart |
+--------+-----------------+---------+---------+----+-----------+-----------------+
| db25   | xxx:5866 | Leader  | running |  1 |           |                 |
| db27   | xxx:5866 | Replica | running |  1 |         0 | *               |
+--------+-----------------+---------+---------+----+-----------+-----------------+

```

## hgproxy安装配置（主备节点）

### 安装

```sh
]# rpm -ivh hgproxy-4.0.8-261feb8.x86_64.rpm
准备中...                          ################################# [100%]
正在升级/安装...
   1:hgproxy-4.0.8-261feb8            ################################# [100%]
Created symlink from /etc/systemd/system/multi-user.target.wants/hgproxy.service to /usr/lib/systemd/system/hgproxy.service.
Created symlink from /etc/systemd/system/graphical.target.wants/hgproxy.service to /usr/lib/systemd/system/hgproxy.service.

```

### 配置文件

copy一个配置文件

```sh
mv /opt/highgo/hgproxy/etc/proxy.conf /opt/highgo/hgproxy/etc/proxy.conf.bak
mkdir /opt/highgo/hgproxy_log
vi /opt/highgo/hgproxy/etc/proxy.conf


```

配置hgproxy

配置参考

```sh
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

```

具体配置

```sh
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
hostname0 =xxx
port0 =5866
backend_weigh0 =1
hostname1 =xxx
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

```

### 拷贝ssl证书

拷贝ssl相关文件至指定路径（proxy.conf文件中ssl_ca_cert_dir）

```sh
scp /data/highgo/data/server.* xxx:/data/highgo/data #备库
scp /data/highgo/data/root.crt xxx:/data/highgo/data
cp /data/highgo/data/server.* /opt/highgo/hgproxy/etc
cp /data/highgo/data/root.crt /opt/highgo/hgproxy/etc


```

### 初始化proxy

```sh
/opt/highgo/hgproxy/bin/proxy_ctl  init -h 10.8.72.25 -p 5866 -U sysdba -d highgo

```

:warning: -h使用本机ip或vip

### 开启服务

```sh
systemctl start hgproxy.service

```

尝试连接数据库

```sh
psql -U sysdba -d highgo -h 10.8.72.25  -p 5888

```

:warning: 如果不正常。就重来一遍，重启数据库。

## posttask

设为自启动

```sh

#务必设置数据库服务非自启！
systemctl disable hgdb-see-4.5.7.service
systemctl enable etcd.service
systemctl enable hghac-vip.service
systemctl enable hgproxy.service

```

以上在所有节点操作！！！！！！！！！！！！

其他配置，如backup

## hghac运维管理

重启数据库节点

```sh
# systemctl stop hgproxy.service
# hghactl restart hg xx
+ Cluster: hg (7039584945637938737) -+---------+----+-----------+-----------------+
| Member | Host            | Role    | State   | TL | Lag in MB | Pending restart |
+--------+-----------------+---------+---------+----+-----------+-----------------+
| xx   | xxx:5866 | Leader  | running |  1 |           |                 |
| xx   | xxx:5866 | Replica | running |  1 |         0 | *               |
+--------+-----------------+---------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2021-12-09T17:11)  [now]: 
Are you sure you want to restart members xx? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []: 
Success: restart on member xx
# hghactl restart hg xx
+ Cluster: hg (7039584945637938737) -+---------+----+-----------+-----------------+
| Member | Host            | Role    | State   | TL | Lag in MB | Pending restart |
+--------+-----------------+---------+---------+----+-----------+-----------------+
| xx   | xxx:5866 | Leader  | running |  1 |           |                 |
| xx   | xxx:5866 | Replica | running |  1 |         0 | *               |
+--------+-----------------+---------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2021-12-09T17:11)  [now]: 
Are you sure you want to restart members xx? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []: 
Success: restart on member xx

```

## 问题

问题描述

```sh
1月 17 18:30:23 host-1-2-1-94 proxy_ctl[1980054]: 2022-01-17 18:30:23 ERROR [pid:1980143 cid:415 proxydbc_main.c:663] Life check failed! The backend errorMsg:
1月 17 18:30:23 host-1-2-1-94 proxy_ctl[1980054]: 2022-01-17 18:30:23 ERROR [pid:1980143 cid:415 proxydbc_main.c:664] password authentication failed for user "sysdba"
1月 17 18:30:23 host-1-2-1-94 proxy_ctl[1980054]: 2022-01-17 18:30:23 WARNING [pid:1980143 cid:415 proxydbc_main.c:884]  ip =[1.2.1.231] port=[5866] node down
1月 17 18:30:23 host-1-2-1-94 proxy_ctl[1980054]: 2022-01-17 18:30:23 ERROR [pid:1980143 cid:415 proxydbc_main.c:663] Life check failed! The backend errorMsg:
1月 17 18:30:23 host-1-2-1-94 proxy_ctl[1980054]: 2022-01-17 18:30:23 ERROR [pid:1980143 cid:415 proxydbc_main.c:664] password authentication failed for user "sysdba"
1月 17 18:30:23 host-1-2-1-94 proxy_ctl[1980054]: 2022-01-17 18:30:23 WARNING [pid:1980143 cid:415 proxydbc_main.c:884]  ip =[1.2.1.94] port=[5866] node down

```

解决方案

重新初始化，初始化过程填写密码