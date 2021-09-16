# route


**作者**

Chrisx

**日期**

2021-09-10

**内容**

ubuntu添加路由

----

[toc]

## 路由查看

```sh
chris@hg-cx:/mnt/c/Users/chris$ route -n    #查看路由
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.24.240.1    0.0.0.0         UG    0      0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
172.24.240.0    0.0.0.0         255.255.240.0   U     0      0        0 eth0
192.168.6.0     0.0.0.0         255.255.255.0   U     0      0        0 br-819cca1a6d60
192.168.8.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
192.168.80.0    172.24.240.1    255.255.255.0   UG    0      0        0 eth0
192.168.80.0    0.0.0.0         255.255.255.0   U     0      0        0 br-2ab12e2b2cbf
chris@hg-cx:/mnt/c/Users/chris$

```

## 路由添加删除

```sh
sudo route add -net 192.168.80.0/24 gw 172.24.240.1 dev br-2ab12e2b2cbf   #添加路由，192.168.80.0网段的默认网关为192.168.80.254
sudo route del -net 192.168.80.0/24 gw 172.24.240.1 dev eth0  #删除路由

sudo route del -net 192.168.80.0/24 gw 192.168.80.254 dev br-2ab12e2b2cbf
```