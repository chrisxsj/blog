# scheduler

**作者**

chrisx

**日期**

2021-05-12

**内容**

io调度算法

----

[toc]

## 介绍

通常性能最大的瓶颈是io，io调度算法有很多种
不同的Linux版本，其默认的I/O调度算法不同。rhel7的默认的I/O调度算法是deadline。在RHEL6及更老的RHEL版本中，默认的I/O调度算法是cfq。

Cfq称之为绝对公平调度算法，
Noop是电梯调度算法，它基于FIFO队列实现，所有I/O请求先进先出，适合SSD
Deadline称为绝对保障算法，是RHEL7的默认I/O算法，适合数据库服务器。

## 查看

可以通过如下方式查看某个磁盘的I/O调度算法

```sh
[root@rhel78 ~]# cat /sys/block/sda/queue/scheduler
noop [deadline] cfq
```

:warning: 注意：方括号中的算法是当前正在使用的算法。

## 修改

针对PostgreSQL来说，若是$PGDATA在SSD固态盘上，我们推荐的I/O调度算法是noop,deadline或mq-deadline的其中一种
针对PostgreSQL来说，若是$PGDATA在机械盘上，我们推荐的I/O调度算法是cfq或bfq策略
可以通过shell命令来临时修改调度算法算法

```sh
[root@rhel78 ~]# echo noop > /sys/block/sda/queue/scheduler
[root@rhel78 ~]# cat /sys/block/sda/queue/scheduler
[noop] deadline cfq

```

通过shell命令修改的调度算法，在服务器重启后就会恢复到系统默认值，永久修改调度算法需要修改grub文件

永久修改方式

```sh
grubby --update-kernel=ALL --args="elevator=deadline"
reboot

```

:warning: 注：需将命令中的sda替换为实际的磁盘名称
