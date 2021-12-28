# docker pg

**作者**

chrisx

**时间**

2021-04-20

**内容**

安装pg使用docker

ref [docker_postgres](https://hub.docker.com/_/postgres)

---

[toc]

## 运行pg

```sh
docker run --name pg13.2 --net subnet -v /opt/docker/postgres13.2:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres --ip 192.168.6.21 -p 5532:5432 -d postgres:13.2

docker run --name pg129 --user "$(id -u):$(id -g)" -v /opt/pg129:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -p 5434:5432 -d postgres:12.9

docker run --name pg141 --user "$(id -u):$(id -g)" -v /opt/pg141:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -p 5433:5432 -d postgres:14.1

```

:warning: 注意，如果没有配置subnet，需要去掉参数--net subnet和--ip
:warning: --user "$(id -u):$(id -g)"指定外挂目录的权限

## 查看卷信息

```sh
docker volume ls


```

## 进入镜像

```sh
docker exec -it pg141 bash

```

## pgadmin

```sh
docker pull dpage/pgadmin4  #拉取镜像
docker run --name pgadmin4 -e SERVER_MODE=true -e PGADMIN_DEFAULT_EMAIL=pgadmin@mail.com -e PGADMIN_DEFAULT_PASSWORD=pgadmin -d -p 5480:80 dpage/pgadmin4   #运行
http://localhost:5480  #使用

```

## 远程连接docker中的pg

1. 使用本机ip连接

使用本机ip和映射的hostport

```sh
psql -h localhost -U postgres -d postgres -p 5434

```

2. 使用docker ip连接

使用docker中的ip和端口连接

```sh
sudo docker inspect pg129 |grep IP  #查询docker中的ip
sudo docker inspect pg129 |grep tcp #查询docker中的端口

psql -h 172.18.0.2 -p 5432 -U postgres  #连接

```
