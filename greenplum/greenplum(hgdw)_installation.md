# greenplum(hgdw)_installation

**作者**

Chrisx

**日期**

2021-09-13

**内容**

greenplum(hgdw)安装

下载[greenplum-db](https://github.com/greenplum-db/gpdb/releases)

安装[Installation Guide](https://docs.greenplum.org/6-8/install_guide/install_guide.html)

安装前参考最佳实践[greenplum(hgdw)_Best_practices](./greenplum(hgdw)_Best_practices.md)进行优化

---

[TOC]

## pretasks

OS：rhel7.5 x86_64

DB：GreenPlum db 6.x(hgdw3.0)

### 修改主机名并配置解析

```bash
cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# hgdw
10.100.10.163    redhat163
10.100.10.164    redhat164
10.100.10.165    redhat165
10.100.10.166    redhat166
10.100.10.167    redhat167

```

### 创建操作系统用户

使用root用户登录主节点主机系统，在主节点创建数据库用gpadmin户，切换到新用户运行运行数据仓库安装包。

```bash
groupadd hgadmin
useradd -g hgadmin hgadmin; echo hgadmin | passwd -f --stdin hgadmin
```

## install

### 安装数据仓库软件

gp6.2 开始不提供zip格式压缩包，仅提供rpm包，安装分以下步骤

1. 安装master(rpm -ivh / yum install -y),不可以指定安装目录，默认安装到/usr/local/
2. gp6 没有 gpseginstall工具。需要各个节点单独安装。
3. 集群性能校验
4. gpinitsystem 集群初始化

安装软件

```bash
rpm -ivh xxx.rpm

```

hgdw 解压即可

```sh
mkdir -p /opt/software
chmod 777 /opt/software

unzip -d /usr/local /opt/software/hgdw_3.0.zip
chown hgadmin:hgadmin /usr/local/hgdw -R
```

### 环境变量

添加下面初始化变量到gpadmin用户.bash_profile文件

```bash

# hgdw
source /usr/local/hgdw/hgdw_path.sh ##该文件包含数据仓库的基础环境变量。默认自动生成
export MASTER_DATA_DIRECTORY=/pgdata/master/hgseg-1
export PGPORT=5433
export PGUSER=hgadmin
export PGDATABASE=hgdw

source .bash_profile  #使立即生效

```

### 创建hostfile

创建几个host文件，用于后续使用hgssh,hgscp 等脚本host参数文件

```sh
# 主机信息
10.100.10.163 redhat163
10.100.10.164 redhat164
10.100.10.165 redhat165
10.100.10.166 redhat166
10.100.10.167 redhat167

```

* hostfile_exkeys 内容是集群所有主机名或ip，用于ssh互信配置
* hostfile_all 内容是集群所有主机名或ip，包含master,segment,standby等
* hostfile_prim 包含master，standby
* hostfile_seg 内容是所有 segment主机名或ip
* hostfile_gpcheckperfnet 所有节点
* hostfile_gpcheckperfio 计算节点

```bash
cat hostfile_exkeys
10.100.10.163
10.100.10.164
10.100.10.165
10.100.10.166
10.100.10.167
cat hostfile_all
redhat163
redhat164
redhat165
redhat166
redhat167

cat hostfile_prim
redhat163
redhat164

cat hostfile_seg
redhat164
redhat165
redhat166
redhat167

cat hostfile_gpcheckperfnet
redhat163
redhat164
redhat165
redhat166
redhat167

hostfile_gpcheckperfio

redhat163
redhat164
redhat165
redhat166
redhat167
```

### 同步系统时钟

瀚高数据仓库建议使用NTP(网络时间协议)来同步瀚高数据仓库系统中所有主机的系统时钟
在计算节点主机上，NTP应该配置主节点主机作为主时间源，而备用主节点主机作为备选时源。在主节点和备用主节点上配置NTP到用户首选的时间服务器。

配置NTP

在主节点主机，以root登录编辑/etc/ntp.conf文件。设置server参数指向数据中心的NTP时间服务器。例如(假如10.6.220.20是数据中心NTP服务器的IP地址)：server 10.6.220.20

在每个计算节点主机，以root登录编辑/etc/ntp.conf文件。设置第一个server参数指向主节点主机，第二个server参数指向备用主节点主机。例如：
server gp1 prefer  
server gp2

在备用主节点主机，以root登录编辑/etc/ntp.conf文件。设置第一个server参数指向主节点主机，第二个参数指向数据中心的时间服务器。例如：

server gp1 prefer  
server 10.6.220.20

在主节点主机，使用NTP守护进程同步所有计算节点主机的系统时钟。例如，使用gpssh来完成：
gpssh -f hostfile_gpssh_allhosts  -v -e 'ntpd'

ref [ntp](../os/ntp.md)

### 配置节点互信

配置互信

root用户和hgadin用户都需要做

root

1. 主机生成密钥

```bash
ssh-keygen -t rsa

```

2. 将公钥复制到各个节点机器的authorized_keys文件中

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub root@redhat163
ssh-copy-id -i ~/.ssh/id_rsa.pub root@redhat164
ssh-copy-id -i ~/.ssh/id_rsa.pub root@redhat165
ssh-copy-id -i ~/.ssh/id_rsa.pub root@redhat166
ssh-copy-id -i ~/.ssh/id_rsa.pub root@redhat167

```

3. 使用hgssh-exkeys 工具，打通n-n的免密登陆

```bash
source /usr/local/hgdw/hgdw_path.sh
hgssh-exkeys -f  /home/hgadmin/hostfile_exkeys


[root@redhat163 ~]# hgssh-exkeys -f  /home/hgadmin/hostfile_exkeys
[STEP 1 of 5] create local ID and authorize on local host
  ... /root/.ssh/id_rsa file exists ... key generation skipped

[STEP 2 of 5] keyscan all hosts and update known_hosts file

[STEP 3 of 5] retrieving credentials from remote hosts
  ... send to 10.100.10.163
  ... send to 10.100.10.164
  ... send to 10.100.10.165
  ... send to 10.100.10.166
  ... send to 10.100.10.167

[STEP 4 of 5] determine common authentication file content

[STEP 5 of 5] copy authentication files to all remote hosts
  ... finished key exchange with 10.100.10.163
  ... finished key exchange with 10.100.10.164
  ... finished key exchange with 10.100.10.165
  ... finished key exchange with 10.100.10.166
  ... finished key exchange with 10.100.10.167

[INFO] completed successfully
[root@redhat163 ~]#

验证
hgssh -f  /home/hgadmin/hostfile_all -e 'date'

[root@redhat163 ~]# hgssh -f  /home/hgadmin/hostfile_all -e 'date'
[redhat166] date
[redhat166] Wed Jul 29 16:43:53 CST 2020
[redhat164] date
[redhat164] Wed Jul 29 16:43:53 CST 2020
[redhat165] date
[redhat165] Wed Jul 29 16:43:53 CST 2020
[redhat167] date
[redhat167] Wed Jul 29 16:43:54 CST 2020
[redhat163] date
[redhat163] Wed Jul 29 16:43:54 CST 2020
[root@redhat163 ~]#

```

hgadmin

```bash
su - hgadmin

ssh-keygen -t rsa

ssh-copy-id -i ~/.ssh/id_rsa.pub hgadmin@redhat163
ssh-copy-id -i ~/.ssh/id_rsa.pub hgadmin@redhat164
ssh-copy-id -i ~/.ssh/id_rsa.pub hgadmin@redhat165
ssh-copy-id -i ~/.ssh/id_rsa.pub hgadmin@redhat166
ssh-copy-id -i ~/.ssh/id_rsa.pub hgadmin@redhat167

hgssh-exkeys -f  /home/hgadmin/hostfile_exkeys

hgssh -f  /home/hgadmin/hostfile_all -e 'date'

```

### 同步个节点环境变量

```bash
gpscp -f  /home/hgadmin/hostfile_seg /home/hgadmin/.bash_profile  hgadmin@=:/home/hgadmin/.bash_profile

```

### 在所有计算节点上安装配置数据仓库

```bash
root
source /usr/local/hgdw/hgdw_path.sh
hgssh -f  /home/hgadmin/hostfile_seg -e 'mkdir -p /opt/software'
hgssh -f  /home/hgadmin/hostfile_seg -e 'chmod 777 /opt/software'


# greenplum
gpscp -f  /home/hgadmin/hostfile_seg /opt/software/greenplum-db-6.5.0-rhel7-x86_64.rpm  hgadmin@=:/opt/software/
su - root
source /usr/local/greenplum-db/greenplum_path.sh
gpssh -f  /home/hgadmin/hostfile_seg -e 'yum install apr -y'
gpssh -f  /home/hgadmin/hostfile_seg -e 'yum install apr-util -y'
gpssh -f  /home/hgadmin/hostfile_seg -e 'rpm -ivh /opt/software/greenplum-db-6.5.0-rhel7-x86_64.rpm'
gpssh -f  /home/hgadmin/hostfile_seg -e 'chown hgadmin:hgadmin /usr/local/greenplum* -R'

# hgdw
gpscp -f  /home/hgadmin/hostfile_seg /opt/software/hgdw-3.0.zip  hgadmin@=:/opt/software/
hgssh -f  /home/hgadmin/hostfile_seg -e 'unzip -d /usr/local /opt/software/hgdw-3.0.zip'
hgssh -f  /home/hgadmin/hostfile_seg -e 'chown hgadmin:hgadmin /usr/local/hgdw -R'


```

### 创建数据存储区域

创建或者选择一个用于主节点的数据存储区域。该目录需要有足够的磁盘空间并确保归属于gpadmin用户和组。

```bash
su - hgadmin
创建master 数据目录

hgssh -f /home/hgadmin/hostfile_prim -e 'mkdir -p /pgdata/master'

创建segment 数据目录,计划使用mirror,创建primary和mirror目录

hgssh -f /home/hgadmin/hostfile_seg -e 'mkdir -p /pgdata/hgsegp'
hgssh -f /home/hgadmin/hostfile_seg -e 'mkdir -p /pgdata/hgsegm'

```

## 检查系统环境

瀚高数据仓库提供命令用以检查系统的配置和性能，这些命令可以在瀚高数据仓库安装的$GPHOME/bin目录下找到。初始化瀚高数据仓库系统之前，应执行硬件性能检查。

瀚高数据仓库提供的gpcheckperf命令可用来在瀚高数据仓库集群主机上检查硬件和系统级gpcheckperf在指定的主机上启动一个会话并执行下面的性能测试：

检查网络性能
检查磁盘I/O性能
检查内存带宽

在使用gpcheckperf之前，必须已经在所有相关需要做性能测试的主机之间建立了互信。如果还没有做，可以使用gpssh-exkeys命令来建立互信。gpcheckperf会调用gpssh和gpscp，所以这些命令必须已经存在在$PATH中。

1. 检查网络性能

```bash
su - hgadmin

gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfnet -r N -d /tmp > subnet1.out


[hgadmin@redhat163 ~]$ gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfnet -r N -d /tmp
/usr/local/hgdw/bin/gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfnet -r N -d /tmp

-------------------
--  NETPERF TEST
-------------------
NOTICE: -t is deprecated, and has no effect
NOTICE: -f is deprecated, and has no effect
NOTICE: -t is deprecated, and has no effect
NOTICE: -f is deprecated, and has no effect
NOTICE: -t is deprecated, and has no effect
NOTICE: -f is deprecated, and has no effect
NOTICE: -t is deprecated, and has no effect
NOTICE: -f is deprecated, and has no effect
NOTICE: -t is deprecated, and has no effect
NOTICE: -f is deprecated, and has no effect
NOTICE: -t is deprecated, and has no effect
NOTICE: -f is deprecated, and has no effect

====================
==  RESULT 2020-07-29T17:01:50.831876
  ==================
Netperf bisection bandwidth test
redhat163 -> redhat164 = 1828.640000
redhat165 -> redhat166 = 1959.020000
redhat167 -> redhat163 = 555.240000
redhat164 -> redhat163 = 1319.050000
redhat166 -> redhat165 = 2008.520000
redhat163 -> redhat167 = 512.230000

Summary:
sum = 8182.70 MB/sec
min = 512.23 MB/sec
max = 2008.52 MB/sec
avg = 1363.78 MB/sec
median = 1828.64 MB/sec

[Warning] connection between redhat167 and redhat163 is no good
[Warning] connection between redhat164 and redhat163 is no good
[Warning] connection between redhat163 and redhat167 is no good
```

2. 检查磁盘I/O和内存带宽

```sh
使用gpadmin用户登录主节点主机。
创建一个名为hostfile_gpcheckperfio的文件，包含所有计算节点主机名，每个名称一行。不要包含主节点主机名。

gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfio -r ds -d /pgdata/hgsegp -d /pgdata/hgsegm -S 100GB > io.out  #目录指定primary和mirror所在目录的磁盘

[hgadmin@redhat163 pgdata]$ gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfio -r ds -d /pgdata/hgsegp -d /pgdata/hgsegm 
/usr/local/hgdw/bin/gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfio -r ds -d /pgdata/hgsegp -d /pgdata/hgsegm

--------------------
--  DISK WRITE TEST
--------------------

--------------------
--  DISK READ TEST
--------------------

--------------------
--  STREAM TEST
--------------------

====================
==  RESULT 2020-07-29T17:58:00.301249
====================

 disk write avg time (sec): 773.71
 disk write tot bytes: 2694776094720
 disk write tot bandwidth (MB/s): 3389.56
 disk write min bandwidth (MB/s): 783.37 [redhat164]
 disk write max bandwidth (MB/s): 985.13 [redhat167]


 disk read avg time (sec): 1090.41
 disk read tot bytes: 2694776094720
 disk read tot bandwidth (MB/s): 2344.01
 disk read min bandwidth (MB/s): 564.73 [redhat164]
 disk read max bandwidth (MB/s): 604.68 [redhat166]


 stream tot bandwidth (MB/s): 44294.10
 stream min bandwidth (MB/s): 9532.90 [redhat166]
 stream max bandwidth (MB/s): 13136.20 [redhat167]

[hgadmin@redhat163 pgdata]$
```

## 初始化数据仓库

gpinitsystem，能够在主节点和每个计算节点实例上按照正确的顺序完成初始化和启动操作。
在瀚高数据仓库系统初始化并启动之后，就可以像使用常规的PostgreSQL数据库一样，通过连接到瀚高数据仓库主节点来创建和管理数据库。

### 创建瀚高数据仓库配置文件

数据仓库配置文件会告诉gpinitsystem命令按照什么样的方式配置系统。在软件的安装目录的$GPHOME/docs/cli_help/gpconfigs/gpinitsystem_config文件可以作为配置的例子参考

1. 以gpadmin用户登录：

```sh
$ su - gpadmin

```

2. 拷贝一个gpinitsystem_config示例文件。例如

```sh
cp $GPHOME/docs/cli_help/gpconfigs/gpinitsystem_config /home/hgadmin/gpinitsystem_config

cp /usr/local/hgdw/docs/cli_help/hgconfigs/hginitsystem_config /home/hgadmin/hginitsystem_config

```

3. 打开刚拷贝的文件并编辑。

DATA_DIRECTORY参数指定每个计算节点主机配置多少个计算节点实例。如果在host文件中为每个计算节点主机列出了多个网口，这些实例将平均分布到所有列出的网口上。
下面是一个gpinitsystem_config文件的例子：

```sh
ARRAY_NAME="HighGo DataWarehouse"
SEG_PREFIX=hgseg
PORT_BASE=6000
declare -a DATA_DIRECTORY=(/pgdata/hgsegp /pgdata/hgsegp /pgdata/hgsegp /pgdata/hgsegp)
MASTER_HOSTNAME=redhat163
MASTER_DIRECTORY=/pgdata/master
MASTER_PORT=5433
TRUSTED_SHELL=ssh
CHECK_POINT_SEGMENTS=80
ENCODING=UNICODE

```

4. 作为可选项，可以配置镜像计算节点实例，取消文件中的注释并根据环境情况配置参数。下面是gpinitsystem_config文件中可选配置镜像的例子：

```sh
MIRROR_PORT_BASE=7000
declare -a MIRROR_DATA_DIRECTORY=(/pgdata/hgsegm /pgdata/hgsegm /pgdata/hgsegm /pgdata/hgsegm)

DATABASE_NAME=hgdw

```

> 注意：可以在初始化时值配置主计算节点实例，而在之后使用gpaddmirrors命令部署镜像计算节点实例。

5. 保存关闭该文件。

```bash
[hgadmin@redhat163 ~]$ cat hginitsystem_config |grep -v '#' |grep -v '^$'
ARRAY_NAME="HighGo DataWarehouse"
SEG_PREFIX=hgseg
PORT_BASE=6000
declare -a DATA_DIRECTORY=(/pgdata/hgsegp /pgdata/hgsegp /pgdata/hgsegp /pgdata/hgsegp)
MASTER_HOSTNAME=redhat163
MASTER_DIRECTORY=/pgdata/master
MASTER_PORT=5433
TRUSTED_SHELL=ssh
CHECK_POINT_SEGMENTS=80
ENCODING=UNICODE
MIRROR_PORT_BASE=7000
declare -a MIRROR_DATA_DIRECTORY=(/pgdata/hgsegm /pgdata/hgsegm /pgdata/hgsegm /pgdata/hgsegm)
DATABASE_NAME=hgdw
```

### 初始化数据库

i /etc/profile

```bash
# hgdw
ulimit -HSn 1024000

[hgadmin@redhat163 ~]$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 511547
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024000
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 511547
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
[hgadmin@redhat163 ~]$

```

运行gpinitsystem命令将根据指定的配置文件创建一个瀚高数据仓库系统。
运行初始化命令,指定一个主机清单文件,该文件指定的是计算节点,不包含master和standby主机

hginitsystem -c /home/hgadmin/hginitsystem_config -h /home/hgadmin/hostfile_seg -b 8GB -m 1000

64GB占用物理内存的50%,每天机器8个,每个8G


命令将自动检查安装信息，确认可以连接到每个主机，可以访问配置文件中指定的每个目录。如果检查都通过了，将会提示确认配置信息。例如：

=> Continue with Greenplum creation? Yy/Nn


输入y以开始初始化。

该命令将初始化主节点实例和系统中的每个计算节点实例。每个计算节点实例的安装是并行的。 计算节点实例的数量决定这个过程使用的时间。

在成功安装初始化结束时， 命令将会启动瀚高数据仓库系统，并可以看到如下提示信息：

=> Database successfully started

[comment]: <>

<!--
```bash
[hgadmin@redhat163 pgdata]$ hginitsystem -c /home/hgadmin/hginitsystem_config -h /home/hgadmin/hostfile_seg -b 8GB -m 1000
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Checking configuration parameters, please wait...
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Reading HGDW configuration file /home/hgadmin/hginitsystem_config
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Locale has not been set in /home/hgadmin/hginitsystem_config, will set to default value
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Locale set to en_US.utf8
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Checking configuration parameters, Completed
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Commencing multi-home checks, please wait...
....
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Configuring build for standard array
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Commencing multi-home checks, Completed
20200729:19:37:21:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Building primary segment instance array, please wait...
................
20200729:19:37:24:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Building group mirror array type , please wait...
................
20200729:19:37:28:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Checking Master host
20200729:19:37:28:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Checking new segment hosts, please wait...
20200729:19:37:28:032001 hginitsystem:redhat163:hgadmin-[WARN]:-Host redhat163 open files limit is 1024 should be >= 65535
20200729:19:37:28:032001 hginitsystem:redhat163:hgadmin-[WARN]:-Host redhat163 open files limit is 1024 should be >= 65535
20200729:19:37:29:032001 hginitsystem:redhat163:hgadmin-[WARN]:-Host redhat163 open files limit is 1024 should be >= 65535
20200729:19:37:29:032001 hginitsystem:redhat163:hgadmin-[WARN]:-Host redhat163 open files limit is 1024 should be >= 65535
................................
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Checking new segment hosts, Completed
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-HGDW Database Creation Parameters
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:---------------------------------------
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master Configuration
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:---------------------------------------
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master instance name       = HighGo DataWarehouse
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master hostname            = redhat163
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master port                = 5433
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master instance dir        = /pgdata/master/hgseg-1
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master LOCALE              = en_US.utf8
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-HGDW segment prefix   = hgseg
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master Database            = hgdw
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master connections         = 1000
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master buffers             = 8GB
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Segment connections        = 3000
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Segment buffers            = 8GB
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Checkpoint segments        = 80
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Encoding                   = UNICODE
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Postgres param file        = Off
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Initdb to be used          = /usr/local/hgdw/bin/initdb
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-GP_LIBRARY_PATH is         = /usr/local/hgdw/lib
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-HEAP_CHECKSUM is           = on
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-HBA_HOSTNAMES is           = 0
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[WARN]:-Ulimit check               = Warnings generated, see log file <<<<<
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Array host connect type    = Single hostname per node
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master IP address [1]      = ::1
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master IP address [2]      = 10.100.10.163
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master IP address [3]      = 192.168.122.1
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Master IP address [4]      = fe80::5c1a:18d4:4ee5:2024
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Standby Master             = Not Configured
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Number of primary segments = 4
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Total Database segments    = 16
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Trusted shell              = ssh
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Number segment hosts       = 4
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Mirror port base           = 7000
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Number of mirror segments  = 4
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Mirroring config           = ON
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Mirroring type             = Group
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:----------------------------------------
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-HGDW Primary Segment Configuration
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:----------------------------------------
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegp/hgseg0   6000    2       0
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegp/hgseg1   6001    3       1
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegp/hgseg2   6002    4       2
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegp/hgseg3   6003    5       3
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegp/hgseg4   6000    6       4
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegp/hgseg5   6001    7       5
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegp/hgseg6   6002    8       6
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegp/hgseg7   6003    9       7
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegp/hgseg8   6000    10      8
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegp/hgseg9   6001    11      9
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegp/hgseg10  6002    12      10
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegp/hgseg11  6003    13      11
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegp/hgseg12  6000    14      12
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegp/hgseg13  6001    15      13
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegp/hgseg14  6002    16      14
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegp/hgseg15  6003    17      15
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:---------------------------------------
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-HGDW Mirror Segment Configuration
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:---------------------------------------
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegm/hgseg0   7000    18      0
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegm/hgseg1   7001    19      1
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegm/hgseg2   7002    20      2
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat165       /pgdata/hgsegm/hgseg3   7003    21      3
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegm/hgseg4   7000    22      4
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegm/hgseg5   7001    23      5
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegm/hgseg6   7002    24      6
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat166       /pgdata/hgsegm/hgseg7   7003    25      7
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegm/hgseg8   7000    26      8
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegm/hgseg9   7001    27      9
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegm/hgseg10  7002    28      10
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat167       /pgdata/hgsegm/hgseg11  7003    29      11
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegm/hgseg12  7000    30      12
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegm/hgseg13  7001    31      13
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegm/hgseg14  7002    32      14
20200729:19:37:39:032001 hginitsystem:redhat163:hgadmin-[INFO]:-redhat164       /pgdata/hgsegm/hgseg15  7003    33      15

Continue with HGDW creation Yy|Nn (default=N):
> y
20200729:19:38:12:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Building the Master instance database, please wait...
20200729:19:39:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Starting the Master in admin mode
20200729:19:39:53:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Commencing parallel build of primary segment instances
20200729:19:39:53:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Spawning parallel processes    batch [1], please wait...
................
20200729:19:39:53:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Waiting for parallel processes batch [1], please wait...
.................................................................................................................
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:------------------------------------------------
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Parallel process exit status
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:------------------------------------------------
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Total processes marked as completed           = 16
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Total processes marked as killed              = 0
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Total processes marked as failed              = 0
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:------------------------------------------------
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Deleting distributed backout files
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Removing back out file
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-No errors generated from parallel processes
20200729:19:41:47:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Restarting the HGDW instance in production mode
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-Starting hgstop with args: -a -l /home/hgadmin/gpAdminLogs -m -d /pgdata/master/hgseg-1
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-Gathering information and validating the environment...
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-Obtaining HGDW Master catalog information
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-Obtaining Segment details from master...
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-HGDW Version: 'postgres (HGDW Database) 3.0'
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-Commencing Master instance shutdown with mode='smart'
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-Master segment instance directory=/pgdata/master/hgseg-1
20200729:19:41:47:043384 hgstop:redhat163:hgadmin-[INFO]:-Stopping master segment and waiting for user connections to finish ...
server shutting down
20200729:19:41:48:043384 hgstop:redhat163:hgadmin-[INFO]:-Attempting forceful termination of any leftover master process
20200729:19:41:48:043384 hgstop:redhat163:hgadmin-[INFO]:-Terminating processes for segment /pgdata/master/hgseg-1
20200729:19:41:48:043409 hgstart:redhat163:hgadmin-[INFO]:-Starting hgstart with args: -a -l /home/hgadmin/gpAdminLogs -d /pgdata/master/hgseg-1
20200729:19:41:48:043409 hgstart:redhat163:hgadmin-[INFO]:-Gathering information and validating the environment...
20200729:19:41:48:043409 hgstart:redhat163:hgadmin-[INFO]:-HGDW Binary Version: 'postgres (HGDW Database) 3.0'
20200729:19:41:48:043409 hgstart:redhat163:hgadmin-[INFO]:-HGDW Catalog Version: '301908232'
20200729:19:41:48:043409 hgstart:redhat163:hgadmin-[INFO]:-Starting Master instance in admin mode
20200729:19:41:52:043409 hgstart:redhat163:hgadmin-[INFO]:-Obtaining HGDW Master catalog information
20200729:19:41:52:043409 hgstart:redhat163:hgadmin-[INFO]:-Obtaining Segment details from master...
20200729:19:41:52:043409 hgstart:redhat163:hgadmin-[INFO]:-Setting new master era
20200729:19:41:52:043409 hgstart:redhat163:hgadmin-[INFO]:-Master Started...
20200729:19:41:52:043409 hgstart:redhat163:hgadmin-[INFO]:-Shutting down master
20200729:19:41:53:043409 hgstart:redhat163:hgadmin-[INFO]:-Commencing parallel segment instance startup, please wait...
....
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-Process results...
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-   Successful segment starts                                            = 16
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-   Failed segment starts                                                = 0
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-   Skipped segment starts (segments are marked down in configuration)   = 0
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-Successfully started 16 of 16 segment instances
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200729:19:41:58:043409 hgstart:redhat163:hgadmin-[INFO]:-Starting Master instance redhat163 directory /pgdata/master/hgseg-1
20200729:19:42:02:043409 hgstart:redhat163:hgadmin-[INFO]:-Command pg_ctl reports Master redhat163 instance active
20200729:19:42:02:043409 hgstart:redhat163:hgadmin-[INFO]:-Connecting to dbname='template1' connect_timeout=15
20200729:19:42:02:043409 hgstart:redhat163:hgadmin-[INFO]:-No standby master configured.  skipping...
20200729:19:42:02:043409 hgstart:redhat163:hgadmin-[INFO]:-Database successfully started
20200729:19:42:02:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Completed restart of HGDW instance in production mode
20200729:19:42:05:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Commencing parallel build of mirror segment instances
20200729:19:42:05:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Spawning parallel processes    batch [1], please wait...
................
20200729:19:42:05:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Waiting for parallel processes batch [1], please wait...
..........
20200729:19:42:15:032001 hginitsystem:redhat163:hgadmin-[INFO]:------------------------------------------------
20200729:19:42:15:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Parallel process exit status
20200729:19:42:15:032001 hginitsystem:redhat163:hgadmin-[INFO]:------------------------------------------------
20200729:19:42:15:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Total processes marked as completed           = 16
20200729:19:42:15:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Total processes marked as killed              = 0
20200729:19:42:15:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Total processes marked as failed              = 0
20200729:19:42:15:032001 hginitsystem:redhat163:hgadmin-[INFO]:------------------------------------------------
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Scanning utility log file for any warning messages
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[WARN]:-*******************************************************
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[WARN]:-Scan of log file indicates that some warnings or errors
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[WARN]:-were generated during the array creation
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Please review contents of log file
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-/home/hgadmin/gpAdminLogs/hginitsystem_20200729.log
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-To determine level of criticality
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-These messages could be from a previous run of the utility
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-that was called today!
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[WARN]:-*******************************************************
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-HGDW Database instance successfully created
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-------------------------------------------------------
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-To complete the environment configuration, please
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-update hgadmin .bashrc file with the following
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-1. Ensure that the hgdw_path.sh file is sourced
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-2. Add "export MASTER_DATA_DIRECTORY=/pgdata/master/hgseg-1"
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-   to access the HGDW scripts for this instance:
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-   or, use -d /pgdata/master/hgseg-1 option for the HGDW scripts
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-   Example gpstate -d /pgdata/master/hgseg-1
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Script log file = /home/hgadmin/gpAdminLogs/hginitsystem_20200729.log
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-To remove instance, run gpdeletesystem utility
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-To initialize a Standby Master Segment for this HGDW instance
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Review options for gpinitstandby
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-------------------------------------------------------
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-The Master /pgdata/master/hgseg-1/pg_hba.conf post gpinitsystem
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-has been configured to allow all hosts within this new
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-array to intercommunicate. Any hosts external to this
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-new array must be explicitly added to this file
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-Refer to the HGDW Admin support guide which is
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-located in the /usr/local/hgdw/docs directory
20200729:19:42:16:032001 hginitsystem:redhat163:hgadmin-[INFO]:-------------------------------------------------------
[hgadmin@redhat163 pgdata]$
```

-->

失败回退

安装中途失败，提示使用 bash /home/gpadmin/gpAdminLogs/backout_gpinitsystem_gpadmin_* 回退，执行该脚本即可

删除重建

安装完成，出于种种原因，若需要集群删除重装，使用 gpdeletesystem 工具

```sh
gpdeletesystem -d /data/hgdata/master/gpseg-1 -f

-d 后面跟 MASTER_DATA_DIRECTORY（master 的数据目录），会清除master,segment所有的数据目录。
-f force， 终止所有进程，强制删除。

```

### 环境变量确认

必须在瀚高数据仓库主节点(包括备用主节点)设置相应的环境变量。在$GPHOME目录下的greenplum_path.sh文件提供了诸多瀚高数据仓库相关的环境变量。可以在gpadmin用户启动脚本(比如.bashrc)中加载这个文件。
瀚高数据仓库的管理命令还需要设置MASTER_DATA_DIRECTORY环境变量。这个变量应该指向gpinitsystem命令初始化时指定的主节点数据目录位置。

```bash
vi ~/.bash_profile
source /opt/gp/greenplum/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/pgdata/master
export PGPORT=5433
export PGUSER=gpadmin
export PGDATABASE=hgdw


如果有备用主节点，应该将环境变量的文件拷贝到备用主节点。例如：

scp ~/.bash_profile gp2:/home/gpadmin

```

## 常用命令

查看状态

```bash
hgstate

[hgadmin@redhat163 ~]$ hgstate
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-Starting hgstate with args:
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-local HGDW Version: 'postgres (HGDW Database) 3.0'
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-master HGDW Version: 'PostgreSQL 9.4.24 (HGDW Database 3.0 build dev) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-39), 64-bit compiled on Mar 26 2020 17:28:51'
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-Obtaining Segment details from master...
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-Gathering data from segments...
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-HGDW instance status summary
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Master instance                                           = Active
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Master standby                                            = redhat164
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Standby master state                                      = Standby host passive
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total segment instance count from metadata                = 32
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Primary Segment Status
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total primary segments                                    = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total primary segment valid (at master)                   = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total primary segment failures (at master)                = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid files found                = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of /tmp lock files found                     = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number postmaster processes found                   = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Mirror Segment Status
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-----------------------------------------------------
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total mirror segments                                     = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total mirror segment valid (at master)                    = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total mirror segment failures (at master)                 = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid files found                = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number of /tmp lock files found                     = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number postmaster processes found                   = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number mirror segments acting as primary segments   = 0
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-   Total number mirror segments acting as mirror segments    = 16
20200730:09:13:42:198062 hgstate:redhat163:hgadmin-[INFO]:-----------------------------------------------------
[hgadmin@redhat163 ~]$

```

其他操作

```bash
hgstart #启动数据库
hgstop -M fast   #快速关闭
hgstop -u  #加载文件

```

## poststep

### 优化数据库参数

ref [greenplum(hgdw)_Best_practices](./greenplum(hgdw)_Best_practices.md)

### 允许客户端连接

瀚高数据仓库第一次初始化之后，只允许gpadmin用户从本地进行连接（gpinitsystem时指定的系统用户）。如果希望其他用户或者客户端机器也能够访问瀚高数据仓库,必须设置数据库的访问权限。**只在主节点配置即可**

1.  listen_addresses默认就是*

```sql
hgdw=# show listen_addresses ;
 listen_addresses 
------------------
 *
(1 row)
```

2. 修改pg_hba.conf文件

```sh
cat pg_hba.conf  |grep -v '#'

host	all	gpadmin	192.168.80.147/32	trust
host	replication	gpadmin	192.168.80.147/32	trust
host	all	gpadmin	192.168.122.1/32	trust
host	replication	gpadmin	192.168.122.1/32	trust
local    all         gpadmin         ident
host     all         gpadmin         127.0.0.1/28    trust
host     all         gpadmin         192.168.80.146/32       trust
host     all         gpadmin         192.168.122.1/32       trust
host     all         gpadmin         192.168.80.147/32       trust
host     all         gpadmin         192.168.122.1/32       trust
host     all         gpadmin         ::1/128       trust
host     all         gpadmin         fe80::a00:27ff:fe7a:276e/128       trust
local    replication gpadmin         ident
host     replication gpadmin         samenet       trust
# hgdw
host    all     all             0.0.0.0/0       md5

```

### 添加standby

```sh
[hgadmin@redhat163 pgdata]$ gpinitstandby -s redhat164
20200729:19:44:30:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Validating environment and parameters for standby initialization...
20200729:19:44:30:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Checking for data directory /pgdata/master/hgseg-1 on redhat164
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:------------------------------------------------------
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW standby master initialization parameters
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:------------------------------------------------------
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW master hostname               = redhat163
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW master data directory         = /pgdata/master/hgseg-1
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW master port                   = 5433
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW standby master hostname       = redhat164
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW standby master port           = 5433
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW standby master data directory = /pgdata/master/hgseg-1
20200729:19:44:31:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-HGDW update system catalog         = On
Do you want to continue with standby master initialization? Yy|Nn (default=N):
> y
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Syncing HGDW Database extensions to standby
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-The packages on redhat164 are consistent.
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Adding standby master to catalog...
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Database catalog updated successfully.
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Updating pg_hba.conf file...
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to update pg_hba.conf bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment log file for more details
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to update pg_hba.conf bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment log file for more details
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to update pg_hba.conf bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment log file for more details
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to update pg_hba.conf bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment log file for more details
20200729:19:44:35:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-pg_hba.conf files updated successfully.
20200729:19:44:36:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Starting standby master
20200729:19:44:36:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Checking if standby master is running on host: redhat164  in directory: /pgdata/master/hgseg-1
20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Cleaning up pg_hba.conf backup files...
20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to cleanup pg_hba.conf backup file bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment for more details
20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to cleanup pg_hba.conf backup file bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment for more details
20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to cleanup pg_hba.conf backup file bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment for more details
20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Unable to cleanup pg_hba.conf backup file bash: /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py: Permission denied

20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[ERROR]:-Please check the segment for more details
20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Backup files of pg_hba.conf cleaned up successfully.
20200729:19:44:42:047597 gpinitstandby:redhat163:hgadmin-[INFO]:-Successfully created standby master on redhat164

[hgadmin@redhat163 hgseg-1]$ ls -atl /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py
-rw-r--r-- 1 hgadmin hgadmin 8496 Jul 29 16:22 /usr/local/hgdw/lib/python/gppylib/operations/initstandby.py
```

### 创建数据库并加载数据

验证安装成功之后，用户就可以创建数据库并加载数据了。关于创建数据库、模式、表或其他数据库对象的更多信息，请查看瀚高数据仓库管理员手册。

```sql

test_product.csv

0001,T 恤 , 衣服 ,1000,500,2017-09-20
0002, 打孔器 , 办公用品 ,500,320,2017-09-11
0003, 运动 T 恤 , 衣服 ,4000,2800,
0004, 菜刀 , 厨房用具 ,3000,2800,2017-09-20
0005, 高压锅 , 厨房用具 ,6800,5000,2017-01-15
0006, 叉子 , 厨房用具 ,500,,2017-09-20
0007, 切菜板 , 厨房用具 ,880,790,2017-04-28
0008, 圆珠笔 , 办公用品 ,100,,2017-11-11


nohup gpfdist -d /home/gpadmin/exttable -p 8888 -l /home/gpadmin/exttable/gpfdist.log 2>&1 &


create external table test_ext(
    p_id int,
    p_name text,
    p_type text,
    sale_price int,
    pruchase_price int,
    regist_date date
 )
 location ('gpfdist://192.168.80.146:8888/test_product.csv')
format 'CSV' (delimiter as ',' null as '')
;

hgdw=# select * from test_ext;
 p_id |  p_name   |  p_type   | sale_price | pruchase_price | regist_date 
------+-----------+-----------+------------+----------------+-------------
    1 | T恤       |  衣服     |       1000 |            500 | 2017-09-20
    2 |  打孔器   |  办公用品 |        500 |            320 | 2017-09-11
    3 |  运动T恤  |  衣服     |       4000 |           2800 | 
    4 |  菜刀     |  厨房用具 |       3000 |           2800 | 2017-09-20
    5 |  高压锅   |  厨房用具 |       6800 |           5000 | 2017-01-15
    6 |  叉子     |  厨房用具 |        500 |                | 2017-09-20
    7 |  切菜板   |  厨房用具 |        880 |            790 | 2017-04-28
    8 |  圆珠笔   |  办公用品 |        100 |                | 2017-11-11
(8 rows)


create table test_product as select * from test_ext; 
```

### 查询会话信息

```sql
SELECT usename as "连接用户",
       datname as "连接业务库",
       STATE as "连接状态",
       application_name as "应用名称",
       client_addr as "连接地址",
       client_hostname as "会话主机名",
       client_port as "会话端口",
       waiting as "是否排队",
       xact_start as "开始时间",
       query as "会话语句",
       pid as "连接ID",
       now()-xact_start AS "执行时长"
FROM pg_stat_activity
WHERE now()-xact_start>interval '5 sec'
  AND query !~ '^COPY'
  AND STATE<>'idle'
ORDER BY xact_start;

```
