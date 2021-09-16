```
top - 11:28:43 up 30 days, 15:53, 3 users, load average: 0.00, 0.01, 0.19
Tasks: 454 total, 1 running, 453 sleeping, 0 stopped, 0 zombie
%Cpu(s): 0.0 us, 0.0 sy, 0.0 ni,100.0 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st
KiB Mem : 65460224 total, 1873028 free, 889816 used, 62697380 buff/cache
KiB Swap: 67108860 total, 63780520 free, 3328340 used. 43441744 avail Mem
PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
4358 postgres 20 0 17.034g 0.016t 0.016t S 0.0 26.1 14:21.90 postgres --checkpoint ≈ shared_buffer=16G
4359 postgres 20 0 17.013g 0.015t 0.015t S 0.0 24.8 6:05.04 postgres --write ≈ shared_buffer=16G
4344 postgres 20 0 17.013g 887356 886972 S 0.0 1.4 0:45.99 postgres --postmast ≈ 887M
9571 pguat 20 0 17.169g 719184 718668 S 0.0 1.1 1:13.27 postgres
4360 postgres 20 0 17.013g 525620 525316 S 0.3 0.8 32:56.91 postgres
--如果shared_buffer是物理内存的1/4,根据以上现象pg会占用3/4物理内存吗？（shared_buffer+checkpoint+write）
--postmast只占用887M，shared_buffer（16G）去哪了？
 
<!--1 固定分配的shared_buffer去了哪里？
2 为什么checkpoing和write占用的内存和shared_buffer一样大
3 是否数据库启动后，直接占用3/4内存（shared_buffer,checkpoint,write）,如果是，那么加上recover是否物理内存就用完了!-->
 
 
[pg@pg ~]$ ipcs -m
------ Shared Memory Segments --------
key shmid owner perms bytes nattch status
0x0052e2c1 32768 pg 600 56 9
root@pg Packages]# lsof |grep 32768
postgres 2089 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2092 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2093 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2094 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2095 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2098 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2135 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2135 pg 19u REG 253,0 32768 453173 /opt/postgres/data/base/13212/2662
postgres 2138 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2138 pg 7u REG 253,0 32768 453173 /opt/postgres/data/base/13212/2662
postgres 2138 pg 24u REG 253,0 32768 453425 /opt/postgres/data/base/13212/2703
postgres 2138 pg 33u REG 253,0 32768 453097 /opt/postgres/data/base/13212/2610
postgres 2138 pg 71u REG 253,0 32768 453408 /opt/postgres/data/base/13212/2696
postgres 2143 pg DEL REG 0,4 32768 /SYSV0052e2c1
 
[root@pg Packages]# ps -ef |grep 2089
pg 2089 1 0 14:24 pts/0 00:00:00 /opt/postgres/bin/postgres
pg 2090 2089 0 14:24 ? 00:00:00 postgres: logger process
pg 2092 2089 0 14:24 ? 00:00:00 postgres: checkpointer process
pg 2093 2089 0 14:24 ? 00:00:00 postgres: writer process
pg 2094 2089 0 14:24 ? 00:00:00 postgres: wal writer process
pg 2095 2089 0 14:24 ? 00:00:00 postgres: autovacuum launcher process
pg 2096 2089 0 14:24 ? 00:00:00 postgres: archiver process
pg 2097 2089 0 14:24 ? 00:00:00 postgres: stats collector process
pg 2098 2089 0 14:24 ? 00:00:00 postgres: bgworker: logical replication launcher
pg 2135 2089 0 14:31 ? 00:00:00 postgres: pg postgres 192.168.6.1(55088) idle
pg 2138 2089 0 14:31 ? 00:00:00 postgres: test postgres [local] idle
pg 2143 2089 0 14:33 ? 00:00:00 postgres: pg postgres 192.168.6.1(55122) idle
root 2428 2104 0 16:50 pts/1 00:00:00 grep --color=auto 2089
 
 
[root@pg Packages]# ps -ef |grep 2092
pg 2092 2089 0 14:24 ? 00:00:00 postgres: checkpointer process
root 2469 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2092
[root@pg Packages]# ps -ef |grep 2093
pg 2093 2089 0 14:24 ? 00:00:00 postgres: writer process
root 2471 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2093
[root@pg Packages]# ps -ef |grep 2094
pg 2094 2089 0 14:24 ? 00:00:00 postgres: wal writer process
root 2473 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2094
[root@pg Packages]# ps -ef |grep 2095
pg 2095 2089 0 14:24 ? 00:00:00 postgres: autovacuum launcher process
root 2475 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2095
[root@pg Packages]# ps -ef |grep 2098
pg 2098 2089 0 14:24 ? 00:00:00 postgres: bgworker: logical replication launcher
root 2477 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2098
[root@pg Packages]# ps -ef |grep 2135
pg 2135 2089 0 14:31 ? 00:00:00 postgres: pg postgres 192.168.6.1(55088) idle
root 2479 2104 0 17:02 pts/1 00:00:00 grep --color=auto 2135
[root@pg Packages]# ps -ef |grep 2138
pg 2138 2089 0 14:31 ? 00:00:00 postgres: test postgres [local] idle
root 2481 2104 0 17:02 pts/1 00:00:00 grep --color=auto 2138
[root@pg Packages]# ps -ef |grep 2143
pg 2143 2089 0 14:33 ? 00:00:00 postgres: pg postgres 192.168.6.1(55122) idle
root 2484 2104 0 17:02 pts/1 00:00:00 grep --color=auto 2143
[root@pg Packages]#
```
 
