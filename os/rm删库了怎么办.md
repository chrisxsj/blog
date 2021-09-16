# rm删除了文件除了跑路还能怎么办

[toc]

## 前言

每当我们在生产环境服务器上执行rm命令时，总是提心吊胆的，因为一不小心执行了误删，然后就要准备跑路了，毕竟人不是机器，更何况机器也有bug，呵呵。那么如果真的删除了不该删除的文件，比如数据库、日志或执行文件，怎么办呢？

## 模拟场景

```bash
pg_ctl start

$ ll
total 8
-rw------- 1 hgdb565 hgdb565 413 May 21 16:45 postgresql-server_log_21
-rw------- 1 hgdb565 hgdb565 760 May 21 16:45 postgresql-server_log_21.csv

```

### 删除

误删除数据库日志文件，postgresql-server_log_21.csv

```bash
rm postgresql-server_log_21.csv

$ ll
total 4
-rw------- 1 hgdb565 hgdb565 413 May 21 16:45 postgresql-server_log_21
```

### 恢复

1 使用lsof命令查看当前是否有进程打开postgresql-server_log_21.csv文件

```bash
$ lsof |grep  postgresql-server_log_21
postgres  2465             hgdb565   10w      REG              253,0       413    201050 /opt/HighGo5.6.5/data/pg_log/postgresql-server_log_21
postgres  2465             hgdb565   11w      REG              253,0       877    201051 /opt/HighGo5.6.5/data/pg_log/postgresql-server_log_21.csv (deleted)
```

**从上面可以看出，当前文件状态为已删除（deleted）**

2 查看是否存在恢复数据

```bash
$ cd /proc/2465/fd
$ ll
total 0
lr-x------ 1 hgdb565 hgdb565 64 May 21 16:46 0 -> /dev/null
lrwx------ 1 hgdb565 hgdb565 64 May 21 16:46 1 -> /dev/pts/0
l-wx------ 1 hgdb565 hgdb565 64 May 21 16:46 10 -> /opt/HighGo5.6.5/data/pg_log/postgresql-server_log_21
l-wx------ 1 hgdb565 hgdb565 64 May 21 16:46 11 -> /opt/HighGo5.6.5/data/pg_log/postgresql-server_log_21.csv (deleted)
lr-x------ 1 hgdb565 hgdb565 64 May 21 16:46 12 -> pipe:[30810]
l-wx------ 1 hgdb565 hgdb565 64 May 21 16:46 13 -> pipe:[30810]
lrwx------ 1 hgdb565 hgdb565 64 May 21 16:46 2 -> /dev/pts/0
lrwx------ 1 hgdb565 hgdb565 64 May 21 16:46 3 -> anon_inode:[eventpoll]
lr-x------ 1 hgdb565 hgdb565 64 May 21 16:46 6 -> pipe:[30804]
lr-x------ 1 hgdb565 hgdb565 64 May 21 16:46 8 -> pipe:[30805]

可以看到链接号11对应了被删除的文件
11 -> /opt/HighGo5.6.5/data/pg_log/postgresql-server_log_21.csv (deleted)
```

> 注意，/proc/[pid]/fd此目录包含进程打开的所有文件，文件名为文件描述符，目录中每个软连接都会指向进程打开的实际文件。

3 使用I/O重定向恢复文件

```bash
cat /proc/2465/fd/11 > /opt/HighGo5.6.5/data/pg_log/postgresql-server_log_21.csv

$ ll /opt/HighGo5.6.5/data/pg_log/
total 8
-rw------- 1 hgdb565 hgdb565  413 May 21 16:45 postgresql-server_log_21
-rw-rw-r-- 1 hgdb565 hgdb565 1321 May 21 17:00 postgresql-server_log_21.csv
```

### 原理

在Linux系统中，每个运行中的程序都有一个宿主进程彼此隔离，以/proc/进程号来体现（Linux本质上就是一个文件系统），比如：ls -l /proc/13067 查看进程PID为13067的进程信息；当程序运行时，操作系统会专门开辟一块内存区域，提供给当前进程使用，对于依赖的文件，操作系统会发放一个文件描述符，以便读写文件，当我们执行 rm -f 删除文件时，其实只是删除了文件的目录索引节点，对于文件系统不可见，但是对于打开它的进程依然可见，即仍然可以使用先前发放的文件描述符读写文件，正是利用这样的原理，所以我们可以使用I/O重定向的方式来恢复文件。
如果不小心误删了文件，不要着急，首先使用 lsof 查看打开该文件的进程，然后再使用 cat /proc/进程号/fd/文件描述符 查看恢复数据，最后使用I/O重定向的方式来恢复文件。