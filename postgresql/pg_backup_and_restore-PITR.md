# pg_backup_and_restore-PITR

**作者**

chrisx

**日期**

2021-03-16

**内容**

* pg backup and restore
* pg_basebackup
* Continuous Archiving and Point-in-Time Recovery (PITR)
* Timelines

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
pg_basebackup -F t -X stream -v -D /tmp/backup  -h 192.168.80.105 -p 5432 -U postgres -P -v
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

### Recovering Using a Continuous Archive Backup

 好，现在最坏的情况发生了，你需要从你的备份进行恢复。这里是其过程：

1. 如果服务器仍在运行，停止它。

2. 如果你具有足够的空间，将整个集簇数据目录和表空间复制到一个临时位置，稍后你将用到们。注意这种预防措施将要求在你的系统上有足够的空闲空间来保留现有数据库的两个拷贝。如你没有足够的空间，你至少要保存集簇的pg_wal子目录的内容，因为它可能包含在系统垮掉之前未被归档的日志。

3. 移除所有位于集簇数据目录和正在使用的表空间根目录下的文件和子目录。

4. 从你的文件系统备份中恢复数据库文件。注意它们要使用正确的所有权恢复（数据库系统用户，不是root！）并且使用正确的权限。如果你在使用表空间，你应该验证pg_tblspc/中的符号链接被正确地恢复。

5. 移除pg_wal/中的任何文件，这些是来自于文件系统备份而不是当前日志，因此可以被忽略。如果你根本没有归档pg_wal/，那么以正确的权限重建它。注意如果以前它是一个符号链接，请确保你也以同样的方式重建它。

6. 如果你有在第2步中保存的未归档WAL段文件，把它们拷贝到pg_wal/（最好是拷贝而不是移动它们，这样如果在开始恢复后出现问题你任然有未修改的文件）。

7. 在集簇数据目录中创建一个恢复命令文件recovery.conf（见第 27 章）。你可能还想临时修改pg_hba.conf来阻止普通用户在成功恢复之前连接。

8. 启动服务器。服务器将会进入到恢复模式并且进而根据需要读取归档WAL文件。恢复可能因为一个外部错误而被终止，可以简单地重新启动服务器，这样它将继续恢复。恢复过程结束后，服务器将把recovery.conf重命名为recovery.done（为了阻止以后意外地重新进入恢复模式），并且开始正常数据库操作。

9. 检查数据库的内容来确保你已经恢复到了期望的状态。如果没有，返回到第1步。如果一切正常，通过恢复pg_hba.conf为正常来允许用户连接。 

所有这一切的关键部分是设置一个恢复配置文件, 它描述了您希望恢复的方式以及恢复应运行的程度。您可以使用 recovery.conf.sample (通常位于安装的共享/目录中) 作为原型。在恢复过程中绝对必须指定的一件事是 restore_command, 它告诉 PostgreSQL 如何检索存档的WAL文件。

```bash
restore_command = 'cp /mnt/server/archivedir/%f %p'
```

* 先使用归档的文件，再使用pg_wal未归档文件！归档文件优先级高。
* 通常，恢复将会处理完所有可用的WAL段，从而将数据库恢复到当前时间点（或者尽可能接近给定的可 用WAL段）。因此，一个正常的恢复将会以一个“文件未找到”消息结束，错误消息的准确文 本取决于你选择的restore_command。你也可能在恢复的开始看到一个针对名称类 似于00000001.history文件的错误消息。这也是正常的并且不表示在简单恢复情 况中的问题
* 如果你希望恢复到之前的某个时间点（例如，恢复到幼稚的DBA丢弃了你主要的交易表之前），只需要 在recovery.conf中指定要求的停止点。
* 如果恢复找到被破坏的WAL数据，恢复将会停止于该点并且服务器不会启动。在这种情况下，恢复进程需要从开头重新开始运行，并指定一个在损坏点之前的“恢复目标”以便恢复能够正常完成。