VIRT,RES,SHR,虚拟内存和物理内存(转)
VIRT：
1、进程“需要的”虚拟内存大小，包括进程使用的库、代码、数据，以及malloc、new分配的堆空间和分配的栈空间等；
2、假如进程新申请10MB的内存，但实际只使用了1MB，那么它会增长10MB，而不是实际的1MB使用量。
3、VIRT = SWAP + RES
RES：
1、进程当前使用的内存大小，包括使用中的malloc、new分配的堆空间和分配的栈空间，但不包括swap out量；
2、包含其他进程的共享；
3、如果申请10MB的内存，实际使用1MB，它只增长1MB，与VIRT相反；
4、关于库占用内存的情况，它只统计加载的库文件所占内存大小。
5、RES = CODE + DATA
SHR：
1、除了自身进程的共享内存，也包括其他进程的共享内存；
2、虽然进程只使用了几个共享库的函数，但它包含了整个共享库的大小；
3、计算某个进程所占的物理内存大小公式：RES – SHR；
4、swap out后，它将会降下来。
 
```
曾工，你好
top - 11:28:43 up 30 days, 15:53, 3 users, load average: 0.00, 0.01, 0.19
Tasks: 454 total, 1 running, 453 sleeping, 0 stopped, 0 zombie
%Cpu(s): 0.0 us, 0.0 sy, 0.0 ni,100.0 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st
KiB Mem : 65460224 total, 1873028 free, 889816 used, 62697380 buff/cache
KiB Swap: 67108860 total, 63780520 free, 3328340 used. 43441744 avail Mem
PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
4358 postgres 20 0 17.034g 0.016t 0.016t S 0.0 26.1 14:21.90 postgres --checkpoint ≈ shared_buffer=16G
4359 postgres 20 0 17.013g 0.015t 0.015t S 0.0 24.8 6:05.04 postgres --write ≈ shared_buffer=16G
4344 postgres 20 0 17.013g 887356 886972 S 0.0 1.4 0:45.99 postgres --postmast ≈ 887M
9571 pguat 20 0 17.169g 719184 718668 S 0.0 1.1 1:13.27 postgres
4360 postgres 20 0 17.013g 525620 525316 S 0.3 0.8 32:56.91 postgres
根据以上抓取的信息分析，pg后台进程checkpoing和write均占用约16G内存。
通过对比其他环境的的数据库，发现均有此现象。
经过分析，此为正常现象，checkpoing和write均为postmast主进程fork出来的子进程，其使用的内存均为shared_buffer共享内存。Shared_buffer为16G。
分析：
在top命令中，进程占用的实际物理内存为RES-SHR
以上可以发现进程占用的物理内存均为0，均使用的共享内存。
查找进程占用的共享内存情况参考如下：
[pg@pg ~]$ ipcs -m
------ Shared Memory Segments --------
key shmid owner perms bytes nattch status
0x0052e2c1 32768 pg 600 56 9
root@pg Packages]# lsof |grep 32768
postgres 2089 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2092 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2093 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2094 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2095 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2098 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2135 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2135 pg 19u REG 253,0 32768 453173 /opt/postgres/data/base/13212/2662
postgres 2138 pg DEL REG 0,4 32768 /SYSV0052e2c1
postgres 2138 pg 7u REG 253,0 32768 453173 /opt/postgres/data/base/13212/2662
postgres 2138 pg 24u REG 253,0 32768 453425 /opt/postgres/data/base/13212/2703
postgres 2138 pg 33u REG 253,0 32768 453097 /opt/postgres/data/base/13212/2610
postgres 2138 pg 71u REG 253,0 32768 453408 /opt/postgres/data/base/13212/2696
postgres 2143 pg DEL REG 0,4 32768 /SYSV0052e2c1
 
[root@pg Packages]# ps -ef |grep 2089
pg 2089 1 0 14:24 pts/0 00:00:00 /opt/postgres/bin/postgres
pg 2090 2089 0 14:24 ? 00:00:00 postgres: logger process
pg 2092 2089 0 14:24 ? 00:00:00 postgres: checkpointer process
pg 2093 2089 0 14:24 ? 00:00:00 postgres: writer process
pg 2094 2089 0 14:24 ? 00:00:00 postgres: wal writer process
pg 2095 2089 0 14:24 ? 00:00:00 postgres: autovacuum launcher process
pg 2096 2089 0 14:24 ? 00:00:00 postgres: archiver process
pg 2097 2089 0 14:24 ? 00:00:00 postgres: stats collector process
pg 2098 2089 0 14:24 ? 00:00:00 postgres: bgworker: logical replication launcher
pg 2135 2089 0 14:31 ? 00:00:00 postgres: pg postgres 192.168.6.1(55088) idle
pg 2138 2089 0 14:31 ? 00:00:00 postgres: test postgres [local] idle
pg 2143 2089 0 14:33 ? 00:00:00 postgres: pg postgres 192.168.6.1(55122) idle
root 2428 2104 0 16:50 pts/1 00:00:00 grep --color=auto 2089
 
 
[root@pg Packages]# ps -ef |grep 2092
pg 2092 2089 0 14:24 ? 00:00:00 postgres: checkpointer process
root 2469 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2092
[root@pg Packages]# ps -ef |grep 2093
pg 2093 2089 0 14:24 ? 00:00:00 postgres: writer process
root 2471 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2093
[root@pg Packages]# ps -ef |grep 2094
pg 2094 2089 0 14:24 ? 00:00:00 postgres: wal writer process
root 2473 2104 0 17:01 pts/1 00:00:00 grep --color=auto 2094
[root@pg Packages]# ps -ef |grep 2095
`        
 
