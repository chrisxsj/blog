# pg_upgrade

**作者**

chrisx

**日期**

2021-05-27

**内容**

使用pg_upgrade方式进行数据库升级

ref [pg_upgrade](https://www.postgresql.org/docs/13/pgupgrade.html)

----

[toc]

## 介绍

pg_upgrade（之前被称为pg_migrator） 允许允许主版本“原位”升级而无需数据转储/重载。 对于次版本升级则不需要这个程序。

主 PostgreSQL 发行通常会加入新的特性，这些新特性常常会更改系统表的布局，但是内部数据存储格式很少会改变。pg_upgrade 使用这一事实来通过创建新系统表并且重用旧的用户数据文件来执行快速升级。 如果一个未来的主发行没有把数据存储格式改得让旧数据格式不可读取，这类升级就用不上pg_upgrade（社区将尝试避免这类情况）。

## 升级步骤

### 移动旧集簇（可选）

新安装的软件目录和旧软件目录重复，就需要重命名相关目录。建议使用不同的安装目录。

### 安装新版本软件

用兼容旧集簇的configure标记编译新的 PostgreSQL 源码。查看旧版本信息。

```sh
pg_config |grep -i CONFIGURE #编译信息

```

编译安装新版本，包括二进制文件。ref [pg_installation](./pg_installation.md)。在开始升级之前，pg_upgrade 将检查pg_controldata来确保所有设置都是兼容的。

### 初始化数据库

使用initdb初始化新集簇。这里也要使用与旧集簇相兼容的initdb标志（如，--wal-segsize=64)。

```sh
#旧
psql -c 'show server_encoding;' #数据库字符集
psql -c 'show wal_segment_size;' #数据库wal段大小
psql -c 'show lc_collate;'  #地区语言排序方式
#新

export PGPORT=5435
export PGHOME=/opt/pg142
export PGDATA=/opt/pg142/data
export MANPATH=$PGHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PGHOME/bin:$PATH
export PGDATABASE=postgres
export PGUSER=postgres

initdb -E UTF8 -D $PGDATA --locale=C -U postgres -W
```

### 安装自定义共享库和插件

* 把旧集簇使用的所有自定义共享对象文件或插件安装到新集簇中，例如pgcrypto.so，不管它们是来自于 contrib还是某些其他源码。
* 不要创建模式定义 （例如CREATE EXTENSION pgcrypto），因为这些将会从旧集簇升级得到。 还有，任何自定义的全文搜索文件（词典、同义词、辞典、停用词）也必须 被复制到新集簇中。

检查每个数据库的扩展

```sh
#旧
for db in `psql --pset=pager=off -qtA -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$);'`
do
psql -d $db --pset=pager=off -q -c 'select current_database(),* from pg_extension'
done

```

### 调整认证

pg_upgrade将会多次连接到旧服务器和新服务器，因此使用一个~/.pgpass文件

ref [pgpass](./pgpass.md)

### 停止两个服务器

```sh
/opt/pg126/bin/pg_ctl -D /opt/pg126/data stop
/opt/pg142/bin/pg_ctl -D /opt/pg142/data stop
```

:warning: 此时涉及停机时间

### 为后备服务器升级做准备

如有有复制环境，在关闭主库前，确保数据是同步的。验证“Latest checkpoint location”值在所有集簇中都匹配。此外，在新的主集簇上的postgresql.conf文件中把wal_level改为replica

### 运行pg_upgrade

* 总是应该运行新服务器而不是旧服务器的pg_upgrade二进制文件。pg_upgrade需要连接新旧集簇的数据（data）和可执行文件(bin)目录
* 升级模式有多种，如果你使用链接模式，升级将会快很多（不需要文件拷贝）并且将使用 更少的磁盘空间，但是在升级后一旦启动新集簇，旧集簇就无法被访问。 链接模式也要求新旧集簇数据目录位于同一个文件系统中（表空间和 pg_wal可以在不同的文件系统中）。 克隆模式提供了相同的速度以及磁盘空间优势，但不会导致新群集启动后旧群集不可用。 克隆模式还需要新旧数据目录位于同一文件系统中。 此模式仅在某些操作系统和文件系统上可用。

可以使用pg_upgrade --check来检查升级兼容性， 这种模式即使在旧服务器还在运行时也能使用。

```sh
/opt/pg142/bin/pg_upgrade --link --jobs 2 --check -b /opt/pg126/bin -B /opt/pg142/bin -d  /opt/pg126/data.bak  -D  /opt/pg142/data

# --check 表示仅检查，并不会做任何更改。
# --jobs使用多cpu并行。
# --link 是使用link模式
# -b, -B 分别表示老版本 PG bin 目录，新版本 PG bin目录， 
# -d, -D 分别表示老版本PG 数据目录，新版本 PG 数据目录， 

