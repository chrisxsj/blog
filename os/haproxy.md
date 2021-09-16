# haproxy

**作者**

Chrisx

**日期**

2021-09-06

**内容**

haproxy配置使用

ref[HAProxy](https://www.haproxy.org/)

----

[TOC]

## 介绍

HAProxy是一个免费、非常快速和可靠的解决方案，为基于TCP和HTTP的应用程序提供高可用性、负载平衡和代理。
Patroni可以使用proxy，它能够为应用程序提供集群的一个单点入口

HAProxy的内置pgsql-check，和httpchk都可用来进行健康检查。

| 健康检查方式 | 优点                 | 缺点                                                             |
| ------------ | -------------------- | ---------------------------------------------------------------- |
| pgsql-check  | 无需任何额外组件       | 默认无法在HA设置中区分主备，但可配合user与pg_hba设置来实现此功能 |
| httpchk      | 可在HA设置中区分主备 | 需要配合shell脚本和xinetd                                        |

 
ref[Configure HAProxy with PostgreSQL Using Built-in pgsql-check](https://www.percona.com/blog/2019/11/08/configure-haproxy-with-postgresql-using-built-in-pgsql-check/)

ref[PostgreSQL Application Connection Failover Using HAProxy with xinetd](https://www.percona.com/blog/2019/10/31/postgresql-application-connection-failover-using-haproxy-with-xinetd/)

<!--

ref[PostgreSQL Application Connection Failover Using HAProxy with xinetd](https://www.percona.com/blog/2019/10/31/postgresql-application-connection-failover-using-haproxy-with-xinetd/)

HAProxy可能是最流行的连接路由和负载平衡软件。它与PostgreSQL一起用于不同类型的高可用性集群。HAProxy，顾名思义，可以作为TCP（第4层）和HTTP（第7层）的代理，但它还有额外的负载平衡功能。TCP代理功能允许我们将其用于PostgreSQL的数据库连接。PostgreSQL群集的连接路由有三个目标：

* 读写加载到主机
* 只读加载到从机
* 多个从机的负载平衡可以通过HAProxy实现。

HAProxy维护一个内部路由表。在本博客中，我们将了解使用PostgreSQL配置HAProxy的最传统方法。此方法独立于底层群集软件，甚至可以与传统的PostgreSQL内置复制功能一起使用，而无需任何群集或自动化解决方案。

在这个通用配置中，我们不会使用集群框架提供的任何特殊软件或功能。这要求我们有3个组成部分：

* 一个简单的shell脚本，用于检查本地计算机上运行的PostgreSQL实例的状态。
* xinetd服务守护程序。
* HAProxy：它维护路由机制。


ref[Configure HAProxy with PostgreSQL Using Built-in pgsql-check](https://www.percona.com/blog/2019/11/08/configure-haproxy-with-postgresql-using-built-in-pgsql-check/)

在上一篇关于使用Xinetd配置HAProxy的博客中，我们讨论了使用PostgreSQL配置HAProxy的传统方法之一。在这里，我们简要地提到了HAProxy的内置pgsql检查健康检查选项的局限性。它缺乏检测和区分主备用和热备用的功能。它尝试建立与数据库实例的连接，如果连接请求正在进行，则将被视为成功检查，并且没有检查当前角色（主角色或备用角色）的规定。

因此，问题仍然是：

HAProxy的内置pgsql检查是否完全无用，因为它无法在HA设置中区分主备用和热备用（接受读取的备用）？

有没有办法调整pgsql检查以便区分主备用和热备用？

这篇博文讨论了使用pgsql检查可以实现什么，以及如何实现这一点。

注意：这个博客展示了这个概念。与特定HA框架/脚本的集成留给用户，因为有大量针对PostgreSQL的HA解决方案，这些概念同样适用于他们
-->

## 安装

ref [HAProxy](https://www.haproxy.org/)，解压后，读README、INSTALL
<!--https://zhuanlan.zhihu.com/p/356921154-->

```sh
tar -xvf haproxy-2.4.3.tar.gz
cd haproxy-2.4.3
make clean
make -j $(nproc) TARGET=linux310 ARCH=x86_64 PREFIX=/opt/haproxy
make install PREFIX=/opt/haproxy

-j $(nproc) #并行进程数
TARGET=linux310 #内核版本，使用uname -r查看内核
ARCH=x86_64 #系统位数
PREFIX=/opt/haproxy #安装路径


# /opt/haproxy/sbin/haproxy -v  #查看版本
HAProxy version 2.4.3-4dd5a5a 2021/08/17 - https://haproxy.org/
Status: long-term supported branch - will stop receiving fixes around Q2 2026.
Known bugs: http://www.haproxy.org/bugs/bugs-2.4.3.html
Running on: Linux 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64


#如编译错误，建议安装对应的依赖包

yum groupinstall "Development Tools"

```

## pgsql-check

HAProxy’s built-in pgsql-check health check option.

pgsql-check 缺乏检测和区分主备用和热备用的功能。需要配合pg_hba.conf和数据库用户实现。

创建用户

```sql
create user primaryuser with password 'primaryuser';    --连接rw节点
create user standbyuser with password 'standbyuser';    --连接ro节点

```

现在，我们需要有pg_hba.conf条目，以便将对该用户的连接请求转发以进行身份验证。

```sh
host    primaryuser    primaryuser    192.168.80.0/24    md5
host    standbyuser    standbyuser    192.168.80.0/24    md5

```

请确保用户名和数据库名称保持不变。因为数据库的默认名称与user相同。这将有助于直接拒绝我们想要的连接，而不是稍后报告数据库“xyz”不存在。我们应该记住，在这个PostgreSQL集群中没有名为“primaryuser”或“standbyuser”的数据库。因此，即使我们不拒绝任何数据库，该用户也无法真正连接到任何数据库。这为整个设置增加了安全性。

```sh
pg_ctl reload #生效

```

测试

```sh
$ psql -h 192.168.80.141 -U primaryuser -d primaryuser
Password for user primaryuser:
psql: FATAL: database "primaryuser" does not exist
```

在这里，我们可以看到连接请求被转发以进行身份验证，因此它会提示输入密码，但连接最终将被拒绝，因为没有“primaryuser”这样的数据库。这对于HAProxy配置足够了。

我们需要对PostgreSQL集群的所有节点进行相同的设置，因为任何节点都可以升级到主节点或降级到备用节点。

## 配置文件/opt/haproxy/haproxy.cfg

我们将在haproxy打开两个端口进行连接。

* 用于主连接的端口5000（读写）
* 用于备用连接的端口5001（只读）

```sh
#
global
    maxconn 100
    daemon

defaults
    log global
    mode tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s

listen stats
    mode http
    bind *:7000
    stats enable
    stats uri /

listen pgReadWrite
    bind *:5000
    option pgsql-check user primaryuser
    default-server inter 3s fall 3
    server 192.168.80.141 192.168.80.141:5433 check port 5433
    server 192.168.80.142 192.168.80.142:5433 check port 5433

listen pgReadOnly
    bind *:5001
    balance roundrobin
    option pgsql-check user standbyuser
    default-server inter 3s fall 3
    server 192.168.80.141 192.168.80.141:5433 check port 5433
    server 192.168.80.142 192.168.80.142:5433 check port 5433


```

As per the above configuration, the key points to note are

* HAProxy is configured to use TCP mode
* HAProxy service will start listening to port 5000 and 5001
* Port 5000 is for Read-Write connections and 5001 is for Read-Only connections
* Status check is done using pgsql-check feature on port 5433
* Both server 141 and 142 are candidates for both Read-write and Read-only connections
* daemon（后台运行）
* balance roundrobin（负载方式）
    roundrobin，表示简单的轮询，每个服务器根据权重轮流使用，在服务器的处理时间平均分配的情况下这是最流畅和公平的算法。该算法是动态的，对于实例启动慢的服务器权重会在运行中调整。
    leastconn，表示最少连接者先处理，建议关注；leastconn建议用于长会话服务，例如LDAP、SQL、TSE等，而不适合短会话协议。如HTTP.该算法是动态的，对于实例启动慢的服务器权重会在运行中调整。

run:

```sh
$ /opt/haproxy/sbin/haproxy -f haproxy.cfg

```

**在此阶段，所有节点都将作为读写和只读连接的候选节点列出**，缺乏检测和区分主备，这不是我们想要实现的。

因此，更改pg_hba.conf设置拒绝主节点上的备用用户连接和备用服务器上的主用户连接。

```sh
$ sed -i 's/\(host\s*standbyuser\s*standbyuser.*\) md5/\1 reject/g' $PGDATA/pg_hba.conf #On Primary
$ sed -i 's/\(host\s*primaryuser\s*primaryuser.*\) md5/\1 reject/g' $PGDATA/pg_hba.conf #On Standby

pg_ctl reload   #生效
```

## 查看状态

访问监控地址

http://192.168.80.141:7000/stats    #说明：7000即haproxy配置文件中监听端口，stats 即haproxy配置文件中的监听名称

每个listen会以表格的形式呈现。

## 测试

可在当前配置HAProxy的机器（应用程序）上测试该HAProxy设置。

端口5000的连接将路由到主端口：

```sh
[pg@t1 data]$ psql -h localhost -U postgres -p 5000 -c "select pg_is_in_recovery()"
Password for user postgres:
 pg_is_in_recovery
-------------------
 f
(1 row)

```

到端口5001的连接将路由到备用端口之一

```sh
[pg@t1 data]$ psql -h localhost -U postgres -p 5001 -c "select pg_is_in_recovery()"
Password for user postgres:
 pg_is_in_recovery
-------------------
 t
(1 row)

```
