# pg_resetwal

**作者**

Chrisx

**日期**

2021-05-26

**内容**

配置WAL文件大小

重建控制文件

ref [wal-segsize](https://www.postgresql.org/docs/13/app-initdb.html)

ref [pg_resetwal](https://www.postgresql.org/docs/13/app-pgresetwal.html)

---

[toc]

## 配置WAL文件大小

PostgreSQL 11 版本的一个重要调整是支持 initdb 和 pg_resetwal 修改 WAL 文件大小，而 11 版本之前只能在编译安装 PostgreSQL 时设置 WAL 文件大小。这一特性能够方便 WAL 文件的管理。

Release 的说明

```sh
Allow the WAL file size to be set via initdb (Beena Emerson)
Previously the 16MB default could only be changed at compile time.
```

1. 使用 initdb 调整WAL文件大小

WAL 日志文件大小默认为16MB，该值必须是1到1024之间的2的次方，增大WAL文件大小能够减少WAL日志文件的产生。
初始化一个新的 PostgreSQL 数据库实例，指定WAL文件大小64MB，如下

```sh
$ initdb -E UTF8 --locale=C --wal-segsize=64 -D /opt/pg126/data -U postgres -W

–wal-segsize=size
Set the WAL segment size, in megabytes. This is the size of each individual file in the WAL log. The default size is 16 megabytes. The value must be a power of 2 between 1 and 1024 (megabytes). This option can only be set during initialization, and cannot be changed later.
It may be useful to adjust this size to control the granularity of WAL log shipping or archiving. Also, in databases with a high volume of WAL, the sheer number of WAL files per directory can become a performance and management problem. Increasing the WAL file size will reduce the number of WAL files.
```

2. 使用 pg_resetwal 调整WAL文件大小

pg_resetwal 用来重置WAL日志和一些控制信息，常用于数据库恢复场景，不到万不得已不轻易使用，以下演示使用pg_resetwal命令调整WAL日志文件大小，仅供测试参考，生产环境慎用。

```sh
pg_ctl stop #pg_resetwal操作时需要关闭数据库
pg_resetwal --wal-segsize=128 -D /opt/pg126/data

--wal-segsize=wal_segment_size
Set the new WAL segment size, in megabytes. The value must be set to a power of 2 between 1 and 1024 (megabytes). See the same option of initdb for more information.

```

Note
While pg_resetwal will set the WAL starting address beyond the latest existing WAL segment file, some segment size changes can cause previous WAL file names to be reused. It is recommended to use -l together with this option to manually set the WAL starting address if WAL file name overlap will cause problems with your archiving strategy.

-l walfile
--next-wal-file=walfile
Manually set the WAL starting location by specifying the name of the next WAL segment file.
The name of next WAL segment file should be larger than any WAL segment file name currently existing in the directory pg_wal under the data directory. These names are also in hexadecimal and have three parts. The first part is the “timeline ID” and should usually be kept the same. For example, if 00000001000000320000004A is the largest entry in pg_wal, use -l 00000001000000320000004B or higher.
Note that when using nondefault WAL segment sizes, the numbers in the WAL file names are different from the LSNs that are reported by system functions and system views. This option takes a WAL file name, not an LSN.

## resetwal重建控制文件

重建控制文件会丢失一部分数据，在没有备份情况下可以尝试次方法。

```sh
pg_resetwal -l 0x1,0x96E8,0x60 -x 0x046A00000 -m 0x10000 -O 0x10000 -f $PGDATA  
```

-l timelineid,fileid,seg 的数据来自pg_xlog文件名的三个部分, 分别占用8个16进制位.

```sh
ls -atl $PGDATA/pg_wal

-rw------- 1 ocz ocz 16M Jan 11 09:39 00000001000096E80000005C
-rw------- 1 ocz ocz 16M Jan 11 09:39 00000001000096E80000005D
-rw------- 1 ocz ocz 16M Jan 11 09:48 00000001000096E80000005E
-rw------- 1 ocz ocz 16M Jan 11 09:48 00000001000096E80000005F  

段大小为16MB, 所以末端最大为0xFF。得出-l 0x1,0x96E8,0x60
```

-x XID的信息，来自pg_clog

```sh
ls -atl $PGDATA/pg_clog

-rw------- 1 ocz ocz 8.0K Jan 11 09:48 0469
-rw------- 1 ocz ocz 216K Jan 10 21:00 0468
-rw------- 1 ocz ocz 256K Jan 10 12:56 0467
-rw------- 1 ocz ocz 256K Jan 10 09:35 0466

取最大值加1然后乘以1048576.转换成16进制的话相当于取最大值加1然后末尾添加5个0.得到-x 0x046A00000
```

-m XID的信息,来自pg_multixact/offsets

```sh
ls -atl $PGDATA/pg_multixact/offsets

取最大值加1然后乘以65536.转换成16进制的话相当于取最大值加1然后末尾添加4个0.没有文件的话使用0加1, 然后末尾添加4个0.得到-m 0x10000
```

-O OFFSET,来自pg_multixact/members

```sh
ls -atl $PGDATA/pg_multixact/members

取最大值加1然后乘以65536.转换成16进制的话相当于取最大值加1然后末尾添加4个0.没有文件的话使用0加1, 然后末尾添加4个0.得到-O 0x10000
```

最后, 不确定的值有2个,可以先不管这两个值

```sh
-e XIDEPOCH，如果么有使用 slony或者londiste这种基于触发器的数据同步软件，则-e意义不大，它实际上是在将32位的xid转换为64位的xid时使用的一个转换系数 。
-o OID, 系统会自动跳过已经分配的OID，自动容错，例如OID被别的程序使用掉了，PG会自动生成下一个OID，并且继续判断可用性。知道可用为止。
```
