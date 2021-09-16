# DBA必须要学会的9个Linux网络命令

## 1、ethtool

Ethtool是用于查询及设置网卡参数的命令，用得最多的，莫过于查看网卡的速度，如百兆、千兆、万兆。
常用用法：
（1）ethtool enp0s3--enp0s3是一号网卡，实际应用时根据自己的网卡编号进行修改。查看网卡的支持信息与运行速率信息
```bash
$ ethtool enp0s3
Settings for enp0s3:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Supported FEC modes: Not reported
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Advertised FEC modes: Not reported
	Speed: 1000Mb/s --网卡速率
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: off (auto)
Cannot get wake-on-lan settings: Operation not permitted
	Current message level: 0x00000007 (7)
			       drv probe link
	Link detected: yes
```

（2）ethtool –I eth0 --查看网卡的驱动版本与固件版本信息
```bash
$ ethtool -i enp0s3
driver: e1000
version: 7.3.21-k8-NAPI --驱动版本
firmware-version: --固件版本
expansion-rom-version:
bus-info: 0000:00:03.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
```

## netstat

Netstat是控制台命令,是一个监控TCP/IP网络的运行情况的工具，它可以显示路由表、实际的网络连接以及每一个网络接口设备的状态信息。包括IP、TCP、UDP和ICMP协议相关的统计数据，一般用于检验本机各端口的网络连接情况
常用用法：
（1）netstat –r --查看路由表信息
```bash
$ netstat -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
default         gateway         0.0.0.0         UG        0 0          0 enp0s3
192.168.6.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
192.168.122.0   0.0.0.0         255.255.255.0   U         0 0          0 virbr0
```

（2）netstat–i  --显示网络接口信息

```bahs
$ netstat -i
Kernel Interface table
Iface             MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
enp0s3           1500      252      0      0 0           178      0      0      0 BMRU
lo              65536      114      0      0 0           114      0      0      0 LRU
virbr0           1500        0      0      0 0             0      0      0      0 BMU
```

（3）netstat–ie --显示网络接口的详细信息，与ifconfig命令输出的结果安全相同

```bash
$ netstat -ie
Kernel Interface table
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.6.11  netmask 255.255.255.0  broadcast 192.168.6.255
        inet6 fe80::e4c9:29fb:6751:923f  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:43:51:0f  txqueuelen 1000  (Ethernet)
        RX packets 264  bytes 21968 (21.4 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 184  bytes 27069 (26.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 114  bytes 8672 (8.4 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 114  bytes 8672 (8.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:4e:89:ff  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

（4）netstat -nat --查看服务器的某个端口有哪些机器在连接，以及连接的数量

```bash
$ netstat -ant |grep 5866
tcp        0      0 127.0.0.1:5866          0.0.0.0:*               LISTEN
tcp6       0      0 ::1:5866                :::*                    LISTEN
```

（5）netstat–an |grep 5866 --列出指定端口所运行的程序，以及有哪些IP在连接该端口（即指定端口被谁占用，哪些本地或远程IP在连接它）

```bash
$ netstat -an |grep 5866
tcp        0      0 127.0.0.1:5866          0.0.0.0:*               LISTEN     
tcp6       0      0 ::1:5866                :::*                    LISTEN     
unix  2      [ ACC ]     STREAM     LISTENING     43064    /tmp/.s.PGSQL.5866
```

（6）netstat -nat | grep "5866" |awk '{print $5}'|awk -F: '{print$1}'|sort|uniq -c|sort -nr|head -20  --统计连接特定端口最多的远程或本地的IP地址及数量

## ifconfig

ifconfig是用来显示与配置内核的网络接口。它是在启动时使用的，在必要时设置接口。

## ss
ss命令用于显示socket状态。他可以显示PACKET sockets, TCP sockets,UDP sockets, DCCP sockets, RAW sockets, Unix domain sockets等等统计。它比其他工具展示等多tcp和state信息. 它是一个非常实用、快速、有效的跟踪IP连接和sockets的新工具。
常用用法：
（1）ss

```bash
$ ss |head -n 5
Netid  State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
u_str  ESTAB      0      0       * 25179                 * 25180                
u_str  ESTAB      0      4608   @/tmp/.X11-unix/X0 24924                 * 24923                
u_str  ESTAB      0      0      /run/dbus/system_bus_socket 18401                 * 18400                
u_str  ESTAB      0      0      /run/systemd/journal/stdout 26963                 * 26961  
```

（2）ss -V  --输出ss版本信息

```bash
$ ss -V
ss utility, iproute2-ss170501

```

（3）ss –s  --显示当前SOCKET的详细信息

```bash
$ ss -s
Total: 613 (kernel 0)
TCP:   15 (estab 1, closed 1, orphaned 0, synrecv 0, timewait 0/0), ports 0

Transport Total     IP        IPv6
*	  0         -         -        
RAW	  1         0         1        
UDP	  9         6         3        
TCP	  14        8         6        
INET	  24        14        10       
FRAG	  0         0         0        
```

## 6 traceroute
路由跟踪，在网络故障时，定位出在哪一个路由或网络上很重要
常用用法：
（1）traceroute IP

```bash
$ traceroute 192.168.6.11
traceroute to 192.168.6.11 (192.168.6.11), 30 hops max, 60 byte packets
 1  hgdb1 (192.168.6.11)  0.077 ms  0.025 ms  0.018 ms

```

## 7 nslookup
nslookup是用来通过解析IP地址与域名的对应关系的命令。
常用用法：

```bash
$ nslookup www.163.com
名称:    163.xdwscache.glb0.lxdns.com
Address:  122.191.127.8
Aliases:  www.163.com
www.163.com.lxdns.com
```

## 8 ifup
网络接口启动命令
常用用法：启动处于关闭状态的网络接口

```bash
# ifup eth0
```

## 9 ifdown
网络接口关闭命令
常用用法：关闭处于启动状态的网络接口

```bash
ifdown eth0
```