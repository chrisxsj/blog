# docker pg

docker run --name postgres13.2 --net subnet -v /opt/docker/postgres13.2:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres --ip 192.168.6.21 -p 5532:5432 -d postgres:13.2

docker run --name postgres12.6 --net subnet -v /opt/docker/postgres12.6:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres --ip 192.168.6.22 -p 5533:5432 -d postgres:12.6

docker run --name postgres10.16 --net subnet -v /opt/docker/postgres10.16:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres --ip 192.168.6.23 -p 5534:5432 -d postgres:10.16

> 注意，如果没有配置subnet，需要去掉参数--net subnet和--ip

## 进入镜像

docker exec -it postgres10.16 bash

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
