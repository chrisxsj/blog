# sql_dump

**作者**

chrisx

**日期**

2021-05-11

**内容**

使用sql_dump备份恢复数据，移动数据。

Backup and Restore-sql dump

ref[sql dump](https://www.postgresql.org/docs/12/backup-dump.html)

ref[14.4. Populating a Database](https://www.postgresql.org/docs/12/populate.html)

----

[TOC]

## sql转储

SQL 转储创建一个由SQL命令组成的文件，服务器将利用其中的SQL命令重建与转储时状态一样的数据库。 PostgreSQL为此提供了工具pg_dump。

pg_dump — 把PostgreSQL数据库抽取为一个脚本文件或其他归档文件

* pg_dump是一个客户端，因此可以远程访问数据库进行备份。备份存放在客户端。
* pg_dump需要有备份表的读权限，因此为了备份整个数据库你几乎总是必须以一个数据库超级用户来运行它。
* pg_dump可以支持跨版本数据库导入
* pg_dump可以跨架构传输数据，例如从一个32位服务器到一个64位服务器。
* pg_dump转储的是数据库快照，在pg_dump运行过程中发生的更新将不会被转储
* pg_dump工作的时候并不阻塞其他的对数据库的操作。但是会阻塞那些需要排它锁的操作，比如大部分形式的ALTER TABLE
* 脚本转储是包含 SQL 命令的纯文本文件，它们可以用来重构数据库到它被转储时的状态。要从这样一个脚本恢复，配合psql使用。
* 自定义文件格式必须与pg_restore配合使用来重建数据。这种格式在默认情况还会被压缩，同时它还允许pg_restore能选择恢复什么。

### pg_dump使用

pg_dump用法

```bash
pg_dump --help
```

pg_dump示例

输出一个纯文本形式的SQL脚本文件（plain）

```bash
pg_dump -h 192.168.6.141 -p 5966 -d highgo -U highgo -t public.test_dump -Fp -v -f /tmp/test_dump1.dmp #导出表
pg_dump -h 192.168.6.141 -p 5966 -d highgo -U highgo -Fp -v -f /tmp/test_dump1.dmp #导出数据库
```

输出一个适合于作为pg_restore输入的自定义格式归档（customer）

```bash
pg_dump -h 192.168.6.141 -p 5966 -d highgo -U highgo -t public.test_dump -Fc -v -f /tmp/test_dump2.dmp  #导出表
pg_dump -d postgres -U pg126 -Fc -v -f /tmp/test_dump2.dmp #导出数据库
```

自定义、9级压缩格式

```bash
pg_dump -h 192.168.6.141 -p 5966 -d highgo -U highgo -t public.test_dump -Fc -Z 9 -v -f /tmp/test_dump3.dmp

```

查看dmp文件信息

```bash
file test*
test_dump1.dmp: ASCII text
test_dump2.dmp: PostgreSQL custom database dump - v1.14-0
test_dump3.dmp: PostgreSQL custom database dump - v1.14-0
 du -sk test*
2532    test_dump1.dmp
1016    test_dump2.dmp
1008    test_dump3.dmp

```

## 从转储中恢复

pg_dump生成的文本文件可以由psql程序读取。自定义转储文件可由pg_restore使用

* 恢复前需创建需要的数据库
* 恢复之前，转储库中对象的拥有者以及在其上被授予了权限的用户必须已经存在。（user，schema）
* psql脚本在遇到一个SQL错误后会继续执行。可以设置ON_ERROR_STOP变量来运行psql，这将使psql在遇到SQL错误后退出。无论怎样，将只能得到一个部分恢复的数据库
* 可以指定让整个恢复作为一个单独的事务运行，这样恢复要么完全完成要么完全回滚。这种模式可以通过向psql传递-1或--single-transaction命令行选项来指定。
<!--在使用这种模式时，注意即使是很小的一个错误也会导致运行了数小时的恢复被回滚。但是，这仍然比在一个部分恢复后手工清理复杂的数据库要更好。-->
* pg_dump和psql读写管道的能力使得直接从一个服务器转储一个数据库到另一个服务器成为可能，例如：

```bash
pg_dump -h host1 dbname | psql -h host2 dbname

```

* pg_restore可以在两种模式下操作。如果指定了一个数据库名称，pg_restore会连接那个数据库并且把归档内容直接恢复到该数据库中。否则，会创建一个脚本,等效于pg_dump的纯文本输出格式.

> 注意，一旦完成恢复，在每个数据库上运行ANALYZE操作

### 恢复使用

导入前创建user,sechema，如果需要的话，手动建库。

> 注意，导出schema的话，会有schema创建语句，无需手动创建schema

```sql
--CREATE ROLE highgo;
--ALTER ROLE highgo WITH login PASSWORD 'highgo@123';
```

psql恢复（plain文件）

```bash
psql -h 192.168.6.141 -p 5966 -U highgo -d test -f /tmp/test_dump1.dmp
psql -h 192.168.6.141 -p 5966 -U highgo -d test -f /tmp/test_dump1.dmp --single-transaction

```

pg_restore恢复（customer文件）

```bash
pg_restore -h 192.168.6.141 -p 5966 -U highgo -d test /tmp/test_dump2.dmp -v
pg_restore -h 192.168.100.5 -p 5866-v -U highgo -d picctest "H:\dump_from8\picctest.dmp" --single-transaction
```

## 使用pg_dumpall

* pg_dump每次只转储一个数据库，而且它不会转储关于角色或表空间（因为它们是集簇范围的）的信息。为了支持方便地转储一个数据库集簇的全部内容，提供了pg_dumpall程序。pg_dumpall备份一个给定集簇中的每一个数据库，并且也保留了集簇范围的数据，如角色和表空间定义。
* pg_dumpall工作时会发出命令重新创建角色、表空间和空数据库，接着为每一个数据库pg_dump。
* 集簇范围的数据可以使用pg_dumpall的--globals-only选项来单独转储。
* pg_dumpall需要多次连接到PostgreSQL服务器（每个数据库一次）。如果你使用口令认证，可能每次都会要求口令。这种情况下使用一个~/.pgpass会比较方便

可用pg_dumpall转储role，schema或表空间定义，配合pg_dump转储数据来用。

仅导出全局角色和模式

```bash
pg_dumpall -h 192.168.6.141 -p 5966 -U highgo -l highgo -r -s -v -f /tmp/test_all_role_schema.dmp

```

## 处理大型数据库

在一些具有最大文件尺寸限制的操作系统上创建大型的pg_dump输出文件可能会出现问题，幸运地是，pg_dump可以写出到标准输出,因此可以使用标准Unix工具处理潜在的问题

### 1. 压缩转储

使用压缩转储，可以使用你喜欢的压缩程序，例如gzip：

备份

```bash
pg_dump dbname | gzip > filename.gz

```

恢复

```bash
gunzip -c filename.gz | psql dbname

```

### 2. 分割

使用split，让每一块的大小为1兆字节

备份

```bash
pg_dump dbname | split -b 1m - filename

```

恢复

```bash
cat filename* | psql dbname

```

### 3. 自定义转储格式

如果PostgreSQL所在的系统上安装了zlib压缩库，自定义转储格式将在写出数据到输出文件时对其压缩。
这种方式的一个优势是其中的表可以被有选择地恢复

备份

```bash
pg_dump -Fc dbname > filename

```

自定义格式的转储不是psql的脚本，只能通过pg_restore恢复，例如：

```bash
pg_restore -d dbname filename

```

pg_restore 用法

```bash
pg_restore --help

```

### 4. 使用pg_dump的并行转储特性

为了加快转储一个大型数据库的速度，你可以使用pg_dump的并行模式。它将同时转储多个表。你可以使用-j参数控制并行度。并行转储只支持“目录”归档格式。

```bash
pg_dump -j num -F d -f out.dir dbname

pg_dump -h 192.168.6.16 -U highgo -p 5433  -d highgo -Ft -v -Z 1 -t test_dump -f /tmp/test_dump3.dmp
pg_restore -d htest_c -F d -j 5 -h localhost -p 5866 -U htest /home/highgo/baktest/test1
```

> 注意，以使用pg_restore -j来以并行方式恢复一个转储。它只能适合于“自定义”归档或者“目录”归档，但不管归档是否由pg_dump -j创建。
> 注意
1、pg_dump 生成的转储文件不包含优化器用于做出查询规划决策的统计信息。因此，明智的做法是从转储文件还原后运行 ANALYZE，以确保最佳性能;
2、通常pg_dump用于将数据传输到最新版本，因此从老的postgresql数据库版本转储出来的dmp数据可以导入更高版本postgresql数据库中。
3、pg_dump工具可以连接比自己版本老的postgresql数据库。但不能连接比自己版本新的postgresql数据库。它甚至会拒绝尝试。
4、dump的数据也不能保证能加载到旧版本数据库中。将转储文件加载到较旧的服务器可能需要手动编辑转储文件，以删除旧服务器无法理解的语法。

## pg_restore过滤

列出dmp内容

```bash
pg_restore -l /tmp/testdmp.dmp -f /tmp/testdmp_list.dmp
```

过滤函数（dump文件只包含函数）产生list

```bash
pg_restore -l /tmp/test.dump | grep FUNCTION > /tmp/test_f.dump

```

反向过滤（排除函数）生成list

```bash
pg_restore -l /tmp/test.dump | grep -v FUNCTION > /tmp/test_nofun_noseq.dump
```

反向过滤（排除函数|触发器|序列|外键)，生成list

```bash
pg_restore -l /tmp/test.dump  | grep -v -E "FUNCTION|TRIGGER|SEQUENCE|FK" > /tmp/test_nofun_notrig_noseq_nofk.dump

```

> 注,去掉序列后，建表语句中可能会引用序列作为列的默认值，这种sql需要手动修改，删除语句中序列引用（DEFAULT nextval）

pg_restore自带参数-x，可在以上过滤的基础上进一步过滤掉授权语句grant

```bash
pg_restore -x /tmp/test_nofun_notrig_noseq_nofk.dump > /tmp/test_nofun_notrig_noseq_nofk_nogrant.dump

```

过滤后，-L将依据list导成sql（不指定db，会生成sql文件）

```postgresql
pg_restore -L /tmp/test_nofun_notrig_noseq_nofk_nogrant.dump /tmp/test.dump -f /tmp/test_nofun_notrig_noseq_nofk_nogrant.sql

```

> 注意，-L 指定恢复元素，只恢复在list-file中列出的归档元素，并且按照它们出现在该文件中的顺序进行恢复

执行sql导入

```sql
\i /tmp/test_nofun_notrig_noseq_nofk_nogrant.sql
or
nohup psql -p 6067 -U highgo -d party_org_info_mgmt -f /data/20210310/party_org_info_mgmt_zao.sql -o ~/party_org_info_mgmt_zao.out 2>&1 &
```

## 导入到不同的schema或tablespace

如果需要将数据导入到不同的schema，tablespace。如何做？
实现方式：将schema数据导出为Fp平面文件，及sql脚本的形式，然后替换sql脚本中的schema和tablespace，再将其导入到数据库中。（schema可以使用-n/--schema，但表空间只能修改脚本）

步骤如下：
1 使用pg_dump工具实现平面文件格式备份文件，将数据字典和表数据分开导出

如：导出schema pub数据

```sh
pg_dump -Fp -s -v -n pub test -f /backup/pub_dic.dmp    #导出字典信息
pg_dump -Fp -a -v -n pub test -f /backup/pub_data.dmp   #导出表数据
```

2 创建新的用户和schema
如：创建新用户和schema test_1209

```sql
create role prod_1209 with login password 'test_1209';
create schema if not exists test_1209;
grant all on schema prod_1209 to test_1209;
```

3 替换备份文件中schema的名字

如 将schema pub替换为schema test_1209

```sh
sed -i "s/pub/test_1209/g" /backup/pub_dic.dmp  #替换字典备份文件
sed -i "s/COPY pub/COPY test_1209/g" /backup/pub_data.dmp   #替换数据备份文件
```

4 替换替换字典备份文件中的tablespace参数设置

```sh
sed -i "s/default_tablespace='postgres'/default_tablespace='test'/g" /backup/pub_dic.dmp
```

5 导入数据到新schema和tablespace

导入数据

```sql
db=> \i /backup/pub_dic.dmp
db=> \i /backup/pub_data.dmp
```

## hgdb 通用版数据导入安全版

支持

## 最后收集统计信息

重要
pg_dump产生的转储是相对于template0。这意味着在template1中加入的任何语言、过程等都会被pg_dump转储。结果是，如果在恢复时使用的是一个自定义的template1，你必须从template0创建一个空的数据库，正如上面的例子所示。

一旦完成恢复，在每个数据库上运行ANALYZE是明智的举动，这样优化器就有有用的统计数据了，更多信息参见第 24.1.3 节和第 24.1.6 节。更多关于如何有效地向PostgreSQL里装载大量数据的建议， 请参考第 14.4 节。

```sql
ANALYZE database;
```

<!--
填充一个数据库
14.4.1. 禁用自动提交
14.4.2. 使用COPY
14.4.3. 移除索引
14.4.4. 移除外键约束
14.4.5. 增加maintenance_work_mem
14.4.6. 增加max_wal_size
14.4.7. 禁用 WAL 归档和流复制
14.4.8. 事后运行ANALYZE
14.4.9. 关于pg_dump的一些注记
-->
