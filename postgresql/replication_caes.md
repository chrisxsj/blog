## replication_case

**作者**

Chrisx

**日期**

2021-09-03

**内容**

流复制配置案例

----

[toc]

### 主端配置

1. 配置参数

```sql
-- for replication parameter(master)
alter system set wal_level = logical;
alter system set max_wal_senders= 40;
alter system set wal_keep_segments = 200;
alter system set archive_mode = on;
alter system set archive_command = 'test ! -f  /arch/%f && cp -i %p /arch/%f';

-- 主库创建流复制专用同步用户
create role repuser login replication encrypted password 'repuser';

-- 主库创建流复制使用的物理复制槽
select * from pg_create_physical_replication_slot('pslot1');

-- 查看复制槽
select * from pg_replication_slots;
```

> 注：删除复制槽语句， SELECT * FROM pg_drop_replication_slot('node_a_slot');

2. 主库网络访问控制配置

主库修改访问控制文件 pg_hba.conf ，增加replication连接权限。运行备库使用同步用户直接连接到主库

$ vim /data/postgresql/data/pg_hba.conf

```bash
# ip
#host    all             all             192.168.80.0/24         md5
# replication
host    replication     repuser         192.168.80.0/24        md5

```

<!--
[pg106@db2 ~]$ pg_basebackup -h 192.168.6.141 -p 5970 -U repuser -Fp -X stream -P -D /opt/pg106/data -v
pg_basebackup: could not connect to server: FATAL:  no pg_hba.conf entry for replication connection from host "192.168.6.142", user "repuser"
pg_basebackup: removing data directory "/opt/pg106/data"
-->

### 备端配置

1. 安装数据库软件
2. 初始化基础数据。可以直接将主库复制到备库（duplicate）。操作步骤如下

```bash
$ pg_basebackup -h 192.168.80.146 -p 5866 -U repuser -Fp -X stream -P -D /opt/hgdb/data -v 
Password:
pg_basebackup: initiating base backup, waiting for checkpoint to complete 
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/9000028 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_2434"
25396/25396 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/90000F8
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: base backup completed

> 注意，如果包括非默认表空间，主备目录需一致，或者使用参数 -T 进行映射
  -T, --tablespace-mapping=OLDDIR=NEWDIR
                         relocate tablespace in OLDDIR to NEWDIR

pg_basebackup --help
-h ，主库主机， -p ，主库服务端口；
-U ，复制用户；
-F ， p 是默认输出格式，输出数据目录和表空间相同的布局， t 表示 tar 格式输出
-P ，同 --progress ，显示进度；
-D ，输出到指定目录；
-X ，  --wal-method=none|fetch|stream
include required WAL files with specified method
-v ,  verbose

-T, --tablespace-mapping=OLDDIR=NEWDIR
                         relocate tablespace in OLDDIR to NEWDIR

or

使用备份恢复的方式

主
select pg_start_backup('rep');
tar -czvf pg_data.tar.gz $PGDATA --exclude=$PGDATA/pg_wal
scp pg_data.tar.gz 192.168.6.17:/tmp
select pg_stop_backup();

备
tar -zxvf pg_data.tar.gz
mkdir $PGDATA/pg_wal
```

3. 配置 recovery.conf

cp ../share/postgresql/recovery.conf.sample recovery.conf

```bash
# stream replicationg
standby_mode='on'
primary_conninfo='user=repuser password=repuser host=10.247.32.16 port=6432 application_name=pgrep1 keepalives_idle=60 keepalives_interval=10 keepalives_count=5'
primary_slot_name='pslot1'
recovery_target_timeline='latest'
```

> 注意： primary_conninfo 明文指出了密码，建议将密码配置在密码文件中。参考[pgpass](./pgpass.md) （备库）

pg12及以上使用以上配置会报错

```sh
2021-04-14 13:48:39.851 CST,,,6044,,607660ed.179c,1,,2021-04-14 11:26:37 CST,,0,WARNING,XX000,"could not flush dirty data: Function not implemented",,,,,,,,,""

```

**以上为pg12前的配置，pg12及之后版本配置如下，参考[pg12新特性-迁移recovery.conf到postgresql.conf](./pg_new_features/pg12新特性-迁移recovery.conf到postgresql.conf.md)**



pg12及以上配置步骤

```sh
touch $PGDATA/standby.signal
#touch $PGDATA/recovery.signal 

postgresql.conf中添加以下内容

# replication
#standby_mode='on' #被移除
primary_conninfo='user=repuser host=10.247.32.16 port=6432 application_name=pgrep1 keepalives_idle=60 keepalives_interval=10 keepalives_count=5'
primary_slot_name='pslot1'
recovery_target_timeline='latest'

```

4 启动备库，流复制搭建完成。默认是异步流复制，下面会介绍同步流复制配置

