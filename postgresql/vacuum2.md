# vacuum2

**作者**

Chrisx

**日期**

2021-04-27

**内容**

vacuum优化

日常清理

ref [Routine Vacuuming](https://www.postgresql.org/docs/13/maintenance.html)

---

[TOC]

## vacuum清理

由于mvcc，pg必须定期清理表。有两种VACUUM的变体：标准VACUUM和VACUUM FULL。
VACUUM会产生大量I/O流量，这将导致其他活动会话性能变差。可以调整一些配置参数来后台清理活动造成的性能冲击

vacuum相关参数查看

```sql
select name,
    setting,
    current_setting(name)
from pg_settings
where name like '%vacuum%';
```

vacuum常用参数

ref [防止事务 ID 回卷失败](http://postgres.cn/docs/13/routine-vacuuming.html)
ref [Preventing Transaction ID Wraparound Failures](https://www.postgresql.org/docs/13/routine-vacuuming.html#VACUUM-BASICS)

* vacuum_freeze_min_age (integer)

影响lazy模式

指定VACUUM在扫描表时用来决定是否冻结行版本的切断年龄（以事务计）。默认值是 5 千万个事务。尽管用户可以将这个值设置为从 0 到 10 亿，VACUUM会悄悄地将有效值设置为autovacuum_freeze_max_age值的一半，这样在强制执行的自动清理之间不会有过短的时间间隔。更多信息请见第 24.1.5 节。

vacuum_freeze_min_age controls how old an XID value has to be before rows bearing that XID will be frozen. Increasing this setting may avoid unnecessary work if the rows that would otherwise be frozen will soon be modified again, but decreasing this setting increases the number of transactions that can elapse before the table must be vacuumed again.
在含有XID的行被冻结之前。vacuum_freeze_min_age控制一个XID可以有多老。如果要被冻结的行很快再次被修改，增加此设置可以避免不必要的工作。但是减少此设置，在下一次vacuum前，会增加表上经过的事务数。

* vacuum_freeze_table_age (integer)

影响eager模式

当表的pg_class.relfrozenxid域达到该设置指定的年龄时，VACUUM会执行一次激进的扫描。激进的扫描与常规VACUUM的不同在于它会访问每一个可能包含未冻结 XID 或者 MXID 的页面，而不只是那些可能包含死亡元组的页面（注：可见映射*vm记录的页面）。默认值是 1.5 亿个事务。尽管用户可以把这个值设置为从 0 到 20 亿，VACUUM会悄悄地将有效值设置为autovacuum_freeze_max_age值的95%，因此在表上启动一次回卷自动清理之前有机会进行一次定期手动VACUUM。更多信息请见第 24.1.5 节。

VACUUM通常会跳过不含有任何死亡行版本的页面，但是不会跳过那些含有带旧 XID 值的行版本的页面。要保证所有旧的行版本都已经被冻结，需要对整个表做一次扫描。vacuum_freeze_table_age控制VACUUM什么时候这样做：如果该表经过vacuum_freeze_table_age减去vacuum_freeze_min_age个事务还没有被完全扫描过，则会强制一次全表清扫。将这个参数设置为 0 将强制VACUUM总是扫描所有页面而实际上忽略可见性映射。

* autovacuum_freeze_max_age (integer)

指定在一个VACUUM操作被强制执行来防止表中事务ID回卷之前，一个表的pg_class.relfrozenxid域能保持的最大年龄（事务的）。注意即便自动清理被禁用，系统也将发起自动清理进程来阻止回卷。

清理也允许从pg_xact子目录中移除旧文件，这也是为什么默认值被设置为较低的2亿事务。该参数只能在服务器启动时设置，但是对于个别表可以通过修改表存储参数来降低该设置。详见第 24.1.5 节。

一个表能保持不被清理的最长时间是 20 亿个事务减去VACUUM上次扫描全表时的vacuum_freeze_min_age值。如果它超过该时间没有被清理，可能会导致数据丢失。要保证这不会发生，将在任何包含比autovacuum_freeze_max_age配置参数所指定的年龄更老的 XID 的未冻结行的表上调用自动清理（即使自动清理被禁用也会发生）。

这意味着如果一个表没有被清理，大约每autovacuum_freeze_max_age减去vacuum_freeze_min_age事务就会在该表上调用一次自动清理。对那些为了空间回收目的而被正常清理的表，这是无关紧要的。然而，对静态表（包括接收插入但没有更新或删除的表）就没有为空间回收而清理的需要，因此尝试在非常大的静态表上强制自动清理的间隔最大化会非常有用。显然我们可以通过增加autovacuum_freeze_max_age或减少vacuum_freeze_min_age来实现此目的。 

vacuum_freeze_table_age的实际最大值是 0.95 * autovacuum_freeze_max_age，高于它的设置将被上限到最大值。一个高于autovacuum_freeze_max_age的值没有意义，因为不管怎样在那个点上都会触发一次防回卷自动清理，并且 0.95 的乘数为在防回卷自动清理发生之前运行一次手动VACUUM留出了一些空间。作为一种经验法则，vacuum_freeze_table_age应当被设置成一个低于autovacuum_freeze_max_age的值，留出一个足够的空间让一次被正常调度的VACUUM或一次被正常删除和更新活动触发的自动清理可以在这个窗口中被运行。将它设置得太接近可能导致防回卷自动清理，即使该表最近因为回收空间的目的被清理过，而较低的值将导致更频繁的全表扫描。

增加autovacuum_freeze_max_age（以及和它一起的vacuum_freeze_table_age）的唯一不足是数据库集簇的pg_xact和pg_commit_ts子目录将占据更多空间，因为它必须存储所有向后autovacuum_freeze_max_age范围内的所有事务的提交状态和（如果启用了track_commit_timestamp）时间戳。提交状态为每个事务使用两个二进制位，因此如果autovacuum_freeze_max_age被设置为它的最大允许值 20 亿，pg_xact将会增长到大约 0.5 吉字节，pg_commit_ts大约20GB。如果这对于你的总数据库尺寸是微小的，我们推荐设置autovacuum_freeze_max_age为它的最大允许值。否则，基于你想要允许pg_xact和pg_commit_ts使用的存储空间大小来设置它（默认情况下 2 亿个事务大约等于pg_xact的 50 MB存储空间，pg_commit_ts的2GB的存储空间）。

减小vacuum_freeze_min_age的一个不足之处是它可能导致VACUUM做无用的工作：如果该行在被替换成FrozenXID之后很快就被修改（导致该行获得一个新的 XID），那么冻结一个行版本就是浪费时间。因此该设置应该足够大，这样直到行不再可能被修改之前，它们都不会被冻结。

 为了跟踪一个数据库中最老的未冻结 XID 的年龄，VACUUM在系统表pg_class和pg_database中存储 XID 的统计信息。特别地，一个表的pg_class行的relfrozenxid列包含被该表的上一次全表VACUUM所用的冻结截止 XID。该表中所有被有比这个截断 XID 老的普通 XID 的事务插入的行 都确保被冻结。相似地，一个数据库的pg_database行的datfrozenxid列是出现在该数据库中的未冻结 XID 的下界 — 它只是数据库中每一个表的relfrozenxid值的最小值。一种检查这些信息的方便方法是执行这样的查询：

SELECT c.oid::regclass as table_name,
       greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as age
FROM pg_class c
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind IN ('r', 'm');

SELECT datname, age(datfrozenxid) FROM pg_database;

age列度量从该截断 XID 到当前事务 XID 的事务数。

**也就是说，在事务时间轴上，vacuum_freeze_min_age越小，freeze 操作就会越频繁**

其他vacuum 参数

* autovacuum_naptime  --默认值60s，vacuum唤醒时间
* autovacuum_max_workers=5; --vacuum最大进程数

* autovacuum_vacuum_threshold --默认值50，影响autovacuum
* autovacuum_vacuum_scale_factor --默认值0.2，影响autovacuum
* autovacuum_freeze_min_age   --表级，eager模式补充

* autovacuum_freeze_table_age  --表级参数

## autovacuum进程触发行为

pg数据库中加入autovacuum机制，定期触发，以实现自动vacuum、freeze等清理操作。那么autovacuum的触发行为是怎么样的呢？

autovacuum包括两种处理进程autovacuum launcher和autovacuum worker。autovacuum launcher选择需要清理的数据库并调度autovacuum worker工作。

1. autovacuum launcher选择需要清理的数据库。
数据库中xid超过autovacuum_freeze_max_age时，会强制触发autovacuum launcher，主要是freeze操作，从而避免 wraparound。冻结过程根据参数配置选择lazy或eager模式
数据库中参数autovacuum_naptime也会定期触发autovacuum launcher，选择一个最早未执行自动清理的数据库。

1. 清理表的触发条件
autovacuum launcher选定数据库后，调用autovacuum worker，清理选择的数据库。扫描数据库中的表
根据一定触发条件，触发表的清理（vacuum）操作
表上（update,delte 记录数） >= autovacuum_vacuum_threshold + autovacuum_vacuum_scale_factor * number of tuples
根据一定触发条件，触发表的分析（analyze）操作
表上(insert,update,delte 记录数) >= autovacuum_analyze_threshold + autovacuum_analyze_scale_factor * number of tuples

## vacuum参数调整建议

vacuum参数采取默认配置即可。可以根据运行情况，进行调整

1. 对于表出现膨胀情况，这意味着表没有被及时清理，会占用磁盘空间。减小参数autovacuum_vacuum_scale_factor，更频繁的触发vacuum。同时适当增加maintenance_work_mem内存和autovacuum_max_workers参数以支撑vacumm操作

2. 对于静态表，没有数据变动，可减少vacuum动作，加大vacuum的间隔。增加autovacuum_freeze_max_age或减少vacuum_freeze_min_age
可以针对表单独配置
alter table test_t1 set (autovacuum_freeze_max_age=250000000);

3. 同时对应已经膨胀的表，如果膨胀率比较高。可在非业务时间段使用vacumm full降低高水位线，释放磁盘空间。

## 对象膨胀的原因

### 1. 未开启autovacuum

对于未开启autovacuum的用户，同时又没有合理的自定义vacuum调度的话，表的垃圾没有及时回收，新的数据又不断进来，膨胀是必然的。（新的数据包括插入和更新，更新产生新版本的记录）

### 2. 开启了autovacuum, 但是各种原因导致回收不及时，并且新的数据又不断产生，从而导致膨胀

回收不及时的原因：

2.1. IO差

当数据库非常繁忙时，如果IO比较差，会导致回收垃圾变慢，从而导致膨胀。

这种一般出现在数据库中存在非常巨大的表，并且这些表在执行whole table vacuum (prevent xid wrapped, 或当表的年龄大于vacuum_freeze_table_age时会全表扫)，因此产生大量IO，这期间很容易导致自身或其他表膨胀。

2.2. autovacuum触发较迟

什么情况会触发autovacuum呢?

A table needs to be vacuumed if the number of dead tuples exceeds a threshold.  This threshold is calculated as  

```sh
threshold = vac_base_thresh + vac_scale_factor * reltuples
```

如果没有设置表级别的autovacuum thresh和factor,那么默认使用参数文件配置的值。如下：

```sh
autovacuum_vac_thresh  # 默认50  
autovacuum_vac_scale  # 默认0.2
```

也就是说dead tuple达到约为表的20%时，才触发autovacuum。然后回收又需要一定的时间，所以最终表的膨胀应该是超过20%的。

2.3. 所有worker繁忙，某些表产生的垃圾如果超过阈值，但是在此期间没有worker可以为它处理垃圾回收的事情。导致可能发生膨胀。

可fork的worker进程个数是参数autovacuum_max_workers决定的，初始化autovacuum共享内存时已固定了它的最大进程数。见代码，

src/backend/postmaster/autovacuum.c

如果数据库的表很多，而且都比较大，那么当需要vacuum的表超过了配置autovacuum_max_workers的数量，某些表就要等待空闲的worker。这个阶段就容易出现表的膨胀。

另外需要注意一点，worker进程在工作时，每个worker最多会消耗的内存由以下参数决定：

```sh
maintenance_work_mem = 64MB            # min 1MB  
autovacuum_work_mem = -1               # min 1MB, or -1 to use maintenance_work_mem  
```

所以worker进程越多，内存需求量也越大。

2.4. 数据库中存在长SQL或带XID的长事务。

通过pg_stat_activity.backend_xid和backend_xmin来观察。

backend_xid表示已申请事务号的事务，例如有增删改，DLL等操作的事务。backend_xid从申请事务号开始持续到事务结束。

backend_xmin表示SQL执行时的snapshot，即可见的最大已提交事务。例如查询语句，查询游标。backend_xmin从SQL开始持续到SQL结束，如果是游标的话，持续到游标关闭。

PostgreSQL目前存在一个非常严重的缺陷，当数据库中存在未结束的SQL语句或者未结束的持有事务ID的事务，在此事务过程中，或在此SQL执行时间范围内产生垃圾的话，这些垃圾无法回收，导致数据库膨胀。

也即是判断当前数据库中backend_xid和backend_xmin最小的值，凡是超过这个最小值的事务产生的垃圾都不能回收。

原因见：

src/backend/utils/time/tqual.c

2.5. 开启了autovacuum_vacuum_cost_delay。

在开启了autovacuum_vacuum_cost_delay后，会使用基于成本的垃圾回收，这个可以有利于降低VACUUM带来的IO影响，但是对于IO没有问题的系统，就没有必要开启autovacuum_vacuum_cost_delay，因为这会使得垃圾回收的时间变长。

当autovacuum进程达到autovacuum_vacuum_cost_limit后，会延迟autovacuum_vacuum_cost_delay后继续。

限制计算方法由另外几个参数决定：

包括在SHARED BUFFER中命中的块，未命中的块，非脏块的额外成本。

vacuum_cost_page_hit (integer)  
The estimated cost for vacuuming a buffer found in the shared buffer cache. It represents the cost to lock the buffer pool, lookup the shared hash table and scan the content of the page. The default value is one.  
  
vacuum_cost_page_miss (integer)  
The estimated cost for vacuuming a buffer that has to be read from disk. This represents the effort to lock the buffer pool, lookup the shared hash table, read the desired block in from the disk and scan its content. The default value is 10.  
  
vacuum_cost_page_dirty (integer)  
The estimated cost charged when vacuum modifies a block that was previously clean. It represents the extra I/O required to flush the dirty block out to disk again. The default value is 20.  
对于IO没有问题的系统，不建议设置autovacuum_vacuum_cost_limit。

2.6. autovacuum launcher process 唤醒时间太长

唤醒时间由参数autovacuum_naptime决定，autovacuum launcher进程负责告诉postmaster需要fork worker进程来进行垃圾回收，但是如果autovacuum launcher进程一直在睡觉的话，那完蛋了，有垃圾了它还在睡觉，那不就等着膨胀吗？

另外还有一个限制在代码中，也就是说不能小于MIN_AUTOVAC_SLEEPTIME 100毫秒：

src/backend/postmaster/autovacuum.c

2.7 批量删除或批量更新，

例如对于一个10GB的表，一条SQL或一个事务中删除或更新9GB的数据，这9GB的数据必须在事务结束后才能进行垃圾回收，无形中增加了膨胀的可能。

2.8 大量的非HOT更新，会导致索引膨胀，对于BTREE索引来说，整个索引页没有任何引用才能被回收利用，因此索引比较容易膨胀。

## 对象膨胀处理

先判断哪些表膨胀比较厉害

-- 查询膨胀比率超过20%排名前5的表，超过20%表示autovacuum不能及时清理dead tuple
SELECT current_database(),
       schemaname,
       relname,
       n_live_tup,
       n_dead_tup,
       n_dead_tup * 1.0 / n_live_tup AS expantion,
       last_vacuum,
       last_autovacuum
FROM pg_stat_all_tables
WHERE n_live_tup > 1000
  AND n_dead_tup > 1000
  AND n_dead_tup * 1.0 / n_live_tup > 0.2
  AND schemaname NOT IN ('pg_toast', 'pg_catalog')
ORDER BY expantion DESC
LIMIT 5;

-- 查询数据库年龄，age(datfrozenxid)超过200000000说明autovacuum不能及时freeze
select datname,
     datfrozenxid,
     age(datfrozenxid),
     2^31-age(datfrozenxid) age_remain,
    (2^31-age(datfrozenxid))/2^31 age_remain_per
from pg_database
order by age(datfrozenxid) desc;

-- 查询rel age(>200000000)的表
select relname,age(relfrozenxid),pg_relation_size(oid)/1024/1024/1024.0 as "size(GB)" from pg_class where relkind='r' and age(relfrozenxid)>200000000 and pg_relation_size(oid)/1024/1024/1024.0 > 1 order by 3 desc;

-- 判断vacuum full，表是否需要进行空间回收

使用插件pg_freespacemap或者查询膨胀的空间大小，

ref [pg_check_table_bloat](../lib/sql/pg_check_table_bloat.sql)

## 表单独配置vacuum策略

alter table test_t1 set (autovacuum_freeze_max_age=250000000);
\d+ test_t1;

<!--
刚刚在群里看到德哥发的一个SQL，案例如下：表已经膨胀的不行了，磁盘没有空间了，vacuum full最多要用到两倍的磁盘空间，vacuum full提示磁盘空间不足，通过SQL来处理：WITH a AS (
    DELETE FROM t
    WHERE ctid = ANY (
            SELECT
                ctid
            FROM
                t
            ORDER BY
                ctid::text DESC
            LIMIT 10000)
    RETURNING
        *)
    INSERT INTO t
    SELECT
        *
    FROM
        a;

VACUUM t;

最开始没看懂，后面想了一下想明白了，先：
1、将文件末尾的行删掉重新插入，可能会插入到前面的空洞数据块中
2、最后vacuum，普通vacuum会释放掉位于文件末尾的页，可以返还一部分的空间
-->