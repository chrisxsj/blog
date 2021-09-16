# hgproxy

参考手册

配置proxy.conf文件

cat  /opt/hgproxy/etc/proxy1.conf

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

log_filename        = /opt/hgproxy_log/hgproxy.log
                    # 日志输出文件

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
                    # 创建的进程个数

max_connection      = 2000
                    # 限制客户端最大连接数

extension_module    = librwsplit.so
                    # hgproxy扩展模块, 目前只有读写分离模块，默认即可

[BackendNode]
#node_num            = 3
#node_num            = 2
#                    # 后端节点数量
#
#load_balancing_mode = 1
#                    # 负载均衡模式（目前只有一种模式，默认即可）
#                    # 1：权重模式
#
#hostname0           = 192.168.80.252
#port0               = 5866
#backend_weigh0      = 1
#                    # hostnameN        第N个节点IP
#                    # portN            第N个节点端口
#                    # backend_weightN  第N个节点权重比
#
#hostname1           = 192.168.80.253
#port1               = 5866
#backend_weigh1      = 1

#hostname2           = 192.168.100.175
#port2               = 5866
#backend_weigh2      = 1

[Replication]
streaming_replication_switch        = off
                                    #流复制延时开关

streaming_replication_delay_time    = 8000
                                    # 流复制延迟检测, 单位: 微秒

[DatabaseCheck]

#lifecheck_user      = postgres
#                    # 用于检测时的用户名
#
#lifecheck_dbname    = postgres
#                    # 用于检测时的数据库
#
#lifecheck_time      = 30
#                    # 连接间隔时间，取值范围 1 - 3600, 单位：秒
#
#lifecheck_num       = 3
#                    # 连续连接失败指定次数，达到该次数，节点将置为异常, 取值范围 1 - 10

[BlackList]
black_regex_token_list          =
                                # 匹配到了发往主节点

white_regex_token_list          =
                                # 匹配成功发往备节点

object_relationship_list        = /opt/hgproxy/etc/object_relationship_list.json

[SSL]
#ssl_switch                = off
#
#ssl_cert                  = /opt/HighGo4.5.6-see/hgproxy/etc/server.crt
#ssl_key                   = /opt/HighGo4.5.6-see/hgproxy/etc/server.key
#ssl_ca_cert               = /opt/HighGo4.5.6-see/hgproxy/etc/root.crt
#ssl_ca_cert_dir           = /opt/HighGo4.5.6-see/hgproxy/etc
#
#ssl_ciphers               = HIGH:MEDIUM:+3DES:!aNULL
#ssl_prefer_server_ciphers = on
#ssl_ecdh_curve            = prime256v1
#ssl_dh_params_file        =

[ETCD]
etcd_switch     = on
etcd_hostname   = 192.168.80.252
etcd_port       = 2379
etcd_key        = '/opt/etcd_data'
etcd_server     = 'http://192.168.80.252:2379'

```

/opt/hgproxy/bin/proxy_ctl init -h 192.168.80.252 -p 5866 -d postgres -U postgres -w postgres -f /opt/hgproxy/etc/proxy.conf


hgcmm2:/usr/lib64 # /opt/hgproxy/bin/proxy_ctl init -h 192.168.80.252 -p 5866 -d postgres -U postgres -w postgres -f /opt/hgproxy/etc/proxy.conf
/opt/hgproxy/bin/proxy_ctl: error while loading shared libraries: libssl.so.10: cannot open shared object file: No such file or directory
hgcmm2:/usr/lib64 # /opt/hgproxy/bin/proxy_ctl init -h 192.168.80.252 -p 5866 -d postgres -U postgres -w postgres -f /opt/hgproxy/etc/proxy.conf
/opt/hgproxy/bin/proxy_ctl: error while loading shared libraries: libcrypto.so.10: cannot open shared object file: No such file or directory

