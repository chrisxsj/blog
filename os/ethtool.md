# ethtool

**作者**

Chrisx

**日期**

2021-05-12

**内容**

ethtool查询修改网卡驱动信息（速率等）

----

[toc]

## 介绍

NAME
       ethtool - query or control network driver and hardware settings

其他平台类似的工具

solaris # ndd /dev/NICNAME link_speed
Linux # ethtool NICNAME|grep Speed
AIX # entstat -d NICNAME |grep Speed
HPUX # lanadmin -s CARDNumber

## 查看网卡信息

```sh
# ethtool enp2s0
Settings for enp2s0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised pause frame use: Symmetric Receive-only
        Advertised auto-negotiation: Yes
        Speed: 10Mb/s
        Duplex: Half
        Port: MII
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000033 (51)
                               drv probe ifdown ifup
        Link detected: no

```

一些信息解释

Duplex: Half   #工作模式，全双工、半双工
Speed: 10Mb/s  #网络速率
Link detected: no #是否连接网线

## 修改网卡信息

```sh
ethtool -s enp2s0 speed 1000  #修改速率1000Mb/s
ethtool -s enp2s0 duplex full #修改为全双工
```