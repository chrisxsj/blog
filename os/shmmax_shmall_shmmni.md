# shmmax_shmall_shmmni

**作者**

chrisx

**日期**

2021-05-12

**内容**

kernel.shmmax、kernel.shmall、kernel.shmmni、aio-max-nr参数解释和配置

tip、oracle

----

[toc]

## 场景

数据库安装前的检查任务中有以下几个内核参数需要配置，在巡检中我们也会检查这些参数配置是否合理，然后给出一个合理的建议值

```sh
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096
aio-max-nr = 1048576
```

参考[docs](https://docs.oracle.com/cd/E11882_01/install.112/e47689/pre_install.htm#LADBI1187)

如果客户提出让我们解释这几个参数，为什么要设置这个值， 能否给客户一个满意的答复呢？

同时，如果SHMMAX配置错误，则在尝试使用initdb命令初始化PostgreSQL集群以及使用pg_ctl这类操作时可能会出错。

出现此类报错的原因通常是PostgreSQL对共享内存段的请求超出了内核的SHMMAX参数值或者是低于了内核的SHMMIN参数值。

此时如何处理呢？

## 描述

下面来看一下这几个参数

* SHMMNI-此参数设置系统内最大共享内存段个数
* SHMMAX-此参数定义单个共享内存段的最大大小 (以字节为单位)
* SHMALL-此参数设置系统范围内共享内存总数量（以内存页PAGE_SIZE表示）。因此, SHMALL 始终大于(shmmax/PAGE_SIZE)。
* aio-max-nr-此参数设置系统所允许的，并发请求的最大异步IO个数

当前系统/etc/sysctl.conf 文件配置如下

```sh
# oracle set by jason
kernel.shmmax = 68719476736 #单个共享内存段最大64G
kernel.shmall = 4294967296  #系统最大共享内存大小为4294967296*PAGE_SIZE
kernel.shmmni = 4096    #当前系统最大允许4096个共享内存段
fs.aio-max-nr = 1048576 #异步io最大个数为1048576
```

```sh
[root@db ~]# getconf PAGE_SIZE     --PAGE_SIZE
4096

kernel.shmall = 4294967296             --最大共享内存为17179869184kb，此值为 RHEL6 默认设置

```

## 验证

可用以下命令获取系统共享内存段使用情况

```sh
[root@db ~]# ipcs -m
 
------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status    
0x00000000 0          gdm        600        393216     2          dest       
0x00000000 32769      gdm        600        393216     2          dest       
0x00000000 65538      gdm        600        393216     2          dest       
0x00000000 131075     grid       640        4096       0                     
0x00000000 163844     grid       640        4096       0                     
0xa3c20e68 196613     grid       640        4096       0                     
0x00000000 262150     oracle     640        8388608    36                    
0x00000000 294919     oracle     640        301989888  36                    
0x3ff6041c 327688     oracle     640        2097152    36

```

当前系统共有9个共享内存段
最大的共享内存段为oracle用户所有，大小为301989888，其实就是sga大小

```sql
SQL> show parameter sga_target  
 
NAME                      TYPE     VALUE
------------------------------------ ----------- ------------------------------
sga_target                  big integer 296M

```

可用以下命令查看共享内存段限制--与/etc/sysctl.conf配置相匹配

```sh
[root@db ~]# ipcs -lm
 
------ Shared Memory Limits --------
max number of segments = 4096
max seg size (kbytes) = 67108864
max total shared memory (kbytes) = 17179869184
min seg size (bytes) = 1
```

参考https://access.redhat.com/solutions/414533

## 参数值设置

这几个参数应该设置成什么值呢？首先，参考官方文档

```sh
shmall         2097152
shmmax         Minimum: 536870912
32-bit Linux Systems
Maximum: A value that is 1 byte less than 4 GB, or 4294967295
Recommended: More than half the physical memory
 
64-bit Linux Systems
Maximum: A value that is 1 byte less than the physical memory
Recommended: More than half the physical memory
 
shmmni         4096
aio-max-nr     1048576
Note: This value limits concurrent outstanding requests and should be set to avoid I/O subsystem failures.

```

官方文档有明确要求，但并不完全正确，实践出真知啊#_#!

```sh
shmall=2097152=2097152*4=8G，总共享内存段大小才8G，太小了，一般的sga都满足不了
shmall 需要大于shmmax/PAGE_SIZE，需要大于sga+pga

```

当shmall设置过小时会报如下错误（从一个内存大的服务器迁移到内存小的服务器上，sga没有更改的情况）

```sql
SQL> startup nomount
ORA-27102: out of memory
Linux-x86_64 Error: 28: No space left on device

```

参考[mos Upon startup of Linux database get ORA-27102: out of memory Linux-X86_64 Error: 28: No space left on device (Doc ID 301830.1)]()

建议

```sh
直接使用默认值，或= 物理内存/PAGE_SIZE
kernel.shmall = 4294967296

shmmax=1/2物理内存
shmmax需要大于SGA
```

可用以下命令计算

```sh
# echo $(expr $(getconf _PHYS_PAGES) / 2)                   
2041774
# echo $(expr $(getconf _PHYS_PAGES) / 2 \* $(getconf PAGE_SIZE))
8363106304

```

参考[mos Maximum SHMMAX values for Linux x86 and x86-64 (Doc ID 567506.1)]()

建议：

```sh
shmmni=4096 #默认值

```

aio-max-nr=1048576  在RAC中此参数是一个不正确的值，RAC环境中，设置过小ASM alert log会报如下错误

```sh
Errors in file /u01/app/grid/diag/asm/+asm/+ASM1/trace/+ASM1_ora_93958.trc:
ORA-27090: Unable to reserve kernel resources for asynchronous disk I/O
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3
Additional information: 128
Additional information: 180366048

```

参考[mos ORA-27090 - Unable to Reserve Kernel Resources for Asynchronous Disk I/O (Doc ID 579108.1)]()

明确指出官方文档值不正确

the published limit in the Oracle Documentation at http://docs.oracle.com/cd/E11882_01/install.112/e24326/toc.htm#BHCCADGD is incorrect.

建议

```sh
Also, this parameter should be set as follows:
-------------------------------------
fs.aio-max-nr= 3145728
-------------------------------------
```

## 参数修改

临时生效

```sh
echo 4000 > /proc/sys/kernel/shmmni
```

永久生效

```sh
写入/etc/sysctl.conf
sysctl -p
```

## 补充

在一个程序中如果涉及到磁盘的IO操作时,有两种情况
1. 程序等待IO操作完成，CPU再接下来处理程序的其他部分（等待IO的时间段内，CPU处于Idle Waiting状态）。
2. 程序不等待IO操作完成，允许CPU处理接下来的其他任务（或者理解为允许CPU处理接下来的不依赖于IO完成的任务）。
显然，第一种情况，CPU的资源白白的浪费了,也就是同步IO。第二种情况更有利于CPU的充分利用,这就是异步IO(asynchronous IO)
 
http://blog.csdn.net/hemiao1987/article/details/46044049