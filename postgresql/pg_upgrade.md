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

使用initdb初始化新集簇。这里也要使用与旧集簇相兼容的initdb标志。

```sh
psql -c 'show server_encoding;' #数据库字符集

```

### 安装自定义共享库和插件

* 把旧集簇使用的所有自定义共享对象文件或插件安装到新集簇中，例如pgcrypto.so，不管它们是来自于 contrib还是某些其他源码。
* 不要创建模式定义 （例如CREATE EXTENSION pgcrypto），因为这些将会从旧集簇升级得到。 还有，任何自定义的全文搜索文件（词典、同义词、辞典、停用词）也必须 被复制到新集簇中。

检查每个数据库的扩展

```sh
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

### 运行pg_upgrade

* 总是应该运行新服务器而不是旧服务器的pg_upgrade二进制文件。
* 升级模式有多种，如果你使用链接模式，升级将会快很多（不需要文件拷贝）并且将使用 更少的磁盘空间，但是在升级后一旦启动新集簇，旧集簇就无法被访问。 链接模式也要求新旧集簇数据目录位于同一个文件系统中（表空间和 pg_wal可以在不同的文件系统中）。 克隆模式提供了相同的速度以及磁盘空间优势，但不会导致新群集启动后旧群集不可用。 克隆模式还需要新旧数据目录位于同一文件系统中。 此模式仅在某些操作系统和文件系统上可用。
* --jobs选项允许多个 CPU 核心被用来复制/链接文件以及 并行地转储和重载数据库模式。
* 可以使用pg_upgrade --check来只执行检查， 这种模式即使在旧服务器还在运行时也能使用。 pg_upgrade --check也将列出任何在更新后需要做的手工调整。
* 如果你将要使用链接或克隆模式，你应该使用--link或--clone选项和--check一起来启用相关模式相关的检查。
* 没有人可以在升级期间访问这些集簇。

:warning: 如果老版本软件安装了相关插件，使用 pg_upgrade 升级前，新版本软件也需要安装相关插件。

检查新旧版本是否兼容

```sh
/opt/pg13/bin/pg_upgrade --link --jobs 1 -c -b /opt/pg126/bin -B /opt/pg13/bin -d  /opt/pg126_data  -D  /opt/pg13_data

Performing Consistency Checks
-----------------------------
Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for system-defined composite types in user tables  ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
Checking for presence of required libraries                 ok
Checking database user is the install user                  ok
Checking for prepared transactions                          ok
Checking for new cluster tablespace directories             ok

*Clusters are compatible*

```

:warning: b, -B 分别表示老版本 PG bin 目录，新版本 PG bin目录， -d, -D 分别表示老版本PG 数据目录，新版本 PG 数据目录， -c 表示仅检查，并不会做任何更改。--link是使用link模式,--jobs使用多cpu并行。

<!--

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
/opt/pg13/bin/pg_upgrade --link --jobs 1 -b /opt/pg126/bin -B /opt/pg13/bin -d  /opt/pg126_data  -D  /opt/pg13_data

......
Upgrade Complete
----------------
Optimizer statistics are not transferred by pg_upgrade so,
once you start the new server, consider running:
    ./analyze_new_cluster.sh

Running this script will delete the old cluster's data files:
    ./delete_old_cluster.sh

出现以上提示，即表示升级完成

```

<!--

理解以下的升级过程！

[pg126@8cfba0c9a15f software]$ /opt/pg13/bin/pg_upgrade --link --jobs 1 -b /opt/pg126/bin -B /opt/pg13/bin -d  /opt/pg126_data  -D  /opt/pg13_data
Performing Consistency Checks
-----------------------------
Checking cluster versions                                   ok
Checking database user is the install user                  ok
Checking database connection settings                       ok
Checking for prepared transactions                          ok
Checking for system-defined composite types in user tables  ok
Checking for reg* data types in user tables                 ok
Checking for contrib/isn with bigint-passing mismatch       ok
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
the ".old" suffix from /opt/pg126_data/global/pg_control.old.
Because "link" mode was used, the old cluster cannot be safely
started once the new cluster has been started.

Linking user relation files
                                                            ok
Setting next OID for new cluster                            ok
Sync data directory to disk                                 ok
Creating script to analyze new cluster                      ok
Creating script to delete old cluster                       ok

Upgrade Complete
----------------
Optimizer statistics are not transferred by pg_upgrade so,
once you start the new server, consider running:
    ./analyze_new_cluster.sh

Running this script will delete the old cluster's data files:
    ./delete_old_cluster.sh
[pg126@8cfba0c9a15f software]$

-->

### 升级流复制和日志传送后备服务器

如果使用链接模式并且有流复制（见第 26.2.5 节）或者日志 传送（见第 26.2 节）后备服务器，你可以遵照下面的 步骤对它们进行快速的升级。你将不用在这些后备服务器上运行 pg_upgrade，而是在主服务器上运行rsync。 到这里还不要启动任何服务器。

