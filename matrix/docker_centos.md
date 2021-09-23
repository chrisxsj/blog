# docker_centos

**作者**

chrisx

**时间**

2021-04-20

**内容**

docker中使用centos

---

[toc]

## 镜像

[centos镜像库](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)

```sh
sudo docker search centos #查找需要的镜像
sudo docker pull centos:centos7.9.2009  #拉取镜像,具体镜像参考镜像库
```

## 运行容器

```sh
docker run --name=c79 -p 1022:22 -itd centos:7.9.2009 /bin/bash

or

docker run --name c79 --privileged=true --net subnet --ip 192.168.80.41 -p 1022:22 -itd centos:7.9.2009 /usr/sbin/init

```

## 进入容器

```sh
docker exec -it c79 /bin/bash

```

## 问题

```sh
[root@4bfa7c40f62e /]# systemctl status
Failed to get D-Bus connection: Operation not permitted

```

如果要是用systemctl 管理服务就要加上参数 --privileged 来增加权，并且不能使用默认的bash，换成 init，命令如下

```sh
docker run --name t11 --privileged=true --net subnet --ip 192.168.6.11 -p 1022:22 -itd centos:7.9.2009 /usr/sbin/init

docker run --name t12 --privileged=true --net subnet --ip 192.168.6.12 -p 1023:22 -itd centos:7.9.2009 /usr/sbin/init

docker run --name t11 --privileged=true --net subnet --ip 192.168.6.11 -p 1022:22 -p 6966:5966 -itd centos7.9-hgdb:20210422 /usr/sbin/init
docker run --name t12 --privileged=true --net subnet --ip 192.168.6.12 -p 1023:22 -p 6967:5966 -itd centos7.9-hgdb:20210422 /usr/sbin/init

```
