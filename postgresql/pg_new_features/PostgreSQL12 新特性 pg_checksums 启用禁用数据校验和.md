### PostgreSQL12 新特性 pg_checksums 启用/禁用数据校验和

#### 简介

1. pg_checksums 在 PostgreSQL 11 中 名称为 pg_verify_checksums，PostgreSQL12 之后增强了相关功能，使用此工具可以在数据库集簇中启用 / 禁用离线集群中的页面校验和用于检测数据是否损坏。

2. 运行 pg_checksums 之前，必须彻底关闭服务器。验证校验和时，如果没有校验和错误，则退出状态为零，如果检测到至少一个校验和失败，则退出状态为非零。启用或禁用校验和时，如果操作失败，则退出状态为非零。

3. 验证校验和时，集簇中的每个文件都要被扫描。启用校验和时，集簇中的每个文件都会被重写。禁用校验和时，仅更新 pg_control 文件。

#### 校验和的概念

1. PostgreSQL9.3 中引入了一种数据校验和功能。例如，如何知道数据库整体上具有 100％的完整性？如何知道数据文件和页面是否全部 100％良好且没有损坏？此时通过校验和对数据页进行校验。
2. 启用 checksum 后，系统会对每个数据页计算 checksum，从存储读取数据时如果检测 checksum 失败，则会发生错误并终止当前正在执行的事务，该功能使得 PostgreSQL 自身拥有了检测 I/O 或硬件错误的能力。
3. 这是一个集群范围的设置，不能应用于单个数据库或对象。另外，这个功能启用可能会导致明显的性能下降。

#### pg_checksums 命令帮助

[/home/postgres]$ pg_checksums --help

```bash
pg_checksums enables, disables, or verifies data checksums in a PostgreSQL database cluster.

Usage:
  pg_checksums [OPTION]... [DATADIR]

Options:
 [-D, --pgdata=] DATADIR   --指定存储数据库集簇的目录
  -c, --check              --检查校验和，默认模式
  -d, --disable            --禁用校验和
  -e, --enable             --启用校验和
  -f, --filenode=FILENODE  --仅验证文件节点为 filenode 的关系中的校验和
  -N, --no-sync            --不要等待变化被安全地写入磁盘，意味着后续如果操作系统崩溃会让更新的数据目录损坏
  -P, --progress           --启用进度报告。在检查或启用校验和时，打开该选项，会提供进度报告。
  -v, --verbose            --启用详细输出。列出所有检查的文件 。
  -V, --version            --打印 pg_checksums 版本并退出
  -?, --help               --显示关于 pg_checksums 命令行参数的帮助并退出

如果没有指定数据目录（DATADIR），则使用环境变量 $PGDATA.

pg_checksums [option...] [[ -D | --pgdata ] datadir]

Report bugs to <pgsql-bugs@lists.postgresql.org>.
```


#### 使用说明

###### 工具在离线集群可执行的三种模式

```
1. enable：启用数据校验和。这将重写所有的关系文件块，并通过更新控制文件完成操作。花费的时间，取决于实例的大小，而且该工具没有并行模式。

2. disables：通过更新控制文件来禁用数据校验和。

3. check：如果没有指定任何内容，，则为默认模式。这个模式会扫描所有的关系文件块，报告任何不匹配的情况。

当运行 --enable 或 --disable 时，数据文件夹会被 fsync 为持久性，然后再进行控制文件的更新和刷新，这是为了保持操作的一致性，防止工具被中断、KILL 或者主机突发断电的影响。如果选项中未指定模式，则使用 --check 模式用于与旧版本的 pg_pg_verify_checksums 工具进行兼容。
```

#### 如何关闭和开启数据校验和

###### 以禁用了数据校验和的群集为例，以下是启用它们的方法。首先，需要彻底关闭要切换的实例：

```bash
1.使用 pg_controldata 查看 PostgreSQL 集群是否启用了 data_checksum
pg12v[/home/postgres]$ pg_controldata |grep checksum
Data page checksum version:           0  --0 为未开启

2. 确认数据库是关闭状态
pg12v[/home/postgres]$ pg_controldata -D $PGDATA | grep state
Database cluster state:               shut down

3. 启用数据校验和，更改将反映到控制文件中
pg12v[/home/postgres]$ pg_checksums --enable --progress -D $PGDATA
2439/2439 MB (100%) computed         -- 显示进度
Checksum operation completed         -- 核对操作完成
Files scanned:  2254                 -- 扫描的文件
Blocks scanned: 312311               -- 块扫描
pg_checksums: syncing data directory -- 同步数据目录
pg_checksums: updating control file  -- 更新控制文件
Checksums enabled in cluster         -- 在集群中启用校验码

4. 使用 pg_controldata 查看 PostgreSQL 集群是否启用了 data_checksum
pg12v[/home/postgres]$ pg_controldata -D $PGDATA |grep checksum
Data page checksum version:           1  --1 表示开启
```

###### 重复相同的操作将导致失败（禁用已经被禁用的数据校验和具有相同结果）

```bash
1.使用 pg_controldata 查看 PostgreSQL 集群是否启用了 data_checksum
pg12v[/home/postgres]$  pg_checksums --enable -D $PGDATA
pg_checksums: error: data checksums are already enabled in cluster

2.如何禁用校验和
pg12v[/home/postgres]$ pg_checksums --disable -D $PGDATA
pg_checksums: syncing data directory
pg_checksums: updating control file
Checksums disabled in cluster

3.使用 pg_controldata 查看 PostgreSQL 集群是否启用了 data_checksum
pg12v[/home/postgres]$ pg_controldata -D $PGDATA |grep checksum
Data page checksum version:           0

该工具能够正常处理介于两者之间的故障或中断。例如，如果在关闭启用数据校验和的过程中主机断电、工具被中断、KILL，则数据文件夹将保持禁用状态，因为最后一次进行控制文件更新。可以从头开始重试该操作。
```



#### 使用事项

1. 在大型集簇中启用校验和的时间可能很长。在此操作期间，写到数据目录的集簇或其它程序必须是未启动的，否则可能出现数据损坏。
2. 当复制设置与执行关系文件块的直接拷贝的工具（例如 pg_rewind）一起使用时，启用和禁用校验和会导致以不正确校验和形式出现的页面损坏，如果未在所有节点上执行一致的操作的话。故在复制设置中启用或禁用校验和时，推荐一致地切换所有集簇之前停止所有集簇。此外在主数据库上执行操作，最后从头开始重建备用服务器，也是安全的，当然也有其他不用重建备库的方式启用带有备库环境的校验和此过程需要进行主备切换。
3. 如果在启用或禁用校验和时异常终止或杀掉 pg_checksums，那么集簇的数据校验和配置保持不变 pg_checksums 可以重新运行以执行相同操作。
4. Checksum 使 PostgreSQL 具备检测因硬件故障或传输导致数据不一致的能力，一旦发生异常，通常会报错并终止当前事务，用户可以尽早察觉数据异常并予以恢复。

