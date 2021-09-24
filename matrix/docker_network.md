# docker network

**作者**

chrisx

**时间**

2021-04-23

**内容**

docker中使用配置桥接网络
docker固定ip地址

---

[toc]

如何在docker中设置容器的固定ip地址，而且重启容器后，ip地址不变，有什么方法呢？

利用docker网络模式中的桥接模式，但是不要利用docker自动生成的虚拟网桥，自己创建一个虚拟网桥即可。

## 指定网络类型

Docker安装后，默认会创建下面三种网络类型bridge、host、null

```sh
$ docker network ls
NETWORK ID     NAME        DRIVER       SCOPE
9781b1f585ae    bridge       bridge       local
1252da701e55    host        host        local
237ea3d5cfbf    none        null        local
```

启动 Docker的时候，用 --network 参数，可以指定网络类型

```sh
docker run -itd --name test1 --network bridge --ip 172.17.0.10 centos:latest /bin/bash

```

## 桥接网络

docker网络类型如下

* bridge：桥接网络

默认情况下启动的Docker容器，都是使用 bridge，Docker安装时创建的桥接网络，每次Docker容器重启时，会按照顺序获取对应的IP地址，这个就导致重启下，Docker的IP地址就变了

* none：无指定网络

使用 --network=none ，docker 容器就不会分配局域网的IP

* host： 主机网络

使用 --network=host，此时，Docker 容器的网络会附属在主机上，两者是互通
例如，在容器中运行一个Web服务，监听8080端口，则主机的8080端口就会自动映射到容器中

* 自定义

## 自定义桥接模式

创建自定义网络（设置固定IP）

1. 创建自定义网络

```sh
docker network create --subnet=192.168.80.0/24 --gateway=192.168.80.254 subnet

docker network ls
NETWORK ID     NAME        DRIVER       SCOPE
9781b1f585ae    bridge       bridge       local
1252da701e55    host        host        local
4f11ae9c85de    mynetwork      bridge       local
237ea3d5cfbf    none        null        local

```

2. 创建Docker容器

如下两个示例

```sh
docker run --name centos7.9 --net subnet --ip 192.168.80.41 -p 22:22 -itd centos:7.9.2009 /bin/bash

docker run --name  postgres13.2 --net subnet -v /opt/docker/postgres13.2:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres --ip 192.168.80.31 -p 5532:5432 -d postgres:13.2

```

## 自定义macvlan

一些应用程序，特别是遗留应用程序或监控网络流量的应用程序，希望直接连接到物理网络。在这种情况下，您可以使用macvlan网络驱动程序为每个容器的虚拟网络接口分配一个MAC地址，使其看起来像是直接连接到物理网络的物理网络接口。

```sh
docker network create -d macvlan --subnet=192.168.8.0/24 --gateway=192.168.8.254 -o parent=eth0 mvnet

docker run --name=test -itd --net mvnet centos:7.9.2009 /bin/bash
docker exec test ip addr show eth0
docker exec -it test /bin/bash

```

> 在宿主机内部可以使用192.168.80.31:5432连接数据库