:warning: 停止点必须位于基础备份的完成时间之后，即pg_stop_backup的完成时间。在备份过程中你不能使用基础备份来恢复（要恢复到这个时间，你必须回到你之前的基础备份并且从这里开始前滚）。

### Timelines

将数据库恢复到一个之前的时间点的能力带来了一些复杂性，这和有关时间旅行和平行宇宙的科幻小说有些相似。例如，在数据库的最初历史中，假设你在周二晚上5：15时丢弃了一个关键表，但是一直到周三中午才意识到你的错误。不用苦恼，你取出你的备份，恢复到周二晚上5：14的时间点，并上线运行。在数据库宇宙的这个历史中，你从没有丢弃该表。但是假设你后来意识到这并非一个好主意，并且想回到最初历史中周三早上的某个时间。你没法这样做，在你的数据库在线运行期间，它重写了某些WAL段文件，而这些文件本来可以将你引向你希望回到的时间。因此，为了避免出现这种状况，你需要将完成时间点恢复后生成的WAL记录序列与初始数据库历史中产生的WAL记录序列区分开来。

要解决这个问题，PostgreSQL有一个时间线概念。无论何时当一次归档恢复完成，一个新的时间线被创建来标识恢复之后生成的WAL记录序列。时间线ID号是WAL段文件名的一部分，因此一个新的时间线不会重写由之前的时间线生成的WAL数据。实际上可以归档很多不同的时间线。虽然这可能看起来是一个无用的特性，但是它常常扮演救命稻草的角色。考虑到你不太确定需要恢复到哪个时间点的情况，你可能不得不做多次时间点恢复尝试和错误，直到最终找到从旧历史中分支出去的最佳位置。如果没有时间线，该处理将会很快生成一堆不可管理的混乱。而有了时间线，你可以恢复到任何之前的状态，包括早先被你放弃的时间线分支中的状态。 

每次当一个新的时间线被创建，PostgreSQL会创建一个“时间线历史”文件，它显示了新时间线是什么时候从哪个时间线分支出来的。系统在从一个包含多个时间线的归档中恢复时，这些历史文件对于允许系统选取正确的WAL段文件非常必要。因此，和WAL段文件相似，它们也要被归档到WAL归档区域。历史文件是很小的文本文件，因此将它们无限期地保存起来的代价很小，而且也是很合适的（而段文件都很大）。

恢复的默认行为是沿着相同的时间线进行恢复，该时间线是基础备份创建时的当前时间线。如果你希望恢复到某个子女时间线（即，你希望回到在一次恢复尝试后产生的某个状态），你需要在recovery.conf中指定目标时间线ID。你不能恢复到早于该基础备份之前分支出去的时间线。 

```bash
recovery_target_timeline = 'latest'
```

```shell
history文件原理

当PITR完成时，会在pg_wal子目录或归档目录创建一个时间线历史文件，文件名类似00000002.history，该文件记录了自己从什么时间哪个时间线什么原因分出来的，该文件可能含有多行记录，每个记录的内容格式如下：

 * <parentTLI> <switchpoint> <reason>
 *
 *      parentTLI       ID of the parent timeline
 *      switchpoint     XLogRecPtr of the WAL position where the switch happened
 *      reason          human-readable explanation of why the timeline was changed

例如：

$ cat 00000004.history
1	0/140000C8	no recovery target specified
2	0/19000060	no recovery target specified
3	0/1F000090	no recovery target specified

时间线历史文件会告诉我们恢复所得的数据库集簇的完成历史，它在PITR过程中也有使用。

时间线历史文件在第二次及后续PITR过程中起着重要作用。

recovery_target_timeline = 2

数据库进入PITR模式，会沿着时间线标识2进行恢复。

当数据库在从包含多个时间线的归档中恢复时，这些history文件允许系统选取正确的WAL文件，当然，它也能像WAL文件一样被归档到WAL归档目录里。历史文件只是很小的文本文件，所以保存它们的代价很小。
当我们在recovery.conf指定目标时间线tli进行恢复时，程序首先寻找.history文件，根据.history文件里面记录的时间线分支关系，找到从pg_control里面的startTLI（Latest checkpoint TimeLineID）到tli之间的所有时间线对应的日志文件，再进行恢复。

```

