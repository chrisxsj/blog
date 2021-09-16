# pg思考

## 内容

1 归档路径需要独立与master
2 为什么不配置非默认表空间
3 非默认表空间与pg_wal读写分离是否可行
4 备库是否启用连续归档

## keep alive为什么没有生效

[postgres@cntpncp-cdb01 data]$ cat postgresql.auto.conf |grep tcp
tcp_keepalives_idle = '900'
tcp_keepalives_interval = '10'
tcp_keepalives_count = '10'
[postgres@cntpncp-cdb01 data]$
 
postgres=# select name,setting from pg_settings where name like '%tcp%';
          name           | setting
-------------------------+---------
 tcp_keepalives_count    | 0
 tcp_keepalives_idle     | 0
 tcp_keepalives_interval | 0
(3 rows)
 
postgres=#
 
 
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_keepalive_intvl = 20
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_mem = 8388608 12582912 16777216