# hghac

**作者**

chrisx

**日期**

2021-09-17

**内容**

hahac常用操作命令

----

[toc]

## 查看日志

```sh
cat /opt/HighGo/tools/hghac/hghac-see.yaml |grep dir
tail -f  /highgo/patroni.log

```

## 重做备库

```sh
# 确认主库正常
psql -U sysdba -c 'checkpoint'
# 备库执行
systemctl stop hgproxy.service
systemctl stop hghac.service
ps -ef |grep hac    #如有进程，kill（不包括etcd进程）
ps -ef |grep post   #如有进程，kill
mv /opt/HighGo456-see/data /opt/HighGo456-see/data.bak
systemctl start hghac.service
systemctl start hgproxy.service

```

## 查看集群状态

```sh
/opt/HighGo456-see/tools/hghac/etcd/etcdctl  --endpoints=http://10.121.32.110:2379,http://10.121.32.111:2379,http://10.121.32.113:2379 endpoint status --write-out=table    #etcd

/opt/HighGo456-see/tools/hghac/hghactl/hghactl list #patroni

psql -U sysdba -c 'select * from pg_stat_replication'   #110

```
