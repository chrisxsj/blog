# open files不生效

## 现象

vi /etc/security/limits.conf

```bash
#<domain>      <type>  <item>         <value>
#

#*               soft    core            0
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#@student        -       maxlogins       4


# End of file

*   soft        nofile      1024000
*   hard        nofile      1024000
*   soft        nproc       unlimited
*   hard        nproc       unlimited
*   soft        core        unlimited
*   hard        core        unlimited
*   soft        memlock     unlimited
*   hard        memlock     unlimited


```

文件中已经设置好，但是检查发现，限制还是1024

```bash
[root@gp1 ~]# ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 5850
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 5850
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

```

永久设置的值没有生效！！！

## 问题处理

原因就在于/etc/security/limits.conf中参数格式不对，缩进、空格等不对。
改为以下形式即可


```bash
#<domain>      <type>  <item>         <value>
#

#*               soft    core            0
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#@student        -       maxlogins       4


# End of file

*               soft    nofile          1024000
*               hard    nofile          1024000
*               soft    nproc           unlimited
*               hard    nproc           unlimited
*               soft    core            unlimited
*               hard    core            unlimited
*               soft    memlock         unlimited
*               hard    memlock         unlimited

```

检查正常

```bash

[highgo@gp1 ~]$ su - root
Password:
Last login: Tue Aug  4 10:41:21 CST 2020 on pts/0
[root@gp1 ~]# ulimit -a
core file size          (blocks, -c) unlimited
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 5850
max locked memory       (kbytes, -l) unlimited
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024000
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) unlimited
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

```
