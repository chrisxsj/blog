# WAL

**作者**

Chrisx

**日期**

2021-04-25

**内容**

WAL详谈

WAL与checkpoint

WAL Internals Of PostgreSQ，WAL日志实现机制

ref [Reliability and the Write-Ahead Log](https://www.postgresql.org/docs/13/wal.html)

---

[toc]

## WAL概述

### 可靠性与整页写

WAL(write ahead log)，在数据库中指事务日志。是pg实现redo的一种方式。数据库使用WAL日志是有必要的

数据库可靠性对于系统至关重要，数据库需尽一切可能来保证可靠的操作。向计算机的永久存储区（如，磁盘驱动器）成功写入数据通常可以满足这个要求。但是，因为磁盘驱动器比内存和CPU要慢很多，在计算机的主存和磁盘盘片之间存在多层的高速缓存。在操作系统缓存向存储硬件写入数据的时候，它没有什么好办法来保证数据真正到达存储区域之前不丢失。如，断电崩溃后，缓存中未写入磁盘的数据将会丢失。

预写式日志（WAL）是保证数据完整性的一种标准方法。WAL要求数据文件（存储着表和索引）的修改必须在这些动作被日志记录之后才被写入，即在日志记录被刷到持久存储以后。这样，我们不需要在每个事务提交时刷写数据页面到磁盘，因为我们知道在发生崩溃时可以使用日志来恢复数据库。任何还没有被应用到数据页面的改变，都可以根据其日志记录重做（这是前滚恢复）。

<!--
提示

因为WAL在崩溃后恢复数据库文件内容，不需要日志化文件系统作为数据文件或WAL文件的可靠存储。实际上，日志会降低性能，特别是如果日志导致文件系统数据被刷写到磁盘。幸运地是，日志期间的数据刷写常常可以在文件系统挂载选项中被禁用，例如在Linux ext3文件系统中可以使用data=writeback。在崩溃后日志化文件系统确实可以提高启动速度。 

禁用文件系统的日志功能？？

-->

另外一个数据丢失的风险来自磁盘盘片写操作自身。磁盘盘片会被分割为扇区，通常每个扇区512字节。每次物理读写都对整个扇区进行操作。当一个写操作到达磁盘的时候，它可能是512 字节（PostgreSQL通常一次写8192字节或者16个扇区）的某个倍数，而写入处理在任何时候都可能因为停电而失败，这意味着某些512字节的扇区写入了，而有些没有。为之了避免这样的失效，PostgreSQL在修改磁盘上的实际页面之前， 周期地把整个页面的映像写入永久WAL存储，称为`整页写（full_page_writes）`。这么做后，在崩溃恢复的时候，PostgreSQL可以从WAL恢复部分写入的页面。如果你的文件系统阻止部分页面写入（如ZFS），你可以通过关闭full_page_writes参数来关闭这种页映像。

### 异步提交

WAL日志可以保证数据库的可靠性。为了提高数据库的性能。也可以使用异步提交。异步提交是一个允许事务能更快完成的选项，代价是在数据库崩溃时最近的事务会丢失。在很多应用中这是一个可接受的交换。

如前文所，述事务提交通常是同步的：服务器等到事务的WAL记录被刷写到持久存储之后才向客户端返回成功指示。因此客户端可以确保那些报告已被提交的事务确会被保存。但是，对于短事务来说这种延迟是其总执行时间的主要部分。选择异步提交模式意味着服务器将在事务被逻辑上提交后立刻返回成功，而此时由它生成的WAL记录还没有被真正地写到磁盘上。这将为小型事务的生产力产生显著地提升。

异步提交会带来数据丢失的风险。在向客户端报告事务完成到事务真正被提交之间有一个短的时间窗口。如果数据库在异步提交和事务WAL记录写入之间的风险窗口期间崩溃，在该事务期间所作的修改将丢失。风险窗口的持续时间是有限制的，因为一个后台进程（“WAL写进程”）每wal_writer_delay毫秒会把未写入的WAL记录刷写到磁盘。。

选择何种提交模式，我们需要在性能和事务持久性之间进行权衡。提交模式由用户可设置的参数synchronous_commit控制。`在很多场景下，异步提交可以提供类似关闭fsync带来的性能提升优势，但异步提交并没有数据损坏的风险。`

使用WAL日志的一些优点

* 保证数据库的可靠性
* 使用WAL可以显著降低磁盘的写次数，提高性能。（日志文件被按照顺序写入，因此同步日志的代价要远低于刷写数据页面的代价。日志是批量写的。日志文件的一个fsync可以提交很多事务。效率更高。）
* 日志异步提交，可减少IO，提高性能
* WAL也使得在线备份和时间点恢复能被支持
* full_page_writes可修复块损坏

:warning: 临时表不写WAL

## WAL数据

为了保证系统可靠性，数据库将所有修改保存成历史数据，并写入持久化存储。这份历史数据被称为`WAL数据`
当数据库发生插入、删除、提交等变更动作时，数据库会将WAL记录写入wal缓冲区。当事务提交或终止时，他们会被写入持久化存储的WAL段文件中。
`日志序列号（Log Sequence Number,LSN）`标识了该记录在WAL日志中的位置。其中检查点启动时，它会向WAL段文件写入一条WAL记录。这条记录包含最新重做点的位置。这条记录分配了唯一的标识符LSN。这也是重做的起始点。

如下，wal记录

|           | (1)checkpoint | (2) insert A             | (3)commit             | (4) insert B            | (5)commit             | (6) crash |
| --------- | ------------- | ------------------------ | --------------------- | ----------------------- | --------------------- | --------- |
| 共享池    | redo point    | table A(LSN0-1)  tuple A | table A(LSN1) tuple A | table A(LSN1-2) tuple B | table A(LSN2) tuple B |           |
| wal缓冲区 | redo point    | A                        |                       | B                       |                       |           |
| wal段     | redo point    |                          | A commit              |                         | B commit              |           |
|           |               | page0                    |                       | page1                   |                       |           |

1. 检查点启动时，它会向wal段文件写入一条wal记录。
2. 第一条insert时将表A加载到共享池。在内存中完成操作。向表插入一条元组。在LSN1的位置创建并写入一条对应的wal记录。再将表A的LSN0改为LSN1。
3. 提交时，将wal缓冲区的wal记录写入到wal段
4. 第二条insert时，在LSN2的位置创建并写入一条wal记录。再将表A的LSN1改为LSN2。
5. 提交时，将wal缓冲区的wal记录写入到wal段
6. 系统崩溃时，所有操作都被写入了wal段中。

数据库进入恢复模式时，从redo point开始，依序读取wal段文件，重放wal数据。将数据库恢复至崩溃前的状态。

可以通过pg_waldump工具将WAL数据转换成可阅读的数据

ref [pg_waldump](./Pg_waldump.md)

### wal记录的写入

WAL记录被缓存在wal缓冲区，需要尽快写持久化存储文件

如果出现以下情况之一，WAL缓冲区上的所有WAL记录都会写入WAL段文件，而不管它们的事务是否已提交。

* 一个正在运行的事务已经提交或已经中止。
* WAL缓冲区已经写满了许多元组。(WAL缓冲区大小设置为参数[wal_buffers])
* WAL写进程定期写入 (wal_writer_delay)。

:warning: 注意，除了DML操作会写WAL外，COMMIT、checkpoint操作都会产生相应的WAL记录。

WAL写操作是有一个后台进程`WAL wirter`完成的。WAL writer 后台进程，用于定期检查WAL缓冲区，并将所有未写入的WAL记录写入WAL段。此过程的目的是避免WAL记录的突发写入。如果此过程尚未启用，那么当一次提交大量数据时，WAL记录的写入可能成为瓶颈。

WAL writer默认启用，不能被禁用。检查间隔由配置参数`wal_writer_delay`设置，默认值为200毫秒。

## WAL段

数据库日志默认被划分成大小为16MB的文件，这些文件被称为`WAL段`。pg11开始在initdb时，可通过--wal-segsize来配置wal段文件大小。

wal段文件存储位置 $PGDATA/pg_wal，命名格式000000010000000000000001

段文件名由24个16进制数组成。段文件前8个16进制部分为时间线标识，0x00000001，时间线发生变化时，可通过此部分标识。中间8位和最后8位都是对段文件的一个标识。

有一定的命名规则。
第一个段文件是000000010000000000000001，第一个段文件写满后，创建第二个段文件000000010000000000000002。后续文件使用升序。0000000100000000000000FF满后，下一个文件为000000010000000100000000。每当两位数字进位时，中间8位数字加1。0000000100000001000000FF,之后就是000000010000000200000000。

通过过函数pg_walfile_name，可以找出包含特定LSN的wal段文件。

```sql
postgres=# select pg_current_wal_lsn();
 pg_current_wal_lsn
--------------------
 0/C025E30
(1 row)

postgres=# select pg_walfile_name(pg_current_wal_lsn());
     pg_walfile_name
--------------------------
 00000001000000000000000C
(1 row)

postgres=#  select pg_walfile_name('5BA/7090A758');
     pg_walfile_name     
--------------------------
 00000001000005BA00000070
(1 row)
```

转换发现此lsn 5BA/7090A758位于wal日志00000001000005BA00000070中
关于LSN ref [lsn](./lsn.md)

### wal段文件内部布局

pg_xlog目录中的物理文件PostgreSQL称它为段。每个段包含8K的块，段尺寸为16m

结构定义在src/include/access/xlogrecord.h中
ref [pg_interdb](./ch9)

### wal段文件管理

wal段文件空间有限，当段文件写满后，需要切换，以继续存储wal更改。

出现以下情况时，段文件会发生切换

* wal段已经被填满
* 调用函数pg_switch_wal()
* 启用了archive_mode,且已经超过archive_timeout配置的时间
* 调用在线备份

ref [wal_size](./wal_size.md)

### 持续归档与归档日志

`持续归档Continue Archiving`是一种功能，可在WAL段切换时将WAL段文件复制到归档区域，并由归档(后台)进程执行。复制的文件称为`归档日志archive log`

归档区域的路径设置通过配置参数archive_command。

```sql
archive_command='cp %p /home/postgres/arch/%f'

```

这里%p是被复制的wal段文件的路径和占位符，%f是归档日志文件的占位符。archive_command可以使用任意的unix命令或程序。因此可以使用scp将日志发送到其他主机上。

数据库并不会清理归档日志。归档日志会随着时间推进而不断增加。必要时使用`pg_archivecleanup`工具进行归档的管理和清理。

使用pg_archivecleanup清理归档示例

```sh
pg_controldata
Latest checkpoint location: 16/79FF5520
Latest checkpoint’s REDO location: 16/79FF54E8
Latest checkpoint’s REDO WAL file: 00000001000000160000001E
这里表示16/79FF54E8检查点已经执行，已经包含在00000001000000160000001E日志文件中，那么这个日志之前的日志是可以清理的。
 
保留000000010000001600000027之后的日志
pg_archivecleanup /opt/pgdata11.3/pg_root/pg_wal/ 000000010000001600000027

```

## WAL与检查点进程和恢复

数据库中存在检查点进程，与wal相配合，支撑数据库的备份恢复等重要功能

### 检查点进程概述

检查点负责两个工作，一是为数据库恢复做准备工作，二是共享池脏页的刷盘工作。

1. 检查点启动时会将`重做点（redo point）`存储在内存中。
2. 检查点对应的wal被写入wal缓冲区。该记录有checkpoint结构体定义。此外，写入检查点记录的位置。
3. 共享内存中的所有数据被刷入持久化存储（如clog）
4. 共享池中的脏页被逐渐刷写到存储中
5. 更新pg_control文件，该文件记录了检查点信息。

检查点位置会被存放于pg_control文件中。因此pg能够从此文件中找到重做点，从重做点回放wal数据进行恢复。
优化检查点，参考checkpoint_warning、checkpoint_completion_target

检查点进程会执行检查点操作。以下情形发生时，会触发检查点进程

* 达到时间间隔`checkpoint_timeout`,默认300s（5min）
* 快要超过 max_wal_size时（默认1G，64个段文件），准确说就是max_wal_size的1/3～1/2时，就会发生一次checkpoint。
* 以smart或fast模式关闭时
* 超级用户执行checkpoint命令时

pg_control文件记录了检查点的元数据。检查点信息可以从此文件中获取。

<!--
而参数max_wal_size也会控制checkpoint发生的频繁程度：

    target = (double) ConvertToXSegs(max_wal_size_mb) / (2.0 + CheckPointCompletionTarget);

如果checkpoint_completion_target设置为0.5时，则每写了 max_wal_size/2.5 的WAL日志时，就会发送一次checkpoint。

checkpoint_completion_target的范围为0~1，那么结果就是写的WAL的日志量超过: max_wal_size的1/3～1/2时，就会发生一次checkpoint。
-->

### pg_control文件

pg_control文件包含了数据库基本信息，包括检查点。

1. 状态-最近检查点开始时数据库的状态，in production表示数据库正在运行。
2. 最新检查点位置-最新检查点的LSN位置
3. 上次检查点位置-前一个检查点LSN位置，11.0版本已经废弃。

pg_control文件位于数据目录的global子目录中，可以使用`pg_controldata`程序显示器内容。

查看检查点信息

```sh
$ pg_controldata  |grep checkpoint
Latest checkpoint location:           0/A02EDF8
Latest checkpoint's REDO location:    0/A02EDF8
Latest checkpoint's REDO WAL file:    00000001000000000000000A
Latest checkpoint's TimeLineID:       1
Latest checkpoint's PrevTimeLineID:   1
Latest checkpoint's full_page_writes: on
Latest checkpoint's NextXID:          0:552
Latest checkpoint's NextOID:          40978
Latest checkpoint's NextMultiXactId:  1
Latest checkpoint's NextMultiOffset:  0
Latest checkpoint's oldestXID:        480
Latest checkpoint's oldestXID's DB:   1
Latest checkpoint's oldestActiveXID:  0
Latest checkpoint's oldestMultiXid:   1
Latest checkpoint's oldestMulti's DB: 1
Latest checkpoint's oldestCommitTsXid:0
Latest checkpoint's newestCommitTsXid:0
Time of latest checkpoint:            Wed Apr 28 16:09:10 2021

```

### WAL与数据库恢复

数据库的恢复功能基于WAL日志实现。数据库通过从重做点依序重放WAL段文件中的WAL记录来恢复数据库集群。

恢复过程如下

1. 启动时读取pg_control文件的所有项。如果state项是in production，将进入恢复模式，因为这意味这数据库没有正常停止。而如果state是shutdown，就会进入正常启动模式。
2. 数据库从pg_control中读取最近的检查点位置，获取重做点，找到从合适的wal段文件。如果检查点记录不可读，就会放弃恢复操作。
3. 使用合适的资源管理器按照顺序读取并重放wal记录。从重做点开始直到wal段文件的最后位置。当遇到一条属于备份区块的wal记录时，无论LSN如何，都会覆写相应表的页面。其他情况下，只有当此记录的LSN大于页面的pd_lsn时，才会重放该WAL记录。

<!--
WAL记录重放，不是无脑重放，而是通过LSN对比，来跳过一些WAL重放，加快恢复速度。
-->

ref [lsn比较](./pg_inter/ch9.md)
