# pg_controldata

**作者**

Chrisx

**日期**

2021-05-28

**内容**

控制文件的作用

ref[[PGSQL]PostgreSQL的控制文件内幕分析 ](https://mp.weixin.qq.com/s/kL9ZvbzoylAW55NJu-8RPA)

---

[toc]

## 控制文件的作用

PostgreSQL的控制文件与Oracle类似，都是记录数据库的一些重要信息。

使用pg_controldata命令就可以显示出控制文件中的内容：

```sh
$ pg_controldata
pg_control version number:            942
Catalog version number:               201409291
Database system identifier:           6197591927813975882
Database cluster state:               in production
pg_control last modified:             Wed 23 Sep 2015 04:14:47 PM CST
Latest checkpoint location:           0/1748510
Prior checkpoint location:            0/1739E70
Latest checkpoint's REDO location:    0/17484D8
Latest checkpoint's REDO WAL file:    000000010000000000000001
Latest checkpoint's TimeLineID:       1
Latest checkpoint's PrevTimeLineID:   1
Latest checkpoint's full_page_writes: on
Latest checkpoint's NextXID:          0/1830
Latest checkpoint's NextOID:          24582
Latest checkpoint's NextMultiXactId:  1
Latest checkpoint's NextMultiOffset:  0
Latest checkpoint's oldestXID:        1800
Latest checkpoint's oldestXID's DB:   1
Latest checkpoint's oldestActiveXID:  1830
Latest checkpoint's oldestMultiXid:   1
Latest checkpoint's oldestMulti's DB: 1
Time of latest checkpoint:            Wed 23 Sep 2015 04:14:46 PM CST
Fake LSN counter for unlogged rels:   0/1
Minimum recovery ending location:     0/0
Min recovery ending loc's timeline:   0
Backup start location:                0/0
Backup end location:                  0/0
End-of-backup record required:        no
Current wal_level setting:            hot_standby
Current wal_log_hints setting:        off
Current max_connections setting:      100
Current max_worker_processes setting: 8
Current max_prepared_xacts setting:   0
Current max_locks_per_xact setting:   64
Maximum data alignment:               8
Database block size:                  8192
Blocks per segment of large relation: 131072
WAL block size:                       8192
Bytes per WAL segment:                16777216
Maximum length of identifiers:        64
Maximum columns in an index:          32
Maximum size of a TOAST chunk:        1996
Size of a large-object chunk:         2048
Date/time type storage:               64-bit integers
Float4 argument passing:              by value
Float8 argument passing:              by value
Data page checksum version:           0

```

我们下面对上面输出的这些内容进行详细的解析。

我们先讲一些与版本、平台迁移升级有关的一些信息。如果这些信息不同，即使在同一种Linux平台上，数据库也是不能迁移或升级的。在数据库启动过程中，读取控制文件后发现不能兼容则报“database files are incompatible with server”
的错误。

* pg_control version number: 控制文件的版本
* Catalog version number: 系统表的版本号，PostgreSQL9.4的版本为201409291。PostgreSQL的版本是由三个数字表示“X.Y.Z”，通常是有功能重大变化“X”才会发生变化，而第二个数字“Y”发生变化，通常指系统表发生了变化。最后一位数字的变化，系统表不会发生变化。所以如果只是最后一位数字变化，如把数据库从9.4.3升级到9.4.4，通常只需要把二制程序升级一个就可以了，因为系统表没有变化，数据文件就是能兼容的。
* Maximum data alignment: 数据结构最大的对齐值
* Database block size: 数据块的大小
* Blocks per segment of large relation: 在一些文件系统上，单个文件的大小是受限制的，为此PG会把一个表的数据分到多个数据文件中存储，此值指定了每个数据文件最多多少个数据块。默认为131072个块，每个块8k，则数据文件最大为1G。
* WAL block size: WAL日志块的大小
* Bytes per WAL segment: WAL日志文件的大小
* Maximum length of identifiers: “name”类型的长度，实际指一些数据库对象名称的最大长度，如表名、索引名的最大长度。
* Maximum columns in an index: 一个索引最多多少个列。目前是32个。
* Maximum size of a TOAST chunk: TOAST chunk的长度。TOAST是解决当列的内容太长，在一个数据块中存不下时的一种行外存储的方式，具体可以见：http://www.postgresql.org/docs/9.4/interactive/storage-toast.html
* Size of a large-object chunk: 大对象的chunk的大小
* Date/time type storage: Date/time类型是用浮点数(double)类型表示还是由64bit的长整数表示。这与不同的类UNIX平台有关。
* Float4 argument passing: Float4类型的参数是传值还是传引用。
* Float8 argument passing: Float8类型的参数是传值还是传引用。
* Data page checksum version: 数据块checksum的版本，如果是0，则数据块没有使用checksum。只有运行initdb命令时加了-k参数，PostgreSQL才会在数据块上启用checksum功能。

控制文件中还记录了数据库的唯一标识串（Database system identifier）：

* Database system identifier:           6197591927813975882

这个标识串是一个64bit的整数，其中包含了创建数据库时的时间戳及initdb时初使化的进程号，所以通常是不会重复的。计算方法可以见xlog.c中：

```c
gettimeofday(&tv, NULL);
sysidentifier = ((uint64) tv.tv_sec) << 32;
sysidentifier |= ((uint64) tv.tv_usec) << 12;
sysidentifier |= getpid() & 0xFFF;
```

如上面的显示的数据库标识串为“6197591927813975882”，通过下面的SQL，我们就可以知道此数据库是什么时候建的：

```sql
postgres=# SELECT to_timestamp(((6197591927813975882>>32) & (2^32 -1)::bigint));
      to_timestamp
------------------------
 2015-09-23 14:21:57+08
(1 row)

```

在控制文件中还记录了实例的状态，在命令pg_controldata中的“Database cluster state”项显示的就是控制文件中实例的状态，有以下几种状态：

* starting up: 表示数据库正在启动的状态，实际上目前没有使用此状态。
* shut down: 数据库实例（非Standby）正常关闭后控制文件中就是此状态。
* shut down in recovery: Standby实例正常关闭后控制文件中就是此状态。
* shutting down: 当正常停库时，会先做checkpoint，在开始做checkpoint时，会把状态设置为此状态，当做完后会把状态置为shut down。
* in crash recovery: 当数据库实例非异常停止后，重新启动后，会先进行实例的恢复，在实例恢复时的状态就是此状态。
* in archive recovery: Standby实例正常启动后，就是此状态。
* in production: 数据库实例正常启动的后就是此状态。Standby数据库正常启动后不是此状态，而是“in archive recovery”

在源码实现中，实例的状态是用一个枚举类型来表示的，具体见pg_control.h中

```c
typedef enum DBState
{
    DB_STARTUP = 0,
    DB_SHUTDOWNED,
    DB_SHUTDOWNED_IN_RECOVERY,
    DB_SHUTDOWNING,
    DB_IN_CRASH_RECOVERY,
    DB_IN_ARCHIVE_RECOVERY,
    DB_IN_PRODUCTION
} DBState;

```

下面我们来看一些与PostgreSQL的异常重启后的实例恢复、物理备份的信息：

Latest checkpoint location:           0/1748510
Prior checkpoint location:            0/1739E70
Latest checkpoint's REDO location:    0/17484D8
Latest checkpoint's REDO WAL file:    000000010000000000000001
Latest checkpoint's TimeLineID:       1
Latest checkpoint's PrevTimeLineID:   1
Latest checkpoint's full_page_writes: on
Latest checkpoint's NextXID:          0/1830
Latest checkpoint's NextOID:          24582
Latest checkpoint's NextMultiXactId:  1
Latest checkpoint's NextMultiOffset:  0
Latest checkpoint's oldestXID:        1800
Latest checkpoint's oldestXID's DB:   1
Latest checkpoint's oldestActiveXID:  1830
Latest checkpoint's oldestMultiXid:   1
Latest checkpoint's oldestMulti's DB: 1
Minimum recovery ending location:     0/0

当数据库异常停止后再重新启动时，需要做实例恢复，实例恢复的过程是从WAL日志中，找到最后一次的checkpoint点，然后读取这个点之后的WAL日志，然后重新应用这些日志，这个过程称为数据库实例的前滚恢复。最后一次的checkpoint点的信息就记录在上面“Latest checkpoint”项中。

上面中还需要关注的一个内容是“Minimum recovery ending location”。这个值与Standby库应用WAL日志有关，需要注意的是主库与备库的控制文件中的checkpoint的信息是不同的。在备库中，每replay一些WAL日志后，就会做一次checkpoint点，然后把这个checkpoint点的信息记录到控制文件中。当在备库replay一些日志后，如果有一些脏数据刷新到磁盘中后，会把产生脏数据的最新日志的位置记录到“Minimum recovery ending location”。为什么要记录呢？因为这是为了能保证恢复到一个一致点。想象一下，备库异常停机后，再启动后，如果备库马上提供只读服务(或激活成主库)，但磁盘上的数据不是一个一致的数据，这时如果读备库就会读到错误的数据，所以要replay日志一直到超过“Minimum recovery ending location”位置后，才能对外提供只读服务（或激活成主库）。

最后我们来讲一下与热备份相关的三项：

    Backup start location:                0/0

    Backup end location:                  0/0

    End-of-backup record required:        no

“Backup start location”与“Backup end location”记录了一个WAL日志的位置。有人可能会误认为当在主库上执行完“SELECT pg_start_backup('tangxxxx');”后，控制文件中“Backup start location”就会变成当前的WAL值，实际不是这样的。

在主库上做“SELECT pg_start_backup('osdba201509230923');”后，只是在主库的数据目录下生成了一个backup_label文件，此文件的内容如下：

START WAL LOCATION: 0/4000028 (file 000000010000000000000004)
CHECKPOINT LOCATION: 0/4000060
BACKUP METHOD: pg_start_backup
BACKUP FROM: master
START TIME: 2015-09-22 19:44:23 CST
LABEL: osdba201509230923

这时我们拷贝主库，拷贝出来的数据文件中就包括了backup_label文件。备库启动时，如果发现了有backup_label这个文件，就会从这个文件中记录的点开始恢复，同时备库会把此位置记录到控制文件的“Backup start location”中。

而“Backup end location:”与“End-of-backup record required”记录了备库恢复过程中的一些中间状态。