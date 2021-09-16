# pg_installation

**作者**

Chrisx

**日期**

2021-04-23

**内容**

PostgreSQL源码安装与参数配置

ref [Installation from Source Code](https://www.postgresql.org/docs/13/installation.html)

---

[toc]

## 操作系统优化配置

参考[performance_turning_os](./performance_turning_os.md)

## 安装PostgreSQL

### 1. Requirements

* packages

*The following software packages are required for building PostgreSQL:*

rpm -q make gcc gzip readline readline-devel zlib zlib-devel
check
make --version
which make tar gzip

*The following packages are optional*

rpm -q perl python tcl OpenSSL Kerberos OpenLDAP

上述软件包的安装最要借助yum进行安装，以上软件包可能需要提供其他依赖包，配置完成yum之后

```sh
yum install make gcc gzip readline* zlib*
rpm -q make gcc gzip readline readline-devel zlib zlib-devel

```

suse参考[suse_readline](../os/suse_readline.md)

<!--
Ubuntu参考
dpkg -l make gcc gzip readline readline-devel zlib zlib-devel
apt-get install make 
apt-get install gcc 
apt-get install gzip 

需要先安装libreadline-gplv2-dev(代替readline，readline-devel )
apt-get install libreadline-gplv2-dev

在ubuntu软件源里zlib和zlib-devel叫做zlib1g zlib1g.dev 直接输命令后还是不能安装。这就要求我们先装ruby. 默认的安装源里没有zlib1g.dev。要在packages.ubuntu.com上找。
apt-get install ruby
apt-get install zlib1g  
apt-get install zlib1g-dev

dpkg -l make gcc gzip readline readline-devel zlib zlib-devel

-->

* disk space

source tree: 100 MB
installation directory: 20MB
empty database cluster: 35MB
databases: 大约是具有相同数据的平面文本文件的五倍

### 2. Getting The Source

Binary Package or Source code

The PostgreSQL 10.4 sources can be obtained from the download section of our website: https://www.postgresql.org/download/. You should get a file named postgresql-10.4.tar.gz

### 3. Installation Procedure

`安装方式1`：使用发行版二进制包的安装，配置本地yum源即可（iso）或官方下载包（rpm）
参考官方文档。

`安装方式2`：源码安装步骤
首先卸载掉原来的pg，如果已经安装的话

```sh
rpm -qa |grep postgres

rpm -e postgresql postgresql-server postgresql-contrib postgresql-devel

gunzip postgresql-10.4.tar.gz
tar xf postgresql-10.4.tar
groupadd -g 5432 postgres
useradd -u 5432 -g postgres postgres; echo postgres@111 | passwd -f --stdin postgres
chown -R postgres:postgres postgresql-10.4

mkdir -p /opt/postgres  #home单独存放
mkdir -p /opt/postgres_data #data单独存放
mkdir -p /opt/postgres_wal  #wal单独存放到高速磁盘上
mkdir -p /opt/postgres_arch #arch单独存放在存储空间较大的磁盘上
chown postgres:postgres /opt/postgres*

```

<!--
ubuntu
groupadd pg126
useradd -g pg126 -m -s /usr/bin/bash pg126

suse
groupadd postgres
useradd -g postgres -m -s /bin/bash postgres
-->

**su - postgres**

1) Configuration
./configure --prefix=/opt/postgres --with-openssl
configure的常用配置参数
-prefix=PREFIX指定安装路径，默认安装路径/usr/local/pgsql。
-with-segsize=SEGSIZE设置段大小（Set the segment size），合理的调大有助于减少大表消耗。建议为2的幂值，更改需要initd。
-with-blocksize=BLOCKSIZE设置块大小这是表中的存储和I/O的单元默认为8KB ，可以设置为1,2,4,8,16,32。
-with-wal-segsize=SEGSIZE 设置WAL段大小默认大小为16兆字节。该值必须是1到1024（兆字节）之间的2的幂。更改此值需要initdb。
-with-wal-blocksize=BLOCKSIZE设置WAL块大小，以千字节为单位。这是WAL日志中的存储和I/O单位。默认值为8千字节，适用于大多数情况; 但在特殊情况下，其他值可能有用。该值必须是1到64（千字节）之间的2的幂。更改此值需要initdb。
-with-pgport=NUMBER设置NUMBER为服务器和客户端的默认端口号。默认值为5432.以后可以随时更改端口，但如果在此处指定端口，则服务器和客户端都将具有相同的默认编译，这非常方便。通常，选择非默认值的唯一理由是，您打算在同一台机器上运行多个 PostgreSQL服务器。
-with-openssl 构建支持SSL（加密）连接。这需要安装OpenSSL包。configure将检查所需的头文件和库，以确保在继续之前您的OpenSSL安装已足够。
下载并解压PostgreSQL源码文件，进入到解压后的目录，执行以下命令，如需修改
--with-openssl 启用ssl功能
--with-libedit-preferred 支持使用BSD许可的libedit库，而不是GPL许可的Readline。
--without-readline 防止使用Readline库（以及libedit）。此选项禁用psql中的命令行编辑和历史记录。

