# greenplum troubleshooting


## select hang

error 
```sql
INSERT INTO test_t1 SELECT generate_series(1,1000); --hang



hgdw=# select * from test_t1;  --hang
WARNING:  interconnect may encountered a network error, please check your network  (seg0 slice1 172.17.105.141:6000 pid=10906)
DETAIL:  Failed to send packet (seq 1) to 172.17.105.139:62006 (pid 30435 cid -1) after 100 retries.
WARNING:  interconnect may encountered a network error, please check your network  (seg3 slice1 172.17.105.144:6000 pid=10678)
DETAIL:  Failed to send packet (seq 1) to 172.17.105.139:62006 (pid 30435 cid -1) after 100 retries.
WARNING:  interconnect may encountered a network error, please check your network  (seg1 slice1 172.17.105.142:6000 pid=10723)
DETAIL:  Failed to send packet (seq 1) to 172.17.105.139:62006 (pid 30435 cid -1) after 100 retries.
WARNING:  interconnect may encountered a network error, please check your network  (seg2 slice1 172.17.105.143:6000 pid=10708)
DETAIL:  Failed to send packet (seq 1) to 172.17.105.139:62006 (pid 30435 cid -1) after 100 retries.
```
solution

```bash
[root@hgdw1 ~]# netstat -tunlpa|grep postgre
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      29006/postgres      
tcp6       0      0 :::5432                 :::*                    LISTEN      29006/postgres      
udp6       0      0 :::54319                :::*                                29015/postgres:  54 
udp6       0      0 :::56770                :::*                                29015/postgres:  54 
udp6       0      0 :::62006                :::*                                30435/postgres:  54 
udp6       0      0 :::36187                :::*                                30435/postgres:  54 
[root@hgdw1 ~]# 


https://segmentfault.com/q/1010000007862841/

解决方案：

a) 切换到TCP，不再使用udpifc: 将GUC参数gp_interconnect_type设置为tcp即可。如果集群过大或者并发较多，可能会有扩展性问题。
b) 确定 UDP 丢包的原因，可以使用tcpdump/nc等工具定位问题，解决网络问题。

Linux操作系统检测TCP/UDP端口连通性的简单方法
TCP端口测试

使用 telnet 测试现有监听端口连通性
telnet <host> <port>
telnet 127.0.0.1 22

UDP端口测试
telnet 仅能用于 TCP 协议的端口测试，若要对UDP端口进行测试，可以使用 nc 程序。
用法：
nc -vuz <目标服务器 IP> <待测试端口>
示例输出：
[root@centos]# nc -vuz 192.168.0.1 25
Connection to 192.168.0.1 25 port [udp/smtp] succeeded!

c) 使用GPDB的稳定版本，不要使用开源版本，开源版本的GPDB正在为第一个稳定版 5.0 release 奋斗，现在还不稳定。 稳定版GPDB 4.3.xx 可以从Pivotal官方下载。

https://www.oschina.net/question/3955174_2289746




master
vi postgresql.conf


[hgadmin@hgdw1 gpseg-1]$ gpconfig -s gp_interconnect_type
Values on all segments are consistent
GUC          : gp_interconnect_type
Master  value: tcp
Segment value: tcp


Segment value: tcp????--no

解决方法，参数设置：
查看参数gp_interconnect_type：

gpconfig -s gp_interconnect_type
修改参数为TCP：

gpconfig -c gp_interconnect_type -v TCP
然后重启PG
```

## [ERROR]: Failed to ssh to hgdw2. No ECDSA host key is known for hgdw2 and you have requested strict checking.

error
```bash
Host key verification failed
[root@hgdw1 software]# hgssh-exkeys -f  /home/hgadmin/hostfile_exkeys
[ERROR]: Failed to ssh to hgdw2. No ECDSA host key is known for hgdw2 and you have requested strict checking.
Host key verification failed.

[ERROR]: Expected passwordless ssh to host hgdw2
[root@hgdw1 software]# 

[root@hgdw1 software]# hgssh-exkeys -f  /home/hgadmin/hostfile_exkeys
[ERROR]: Failed to ssh to hgdw2. Permission denied (publickey,password).

[ERROR]: Expected passwordless ssh to host hgdw2
[root@hgdw1 software]# 

```

solution

```

ssh-copy-id -i id_rsa.pub root@hgdw1
ssh-copy-id -i id_rsa.pub root@hgdw3
ssh-copy-id -i id_rsa.pub root@hgdw3
ssh-copy-id -i id_rsa.pub root@hgdw4
ssh-copy-id -i id_rsa.pub root@hgdw4
ssh-copy-id -i id_rsa.pub root@hgdw6

```

## libapr-1.so.0

error
```bash
nohup gpfdist -d /data/csv -p 8081 -t 600 >>/home/hgadmin/gpAdminLogs/gpfdist.log 2>&1 &

nohup: ignoring input
gpfdist: error while loading shared libraries: libapr-1.so.0: cannot open shared object file: No such file or directory
```
solution
```bash

yum install apr
```

## ERROR: deadlock detected

问题描述

我们在做MR批量导入数据的时候 会引发 Caused by: org.postgresql.util.PSQLException: ERROR: deadlock detected
  详细：Process 3927 waits for ExclusiveLock on relation 16586 of database 16384; blocked by process 的错误，原先在XL上没发现  这个主要是什么原因引起的 ？


问题处理
默认情况下，全局死锁检测器是被禁用的，Greenplum数据库以串行方式对堆表执行并发更新和删除操作。 可以通过设置配置参数gp_enable_global_deadlock_detector，开启并发更新并让全局死锁检测器检测死锁是否存在。

启用全局死锁检测器后，当启动Greenplum数据库时，master 主机上会自动启动一个后端进程。可以通过 gp_global_deadlock_detector_period配置参数，来设置采集和分析锁等待数据的时间间隔。

如果全局死锁检测器发现了死锁，它会通过取消最新的事务所关联的一个或多个后端进程来避免死锁。
当全局死锁检测器发现了以下事物类型的死锁时，只有一个事务将成功。其他事务将失败，并打印错误指出不允许对同一行进行并发更新。
