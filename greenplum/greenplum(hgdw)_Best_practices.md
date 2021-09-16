# greenplum(hgdw)_Best_practices

**作者**

Chrisx

**日期**

2021-09-13

**内容**

greenplum(hgdw)最佳实践

ref [最佳实践概要](https://gp-docs-cn.github.io/docs/best_practices/summary.html)
ref [Greenplum Database Best Practices](https://docs.greenplum.org/6-8/best_practices/intro.html)

----

[toc]

## greenplum介绍

* Greenplum数据库是一种大规模并行处理（MPP）数据库服务器，其架构特别针对管理大规模分析型数据仓库以及商业智能工作负载而设计。
* MPP（也被称为shared nothing架构）指有两个或者更多个服务器协同执行一个操作的系统，每一个服务器都有其自己的内存、操作系统和磁盘。Greenplum使用这种高性能系统架构来分布数据的负载并且能够使用系统的所有资源并行处理一个查询。
* Greenplum数据库是基于PostgreSQL开源技术的。它本质上是多个PostgreSQL数据库实例一起工作形成的一个紧密结合的数据库管理系统（DBMS）

![Greenplum数据库架构](https://docs.greenplum.org/6-8/install_guide/graphics/highlevel_arch.jpg)

关于Greenplum的Master

Greenplum数据库的Master是整个Greenplum数据库系统的入口，它接受连接和SQL查询并且把工作分布到Segment实例上。
Master是全局系统目录的所在地。全局系统目录是一组包含了有关Greenplum数据库系统本身的元数据的系统表。Master上不包含任何用户数据，数据只存在于Segment之上。

![Master Mirroring in Greenplum Database](https://docs.greenplum.org/6-8/admin_guide/graphics/standby_master.jpg)

关于Greenplum的Segment

Greenplum数据库的Segment实例是独立的PostgreSQL数据库，每一个都存储了数据的一部分并且执行查询处理的主要部分。
当一个用户通过Greenplum的Master连接到数据库并且发出一个查询时，在每一个Segment数据库上都会创建一些进程来处理该查询的工作。

![Group Segment Mirroring in Greenplum Database](https://docs.greenplum.org/6-8/admin_guide/graphics/group-mirroring.png)
![Group Segment Mirroring in Greenplum Database](https://docs.greenplum.org/6-8/admin_guide/graphics/spread-mirroring.png)

了解镜像失败和扩展情况

关于Greenplum的Interconnect
Interconnect指的是Segment之间的进程间通信以及这种通信所依赖的网络基础设施。推荐使用万兆网或者更快的系统。
默认情况下，Interconnect使用带流控制的用户数据包协议（UDPIFC）在网络上发送消息。

## 操作系统优化

### 配置操作系统防火墙及selinux

```bash
#禁用friewall
systemctl stop firewalld.service
systemctl disable firewalld.service
#禁用selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
```

### 文件系统

XFS是Greenplum数据库数据目录的最佳实践文件系统。XFS应该用下列选项挂载：

```sh
rw,nodev,noatime,nobarrier,inode64

在/etc/fstab 文件中增加
/dev/sdb        /pgdata         xfs     rw,nodev,noatime,nobarrier,inode64        0 0
```

:warning: XFS的优于ext4(扩展性、存储支持等)

### 设置磁盘设备的预读值

```bash

blockdev --setra 16384 /dev/sda
echo "blockdev --setra 16384 /dev/sda" >> /etc/rc.d/rc.local

/sbin/blockdev --getra /dev/sda
```

### 磁盘IO调度算法

```sh
# cat /sys/block/sdb/queue/scheduler
 noop anticipatory [deadline] cfq 

```

### 调整操作系统内核参数

```bash

/etc/sysctl.conf  #配置文件
sysctl -p #生效命令

kernel.shmmax = 500000000 #此参数设置系统范围内共享内存总数量（以内存页PAGE_SIZE表示）
kernel.shmmni = 4096  #共享内存段的个数
kernel.shmall = 4000000000  #此参数定义单个共享内存段的最大大小 (以字节为单位)

vm.swappiness = 1 #不禁用swap，但又最少量使用
vm.overcommit_memory = 2  #用户一次申请的内存大小不允许超过可用内存的大小(overcommit ratio)，否则可能会造成oom
vm.overcommit_ratio = 95  #vm.overcommit_ratio = (RAM - 0.026 * gp_vmem) / RAM
 
fs.aio-max-nr = 1048576 #异步io，提高性能
fs.file-max = 76724600  #内核定义的最大文件数
fs.nr_open =20480000  #单个进程最大文件数

net.ipv4.ip_local_port_range = 10000 65535 #本地自动分配的端口号范围，请不要在该范围内指定Greenplum数据库端口

```

### 不要配置OS使用大页

每台服务器有多个segment实例

### 配置操作系统资源限制

```bash
/etc/security/limits.conf #配置文件

gpadmin   soft        nofile      524288
gpadmin   hard        nofile      524288
gpadmin   soft        nproc       131072
gpadmin   hard        nproc       131072
 
/etc/security/limits.d/20-nproc.conf  #nproc的配置文件

* soft nproc 1024000
root soft nproc unlimited

验证，
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

### 设置磁盘的IO调度算法为deadline

对数据库来说，推荐的调度算法是deadline

```sh
一次性修改
echo deadline > /sys/block/sdb/queue/scheduler
cat /sys/block/sda/queue/scheduler
永久修改
grubby --update-kernel=ALL --args="elevator=deadline"

# cat /sys/block/sda/queue/scheduler
noop [deadline] cfq

```

## 网卡

建议双万兆

## 数据库优化

### 节点个数

一台服务器上的多个segment会共享cpu、mem、net

需要考虑的因素有

* cpu核心数
* RAM大小
* 网卡的个数
* 存储大小
* 是否混合存在primary和mirror段
* 主机上运行的进程数
* 非gp进程数

建议：一般4-8个

### 高可用

* 设置一个后备Master以便在主Master失效后接管
* 为所有的Segment设置镜像。
* 将主Segment和它们的镜像放置在不同的主机上以预防主机失效。（镜像策略）
* 考虑双集群配置以提供额外层次上的冗余以及额外的查询处理吞吐。
* 定期备份Greenplum数据库。备份文件不要放在本地

### 段内存配置gp_vmem_protect_limit

每个Segment数据库产生的所有进程使用的最大内存

1. 计算Greenplum数据库可用的总内存gp_vmem

```sh
gp_vmem = ((SWAP + RAM) – (7.5GB + 0.05 * RAM)) / 1.7 #其中 SWAP是该主机的交换空间（以GB为单位），RAM是该主机的RAM（以GB为单位）

```

2. 能在一台主机上运行的最主Segment的最大数量（包括镜像Segment由于主机或者Segment失效而被激活的情况）max_acting_primary_segments

```sh
8个

```

3. 每个Segment数据库产生的所有进程使用的最大内存gp_vmem_protect_limit #

```sh
gp_vmem_protect_limit = gp_vmem / acting_primary_segments #参数值配置转换为MB

```

### 语句内存配置statement_mem

段数据库中任何单个查询使用的内存量，如果语句需要额外的内存，它将溢出到磁盘。

```sh
(gp_vmem_protect_limit * .9) / max_expected_concurrent_queries  #max_expected_concurrent_queries最大并发查询数

```

### 溢出文件配置gp_workfile_limit_files_per_query

如果为查询分配的内存不足，无法在内存中执行，Greenplum数据库将在磁盘上创建溢出文件（也称为工作文件），默认情况下，单个查询最多只能创建100000个溢出文件，这对于大多数查询来说已经足够了。

达到限制时，语句会失败。可在适当情况下增加

### 其他

```sh

gpconfig -c max_connections -v 3000 -m 1200
gpconfig -c effective_cache_size  -v '64GB' -m '128GB'
gpconfig -c wal_keep_segments -v 20
gpconfig -c checkpoint_completion_target -v 0.8
gpconfig -c log_statement -v 'none' -m 'ddl'
gpconfig -c log_rotation_age -v '1d'
#gp_log_format                        | csv --格式默认csv


# 以下参数指定-m不生效，不能将master和segment单独设置
gpconfig -c work_mem  -v 64MB -m 128MB
gpconfig -c maintenance_work_mem  -v '128MB' -m 1GB
gpconfig -c temp_buffers -v '128MB' -m '1GB'


# 以下参数gpconfig无法修改，必须写入postgresql.auto.conf,不建议写入postgresql.conf.可能无法启动数据库.（可仅在master设置）

log_filename='hgdw_%d.csv'
logging_collector = on
log_truncate_on_rotation='on'
#checkpoint_timeout='30min'

```

重启数据库，使参数生效gpstop -u 重新加载配置文件 postgresql.conf 和 pg_hba.conf

<!--
如:
gpconfig -c maintenance_work_mem  -v 128MB -m 1GB
重启
[hgadmin@redhat163 hgseg-1]$ gpconfig -s maintenance_work_mem
Values on all segments are consistent
GUC          : maintenance_work_mem
Master  value: 1GB
Segment value: 1GB

PGOPTIONS='-c gp_session_role=utility' psql -h 192.168.6.12 -p 6000 -d hgdw

不指定m修改
gpconfig -c work_mem  -v 128MB
gpconfig -c maintenance_work_mem  -v '1GB'
gpconfig -c temp_buffers -v '1GB'

问题1
[hgadmin@redhat163 pg_log]$ gpconfig -c wal_keep_segments -v 20
20200730:10:22:33:211831 gpconfig:redhat163:hgadmin-[WARNING]:-disallowed GUCs file missing: '/usr/local/hgdw/share/hgdw/gucs_disallowed_in_file.txt'
20200730:10:22:33:211831 gpconfig:redhat163:hgadmin-[INFO]:-completed successfully with parameters '-c wal_keep_segments -v 20'


问题2
[hgadmin@redhat163 pg_log]$ gpconfig -c checkpoint_timeout -v '30min'
20200730:10:22:40:211962 gpconfig:redhat163:hgadmin-[WARNING]:-disallowed GUCs file missing: '/usr/local/hgdw/share/hgdw/gucs_disallowed_in_file.txt'
20200730:10:22:40:211962 gpconfig:redhat163:hgadmin-[CRITICAL]:-GUC Validation Failed: checkpoint_timeout cannot be changed under normal conditions. Please refer to gpconfig documentation.
GUC Validation Failed: checkpoint_timeout cannot be changed under normal conditions. Please refer to gpconfig documentation.
[hgadmin@redhat163 pg_log]$

问题3
[hgadmin@redhat163 pg_log]$ gpconfig -c log_destination -v 'csvlog'
20200730:10:24:22:212388 gpconfig:redhat163:hgadmin-[WARNING]:-disallowed GUCs file missing: '/usr/local/hgdw/share/hgdw/gucs_disallowed_in_file.txt'
20200730:10:24:22:212388 gpconfig:redhat163:hgadmin-[CRITICAL]:-GUC Validation Failed: log_destination cannot be changed under normal conditions. Please refer to gpconfig documentation.
GUC Validation Failed: log_destination cannot be changed under normal conditions. Please refer to gpconfig documentation.
[hgadmin@redhat163 pg_log]$
-->

## 开启OLTP功能

```sh
gpconfig -c gp_enable_global_deadlock_detector -v on

```

具体安装步骤[greenplum(hgdw)_installation](./greenplum(hgdw)_installation.md)

<!--
## 给数据库增加postgis功能

拿gpdb默认数据库举例
psql -d hgdw -f ${GPHOME}/share/postgresql/contrib/postgis-2.5/postgis.sql
psql -d hgdw -f ${GPHOME}/share/postgresql/contrib/postgis-2.5/postgis_comments.sql
psql -d hgdw -f ${GPHOME}/share/postgresql/contrib/postgis-2.5/rtpostgis.sql
psql -d hgdw -f ${GPHOME}/share/postgresql/contrib/postgis-2.5/raster_comments.sql
-->

<!--

### work_memwork_mem
（,global,物理内存的2%-4%）,segment用作sort,hash操作的内存大小
当PostgreSQL对大表进行排序时，数据库会按照此参数指定大小进行分片排序，将中间结果存放在临时文件中，这些中间结果的临时文件最终会再次合并排序，所以增加此参数可以减少临时文件个数进而提升排序效
率。当然如果设置过大，会导致swap的发生，所以设置此参数时仍需谨慎。查看现有配置值

修改配置
gpconfig -c work_mem  -v 128MB

另一种写法：SET work_mem TO '64MB'

配置成功返回：
gpadmin-[INFO]:-completed successfully with parameters 

### mainteance_work_mem
（global，CREATE INDEX, VACUUM等时用到,segment用于VACUUM,CREATE INDEX等操作的内存大小，缺省是16兆字节(16MB)。因为在一个数据库会话里， 任意时刻只有一个这样的操作可以执行，并且一个数据库安装通常不会有太多这样的工作并发执行， 把这个数值设置得比work_mem更大是安全的。 更大的设置可以改进清理和恢复数据库转储的速度。查看现有配置值


修改配置
gpconfig -c maintenance_work_mem  -v 1GB  

### max_statement_mem
设置每个查询最大使用的内存量，该参数是防止statement_mem参数设置的内存过大导致的内存溢出

修改配置
gpconfig -c max_statement_mem  -v 2000MB

### statement_mem
设置每个查询在segment主机中可用的内存，该参数设置的值不能超过max_statement_mem设置的值，如果配置了资源队列，则不能超过资源队列设置的值。
修改配置
gpconfig -c statement_mem  -v 256MB

### gp_vmem_protect_limit
控制了每个segment数据库为所有运行的查询分配的内存总量。如果查询需要的内存超过此值，则会失败。查看现有配置值
gpconfig -c gp_vmem_protect_limit  -v 64MB

使用gp_vmem_protect_limit设置实例可以为每个Segment数据库中执行的所有工作分配的最大内存。

### gp_workfile_limit_files_per_query
SQL查询分配的内存不足，Greenplum数据库会创建溢出文件（也叫工作文件）。在默认情况下，一个SQL查询最多可以创建 100000 个溢出文件，这足以满足大多数查询。 
该参数决定了一个查询最多可以创建多少个溢出文件。0 意味着没有限制。限制溢出文件数据可以防止失控查询破坏整个系统。 查看现有配置值
gpconfig -s gp_workfile_limit_files_per_query
Values on all segments are consistent
GUC          : gp_workfile_limit_files_per_query
Master  value: 100000
Segment value: 100000

### gp_statement_mem
服务器配置参数 gp_statement_mem 控制段数据库上单个查询可以使用的内存总量。如果语句需要更多内存，则会溢出数据到磁盘。

### effective_cache_size
（master节点，可以设为物理内存的85%）
这个参数告诉PostgreSQL的优化器有多少内存可以被用来缓存数据，以及帮助决定是否应该使用索引。这个数值越大，优化器使用索引的可能性也越大。因此这个数值应该设置成shared_buffers加上可用操作系统缓存两者的总量。通常这个数值会超过系统内存总量的50%以上。查看现有配置值：
gpconfig -s effective_cache_size
Values on all segments are consistent
GUC          : effective_cache_size
Master  value: 512MB
Segment value: 512MB

修改配置
gpconfig -c effective_cache_size  -v 40960MB

### gp_resqueue_priority_cpucores_per_segmentmaster
和每个segment的可以使用的cpu个数,每个segment的分配线程数;查看现有配置值
gpconfig -s gp_resqueue_priority_cpucores_per_segment
Values on all segments are consistent
GUC          : gp_resqueue_priority_cpucores_per_segment
Master  value: 4
Segment value: 4

gpconfig -s  checkpoint_segments  

修改配置
gpconfig -c gp_resqueue_priority_cpucores_per_segment  -v 8

### max_connections
最大连接数，Segment建议设置成Master的5-10倍。
max_connections = 200 #(master、standby)
max_connections = 1200 #(segment)查看现有配置值：
gpconfig -s max_connections

GUC          : max_connections
Master  value: 250
Segment value: 750

修改配置
gpconfig -c max_connections -v 1200 -m 300

### max_prepared_transactions
这个参数只有在启动数据库时，才能被设置。它决定能够同时处于prepared状态的事务的最大数目（参考PREPARE TRANSACTION命令）。如果它的值被设为0。则将数据库将关闭prepared事务的特性。它的值通常应该和max_connections的值一样大。每个事务消耗600字节(b)共享内存。查看现有配置值：
gpconfig -s max_prepared_transactions
Values on all segments are consistent
GUC          : max_prepared_transactions
Master  value: 250
Segment value: 250
修改配置
gpconfig -c max_prepared_transactions  -v 300

### max_files_per_process
设置每个服务器进程允许同时打开的最大文件数目。缺省是1000。 如果内核强制一个合理的每进程限制，那么你不用操心这个设置。 但是在一些平台上(特别是大多数BSD系统)， 内核允许独立进程打开比个系统真正可以支持的数目大得多得文件数。 如果你发现有"Too many open files"这样的失败现像，那么就尝试缩小这个设置。 这个值只能在服务器启动的时候设置。查看现有配置值：
gpconfig -s max_files_per_process
Values on all segments are consistent
GUC          : max_files_per_process
Master  value: 1000
Segment value: 1000
修改配置
gpconfig -c max_files_per_process -v 1000

### shared_buffers
只能配置segment节点，用作磁盘读写的内存缓冲区,开始可以设置一个较小的值，比如总内存的15%，然后逐渐增加，过程中监控性能提升和swap的情况。
gpconfig -s shared_buffers
Values on all segments are consistent
GUC          : shared_buffers
Master  value: 64MB
Segment value: 125MB

修改配置
gpconfig -c shared_buffers -v 1024MB
gpconfig -r shared_buffers -v 1024MB
### temp_buffers:
即临时缓冲区，拥有数据库访问临时数据，GP中默认值为1M，在访问比较到大的临时表时，对性能提升有很大帮助。

修改配置
gpconfig -c temp_buffers -v 1GB

### gp_fts_probe_threadcount
设置ftsprobe线程数，此参数建议大于等于每台服务器segments的数目。查看现有配置值：
gpconfig -s gp_fts_probe_threadcount
Values on all segments are consistent
GUC          : gp_fts_probe_threadcount
Master  value: 16
Segment value: 16
-->