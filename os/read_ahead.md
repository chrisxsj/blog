# read_ahead

**作者**

chrisx

**日期**

2021-05-12

**内容**

磁盘预读值配置

----

[toc]

## 查看

把预读扇区设置大一点，让IO寻址的时间缩短，从而优化IO性能。对于大量顺序读取的操作，可以有效减少I/O的等待时间。该参数值建议在实际环境中测试再决定设置多大值。

通过如下命令查看disk的预读设置

```sh
[root@rhel78 ~]# /sbin/blockdev --getra /dev/sda
8192
```

:warning: 请注意，8192的单位是个，也就是8192个sectors.

查看所有disk

```sh
[root@rhel78 ~]# blockdev --report
RO    RA   SSZ   BSZ   StartSec            Size   Device
rw  8192   512  4096          0     21474836480   /dev/sda
rw  8192   512   512       2048      1073741824   /dev/sda1
rw  8192   512  4096    2099200     20400046080   /dev/sda2
rw   256  2048  2048          0      4550819840   /dev/sr0
rw  8192   512   512          0     18249416704   /dev/dm-0
rw  8192   512  4096          0      2147483648   /dev/dm-1

```

上面第二列RA列的单位是个，也就是这么多个sectors.

查看sda的预读的大小

```sh
[root@rhel78 ~]# cat /sys/class/block/sda/queue/read_ahead_kb
4096
```

上面4096的单位是KB

## 设置

设置sda的预读为16484，单位是sectors

```sh
[root@rhel78 ~]# /sbin/blockdev --setra 16384 /dev/sda
[root@rhel78 ~]# /sbin/blockdev --getra /dev/sda
16384
```

值得注意，当存储环境中用到多路径聚合软件时，请修改多路径聚合软件聚合之后的磁盘名称，如下是举例

```sh
# /sbin/blockdev --setra 16384  /dev/<multipath device>
```

通过上面的修改可以看到，修改会立即生效，但是这么设置重启OS后会失效，因此，建议建立udev规则来保证重启OS后不会失效。

```sh
[root@rhel78 ~]# cat /etc/udev/rules.d/99-custom.rules 
SUBSYSTEM!="block", GOTO="end_rule"
ENV{DEVTYPE}=="partition", GOTO="end_rule"
ACTION!="add|change", GOTO="end_rule"
ENV{ID_SERIAL}=="36000c2939dfa82377c155d4b4a8d0acd", ATTR{queue/read_ahead_kb}="8192"
LABEL="end_rule"

[root@rhel78 ~]# udevadm trigger --action="add"

```

:warning: 注意，在上面的输出中36000c2939dfa82377c155d4b4a8d0acd是sda的WWID.8192是sda的预读大小，KB为单位。