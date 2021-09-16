# linux port

端口占用

## Lsof

依据端口查看进程

```bash
lsof -i :5432

COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
postmaste 897   pg    3u  IPv4  17033      0t0  TCP *:postgres (LISTEN)
postmaste 897   pg    4u  IPv6  17034      0t0  TCP *:postgres (LISTEN)
```

## netstat

依据进程查看占用的端口

```bash
 netstat -tunlp 10784
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:5971            0.0.0.0:*               LISTEN      10784/postgres
tcp        0      0 192.168.122.1:53        0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      -
tcp6       0      0 :::5971                 :::*                    LISTEN      10784/postgres

```