```

:warning: 如果你想要使用链接模式并且你不想让你的旧集簇在新集簇启动时被修改，考虑使用克隆模式。 如果(克隆模式)不可用，可以复制一份旧集簇并且在副本上以链接模式进行升级

<!--
[postgres@db pg142]$ /opt/pg142/bin/pg_upgrade --link --jobs 2 --check -b /opt/pg126/bin -B /opt/pg142/bin -d  /opt/pg126/data.bak  -D  /opt/pg142/data
Performing Consistency Checks
-----------------------------
Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for system-defined composite types in user tables  ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for user-defined encoding conversions              ok
Checking for user-defined postfix operators                 ok
Checking for presence of required libraries                 ok
Checking database user is the install user                  ok
Checking for prepared transactions                          ok
Checking for new cluster tablespace directories             ok

*Clusters are compatible*

[postgres@db pg142]$ /opt/pg142/bin/pg_upgrade --clone --jobs 2 --check -b /opt/pg126/bin -B /opt/pg142/bin -d  /opt/pg126/data.bak  -D  /opt/pg142/data
Performing Consistency Checks
-----------------------------
Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for system-defined composite types in user tables  ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for user-defined encoding conversions              ok
Checking for user-defined postfix operators                 ok
Checking for presence of required libraries                 ok

could not clone file between old and new data directories: Operation not supported
Failure, exiting

or

[postgres@db pg142]$

[pg126@8cfba0c9a15f ~]$ /opt/pg13/bin/pg_upgrade --clone -c -b /opt/pg126/bin -B /opt/pg13/bin -d  /opt/pg126_data  -D  /opt/pg13_data
Performing Consistency Checks
-----------------------------
Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for system-defined composite types in user tables  ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for presence of required libraries                 fatal

Your installation references loadable libraries that are missing from the
new installation.  You can add these libraries to the new installation,
or remove the functions using them from the old installation.  A list of
problem libraries is in the file:
    loadable_libraries.txt

Failure, exiting
[pg126@8cfba0c9a15f ~]$

[pg126@8cfba0c9a15f ~]$ cat loadable_libraries.txt
could not load library "$libdir/pgaudit": ERROR:  could not access file "$libdir/pgaudit": No such file or directory
In database: postgres

扩展插件需要提前在新系统安装

-->

升级

```sh
/opt/pg142/bin/pg_upgrade --link --jobs 2 -b /opt/pg126/bin -B /opt/pg142/bin -d  /opt/pg126/data.bak  -D  /opt/pg142/data

......
Creating script to delete old cluster                       ok
Checking for extension updates                              notice

Your installation contains extensions that should be updated
with the ALTER EXTENSION command.  The file
    update_extensions.sql
when executed by psql by the database superuser will update
these extensions.


Upgrade Complete
----------------
Optimizer statistics are not transferred by pg_upgrade.
Once you start the new server, consider running:
    /opt/pg142/bin/vacuumdb --all --analyze-in-stages

Running this script will delete the old cluster's data files:
    ./delete_old_cluster.sh

