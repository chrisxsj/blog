Linux  netword bond

配置物理网卡
 
[root@dgo ~]# cat /etc/sysconfig/network-scripts/ifcfg-p1p1
DEVICE=p1p1
HWADDR=B4:96:91:54:86:38
TYPE=Ethernet
UUID=08bd847f-8cd5-49a1-83c4-a46ac3e303b3
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
 
 
 
[root@dgo ~]# cat /etc/sysconfig/network-scripts/ifcfg-p1p2
DEVICE=p1p2
HWADDR=B4:96:91:54:86:3A
TYPE=Ethernet
UUID=4ebaa850-4d3c-4e95-a154-24d3aefe53f5
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
 
 
配置逻辑网卡bond0
  
[root@dgo ~]# cat /etc/sysconfig/network-scripts/ifcfg-bond0  //需要我们手工创建
DEVICE=bond0
#HWADDR=B4:96:91:54:86:38
TYPE=Ethernet
#UUID=08bd847f-8cd5-49a1-83c4-a46ac3e303b3
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=none
IPADDR=172.17.200.251
NETMASK=255.255.255.0
GATEWAY=172.17.200.254
[root@dgo ~]#
 
 
Or
DEVICE=bond0
#HWADDR=6C:92:BF:2D:6B:0A
TYPE=Ethernet
#UUID=7961fad0-6e73-437b-9377-f0b028e971a3
ONBOOT=yes
#NM_CONTROLLED=yes
BOOTPROTO=none
IPADDR=212.7.8.3
NETMASK=255.255.255.0
GATEWAY=212.7.8.254
BONDING_OPTS="mode=1 miimon=100"
 
 
#加载模块，让系统支持bonding
#
#[root@lixin ~]# cat /etc/modprobe.d/modprobe.conf  //不存在的话，手动创建（也可以放在modprobe.d下面）
alias bond0 bonding
options bond0 miimon=100 mode=1
#[root@lixin ~]#
#配置bond0的链路检查时间为100ms，模式为1。
 
#bond的模式常用的有两种：
#  mode=0（balance-rr）
#    表示负载分担round-robin，并且是轮询的方式比如第一个包走eth0，第二个包走eth1，直到数据包发送完毕。
#    优点：流量提高一倍
#    缺点：需要接入交换机做端口聚合，否则可能无法使用
#  mode=1（active-backup）
#    表示主备模式，即同时只有1块网卡在工作。
#    优点：冗余性高
#    缺点：链路利用率低，两块网卡只有1块在工作
#
#加载bond module
#[root@lixin etc]# modprobe bonding
#
 
**重启生效**
 
查看绑定结果
[root@dgo ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
 
Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: p1p1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
 
Slave Interface: p1p1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: b4:96:91:54:86:38
Slave queue ID: 0
 
Slave Interface: p1p2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: b4:96:91:54:86:3a
Slave queue ID: 0
[root@dgo ~]#