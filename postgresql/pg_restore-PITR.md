# pg_restore-PITR

**作者**

chrisx

**日期**

2021-012-03

**内容**

* restore and recovery
* Continuous Archiving and Point-in-Time Recovery (PITR)
* Timelines

参考[Chapter 25. Backup and Restore](https://www.postgresql.org/docs/13/backup.html)

----

[TOC]

## Recovering Using a Continuous Archive Backup

ref [Chapter 25. Backup and Restore](https://www.postgresql.org/docs/13/backup.html)

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

分实例恢复和故障恢复

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

<!--
S1
1. 做好冷备份
2. 执行
pg_resetwal -l 0000000100000013000000CD -x 0x10000 -m 0x10000 -O 0xCC80 -f -D $PGDATA  

0000000100000013000000CC
0000


重做控制文件
闪回数据库-参考收藏
-->