### PITR

```shell
PITR工作原理
假设在某个时间点犯错，那么就需要删掉当前的数据库聚簇，并使用之前制作的基础备份恢复一个新的，然后创建recovery.conf文件，设置recovery_target_time参数配置恢复目标时间点。

pg启动时，如果存在recovery.conf和backup_label文件就会进入恢复模式

恢复过程注意两点
1. WAL段/归档日志从哪里读取？
	- 普通恢复模式 - 从base目录下的pg_xlog子目录（版本10或更高版本，pg_wal子目录）。
	- PITR模式 - 来自配置参数archive_command中设置的归档目录。
2. 检查点位置从哪里读取？
	- 普通恢复模式 - 来自pg_control文件。
	- PITR模式 - 来自backup_label文件。

pitr原理

1. 找到重做点，read_backup_label函数从backup_label文件读取checkpoint location
2. 从recovery.conf中读取参数，（restore_command、recovery_target_time等）
3. 从重做点重放wal，参数restore_command，将归档日志从归档区域复制到临时区域，并从中读取wal数据，复制到临时区域中的日志文件会在使用后被删除。
recovery_target_time设置一个时间戳，则直到恢复到时间戳为止。如果没有配置恢复目标，则重放至归档日志末尾。
4. 恢复完成时，会在pg_wal子目录中创建时间线历史文件。如000000002.history，如果启用了日志归档功能，则会在归档目录中创建相同的命名文件。
提交和终止操作记录包含操作完成时的时间戳（xl_xact_commit和xl_xact_abort定义）。因此，如果设置了recovery_target_time，则会比较目标时间和每个操作的时间戳，如果时间戳超过目标时间，pitr就会完成。
5. pitr完成时，会在pg_wal子目录和归档目录中创建时间线历史文件，记录当前时间线是从那条时间线发叉出来的。

时间线文件命名规则

'8位数字时间线表示'.history
```

#### backup

可配置crontab

 [hgdb_backup_20201027_rebak.sh](../../repository/bin/hgdb_backup_20201027_rebak.sh) 

#### restore

```shell
1.安装软件
tar -czvf pg116.tar.gz pg116
scp pg116.tar.gz 192.168.6.11:/home/pg11
2.配置环境变量
3.machine restore backup and archivelog，将备份和归档拷贝的恢复服务器相应目录中
mv bak pg116/data

```

#### recover

1. 确认备份起始位置

```shell
$ cat 000000010000001200000065.000019D8.backup
START WAL LOCATION: 12/650019D8 (file 000000010000001200000065)
STOP WAL LOCATION: 12/91381998 (file 000000010000001200000091)
CHECKPOINT LOCATION: 12/652A3510
BACKUP METHOD: pg_start_backup
BACKUP FROM: master
START TIME: 2018-12-25 15:58:24 +08
LABEL: 20181225
STOP TIME: 2018-12-25 16:23:19 +08

```

2. 确认归档起始位置

```shell
ls -atl *.wallog

```

3. 配置文件recovery.conf

```shell
cd data
cp $PGHOME/share/postgresql/recovery.conf.sample /backup/data/recovery.conf

cat recovery.conf
# recovery
restore_command='cp -i /backup/zlx/db/arch/%f %p'
recovery_target_time='2018-12-27 01:30:00' --基于时间点不完全恢复
#recovery_target_action ='pause'
#recovery_target_inclusive='true'
#recovery_target='immediate'
#recovery_target_timeline='lastest' --完全恢复
#recovery_target_name = 'pitr_restore' --基于保存点不完全恢复

```