**postgresql 消耗内存计算方法**
 
```
① wal_buffers默认值为-1,此时wal_buffers使用的shared_buffers,wal_buffers大小为shared_buffers的1/32
② autovacuum_work_mem默认值为-1,此时使用maintenance_work_mem值
1 不使用wal_buffers、autovacuum_work_mem
计算公式为:
max_connections*work_mem + max_connections*temp_buffers+shared_buffers+(autovacuum_max_workers * maintenance_work_mem）
假设PostgreSQL的配置如下:
max_connections = 100
temp_buffers=32MB
work_mem=32MB
shared_buffers=19GB
autovacuum_max_workers = 3
maintenance_work_mem=1GB #默认值64MB
select(
(100*(32*1024*1024)::bigint)
+ (100*(32*1024*1024)::bigint)
+ (19*(1024*1024*1024)::bigint)
+ (3 * (1024*1024*1024)::bigint )
)::float8 / 1024 / 1024 / 1024
--output
28.25
此时pg满载峰值时最多使用28.25GB内存,物理内容为32GB时,还有3.75GB内存给操作系统使用.
2 使用wal_buffers,不使用autovacuum_work_mem
计算公式为:
max_connections*work_mem + max_connections*temp_buffers +shared_buffers+wal_buffers+(autovacuum_max_workers * autovacuum_work_mem）
假设PostgreSQL的配置如下:
max_connections = 100
temp_buffers=32MB
work_mem=32MB
shared_buffers=19GB
wal_buffers=262143kB #wal_buffers支持的最大内存大小
autovacuum_max_workers = 3
maintenance_work_mem=1GB
select(
(100*(32*1024*1024)::bigint)
+ (100*(32*1024*1024)::bigint)
+ (19*(1024*1024*1024)::bigint)
+ (262143*1024)::bigint
+ (3 * (1024*1024*1024)::bigint )
)::float8 / 1024 / 1024 / 1024
--output
28.4999990463257
此时pg满载峰值时最多使用28.5GB内存,物理内容为32GB,还有3.5GB内存给操作系统使用.
3 同时使用wal_buffers、autovacuum_work_mem[建议使用]
计算公式为:
max_connections*work_mem + max_connections*temp_buffers +shared_buffers+wal_buffers+(autovacuum_max_workers * autovacuum_work_mem）+ maintenance_work_mem
假设PostgreSQL的配置如下:
max_connections = 100
temp_buffers=32MB
work_mem=32MB
shared_buffers=19GB
wal_buffers=262143kB #wal_buffers支持的最大内存大小
autovacuum_max_workers = 3
autovacuum_work_mem=256MB
maintenance_work_mem=2GB
select(
(100*(32*1024*1024)::bigint)
+ (100*(32*1024*1024)::bigint)
+ (19*(1024*1024*1024)::bigint)
+ (262143*1024)::bigint
+ (3 * (256*1024*1024)::bigint )
+ ( 2 * (1024*1024*1024)::bigint )
)::float8 / 1024 / 1024 / 1024
--output
28.24999904632
此时pg载峰值时最多使用28.25GB内存,物理内容为32GB时,还有3.75GB内存给操作系统使用.建议所有内存消耗根据硬件配置,也就是使用这个配置.
Measure
Measure
```