1) Build
make
All of PostgreSQL successfully made. Ready to install.
or
make world
PostgreSQL, contrib, and documentation successfully made. Ready to install.

3) Regression Tests(optional)
make check

4) Installing the Files
To install PostgreSQL enter:
make install
To install the documentation (HTML and man pages), enter:
make install-docs
If you built the world above, type instead:
make install-world
This also installs the documentation.

> 注意
安装PostgreSQL插件，编译安装完成PostgreSQL二进制文件后，需要进一步编译PostgreSQL的自带插件，进入PostgreSQL源码文件中的contrib文件夹。如果没有编译安装扩展插件，只要当初用于编译pg的目录还在，就可以后期追加扩展插件.

执行命令如下
cd contrib
gmake install
执行完成后，扩展会将编译后的文件复制到$PGHOME/share/extension目录下。此时扩展并未安装到数据库中，如需要安装到数据库中，请参照《PostgreSQL插件安装和管理》。

**建议全部安装方式**

```sh
make world && make install-world
```

## Uninstallation

make uninstall
https://www.postgresql.org/docs/10/static/install-procedure.html

##　Client-only installation

If you want to install only the client applications and interface libraries, then you can use these commands:

make -C src/bin install
make -C src/include install
make -C src/interfaces install
make -C doc install

来自 <https://www.postgresql.org/docs/10/install-procedure.html>

## Post-Installation Setup

1. 环境变量

```sh
su - postgres
vi .bash_profile

#export PGHOSTADDR=192.168.6.15 --远程时可以定义
#export PGDATABASE=test
#export PGUSER=postgres
#export PGPASSWORD=postgres --基于安全考虑不建议配置
export PGPORT=5433
export PGHOME=/opt/postgres
export PGDATA=$PGHOME/data
export MANPATH=$PGHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
#alias psql='psql -d postgres'
export PATH=$PATH:$PGHOME/bin

source ~/.bash_profile

```

2. Creating a Database Cluster

Before you can do anything, you must initialize a database storage area on disk. We call this a database cluster. (The SQL standard uses the term catalog cluster.) A database cluster is a collection of databases that is managed by a single instance of a running database server. After initialization, a database cluster will contain a database named postgres, which is meant as a default database for use by utilities, users and third party applications. The database server itself does not require the postgres database to exist, but many external utility programs assume it exists. Another database created within each cluster during initialization is called template1. As the name suggests, this will be used as a template for subsequently created databases; it should not be used for actual work.

```sh
initdb -E UTF8 -D /opt/postgres/data --auth-host=md5 --auth-local=trust --wal-segsize=64 --locale=C -U postgres -W
```

> 如果配置了PGDATA可忽略 -D

3. Starting the Database Server

Before anyone can access the database, you must start the database server. The database server program is called postgres. The postgres program must know where to find the data it is supposed to use. This is done with the -D option. Thus, the simplest way to start the server is:

```sh
$ pg_ctl start -l logfile
will start the server in the background and put the output into the named log file

pg_ctl stop

```

## 安装后的优化配置

1. 修改数据库默认参数配置

数据库初始化完成后，会在指定的数据目录下生成必要的文件，其中包含数据库的参数文件postgres.conf，其中的参数使用的是默认值，需要根据操作系统及硬件环境进行优化，可能涉及到的参数如下：

参数优化参考[performance_turning_pg](./performance_turning_pg.md)

重启生效

2. 修改网络访问控制

允许什么样的客户端连接到自己
sed -i '$a host \t all \t all \t 0.0.0.0/0 \t md5' $PGDATA/pg_hba.conf  #增加一行
pg_ctl reload   #重新加载，使配置生效。

> 注意，在pg_hba.conf条目约从上到下有效性递减。如：第一条同意某主机访问，第二条禁止某主机访问，则该主机可以访问。

远程连接测试

```sh
psql -h 192.168.6.12 -d postgres -U pg -p 5432

```

1. 设置PostgreSQL开机自启动

```sh
su - root
1) PostgreSQL的开机自启动脚本位于PostgreSQL源码目录的contrib/start-scripts路径下
linux文件即为linux系统上的启动脚本
2) 修改linux文件属性，添加X属性
chmod a+x linux
3) 复制linux文件到/etc/init.d目录下，更名为postgresql
cp linux /etc/init.d/postgresql
4) 修改/etc/init.d/postgresql文件中的环境变量
# Installation prefix
prefix=/opt/postgres/
# Data directory
PGDATA="/opt/postgres/data"
# Who to run the postmaster as, usually "postgres". (NOT "root")
PGUSER=postgres
5) 启动服务 postgresql
service postgresql start
6) 设置postgresql服务开机自启动
chkconfig --add postgresql
chkconfig --list postgresql
```

4. 安装扩展

每个数据库都安装

```sh
create extension pg_stat_statements;
alter system set shared_preload_libraries = 'pg_stat_statements';

```

5. 备份
