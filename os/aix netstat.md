aix netstat 查看网卡速率

a、查看网卡速率

testterm1:/#netstat -v ent0 | grep -p "Adapter"
IBM 10/100 Mbps Ethernet PCI Adapter Specific Statistics:
------------------------------------------------
Chip Version: 25
RJ45 Port Link Status : up
Media Speed Selected: Auto negotiation
Media Speed Running: 100 Mbps Full Duplex           #当前网卡速率
Receive Pool Buffer Size: 384
Free Receive Pool Buffers: 128
No Receive Pool Buffer Errors: 0
Inter Packet Gap: 96
Adapter Restarts due to IOCTL commands: 1
Packets with Transmit collisions:
 1 collisions: 0           6 collisions: 0          11 collisions: 0
 2 collisions: 0           7 collisions: 0          12 collisions: 0
 3 collisions: 0           8 collisions: 0          13 collisions: 0
 4 collisions: 0           9 collisions: 0          14 collisions: 0
 5 collisions: 0          10 collisions: 0          15 collisions: 0
Excessive deferral errors: 0x0
b、更改网卡速率（网卡必须处于down模式）
chdev -l 'ent0' -a media_speed='100M_Full_Duplex'
注：网卡工作方式有以下几种：
10_Half_Duplex
10_Full_Duplex
100_Half_Duplex
100_Full_Duplex
1000_Half_Duplex（千兆网卡才有此选项）
1000_Full_Duplex（千兆网卡才有此选项）
Auto_Negotiation 