:warning: 注意

* 连续恢复不要使用#recovery_target='immediate'
* recovery_target_time要在归档日志文件之后
* recovery_target_time和结束的归档日志不要太近，太近的话就直接recovery complete，不会pause

4. 配置非默认表空间位置（可选）

如果是异机恢复，且存在非默认表空间，需要修改非默认表空间位置(软连接)

查看

```shell
ls -atl
total 4

lrwxrwxrwx  1 pgrestore pgrestore   14 Dec 28 12:59 16438 -> /db/tbs_data01
lrwxrwxrwx  1 pgrestore pgrestore   13 Dec 28 12:59 16442 -> /db/tbs_idx01
lrwxrwxrwx  1 pgrestore pgrestore   13 Dec 28 12:59 16443 -> /db/tbs_other
lrwxrwxrwx  1 pgrestore pgrestore   16 Dec 28 12:59 16445 -> /db/tbs_otheidex

修改，匹配实际路径
ln -sf /backup/db/tbs_data01   16438
ln -sf /backup/db/tbs_idx01    16442
ln -sf /backup/db/tbs_other    16443
ln -sf /backup/db/tbs_otheidex 16445

```

5. 配置参数（可选）

必要时修改参数配置，如端口号，归档位置等

```shell
port = '5432'
archive_command = 'test ! -f  /db/arch/%f && cp %p /db/arch/%f'

```

6. 启动数据库进行恢复

```shell
pg_ctl sart


2018-12-28 13:31:13.469 +08,,,29780,,5c25b0cc.7454,3464,,2018-12-28 13:12:44 +08,1/0,0,LOG,00000,"restored log file ""000000010000002200000002"" from archive",,,,,,,,,""
2018-12-28 13:31:13.482 +08,,,29780,,5c25b0cc.7454,3465,,2018-12-28 13:12:44 +08,1/0,0,LOG,00000,"recovery stopping before abort of transaction 15304174, time 2018-12-27 01:30:23.956827+08",,,,,,,,,""
2018-12-28 13:31:13.557 +08,,,29780,,5c25b0cc.7454,3466,,2018-12-28 13:12:44 +08,1/0,0,LOG,00000,"recovery has paused",,"Execute pg_wal_replay_resume() to continue.",,,,,,,""

```

7. 如果恢复到需要的时间点，则可以执行一下sql终止恢复。

```sql
select pg_wal_replay_resume();

```

说明：
recovery_target_action (enum) 
指定在达到恢复目标时服务器应该立刻采取的动作。默认动作是pause，这表示恢复将会被暂停。promote表示恢复处理将会结束并且服务器将开始接受连接。最后，shutdown将在达到恢复目标之后停止服务器。

使用pause设置的目的是：如果这个恢复目标就是恢复最想要的位置，就允许对数据库执行查询。暂停的状态可以使用pg_wal_replay_resume()（见表 9.81）继续，这会让恢复终结。如果这个恢复目标不是想要的停止点，那么关闭服务器，将恢复目标设置改为一个稍后的目标并且重启以继续恢复。

[recovery_target_action](https://www.postgresql.org/docs/13/runtime-config-wal.html)

## 热后备系统

将备份恢复成热后备机，可实时追加wal日志。这样可以在最短的时间内恢复数据库

```shell
backup
restore
recover

cat recovery.conf

standby_mode = 'on'
primary_conninfo = 'host=192.168.80.101 port=5432 user=repuser application_name= pgrep1 password=rep keepalives_idle=600 keepalives_interval=5 keepalives_count=5'
restore_command = 'cp /home/pg11/arch116/%f %p'
recovery_target_timeline = 'latest'

```

注意：primary_conninfo需要存在（内容可以随便填）否则时间线会更改。无法追加下一次的wal日志
