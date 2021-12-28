# docker_container

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

[root@4bfa7c40f62e /]# systemctl status
Failed to get D-Bus connection: Operation not permitted

如果要是用systemctl 管理服务就要加上参数 --privileged 来增加权，并且不能使用默认的bash，换成 init，命令如下

docker run --name d11 --privileged=true --net subnet --ip 192.168.8.11 -p 1022:22 -p 15432:5432 -itd centos:7.9.2009 /usr/sbin/init

docker run --name d12 --privileged=true --net subnet --ip 192.168.8.12 -p 2022:22 -p 25432:5432 -itd centos:7.9.2009 /usr/sbin/init

```

## 进入容器

```sh
docker exec -it c79 /bin/bash

```

## 镜像修改tag

```sh

$ sudo docker image ls
REPOSITORY   TAG        IMAGE ID       CREATED         SIZE
<none>       <none>     e96425946916   9 minutes ago   719MB
centos       7.9.2009   eeb6ee3f44bd   10 days ago     204MB

sudo docker tag e96425946916 c79d11:20210926
```

## 将普通用户加入docker组

```sh
usermod -a -G docker cx

```

## 问题

Permission issue with PostgreSQL in docker container

docker外挂目录，自动被修改为systemd-coredump

```sh
drwx------ 19 systemd-coredump chrisx 4096 12月 28 10:53 pg129/
```

解决方案

修改配置文件

/var/lib/docker/containers/[hash_of_the_container]/hostconfig.json

