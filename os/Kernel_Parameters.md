# kernel_parameters

**作者**

chrisx

**日期**

2021-05-12

**内容**

Tune Linux Kernel Parameters For PostgreSQL Optimization
For optimum performance, a PostgreSQL database depends on the operating system parameters being defined correctly. Poorly configured OS kernel parameters can cause degradation in database server performance. Therefore, it is imperative that these parameters are configured according to the database server and its workload. In this post, we will discuss some important Linux kernel parameters that can affect database server performance and how these should be tuned.

ref[Tune Linux Kernel Parameters For PostgreSQL Optimization](https://www.percona.com/blog/2018/08/29/tune-linux-kernel-parameters-for-postgresql-optimization/)

----

[toc]

## 配置文件

配置文件/etc/sysctl.conf

```sh
sysctl -p #生效
sysctl -a | grep fs.aio-max-nr    #查看默认值
cat /proc/sys/kernel/sem #查看内核相关参数当前值
```

## 参数解释

vi kernel.sh

```bash
#!/bin/bash
page_size=`getconf PAGE_SIZE`
phys_pages=`getconf _PHYS_PAGES`
shmall=`echo "$phys_pages * 0.9" |bc`
shmmax=`echo "$phys_pages * 0.6 * $page_size" |bc`

# kernel内存使用。建议参数值比shared buffer大
echo kernel.shmall = $shmall #此参数设置系统范围内共享内存总数量（以内存页PAGE_SIZE表示）。因此, SHMALL 始终大于(shmmax/PAGE_SIZE)。
echo kernel.shmmax = $shmmax #此参数定义单个共享内存段的最大大小 (以字节为单位)
echo kernel.shmmni = 819200 #此参数设置系统内最大共享内存段个数
echo kernel.sem = 4096 2147483647 2147483646 512000 #信号量负责进程间通信，协调各个进程工作
#cat /proc/sys/kernel/sem
#250    32000    32    128
#4个数据分别对应
#SEMMSL SEMMNS SEMOPM SEMMNI
#250       SEMMSL    max semaphores per array     信号集容纳最大信号数量   
#32000     SEMMNS    max semaphores system wide   所有信号的最大数量
#32        SEMOPM    max ops per semop call       调用单个信号集中最大信号数量
#128       SEMMNI    max number of arrays         信号集的最大值
echo kernel.msgmnb = 65536 #该文件指定在一个消息队列中最大的字节数                                                                                                    

# file
echo fs.aio-max-nr = 1048576 #此参数设置系统所允许的，并发请求的最大异步IO个数，异步IO可以优化IO操作和提高性能（进程无需等待IO完成即可进行其他工作）
echo fs.file-max = 76724600 #内核定义的最大file handles(文件句柄数)
echo fs.nr_open=76724600 #单进程最大文件句柄数（最大能够打开的文件数）
# lsof |wc -l     #计算最大句柄数，但是无法限制root，所以lsof实际值可能大于fs.file-max


# vm 虚拟内存使用
echo vm.swappiness = 10
#此参数用于控制Linux系统上将页面在swap分区和内存间进行交换的行为。可能影响数据库性能的内核参数。
#Higher value means more aggressively swap.
#此参数值值的范围为0到100，RHEL 5 and 6上，该参数默认值为60,在 RHEL 7上，该参数默认值为30，你的内存在使用到100-30=60%的时候，就开始出现有交换分区的使用。建议值10
#0，仅在内存不足的情况下--当剩余空闲内存低于vm.min_free_kbytes limit时，使用交换空间
#1，内核版本3.5及以上、Red Hat内核版本2.6.32-303及以上，进行最少量的交换，而不禁用交换。
#Setting a value of 0 in newer kernels may cause the OOM Killer (out of memory killer process in Linux) to kill the process. Therefore, you can be on the safe side and set the value to 1 if you want to minimize swapping. The default value on a Linux system is 60. A higher value causes the MMU (memory management unit) to utilize more swap space than RAM, whereas a lower value preserves more data/code in memory.A smaller value is a good bet to improve performance in PostgreSQL.

# vm内存使用
echo vm.overcommit_memory = 2 
#应用程序获取内存并在不再需要时释放内存。但在某些情况下，一个应用程序会获取大量内存并且不会释放它，这可能会唤醒OOM killer释放内存。
#将vm.overcommit_memory参数的值设置为2会使PostgreSQL有更好的性能。此值最大化服务器进程的内存利用率，而没有任何被OOM killer进程杀死的重大风险。
#0：用户申请更多内存时，系统会判断剩余可用的内存大小，如果可用内存不足就会失败。
#1：Allow overcommit anyway用户申请内存时，系统不进行任何检查，允许超量使用内存，直到内存用完为止。
#2：Don’t over commit beyond the overcommit ratio.。建议值2
#cat /proc/sys/vm/overcommit_memory
#A value of 2 for vm.overcommit_memory yields better performance for PostgreSQL.

echo vm.overcommit_ratio 
#是可用于超额交付的RAM百分比。在具有2 GB RAM的系统上，50%的值最多可提交3 GB RAM。
#应用程序将能够过度提交，但只能在过度提交比率内，从而降低导致进程终止的风险。
#cat /proc/sys/vm/overcommit_ratio

# vm 刷新脏页
echo vm.dirty_background_ratio = 5 #需要刷新到磁盘的脏页的内存百分比。后台完成刷新,异步
echo vm.dirty_ratio = 95 ##需要刷新到磁盘的脏页的内存百分比。前台完成刷新，强制刷新，而且会阻塞应用程序
#场景1：积极的清理方式
#在一些情况下，我们有快速的磁盘子系统，它们有自带的带备用电池的 Cache 我们希望及时写入磁盘。可以在/etc/sysctl.conf中加入下面两行参数，并执行"sysctl -p“
#vm.dirty_background_ratio = 5
#vm.dirty_ratio = 10
#场景2：延后的清理方式
#在一些场景中增加Cache是有好处的。例如，数据不重要丢了也没关系，而且有程序重复地读写一个文件。允许更多的cache，可以更多地在内存上进行读写，提高速度。
#vm.dirty_background_ratio = 30
#vm.dirty_ratio = 90
#情景3：两者兼顾
#有时候系统需要应对突如其来的高峰数据，可能会拖慢磁盘。（比如说，每个小时开始时进行的批量操作等）
# 这个时候需要容许更多的脏数据存到内存，让后台进程慢慢地通过异步方式将数据写到磁盘当中。
#vm.dirty_background_ratio = 5
#vm.dirty_ratio = 80
#此时后台进程在脏数据达到5%时就开始异步清理，但在80%之前系统不会强制同步写磁盘。这样可以使IO变得更加平滑。

echo vm.min_free_kbytes=8192000 #?

#You can tune other parameters for performance, but the improvement gains are likely to be minimal. We must keep in mind that not all parameters are relevant to all applications types. Some applications perform better by tuning some parameters and some applications don’t. You need to find a good balance between these parameter configurations for the expected application workload and type, and OS behavior must also be kept in mind when making adjustments. Tuning kernel parameters are not as easy as tuning database parameters: it’s harder to be prescriptive.

# net
echo net.core.netdev_max_backlog = 10000 #在每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
echo net.core.rmem_default = 262144 #默认的TCP数据接收窗口大小（字节）
echo net.core.rmem_max = 4194304 #最大TCP数据接收窗口大小（字节）
echo net.core.wmem_default = 262144 #默认的TCP数据发送窗口大小（字节）
echo net.core.wmem_max = 4194304 #最大的TCP数据发送窗口（字节）
echo net.core.somaxconn = 4096 #每一个端口最大监听队列的长度
echo net.ipv4.tcp_max_syn_backlog = 4096 #接收数据包的最大数目
#cat /proc/sys/net/ipv4/tcp_max_syn_backlog    --默认值
echo net.ipv4.ip_local_port_range = 40000 65535 #本地自动分配的TCP, UDP端口号范围

#有关进程连接(TCP keep_alive心跳包)的参数
echo net.ipv4.tcp_keepalive_intvl = 60
echo net.ipv4.tcp_keepalive_probes = 6
echo net.ipv4.tcp_keepalive_time = 60
#Results in the following behavior:
#Trigger a keepalive probe every 60 seconds (1 min) after the last received packet If the connection is idle and the remote host does not reply, probe the remote host every 60 seconds Close the connection after 6 failed probes
echo net.ipv4.tcp_mem = 8388608 12582912 16777216 #TCP内存的使用
#low, pressure, high
#8388608 12582912 16777216

# 大页内存
# vm.nr_hugepages = 480
# vm.hugetlb_shm_group = 1001  #这个是操作系统数据库用户的 group id
```

<!--
做成一个脚本
chmod u+x kernel.sh
sh ./kernel.sh >> /etc/sysctl.d/99-hgdb-server.conf
sysctl -p /etc/sysctl.d/99-hgdb-server.conf
sysctl -a|grep shm
-->