```bash
$ pg_ctl start
waiting for server to start....2018-12-27 19:42:34.160 +08 [4225] LOG:  listening on IPv4 address "0.0.0.0", port 6432
2018-12-27 19:42:34.161 +08 [4225] LOG:  listening on IPv6 address "::", port 6432
2018-12-27 19:42:34.164 +08 [4225] LOG:  listening on Unix socket "/tmp/.s.PGSQL.6432"
2018-12-27 19:42:34.481 +08 [4225] LOG:  redirecting log output to logging collector process
2018-12-27 19:42:34.481 +08 [4225] HINT:  Future log output will appear in directory "pg_log".
............................. done
server started
```

日志

```bash
2018-12-27 19:42:34.481 +08,,,4225,,5c24baaa.1081,1,,2018-12-27 19:42:34 +08,,0,LOG,00000,"ending log output to stderr",,"Future log output will go to log destination ""csvlog"".",,,,,,,""
2018-12-27 19:42:34.484 +08,,,4227,,5c24baaa.1083,1,,2018-12-27 19:42:34 +08,,0,LOG,00000,"database system was interrupted; last known up at 2018-12-27 19:09:31 +08",,,,,,,,,""
2018-12-27 19:42:34.532 +08,,,4227,,5c24baaa.1083,2,,2018-12-27 19:42:34 +08,,0,LOG,00000,"entering standby mode",,,,,,,,,""
2018-12-27 19:42:34.536 +08,,,4227,,5c24baaa.1083,3,,2018-12-27 19:42:34 +08,1/0,0,LOG,00000,"redo starts at 2A/7330E518",,,,,,,,,""
2018-12-27 19:43:03.509 +08,,,4227,,5c24baaa.1083,4,,2018-12-27 19:42:34 +08,1/0,0,LOG,00000,"consistent recovery state reached at 2B/E18304F8",,,,,,,,,""
2018-12-27 19:43:03.510 +08,,,4225,,5c24baaa.1081,2,,2018-12-27 19:42:34 +08,,0,LOG,00000,"database system is ready to accept read only connections",,,,,,,,,""
2018-12-27 19:47:55.512 +08,,,4452,,5c24bbeb.1164,1,,2018-12-27 19:47:55 +08,,0,LOG,00000,"started streaming WAL from primary at 2B/E2000000 on timeline 1",,,,,,,,,"
```

正常同步

```bash
 2018-12-28 07:22:38.330 +08,,,4361,,5c24bb6b.1109,69,,2018-12-27 19:45:47 +08,,0,LOG,00000,"recovery restart point at 2D/FEFAD5D8","last completed transaction was at log time 2018-12-28 06:35:57.33835+08",,,,,,,,""
2018-12-28 07:47:48.440 +08,,,4361,,5c24bb6b.1109,70,,2018-12-27 19:45:47 +08,,0,LOG,00000,"restartpoint starting: time",,,,,,,,,""
2018-12-28 07:50:21.827 +08,,,4361,,5c24bb6b.1109,71,,2018-12-27 19:45:47 +08,,0,LOG,00000,"restartpoint complete: wrote 1526 buffers (0.0%); 0 WAL file(s) added, 1 removed, 0 recycled; write=153.374 s, sync=0.003 s, total=153.387 s; sync files=35, longest=0.001 s, average=0.000 s; distance=16118 kB, estimate=686704 kB",,,,,,,,,""
2018-12-28 07:50:21.827 +08,,,4361,,5c24bb6b.1109,72,,2018-12-27 19:45:47 +08,,0,LOG,00000,"recovery restart point at 2D/FFF6B118","last completed transaction was at log time 2018-12-28 06:35:57.33835+08",,,,,,,,""
2018-12-28 08:17:48.928 +08,,,4361,,5c24bb6b.1109,73,,2018-12-27 19:45:47 +08,,0,LOG,00000,"restartpoint starting: time",,,,,,,,,""
2018-12-28 08:21:19.748 +08,,,4361,,5c24bb6b.1109,74,,2018-12-27 19:45:47 +08,,0,LOG,00000,"restartpoint complete: wrote 2099 buffers (0.1%); 0 WAL file(s) added, 1 removed, 0 recycled; write=210.801 s, sync=0.001 s, total=210.819 s; sync files=45, longest=0.001 s, average=0.000 s; distance=16979 kB, estimate=619732 kB",,,,,,,,,""
2018-12-28 08:21:19.748 +08,,,4361,,5c24bb6b.1109,75,,2018-12-27 19:45:47 +08,,0,LOG,00000,"recovery restart point at 2E/10000D0","last completed transaction was at log time 2018-12-28 08:24:00.208869+08",,,,,,,,""
2018-12-28 08:47:48.848 +08,,,4361,,5c24bb6b.1109,76,,2018-12-27 19:45:47 +08,,0,LOG,00000,"restartpoint starting: time",,,,,,,,,""

```
