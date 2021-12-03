# pg_backup

**作者**

chrisx

**日期**

2021-03-16

**内容**

* pg backup and restore
* pg_basebackup

参考[Chapter 25. Backup and Restore](https://www.postgresql.org/docs/13/backup.html)

----

[TOC]

## 备份方法

备份pg有三种不同的方法

* SQL dump
* File system level backup
* Continuous archiving

## SQL Dump

此方式生成sql命令文本或其他格式，可重建数据库到dump时间点，pg提供的一个工具pg_dump
pg_dump是一个客户端程序，可以在任意远端机器运行
pg_dump可以备份整个数据库，也可以备份部分对象，只要有相应的权限

参考[sql_dump](./sql_dump)

> 注意：客户端版本不能低于服务器版本

## File system level backup

此方法直接复制 PostgreSQL 用于存储数据库中数据的文件; 如

```bash
tar -cf backup.tar /usr/local/pgsql/data --warning=no-file-changed --warning=no-file-removed
or
rsync -C -a -c  /usr/local/pgsql/data /backup
```

> 注意：Be certain that your backup includes all of the files under the database cluster directory

限制

* 为了获得可用的备份, 必须关闭数据库服务器
* 文件系统备份只对整个数据库群集的完整备份和恢复起作用。不能恢复单个表、单个数据文件

## Continuous Archiving and Point-in-Time Recovery (PITR)

基于连续归档的备份优点

* 实现在线热备，非一致性备份
* 可以实现增量备份（增量备份wal文件）
* 可实现基于时间点的恢复
* 可以实现热后备系统

> 注意：Continuous Archiving不支持pg_dump和pg_dumpall。其备份不是操作系统备份。没有足够的信息支持应用wal日志。但其与 File system level backup一样适用于整个database cluster的恢复

### Setting Up WAL Archiving

* 系统产生一个无穷长的WAL记录序列。系统从物理上将这个序列划分成WAL 段文件，通常是每个16MB，每一个wal段文件都有一个数字名称，反应其在wal序列中的位置
* 没有使用WAL归档时，系统通常只创建少量段文件，并且通过重命名不再使用的段文件为更高的段编号来“回收”它们
* 启用归档时，每个wal段文件被填满时，需要保存其到其他位置，避免被覆盖重用，造成wal数据丢失。

启用归档，配置以下参数

```bash
wal_level=replica
archive_mode=on
archive_command = 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f'  # Unix
archive_command = 'copy "%p" "C:\\server\\archivedir\\%f"'  # Windows
```

* 有一点很重要：当且仅当归档命令成功时，它才返回零退出。在得到一个零值结果之后，PostgreSQL将假设该文件已经成功归档， 因此它稍后将被删除或者被新的数据覆盖。但是，一个非零值告诉PostgreSQL该文件没有被归档； 因此它会周期性的重试直到成功。
* archive_command通常需要设计为拒绝覆盖已存在的归档文件，这是非常重要的！如cp -i参数
* 设计归档时，要考虑归档失败的提示。如归档空间耗尽，应报告给管理员以尽快处理。 如果归档空间满 pg_wal/目录将继续填写wal段文件, 直到情况得到解决。(如果文件系统包含 pg_wal/填满, PostgreSQL 将进行紧急关闭。没有提交的事务将丢失, 但数据库将保持离线, 直到您释放一些空间）
* 请注意, 尽管wal存档将允许您恢复对 PostgreSQL 数据库中的数据所做的任何修改, 但它不会还原对配置文件 (即 PostgreSQL、pg_hba 和 pg_ident) 所做的更改, 因为这些都是经过编辑的手动而不是通过 SQL 操作。
* 请注意，只有在使用完整个wal段文件（16M）时才会调用归档命令，所以如果服务器产生的wal日志非常少，则可能造成完成的事务与归档中记录存在较长的延迟（理解：比如上午10点产生了一个wal segment file，由于wal日志比较少，下午16点wal日志还没有被填充满，不会发生切换，下午16点10分，完成一个事务，则完成的事务和使用的wal file之间有较长的延迟）可以设置archive_timeout强制切换，但是强制切换后之前的wal segment file即使没有填满，也会与完整占用的wal file一样大，这样一定能程度上会造成归档路径膨胀，所以需要设置一个合理的 archive_timeout
* 必要时可以使用pg_switch_wal()手动切换
* 当wal_level为minimal时，一些SQL命令被优化为避免记录WAL日志。在这些语句的其中之一的执行过程中如果打开了归档或流复制，WAL中将不会包含足够的信息用于归档恢（崩溃恢复不受影响）。minimal会造成部分数据归档无法恢复，但Crash recovery is unaffected，因为minimal参数下部分操作不会写入wal日志（如 CREATE TABLE AS SELECT）

### Making a Base Backup

执行一次基础备份最简单的方法是使用pg_basebackup工具
你也可以使用低级API来制作一个基础备份。

> 注意：通常不需要担心pg_basebackup的运行，但如果full_page_writes被禁用，运行备份时会造成性能下降！

base backup过程将创建一个备份历史记录文件backup history file并立即存储到wal归档区域中（archive_command and pg_wal）。此文件以您需要用于文件系统备份的第一个wal段文件命名。例如
开始的wal文件是 0000000100001234000055CD,
备份历史记录文件将被命名为类似 0000000100001234000055cd.007C9330.backup。(文件名的第二部分代表了在wal文件中的确切位置)。一旦你已经安全地归档了文件系统备份和在备份过程中被使用的WAL段文件（如备份历史文件中所指定的） ，所有名字在数字上低于备份历史文件中记录值的已归档WAL段对于恢复文件系统备份就不再需要了，并且可以被删除。
备份历史文件仅是一个很小的text file，仅包含标签信息，起始wal位置，时间等信息。

使用示例

```bash
pg_basebackup -h 192.168.80.105 -p 5432 -U postgres -P -v -F p -X stream -D /tmp/backup
```

> 注意，The backup is made over a regular PostgreSQL connection, and uses the replication protocol. The connection must be made with a superuser or a user having REPLICATION permissions (see Section 21.2), and pg_hba.conf must explicitly permit the replication connection. The server must also be configured with max_wal_senders set high enough to leave at least one session available for the backup and one for WAL streaming (if used).

```bash
# pg set
host    all             all             0.0.0.0/0              md5
host    replication    all        0.0.0.0/0        md5

```

> 注意，如果包括非默认表空间，主备目录需一致（提前创建目录），pg_basebackup会自动备份非默认表空间。或者使用参数 -T 进行映射
  -T, --tablespace-mapping=OLDDIR=NEWDIR
                         relocate tablespace in OLDDIR to NEWDIR

### Making a Base Backup Using the Low Level API

步骤多但相对base backup简单。pg_basebackup底层使用此技术。

* 1 Ensure that WAL archiving is enabled and working.
* 2 连接服务器（不管哪个数据库）运行pg_start_backup（superuser或具有EXECUTE此函数权限）启动备份模式

```bash
pg_start_backup(label text [, fast boolean [, exclusive boolean ]])

SELECT pg_start_backup('label', true, false);

```

第一个参数label，用来唯一标识本次备份
第二个参数改为true，会使用更多的IO来完成检查点，加快备份
默认情况下，pg_start_backup可能需要较长的时间完成。 这是因为它会执行一个检查点，并且该检查点所需要的 I/O 将会分散到一段 显著的时间上，默认情况下是你的检查点间隔（见配置参数 checkpoint_completion_target）的一半。这通常 是你所想要的，因为它可以最小化对查询处理的影响。如果你想要尽可能快地 开始备份，请把第二个参数改成true，这将会发出一个立即的检查点并且使用尽可能多的I/O。
第三个参数false，告诉备份使用非独占方式。true代表使用独占模式

这里label是任何你希望用来唯一标识这个备份操作的字符串。 pg_start_backup在集簇目录中创建一个关于备份信息的 备份标签文件，也被称为backup_label， 其中包括了开始时间和标签字符串。该函数也会在集簇目录中创建一个 名为tablespace_map的表空间映射文件， 如果在pg_tblspc/中有一个或者多个表空间符号链接存在， 该文件会包含它们的信息。如果你需要从备份中恢复，这两个文件对于备份的 完整性都至关重要。 

```shell
pg_start_backup工作原理
1. 强制进入全页写 full-page write 模式。
2. 切换到当前WAL段文件（版本8.4或更高版本）。
3. checkpoint。
（需要执行checkpoint，以便显示创建一个重做点，此外检查点位置必须存在非pg_control中，因为备份期间可能会执行多次检查点）
4. 创建一个backup_label文件 - 该文件在PGDATA目录创建，包含有关基础备份本身的重要信息，例如该checkpoint的检查点位置。

backup_label文件包含以下五项：

- CHECKPOINT LOCATION - 这是记录由此命令创建的检查点的LSN位置。
- START WAL LOCATION - 这不用于PITR，但与流复制一起使用，这在[第11章](ch11.md)中描述。它被命名为'START WAL LOCATION'，因为复制模式中的备用服务器在初始启动时只读取一次该值。
- BACKUP METHOD - 这是用来获取这个基础备份的方法。（'pg_start_backup'或'pg_basebackup'）。
- START TIME - 这是pg_start_backup执行时的时间戳。
- LABEL - 这是在pg_start_backup中指定的标签。

```

>注意：运行backup的连接不能中断，否则备份终止

* 3 使用File system level backup
* 4 同一个连接，运行pg_stop_backup命令，终止备份模式

```bash

pg_stop_backup(exclusive boolean [, wait_for_archive boolean ])

SELECT * FROM pg_stop_backup(false, true);

NOTICE:  pg_stop_backup complete, all required WAL segments have been archived
    lsn     |                           labelfile                            |          spcmapfile          
------------+----------------------------------------------------------------+------------------------------
0/12000168 | START WAL LOCATION: 0/12000060 (file 000000010000000000000012)+| 16388 /opt/postgres/data/tb1+
            | CHECKPOINT LOCATION: 0/12000098                               +|
            | BACKUP METHOD: streamed                                       +|
            | BACKUP FROM: master                                           +|
            | START TIME: 2018-09-14 08:35:05 CST                           +|
            | LABEL: label                                                  +|
            |                                                                |
(1 row)



```

pg_stop_backup会终止备份模式。在主控机上，它还执行一次自动切换到下一个WAL段。在后备机上，它无法自动切换WAL段，因此用户可能希望在主控机上运行pg_switch_wal来执行一次手工切换。要做切换的原因是让在备份期间写入的最后一个WAL段文件能准备好被归档。

pg_stop_backup将返回一个具有三个值的行。这些域的 第二个应该被写入到该备份根目录中名为backup_label的 文件。第三个域应该被写入到一个名为tablespace_map 的文件，除非该域为空。这些文件对该备份正常工作来说是至关重要的， 不能被随意修改。

```sh
pg_stop_backup工作原理
pg_stop_backup执行以下五个操作来完成备份。

1. 如果已被pg_start_backup强制更改，则重置为非全页写入模式。
2. 写一个备份结束的XLOG记录。
3. 切换WAL段文件。
4. 创建备份历史记录文件 - 该文件包含backup_label文件的内容以及执行pg_stop_backup的时间戳。
5. 删除backup_label文件 - backup_label文件对于从基础备份进行恢复是必需的，一旦进行复制，原始数据库集群中就不需要该文件。


备份历史文件的命名方法如下所示。

{WAL segment}.{offset value at the time the base backup was >started}.backup

```

5. 一旦备份期间活动的WAL段文件被归档，备份就完成了。由 pg_stop_backup的第一个返回值标识的文件是构成一个 完整备份文件集合所需的最后一个段。在主控机上，如果archive_mode被启用并且wait_for_archive参数为true，在最后一个段被归档之前pg_stop_backup都不会返回。在后备机上，为了让pg_stop_backup等待，archive_mode必须为always。从你已经配置好archive_command之后这些文件的 归档就会自动发生。

* 备份中可忽略pg_wal/，pg_replslot/子目录
* 目录 pg_dynshmem/、pg_notify/、pg_serial/、pg_snapshots/、pg_stat_tmp/和 pg_subtrans/(而不是目录本身) 的内容可以从备份中省略
* 从备份中可忽略pgsql_tmp开头的任何文件或目录，这个文件在postmaster启动后被删除，根据需要重建
