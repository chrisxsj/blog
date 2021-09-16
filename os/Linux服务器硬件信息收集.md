Linux服务器硬件信息收集:
uname -a
cat /proc/cpuinfo
cat /porc/meminfo
lscpu
dmidecode -t 16         --->查看Linux的最大可用内存(服务器主板最多能支持多少内存)
ethtool ethX            --->X请自行替换.用于查看网卡的网速(百M,千M,万M等等)
dmidecode -s system-manufacturer   --->服务器生产商(比如inspur)
dmidecode -s system-product-name   --->服务器型号(比如inspur的TS860G3)
dmidecode -s system-serial-number  --->服务器主机的序列号(贴在服务器主机机身上)