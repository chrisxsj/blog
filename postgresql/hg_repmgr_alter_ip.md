# hg_repmgr alter ip

在部署了hgdb集群版（repmgr）后，需要修改物理ip、虚拟vip及主机名的规范步骤。

> 在进行以下操作前，需要先停止使用数据库服务的应用程序服务，待修改完毕后，测试没有问题，再启动应用服务器，此外，修改了VIP还需要在应用程序配置里进行对应的据库IP地址更新。

## 修改物理IP

1. root用户连接到集群中所有的数据库服务器上，停止所有节点的数据库服务，顺序为`先备机后主机`

```shell
repmgr cluster show

systemctl stop hgdb-see-4.3.4.7.service
or
pg_ctl stop -m f
REPMGRD_PID=`ps -ef | grep repmgrd|grep -v grep |awk '{print $2}'`
kill -9 $REPMGRD_PID
```

2. root用户连接到集群中所有的数据库服务器上，分别修改物理IP地址。

3. root用户连接到集群中所有的数据库服务器上，检查hosts文件

```shell
cat /etc/hosts

```

如果里边不存在修改前的ip，则本步无需操作。否则进行相应修改。

4. root用户连接到集群中所有的数据库服务器上，检查repmgr.conf文件中是否涉及物理IP信息。

```shell
cat /opt/HighGo4.3.4.7-see/conf/hg_repmgr.conf

```

查看其中的node_name值和conninfo中的host信息。如果为主机名方式，本步无需操作。否则修改对应的IP信息。

5. root用户连接到集群中所有的备机上，检查recovery.conf文件

```shell
cat $PGDATA/recovery.conf

```

查看其中的primary_conninfo中的host信息。如果为主机名方式，本步无需操作。否则修改对应的IP信息。

6. root用户连接到集群中所有的数据库服务器上，启动数据库

```shell
pg_ctl start

```

7. root用户连接到集群中所有的数据库服务器上，重新注册。


root用户连接到集群中的主角色机器上，执行命令

```shell
repmgr primary register -F

```

root用户连接到集群中所有的备机上，执行命令

```shell
repmgr standby register -F

```

8. root用户连接到集群中所有的数据库服务器上，启动repmgrd守护进程

```shell
repmgrd -d

```

至此物理IP修改完毕。

## 修改虚拟vip

1. root用户连接到集群中所有的数据库服务器上，停止repmgrd守护进程

REPMGRD_PID=`ps -ef | grep repmgrd|grep   -v grep |awk '{print  $2}'`
kill -9 $REPMGRD_PID

2. root用户连接到集群中所有的数据库服务器上，找到virtual_ip参数并修改。

cat /opt/HighGo4.3.4.7-see/conf/hg_repmgr.conf

查看virtual_ip和network_card值，修改为新值

3. root用户连接到主角色机器上，执行命令，enp0s3注意修改为实际的network_card值。

ip addr del 192.168.0.旧/32 dev enp0s3
repmgr primary register -F

4. root用户连接到集群中所有的数据库服务器上，执行命令

repmgrd -d

至此虚拟VIP修改完毕。

## 修改主机名

举例从host1修改为rep1。

1. root用户连接到集群中所有的数据库服务器上，停止所有节点的数据库服务，顺序为`先备机后主机`

```shell
repmgr cluster show

systemctl stop hgdb-see-4.3.4.7.service
or
pg_ctl stop -m f
REPMGRD_PID=`ps -ef | grep repmgrd|grep -v grep |awk '{print $2}'`
kill -9 $REPMGRD_PID
```

2. root用户连接到集群中所有的数据库服务器上，分别修改系统主机名。

3. root用户连接到集群中所有的数据库服务器上，检查hosts文件

```shell
cat /etc/hosts

```

如果里边不存在修改前的ip，则本步无需操作。否则进行相应修改。

4. root用户连接到集群中所有的数据库服务器上，检查repmgr.conf文件中是否涉及主机名信息。

```shell
cat /opt/HighGo4.3.4.7-see/conf/hg_repmgr.conf

```

查看其中的node_name值和conninfo中的host信息。如果为ip方式，本步无需操作。否则修改对应的主机名。

5. root用户连接到集群中所有的备机上，检查recovery.conf文件

```shell
cat $PGDATA/recovery.conf

```

查看其中的primary_conninfo中的host信息。如果为IP方式，本步无需操作。否则修改对应的主机名。

6. root用户连接到集群中所有的数据库服务器上，启动数据库

```shell
pg_ctl start

```

7. root用户连接到集群中所有的数据库服务器上，重新注册。


root用户连接到集群中的主角色机器上，执行命令

```shell
repmgr primary register -F

```

root用户连接到集群中所有的备机上，执行命令

```shell
repmgr standby register -F

```

8. root用户连接到集群中所有的数据库服务器上，启动repmgrd守护进程

```shell
repmgrd -d

```

至此物理IP修改完毕。