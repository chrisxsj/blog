Linux iostat



Linux系统出现了性能问题，一般我们可以通过top、iostat、free、vmstat等命令来查看初步定位问题。在一个以前看到系统监控工具，总在想那些监控工具的代理，如何收集系统性能信息，io性能，cpu使用，带宽使用等信息，偶然发现，不同系统均提供有性能分析工具的，代理可通过这些命令获取系统性能信息，个人猜测，不知道具体是不是这样的。其中iostat可以给我们提供丰富的IO状态数据，下边就来看一下iostat如何使用，命令能够输出那些信息。
简述
Linux系统中通过iostat我们能查看到系统IO状态信息，从而确定IO性能是否存在瓶颈。
命令安装
iostat是查看Linux系统io是否存在瓶颈顶好用的一个命令，但是由此而系统默认没有安装的，以centos系统为例，看看如何安装iostat命令。

[root@localhost ~]# iostat
-bash: iostat: command not found
[root@localhost ~]# yum install -y sysstat
命令使用

[root@localhost ~]# iostat --help
Usage: iostat [ options ] [ <interval> [ <count> ] ]
Options are:
[ -c ] [ -d ] [ -N ] [ -n ] [ -h ] [ -k | -m ] [ -t ] [ -V ] [ -x ] [ -y ] [ -z ]
[ -j { ID | LABEL | PATH | UUID | ... } [ <device> [...] | ALL ] ]
[ <device> [...] | ALL ] [ -p [ <device> [,...] | ALL ] ]
iostat 主要有三个操作箱，options 操作项，interval指定统计时间间隔，count总共输出次数
-c 参数，可以用来插卡部分cpu状态信息

[root@localhost ~]# iostat -c
Linux 2.6.32-573.el6.x86_64 (localhost)         06/30/2017      _x86_64_        (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.02    0.00    0.00    0.00    0.00   99.98
-k 参数，某些使用block为单位的列强制使用Kilobytes为单位

[root@localhost ~]# iostat -k 1 10
Linux 2.6.32-573.el6.x86_64 (localhost)         06/30/2017      _x86_64_        (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.02    0.00    0.00    0.00    0.00   99.98

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda               0.14         0.04         1.65     969915   41732790
dm-0              0.42         0.04         1.65     936269   41632492
dm-1              0.00         0.00         0.00      19920      62056
dm-2              0.00         0.00         0.00       1001      38212
dm-3              0.00         0.01         0.00     127405       7160

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.00    0.00    0.00    0.00    0.00  100.00

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda               4.00         0.00        48.00          0         48
dm-0             12.00         0.00        48.00          0         48
dm-1              0.00         0.00         0.00          0          0
dm-2              0.00         0.00         0.00          0          0
dm-3              0.00         0.00         0.00          0          0
-d 参数，显示设备（磁盘）使用状态

[root@localhost ~]# iostat -d 1 3
Linux 2.6.32-573.el6.x86_64 (localhost)         06/30/2017      _x86_64_        (4 CPU)

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               0.14         0.08         3.31    1939830   83470564
dm-0              0.42         0.07         3.30    1872538   83269968
dm-1              0.00         0.00         0.00      39840     124112
dm-2              0.00         0.00         0.00       2002      76424
dm-3              0.00         0.01         0.00     254810      14320

解释一下输出列表示什么意思：
tps：该设备每秒的传输次数（Indicate the number of transfers per second that were issued to the device.）。“一次传输”意思是“一次I/O请求”。多个逻辑请求可能会被合并为“一次I/O请求”。“一次传输”请求的大小是未知的。
kB_read/s：每秒从设备（drive expressed）读取的数据量；kB_wrtn/s：每秒向设备（drive expressed）写入的数据量；kB_read：读取的总数据量；kB_wrtn：写入的总数量数据量；这些单位都为Kilobytes。
上面的例子中，我们可以看到磁盘sda以及它的各个分区的统计数据，当时统计的磁盘总TPS是39.29，下面是各个分区的TPS。（因为是瞬间值，所以总TPS并不严格等于各个分区TPS的总和）
-x 参数，输出更多详细信息

[root@localhost ~]# iostat -x 1 2
Linux 2.6.32-573.el6.x86_64 (localhost)         06/30/2017      _x86_64_        (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.02    0.00    0.00    0.00    0.00   99.98

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     0.27    0.00    0.14     0.08     3.31    23.78     0.00    0.31    1.51    0.29   0.16   0.00
dm-0              0.00     0.00    0.00    0.41     0.07     3.30     8.13     0.00    2.64    2.05    2.64   0.06   0.00
dm-1              0.00     0.00    0.00    0.00     0.00     0.00     8.00     0.00    2.29    1.61    2.51   0.08   0.00
dm-2              0.00     0.00    0.00    0.00     0.00     0.00     8.01     0.00   19.82    0.64   20.30   0.03   0.00
dm-3              0.00     0.00    0.00    0.00     0.01     0.00    30.85     0.00    0.04    0.02    0.20   0.02   0.00

解释一下 -x参数输出列意思
rrqm/s：每秒这个设备相关的读取请求有多少被Merge了（当系统调用需要读取数据的时候，VFS将请求发到各个FS，如果FS发现不同的读取请求读取的是相同Block的数据，FS会将这个请求合并Merge）；wrqm/s：每秒这个设备相关的写入请求有多少被Merge了。
rsec/s：每秒读取的扇区数；
wsec/：每秒写入的扇区数。
r/s：The number of read requests that were issued to the device per second；w/s：The number of write requests that were issued to the device per second；
await：每一个IO请求的处理的平均时间（单位是毫秒）。这里可以理解为IO的响应时间，一般地系统IO响应时间应该低于5ms，如果大于10ms就比较大了。
%util：在统计时间内所有处理IO时间，除以总共统计时间。例如，如果统计间隔1秒，该设备有0.8秒在处理IO，而0.2秒闲置，那么该设备的%util = 0.8/1 = 80%，所以该参数暗示了设备的繁忙程度。一般地，如果该参数是100%表示设备已经接近满负荷运行了（当然如果是多磁盘，即使%util是100%，因为磁盘的并发能力，所以磁盘使用未必就到了瓶颈）。
常见用法

iostat -d -k 1 10        #查看TPS和吞吐量信息
iostat -d -x -k 1 10      #查看设备使用率（%util）、响应时间（await）
iostat -c 1 10            #查看cpu状态
使用实例
查看指定磁盘吞吐量和速率

[root@localhost ~]# iostat -d -d 1 1
Linux 2.6.32-573.el6.x86_64 (localhost)         06/30/2017      _x86_64_        (4 CPU)

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               0.14         0.08         3.31    1939830   83482716
dm-0              0.42         0.07         3.30    1872538   83282120
dm-1              0.00         0.00         0.00      39840     124112
dm-2              0.00         0.00         0.00       2002      76424
dm-3              0.00         0.01         0.00     254810      14320
#从结果看到平均传输次数0.14，每秒读取0.08M，每秒写3.31M
磁盘性能统计

[root@localhost ~]# iostat -x -k 1 1
Linux 2.6.32-573.el6.x86_64 (localhost)         06/30/2017      _x86_64_        (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.02    0.00    0.00    0.00    0.00   99.98

Device:         rrqm/s   wrqm/s     r/s     w/s       rkB/s    wkB/s  avgrq-sz avgqu-sz   await    r_await  w_await  svctm  %util
sda               0.00     0.27         0.00   0.14     0.04     1.65    23.78       0.00         0.31    1.51            0.29   0.16   0.00
 
来自 <https://www.cnblogs.com/xiuluo--angel/p/7086637.html>