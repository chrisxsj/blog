# Configuring NTP Using ntpd

**作者**

chrisx

**日期**

2021-04-02

**内容**

Configuring NTP Using ntpd
REDHAT 7.x ref [Configuring NTP Using ntpd](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_ntpd)

----

[TOC]

## 停止chronyd

为了使用ntpd，必须停止并禁用默认的用户空间守护进程chronyd

```shell
systemctl stop chronyd
systemctl disable chronyd
systemctl status chronyd

```

## 安装NPT

主从节点都安装

```shell
yum install ntp
systemctl enable ntpd
systemctl start ntpd
systemctl status ntpd


[root@db ~]# ntpstat
unsynchronised
  time server re-starting
   polling server every 8 s
```

## 停止firewalld

ref [friewall](./firewall.md)

## Configure NTP

ntp.conf配置如下

```bash
restrict 192.168.6.0 mask 255.255.255.0 nomodify notrap     #限制，允许网段连接ntp服务器
server 127.127.1.0  #设置本机作为内部时钟数据
fudge  127.127.1.0 stratum 10

# 以下信息注释掉

#server 0.rhel.pool.ntp.org iburst
#server 1.rhel.pool.ntp.org iburst
#server 2.rhel.pool.ntp.org iburst
#server 3.rhel.pool.ntp.org iburst
```

状态查看

```bash
[root@db ~]# ntpstat
synchronised to local net (127.127.1.0) at stratum 11
   time correct to within 7948 ms
   polling server every 64 s
[root@db ~]#


[root@db ~]# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*LOCAL(0)        .LOCL.          10 l   32   64    1    0.000    0.000   0.000
[root@db ~]#

```

## configure client

Ntp.conf

```bash

#restrict 192.168.6.0 mask 255.255.255.0 nomodify notrap     #限制，允许网段连接ntp服务器
server 192.168.6.141  #设置本机作为内部时钟数据

# 以下信息注释掉

#server 0.rhel.pool.ntp.org iburst
#server 1.rhel.pool.ntp.org iburst
#server 2.rhel.pool.ntp.org iburst
#server 3.rhel.pool.ntp.org iburst
```

> 注意，注释掉server0-5

查看状态

```bash
[root@db2 ~]# ntpstat
synchronised to NTP server (192.168.6.141) at stratum 12
   time correct to within 1392 ms
   polling server every 64 s

[root@db2 ~]# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*192.168.6.141   LOCAL(0)        11 u   32   64  377    0.217    0.020   0.045

```

备库可先手动同步一次时间，手动同步时需要关闭ntp服务

```bash
主库
systemctl start ntpd
备库
systemctl stop ntpd
ntpdate 192.168.6.15

```

## 问题

如果不同步，可能是防火墙阻止了端口访问

开通ntpd端口

firewall-cmd --add-port=123/udp --permanent
firewall-cmd --reload
firewall-cmd --list-ports

<!--
# How to setup a NTP server which can synchorize with an Internet time source and provide time service for internal servers?

 SOLUTION UNVERIFIED - 已更新 2014年八月21日04:34 - 
English
环境
*
Red Hat Enterprise Linux 3,4,5,6


问题
I need to setup a NTP server that synchronises with an internet time source, and, at the same time provides time services for my intranet servers. How can this be achieved?
决议
	* 
For example, I have a ntp server with the external ip address 10.66.129.30 and internal ip address 192.168.10.10.
	* 
In the example configuration shown, the ntpd service will be configured to allow hosts within IP subnets (192.168.10.0/255.255.255.0) to use this server as an NTP server. Queries from all other hosts except localhost (127.0.0.1) will not be accepted, and only the servers named with server statements will be trusted as stable time sources we synchronize to.


NTP server
	* 
The example /etc/ntp.conf is shown below. Please see kbase article How do I configure the ntpd service in Red Hat Enterprise Linux to function as an NTP time server for a network of NTP clients? for more details.


Raw

    # egrep -v "^#|^$" /etc/ntp.conf
    restrict default kod nomodify notrap nopeer noquery
    restrict 127.0.0.1
    driftfile /var/lib/ntp/drift
    keys /etc/ntp/keys
    restrict clock.util.phx2.redhat.com mask 255.255.255.255 nomodify notrap noquery
    restrict 192.168.10.0 mask 255.255.255.0 nomodify notrap
    server clock.util.phx2.redhat.com
    server 127.127.1.0
    fudge  127.127.1.0 stratum 10
	* 
After editing the /etc/ntp.conf restart the ntp service to make the changes active:


Raw
# service ntpd restart
	* 
Then, after a few minutes, check that the ntp server is trusted (as shown by the asterisk):


Raw

    # ntpq -p
         remote           refid      st t when poll reach   delay   offset  jitter
    ==============================================================================
    *clock.util.phx2 .CDMA.           1 u   36   64  377  271.580  -15.879   2.112
     LOCAL(0)        .LOCL.          10 l   32   64  377    0.000    0.000   0.001
NTP Client
	* 
On the ntp client, run "system-config-time" and specify 192.168.10.10 as ntp server. Below are the relevant lines of the configuration file:


Raw

    restrict 127.0.0.1
    restrict -6 ::1
    server 192.168.10.10
    restrict 192.168.10.10 mask 255.255.255.255 nomodify notrap noquery
	* 
Then restarting the ntpd service on the client, and run ntpq -p, and check that client is syncing with the server:


Raw

    # ntpq -p
         remote           refid      st t when poll reach   delay   offset  jitter
    ==============================================================================
     LOCAL(0)        .LOCL.          10 l   54   64  377    0.000    0.000   0.001
    *192.168.10.10   10.5.26.10       2 u   48   64  377    0.129   -1.733   0.468
 
From <https://access.redhat.com/solutions/39816>
-->