```

<!--

理解以下的升级过程！

[postgres@db pg142]$ /opt/pg142/bin/pg_upgrade --link --jobs 2 -b /opt/pg126/bin -B /opt/pg142/bin -d  /opt/pg126/data.bak  -D  /opt/pg142/data
Performing Consistency Checks
-----------------------------
Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for system-defined composite types in user tables  ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for user-defined encoding conversions              ok
Checking for user-defined postfix operators                 ok
Creating dump of global objects                             ok
Creating dump of database schemas
                                                            ok
Checking for presence of required libraries                 ok
Checking database user is the install user                  ok
Checking for prepared transactions                          ok
Checking for new cluster tablespace directories             ok

If pg_upgrade fails after this point, you must re-initdb the
new cluster before continuing.

Performing Upgrade
------------------
Analyzing all rows in the new cluster                       ok
Freezing all rows in the new cluster                        ok
Deleting files from new pg_xact                             ok
Copying old pg_xact to new server                           ok
Setting oldest XID for new cluster                          ok
Setting next transaction ID and epoch for new cluster       ok
Deleting files from new pg_multixact/offsets                ok
Copying old pg_multixact/offsets to new server              ok
Deleting files from new pg_multixact/members                ok
Copying old pg_multixact/members to new server              ok
Setting next multixact ID and offset for new cluster        ok
Resetting WAL archives                                      ok
Setting frozenxid and minmxid counters in new cluster       ok
Restoring global objects in the new cluster                 ok
Restoring database schemas in the new cluster
                                                            ok
Adding ".old" suffix to old global/pg_control               ok

If you want to start the old cluster, you will need to remove
the ".old" suffix from /opt/pg126/data.bak/global/pg_control.old.
Because "link" mode was used, the old cluster cannot be safely
started once the new cluster has been started.

Linking user relation files
                                                            ok
Setting next OID for new cluster                            ok
Sync data directory to disk                                 ok
Creating script to delete old cluster                       ok
Checking for extension updates                              notice

Your installation contains extensions that should be updated
with the ALTER EXTENSION command.  The file
    update_extensions.sql
when executed by psql by the database superuser will update
these extensions.


Upgrade Complete
----------------
Optimizer statistics are not transferred by pg_upgrade.
Once you start the new server, consider running:
    /opt/pg142/bin/vacuumdb --all --analyze-in-stages

Running this script will delete the old cluster's data files:
    ./delete_old_cluster.sh
[postgres@db pg142]$

-->

### 升级流复制和日志传送后备服务器

升级完主库后，可升级备库。

有后备服务器的场景中，你将不用在这些后备服务器上运行 pg_upgrade，而是在主服务器上运行rsync。 到这里还不要启动任何服务器。如果不使用此方式，需要重做后备服务器。

#### 在后备服务器上安装新的 PostgreSQL 二进制文件

安装软件

#### 确保不存在新的后备机数据目录

data为空

#### 安装自定义共享对象文件和插件

与新主库一致

#### 停止后备服务器

#### 保存配置文件

postgresql.conf（以及它包含的任何文件）、 postgresql.auto.conf、pg_hba.conf、standby.signal

```sh
#备
cp -i /opt/pg126/data/pg_hba.conf ~/bak
cp -i /opt/pg126/data/postgresql.conf ~/bak
cp -i /opt/pg126/data/postgresql.auto.conf ~/bak
cp -i /opt/pg126/data/standby.signal ~/bak
```

#### 运行rsync

在使用链接模式时，后备服务器可以使用rsync快速升级。为了实现这一点，在主服务器上新旧数据库集簇目录的上一层目录中为每个后备服务器运行这个命令：

```sh
rsync --archive --delete --hard-links --size-only --no-inc-recursive --dry-run old_cluster new_cluster remote_dir -v >/tmp/rsync.log

# old_cluster主服务器旧集簇目录
# new_cluster主服务器新集簇目录
# remote_dir后备服务器上新旧集簇目录上一层
# --dry-run验证该命令将做的事情
# -v显示详细信息

rsync --archive --delete --hard-links --size-only --no-inc-recursive --dry-run -v \
    /opt/pg126 /opt/pg142 192.168.80.152:/opt

rsync --archive --delete --hard-links --size-only --no-inc-recursive -v \
    /opt/pg126 /opt/pg142 192.168.80.152:/opt >/tmp/rsync.log
```

这个命令所做的事情是记录由pg_upgrade的链接模式创建的链接，它们连接主服务器上新旧集簇中的文件。该命令接下来在后备服务器的旧集簇中寻找匹配的文件并且为它们在该后备的新集簇中创建链接。主服务器上没有被链接的文件会被从主服务器拷贝到后备服务器（通常都很小）。这提供了快速的后备服务器升级。不幸地是，rsync会不必要地拷贝与临时表和不做日志表相关的文件，因为通常在后备服务器上不存在这些文件。

:warning: 虽然在主服务器上必须为至少一台后备运行rsync，可以在一台已经升级过的后备服务器上运行rsync来升级其他的后备服务器，只要已升级的后备服务器还没有被启动。

如果有表空间，你将需要为每个表空间目录运行一个类似的rsync命令，例如：

```sh
rsync --archive --delete --hard-links --size-only --no-inc-recursive /vol1/pg_tblsp/PG_9.5_201510051 \
      /vol1/pg_tblsp/PG_9.6_201608131 standby.example.com:/vol1/pg_tblsp

```

如果你已经把pg_wal放在数据目录外面，也必须在那些目录上运行rsync。

#### 配置流复制和日志传送后备服务器

<!--(注意复制槽)-->

为日志传送配置服务器（不需要运行pg_start_backup() 以及pg_stop_backup()或者做文件系统备份，因为从属机 仍在与主机同步）。升级后备库处理

```sh

#主库
升级后复制槽丢失，创建复制槽
select * from pg_create_physical_replication_slot('pslot1');

