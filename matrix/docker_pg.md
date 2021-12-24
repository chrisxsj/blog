# docker pg

**作者**

chrisx

**时间**

2021-04-20

**内容**

docker中使用pg

---

[toc]

## 运行

```sh
docker run --name pg13.2 --net subnet -v /opt/docker/postgres13.2:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres --ip 192.168.6.21 -p 5532:5432 -d postgres:13.2

docker run --name pg129 -v /opt/p129:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -p 15434:5434 -d postgres:12.9

docker run --name pg141 -v /opt/pg141:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -p 15433:5433 -d postgres:14.1

```

:warninig: 注意，如果没有配置subnet，需要去掉参数--net subnet和--ip

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
docker run --name pgadmin4 -e SERVER_MODE=true -e PGADMIN_DEFAULT_EMAIL=pgadmin@mail.com -e PGADMIN_DEFAULT_PASSWORD=pgadmin -d -p 10080:80 dpage/pgadmin4   #运行
http://localhost:10080  #使用

```

## 远程连接docker中的pg

1. 使用本机ip连接

使用本机ip和映射的hostport

pg126@hg-cx:~$ psql -h 127.0.0.1 -p 5532 -U postgres
psql (12.6, server 13.2 (Debian 13.2-1.pgdg100+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

2. 使用docker ip连接

使用docker中的ip和端口连接

查询docker中的ip和端口

sudo docker inspect postgres10.16 |grep IP
sudo docker inspect postgres10.16 |grep tcp

连接
pg126@hg-cx:~$ psql -h 172.17.0.2 -p 5432 -U postgres
psql (12.6, server 13.2 (Debian 13.2-1.pgdg100+1))
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.
