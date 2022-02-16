# logical_replication_case

同步环境如下：
发布库（生产库）：10.247.32.16/rhel7.4/pg10.6
订阅库（报表库）：10.247.32.27/rhel7.4/pg10.6

客户根据业务逻辑，统计了需要同步的表（约568张表，全部属于模式对象xxx）。这些表分成10个通道同步。

查看[同步表](./script/tablelg.xls)

### 初始化表结构

根据同步要求。订阅端导入表结构时，需进行过滤，并导入到其他表空间。

- 过滤：不导入函数、触发器、序列、授权语句、外键
- 导入表空间：数据导入到表空间tbs_other、索引导入到表空间tbs_otheridex

1 使用pg的_dump导出模式对象xxx下的所有表表结构

```sql
pg_dump -p 6432 -U postgres -s -n xxx -Fc -v -f /backup/pgdump/xxx.dump -d xxx
```

2 对dump文件过滤，过滤掉函数、触发器、序列、外键

```sql
pg_restore -l /backup/pgdump/xxx.dump  | grep -v -E "FUNCTION|TRIGGER|SEQUENCE|FK" > /backup/pgdump/xxx_nofun_notrig_noseq_nofk.dump
```

3 在以上基础上过滤掉授权语句。并将dump文件导入成sql文本

```sql
pg_restore -x -L /backup/pgdump/xxx_nofun_notrig_noseq_nofk.dump  /backup/pgdump/xxx.dump > /backup/pgdump/xxx_nofun_notrig_noseq_nofk_nogrant.sql
```

4 由于过滤掉了序列对象，而表中的列引用了序列。还需要修改sql文本，去掉对序列的引用

去掉带有DEFAULT nextval的语句
然后将表和索引放到两个sql脚本中，
最后修改sql脚本中的表空间参数，建表脚本设置SET default_tablespace = 'tbs_other';，建索引脚本设置SET default_tablespace = 'tbs_otheridex';

5 导入数据

```sql
\i /bakcup/pgdump/xxx_nofun_notrig_noseq_nofk_nogrant_table_nodefaultnext.sql
```

6 导入索引

```sql
\i /bakcup/pgdump/xxx_nofun_notrig_noseq_nofk_nogrant_index.sql
```

### 发布端 publisher

1 修改参数

```sql
alter system set wal_level=logical;
alter system set max_replication_slots=30;
alter system set max_wal_senders=40;
alter system set max_logical_replication_workers=40;
alter system set max_sync_workers_per_subscription=10;

```

重启生效
pg_ctl restart

2 发布节点创建逻辑复制用户

```sql
create user logicalrep replication login encrypted password 'logicalrep';
```

修改同步用户密码

```sql
alter user logicalrep with password 'xxx';
```

给同步用户授权

```sql
grant usage on schema sgiprod to logicalrep;
grant select on all tables in schema sgiprod to logicalrep;
grant all on database postgres to logicalrep;
```

3 发布节点创建发布

```sql
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;
create publication xxx_slot;

or

create publication xxx_slot FOR ALL TABLES; --自动将所有的表加入publication
```

查询发布

```sql
select * from pg_publication;
```

pubowner ，发布的属主，与 pg_user 视图中的 usersysid 关联

4 配置 replication 网络访问控制

pg_hba.conf

```bash
# logical replication
host    all     logicalrep      10.247.32.27/32         md5
host    replication     all     10.247.32.27/32         md5
```

加载生效
pg_ctl reload

### 订阅节点配置 subscriber

1 参数配置

```sql
--alter system set wal_level=logical;
alter system set max_replication_slots=30;
alter system set max_wal_senders=40;
alter system set max_logical_replication_workers=40;
alter system set max_sync_workers_per_subscription=10;
```

重启生效
pg_ctl restart

2 配置密码文件

```bash
$ chmod 0600 .pgpass
$ cat .pgpass
#
10.247.32.16:6432:*:logicalrep:logicalrep
```

3 订阅节点创建订阅

```sql
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
create subscription xxx_slot_sub connection 'host=10.247.32.16 port=6432 dbname=xxx user=logicalrep' publication xxx_slot;
```

上面的语句将开始复制过程，它会同步表users以及departments的初始表内容，然后开始复制对那些表的增量更改。

查询发布节点，订阅在发布节点上创建了逻辑复制槽

```sql
select slot_name,plugin,slot_type,database,active,restart_lsn from pg_replication_slots;
```

3 订阅节点查询订阅信息

```sql
select * from pg_subscription;
```

### 同步数据，添加同步表

> 注意，以chengbao_solt为例

此时逻辑复制已经开始，但无同步数据，因为发布中没有对象

日志显示

