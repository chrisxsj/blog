# docker_add_port

**作者**

chrisx

**时间**

2021-05-24

**内容**

docker添加端口号

---

[toc]

## 问题描述

最近在使用docker，返现一个问题。建立完一个容器后，需要增加端口映射。因为创建容器时不会完美考虑到所有端口的使用。但是docker不支持增加端口映射，因为 docker run -p 有 -p 参数，但是 docker start 没有 -p 参数，

## 解决方案

1. 构建新镜像

是将原来的容器提交成镜像，然后利用新的建立的镜像重新建立一个带有端口映射的容器，不推荐这种办法

ref [docker_commit](./docker_commit.md)

2. 改容器配置文件

配置文件有两个

```sh
/var/lib/docker/containers/[hash_of_the_container]/hostconfig.json
/var/lib/docker/containers/[hash_of_the_container]/config.v2.json
```

:warning: hash_of_the_container可以通过docker inspect查看（id）

hostconfig.json 里有 "PortBindings":{} 这个配置项，在这个配置项中增加、修改端口映射

```sh
"PortBindings":{"22/tcp":[{"HostIp":"192.168.6.11","HostPort":"1022"}],"5433/tcp":[{"HostIp":"","HostPort":"5433"}]}
```

* 22/tcp 是容器端口
* [{"HostIp":"","HostPort":"1022"}] 是主机映射ip和端口

config.v2.json 里面添加一个配置项 "ExposedPorts":{} , 将这个配置项添加到 "Tty": true, 前面，

```sh
"ExposedPorts":{"22/tcp":{},"5433/tcp":{}}
```

:warning: 修改前，先停止container

3. 重启 docker的守护进程

```sh
service docker restart
```

<!--
这里有个问题就是重启后 用docker ps -a 是看不到端口映射的，但实际已经映射好了，我正常在新建一个带有端口映射容器的时候，重启 docker的守护进程，端口映射也不会显示出来，但是通过docker inspect 容器名 可以看到配置项已经修改成功了。
-->
