# swap

**作者**

chrisx

**日期**

2021-05-13

**内容**

手动增加swap空间大小

手动刷新swap

----

[toc]

## 手动增加swap空间

1. 确保系统中有足够的空间来用做swap交换空间，准备在一个独立的文件系统中添加一个swap交换文件，如，在/opt/image中加2G的swap交换文件
2. 添加交换文件并设置其大小为2G，使用如下命令

```sh
# dd if=/dev/zero of=/opt/image/swap bs=1024 count=2048000
2048000+0 records in2048000+0 records out2097152000 bytes (2.1 GB) copied, 272.867 seconds, 7.7 MB/s
```

3. 创建（设置）交换空间，使用命令mkswap

```sh
# mkswap /opt/image/swap
Setting up swapspace version 1, size = 2097147 kB
```

4. 启动新增加的2G的交换空间，使用命令swapon

```sh
# swapon /opt/image/swap
```

5. 确认新增加的2G交换空间已经生效，
使用命令free
或者检查meminfo文件grep SwapTotal  /proc/meminfo

6. 修改/etc/fstab文件，使得新加的2G交换空间在系统重新启动后自动生效
在文件最后加入

```sh
/opt/image/swap     swap      swap defaults 0 0
```

## 手动刷新swap

当Swap占用率高达30%，对系统性能可能会有一定影响，所以在适当情况下，我们可以手动刷新一次Swap（将Swap里的数据转储回内存，并清空Swap里的数据）

```sh
swapoff -a && swapon -a
```

```sh
cat /proc/sys/vm/swappiness
30  #默认值30,建议值10
```