#备库
创建standby.signal空文件
在postgresql.auto.conf写入恢复参数
#备
cp -i ~/bak/* /opt/pg142/data

```

### 恢复配置文件

主备库

如果你修改了pg_hba.conf，则要将其恢复到原始的设置。 也可能需要调整新集簇中的其他配置文件来匹配旧集簇，例如 postgresql.conf（以及它包含的任何文件）和 postgresql.auto.conf。

```sh
#主
cp -i /opt/pg126/data.bak/pg_hba.conf /opt/pg142/data
cp -i /opt/pg126/data.bak/postgresql.conf /opt/pg142/data
cp -i /opt/pg126/data.bak/postgresql.auto.conf /opt/pg142/data
#备
cp -i ~/bak/* /opt/pg142/data
```

### 启动新服务器

现在可以安全地启动新的服务器，并且可以接着启动任何 rsync过的后备服务器。

修改环境变量指向新系统

```sh
cat ~/.bash_profile

export PGPORT=5435
export PGHOME=/opt/pg142
export PGDATA=/opt/pg142/data
export MANPATH=$PGHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PATH:$PGHOME/bin
export PGDATABASE=postgres
export PGUSER=postgres

soure ~/.bash_profile

```

启动数据库

```sh
pg_ctl start

```

此时，所有数据均存在于新集簇中。

### 升级后处理

如果需要做任何升级后处理，pg_upgrade 将在完成后发出警告。它也将 生成必须由管理员运行的脚本文件。

```sh
psql -f ./update_extensions.sql

```

### 统计信息

由于pg_upgrade并未传输优化器统计信息，在升级的尾声 你将被指示运行一个命令来生成这些信息。你可能需要设置连接参数来匹配你 的新集簇。

执行分析脚本

```sh
/opt/pg142/bin/vacuumdb --all --analyze-in-stages

```

### 删除旧集簇（必要时）

一旦你对升级表示满意，你就可以通过运行 pg_upgrade完成时提到的脚本来删除旧集簇的 数据目录（如果在旧数据目录中有用户定义的表空间就不可能实现自动删除）。 你也可以删除旧安装目录（例如bin、share）。

执行删除就集群脚本

```sh
./delete_old_cluster.sh

```

### 恢复到旧集簇

在运行pg_upgrade之后，如果你希望恢复到 旧集簇，有几个选项：

* 如果使用了 --check 选项, 则旧集群没有被修改；它可以被重新启动。

* 如果 --link 选项 没有被使用, 旧集群没有被修改；它可以被重新启动。

* 如果使用了--link 选项, 数据文件可能在新旧群集之间共享:

    如果pg_upgrade在链接启动之前中止，旧群集没有被修改，它可以重新启动。

    如果你没有启动新集群，旧集群没有被修改，当链接启动时，一个.old后缀会附加到$PGDATA/global/pg_control。 如果要重用旧集群，从$PGDATA
    global/   pg_control移除.old后缀；你就可以重启旧集群。

    如果你已经启动新群集，它已经写入了共享文件，并且使用旧群集会不安全。这种情况下，需要从备份中还原旧群集。

如果你想要使用链接模式并且你不想让你的旧集簇在新集簇启动时被修改，考虑使用克隆模式。 如果(克隆模式)不可用，可以复制一份旧集簇并且在副本上以链接模式进行升级。要创建旧集簇的一 份合法拷贝，可以在服务器运行时使用rsync创建旧集簇的 一份脏拷贝，然后关闭旧服务器并且再次运行rsync --checksum 把更改更新到该拷贝以让其一致。

<!--
已经启动新群集情况下，启动旧集群报错
[pg126@8cfba0c9a15f ~]$ pg_ctl start
waiting for server to start....postgres: could not find the database system
Expected to find it in the directory "/opt/pg126_data",
but could not open file "/opt/pg126_data/global/pg_control": No such file or directory
 stopped waiting
pg_ctl: could not start server
Examine the log output.

没有写入数据，则可以重命名control文件，启动旧集群

mv /opt/pg126_data/global/pg_control.old /opt/pg126_data/global/pg_control

[pg126@8cfba0c9a15f ~]$ pg_ctl start
waiting for server to start....2021-07-09 03:22:28.486 UTC [1710] LOG:  pgaudit extension initialized
2021-07-09 03:22:28.487 UTC [1710] LOG:  starting PostgreSQL 12.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-44), 64-bit
2021-07-09 03:22:28.487 UTC [1710] LOG:  listening on IPv4 address "0.0.0.0", port 5433
2021-07-09 03:22:28.487 UTC [1710] LOG:  listening on IPv6 address "::", port 5433
2021-07-09 03:22:28.494 UTC [1710] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5433"
2021-07-09 03:22:28.514 UTC [1710] LOG:  redirecting log output to logging collector process
2021-07-09 03:22:28.514 UTC [1710] HINT:  Future log output will appear in directory "pg_log".
 done
server started
[pg126@8cfba0c9a15f ~]$

-->
