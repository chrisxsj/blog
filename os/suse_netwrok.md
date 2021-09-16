# suse_network

**作者**

chrisx

**日期**

2020-07-23

**内容**

SUSE12的网络及路由配置

---

[toc]

## 网络配置

在目录/etc/sysconfig/network/中需要关注三个文件

ifcfg-eth* ：配置网络地址
ifroute-eth* ：定义每个接口的路由
routes：指定各种系统任务所需的所有静态路由

```sh
linux-ndlx:~ # cat /etc/sysconfig/network/ifcfg-eth0
#BOOTPROTO='dhcp'
BOOTPROTO='static'      # 网络模式：dhcp（自动获取）、static（静态)
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR='192.168.80.141' # IP地址
MTU=''
NAME=''
NETMASK='255.255.255.0'
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'        # 开机自启
DHCLIENT_SET_DEFAULT_ROUTE='yes'
linux-ndlx:~ #

```

## 网关配置

```sh
# vi /etc/sysconfig/network/ifroute-eth0    # 这个文件需要自己创建

default 192.168.80.254 - eth0
#default 192.168.80.254 - -

```

## 设置DNS

```sh

cat /etc/resolv.conf

nameserver=8.8.8.8
```

重启网络

```sh
#service network restart
```

<!--
## hostname

# 之所以提到hostname，是因为最近使用的时候，因为是自己测试使用，没有配置静态ip，导致机器重启，hostname变了，强迫症不喜欢，百度了好多，都是修改hosts文件，就自己尝试了修改dhcp配置文件后，得到了解决，因此更新一下
# 静态IP
suse-linux:~ # hostnamectl set-hostname suse-linux --static
# dhcp IP   // dhcp获取的ip，当机器重启的时候，hostname会变成bogon，导致修改的hostname会不生效，但是/etc/HOSTNAME文件中，hostname依旧是设置的hostname，有以下解决方法
suse-linux:~ # vim /etc/sysconfig/network/dhcp
DHCLIENT_HOSTNAME_OPTION=""    # 默认是AUTO，会影响hostname
-->

## 参考命令

```sh
ip route show  #查看路由信息
netstat -r # 可查看网关地址
route
route add default 10.150.36.1 dev eth0 #临时配置默认网关地址
rcnetwork restart #重启网络服务

```