```bash
2019-03-15 11:21:12.641 CST,"logicalrep","postgres",1552,"192.168.6.13:47548",5c8b1a28.610,2,"idle",2019-03-15 11:21:12 CST,5/0,0,LOG,00000,"logical decoding found consistent point at 0/7E004BB0","There are no running transactions.",,,,,,,,"sub1"
2019-03-15 11:25:35.111 CST,,,1454,,5c8b160a.5ae,3,,2019-03-15 11:03:38 CST,,0,LOG,00000,"received SIGHUP, reloading configuration files",,,,,,,,,""
subscriber
2019-03-15 11:39:53.187 CST,,,1347,,5c8b1e89.543,1,,2019-03-15 11:39:53 CST,3/2,0,LOG,00000,"logical replication apply worker for subscription ""sub1"" has started",,,,,,,,,""
```

1 发布节点添加同步表

```sql
alter publication chengbao_solt add table sgiprod.gupolicymain;
alter publication chengbao_solt add table sgiprod.gupolicyrisk;
alter publication chengbao_solt add table sgiprod.gupolicyriskexpensemisc;
```

2 订阅节点手动刷新数据

```sql
alter subscription chengbao_solt_sub refresh publication;
```

> 请注意，向已订阅的发布添加表将需要 ALTER SUBSCRIPTION ... REFRESH PUBLICATION 操作，以便生效。

3 订阅节点subscriber 再次查询数据同步

```sql
select count(*) from sgiprod.gupolicymain;
select count(*) from sgiprod.gupolicyrisk;
select count(*) from sgiprod.gupolicyriskexpensemisc;
```

### logical replication 同步状态查看

1 状态查看

```sql
select pid,usename,application_name,client_addr,state,replay_lsn,replay_lag,sync_state from pg_stat_replication;
```

2 主备库有相关的发布和订阅进程

```bash
发布
pg 1463 1454 0 11:03 ? 00:00:00 postgres: bgworker: logical replication launcher
pg 1587 1454 0 11:39 ? 00:00:00 postgres: wal sender process logicalrep 192.168.6.13(47550) idle
订阅
postgres 1346 1338 0 11:39 ? 00:00:00 postgres: bgworker: logical replication launcher
postgres 1347 1338 0 11:39 ? 00:00:00 postgres: bgworker: logical replication worker for subscription 16391
```

3 查询发布中的表列表

```sql
\dRp+
or
select * from pg_publication_tables;
```

## 13其他操作

### 添加同步表（ add ）

1. 订阅节点导入表结构
2. 发布节点添加发布表
alter publication pub1 add table highgo.test_lr1;
4. 发布节点授予逻辑复制用户权限
grant usage on schema highgo to logicalrep ;
grant select on highgo.test_lr1 to logicalrep;
5. 执行刷新命令初始化数据
alter subscription sub1 refresh publication;
可通过表 pg_subscript 查看 sub 与 pub 的对应关系，来确定刷新那个 sub
6. 查看主备数据是否一致。

> 注意：加表时应避免业务高峰期。如月末结算等。

### 重新同步表（ resync ）

如果想重新同步表数据，不能在原表的基础上增量同步，必须删除重新同步

1. 主库从发布删除表
alter publication test_slot drop table public.test_lr;
2. 订阅端删除表
drop table test_lr;

> 注意，不要使用truncate，否则只会增量同步

3. 订阅端重新导入表结构
4. 主库将表加入发布
alter publication test_slot add table public.test_lr;
4. 订阅端初手动刷新数据
alter subscription test_slot_sub refresh publication;

### 重新同步订阅中的所有表

1. 禁用订阅
alter subscription test_slot_sub disable;
2. 删除订阅
drop subscription test_slot_sub;
3. 订阅端删除表
4. 订阅端导入表结构
5. 创建订阅
create subscription test_slot_sub connection 'host=192.168.6.141 port=5966 dbname=highgo user=logicalrep' publication test_slot;

> 注意，删除订阅后，本地的表不会被删除，数据也不会清除，仅仅是不在接收该订阅的上游信息。删除订阅后，如果要重新使用该订阅，数据需要resync

## 实验

级联逻辑复制测试

<!--
1 schema必须一致，否则报错

postgres=# alter subscription test_slot_sub refresh publication;
ERROR:  schema "test" does not exist
postgres=#

2 数据库，表空间可以不一致。
3 主段发布3个表，订阅端只订阅一个表不可以，订阅是针对整个发布的。
4 ERROR,XX000,"could not start WAL streaming: 错误:  42704: 复制槽名 ""sub1"" 不存在",,,,,,,,,""

注：在实施完成后在发布端把这个复制槽相关信息记录下来，否则复制槽消失后查询不到此记录，主要记录slot_name.plugin等

也就是说需要创建与订阅相同名字的复制槽。
5 可以对订阅端的数据进行修改  但是切记不要修改主键数据      修改其他数据无所谓，数据同步的时候会以主端同步更新，不管你对非主键数据进行了何种修改
-->