如果你没有使用链接模式、没有或不想使用rsync或者想用一种更容易的解决方案，请跳过这一节中的过程并且在pg_upgrade完成并且新的主集簇开始运行后重建后备服务器。

* 在后备服务器上安装新的 PostgreSQL 二进制文件

确保新的二进制和支持文件被安装在所有后备服务器上。

* 确保不存在新的后备机数据目录

确保新的后备机数据目录不存在或者为空。如果 运行过initdb，请删除后备服务器的新数据目录。

* 安装自定义共享对象文件

在新的后备机上安装和新的主集簇中相同的自定义共享对象文件。

* 停止后备服务器

如果后备服务器仍在运行，现在使用上述的指令停止它们。

* 保存配置文件

从旧后备机的配置目录保存任何需要保留的配置文件，例如 postgresql.conf（以及它包含的任何文件）、 postgresql.auto.conf、pg_hba.conf， 因为这些文件在下一步中会被重写或者移除。

* 运行rsync

在使用链接模式时，后备服务器可以使用rsync快速升级。为了实现这一点，在主服务器上一个高于新旧数据库集簇目录的目录中为每个后备服务器运行这个命令：

rsync --archive --delete --hard-links --size-only --no-inc-recursive old_cluster new_cluster remote_dir
其中old_cluster和new_cluster是相对于主服务器上的当前目录的，而remote_dir是后备服务器上高于新旧集簇目录的一个目录。在主服务器和后备服务器上指定目录之下的目录结构必须匹配。指定远程目录的详细情况请参考rsync的手册，例如：

rsync --archive --delete --hard-links --size-only --no-inc-recursive /opt/PostgreSQL/9.5 \
      /opt/PostgreSQL/9.6 standby.example.com:/opt/PostgreSQL
可以使用rsync的--dry-run选项验证该命令将做的事情。虽然在主服务器上必须为至少一台后备运行rsync，可以在一台已经升级过的后备服务器上运行rsync来升级其他的后备服务器，只要已升级的后备服务器还没有被启动。

这个命令所做的事情是记录由pg_upgrade的链接模式创建的链接，它们连接主服务器上新旧集簇中的文件。该命令接下来在后备服务器的旧集簇中寻找匹配的文件并且为它们在该后备的新集簇中创建链接。主服务器上没有被链接的文件会被从主服务器拷贝到后备服务器（通常都很小）。这提供了快速的后备服务器升级。不幸地是，rsync会不必要地拷贝与临时表和不做日志表相关的文件，因为通常在后备服务器上不存在这些文件。

如果有表空间，你将需要为每个表空间目录运行一个类似的rsync命令，例如：

rsync --archive --delete --hard-links --size-only --no-inc-recursive /vol1/pg_tblsp/PG_9.5_201510051 \
      /vol1/pg_tblsp/PG_9.6_201608131 standby.example.com:/vol1/pg_tblsp
如果你已经把pg_wal放在数据目录外面，也必须在那些目录上运行rsync。

* 配置流复制和日志传送后备服务器

为日志传送配置服务器（不需要运行pg_start_backup() 以及pg_stop_backup()或者做文件系统备份，因为从属机 仍在与主机同步）。

### 恢复 pg_hba.conf

如果你修改了pg_hba.conf，则要将其恢复到原始的设置。 也可能需要调整新集簇中的其他配置文件来匹配旧集簇，例如 postgresql.conf（以及它包含的任何文件）和 postgresql.auto.conf。

### 启动新服务器

现在可以安全地启动新的服务器，并且可以接着启动任何 rsync过的后备服务器。

修改环境变量指向新系统

```sh
cat ~/.bash_profile

export PGDATABASE=postgres
export PGPORT=5434
export PGHOME=/opt/pg13
export PGDATA=/opt/pg13_data
export MANPATH=$PGHOME/share/man:$MANPATH
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PATH:$PGHOME/bin

soure ~/.bash_profile

```

启动数据库

```sh
pg_ctl start

```

此时，所有数据均存在于新集群中。

### 升级后处理

如果需要做任何升级后处理，pg_upgrade 将在完成后发出警告。它也将 生成必须由管理员运行的脚本文件。

### 统计信息

由于pg_upgrade并未传输优化器统计信息，在升级的尾声 你将被指示运行一个命令来生成这些信息。你可能需要设置连接参数来匹配你 的新集簇。

执行分析脚本

```sh
./analyze_new_cluster.sh

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

如果你想要使用链接模式并且你不想让你的旧集簇在新集簇启动时被修改，考虑使用克隆模式。 如果(克隆模式)不可用，可以复制一份旧集簇并且在副本上以链接模式进行升级。要创建旧集簇的一 份合法拷贝，可以在服务器运行时使用rsync创建旧集簇的 一份脏拷贝，然后关闭旧服务器并且再次运行rsync --checksum 把更改更新到该拷贝以让其一致

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
