# Concurrency_Control

**作者**

Chrisx

**日期**

2021-05-28

**内容**

并发控制实现原理

mvcc

ref [Concurrency Control](https://www.postgresql.org/docs/13/mvcc.html)

ref [The Internals of PostgreSQL](http://www.interdb.jp/pg/)

---

[TOC]

## 并发控制介绍

数据库一大的特点是能够实现并发操作，即数据库中同时运行多个事务。并发控制描述了数据库系统在多个会话试图同时访问同一数据时的行为。 这种情况的目标是为所有会话提供高效的访问，同时还要维护严格的数据完整性。

在内部，数据一致性（Consistency）通过使用一种多版本模型（多版本并发控制，MVCC  Multi-Version Concurrency Control）来维护。这意味着每个sql语句都只能看到自己对应的数据快照。这样可以保护语句不会看到可能由其他在相同数据行上执行更新的并发事务产生的数据。为每一个会话提供了事务隔离（Isolation）。

MVCC通过避开传统数据库的LOCK机制，最大限度的减少锁竞争以允许合理的多用户环境中的性能。恰当地使用MVCC总会提供比LOCK更好的性能。对于那些无法轻松接收MVCC行为的应用，PostgreSQL也提供了表和行级别的LOCK机制。

传统的事务理论采用锁机制来实现并发控制，但是锁机制会导致读写互斥锁，这种机制对并发访问的性能造成了极大的影响。使用MVCC并发控制模型，对查询（读）数据的锁请求与写数据的锁请求不冲突，所以读不会阻塞写，而写也从不阻塞读。到目前为止，绝大多数商用和开源数据库都已经全面支持多版本并发控制机制， 多版本并发控制机制也已经成为交易型关系型数据库的标准配置。

## 事务隔离

ref [transaction isolation](./Transaction_Isolation.md)

## 锁

ref [pg_lock](./pg_lock.md)

## 并发控制机制

了解并发控制，从以下概念入手。

### 事务回卷

ref [txidwrap](./txidwrap.md)

### tuple增删改及dead tuple产生

ref [tuple_and_deadtuple](./tuple_and_deadtuple.md)

#### 空闲空间映射

插入元组时，使用表与索引的FSM来选择可供插入额页面。

FSM都以后缀fsm存储，在需要时他们会被加载到共享内存中。

可使用插件pg_freespacemap查看表中页面的使用情况。数据库会自动判断使用那些有空闲的页面存储元祖数据。

### 提交日志

提交日志（commit log，CLOG）保存事务的状态。提交日志分配与共享内存中，并用于事务处理的全过程。

数据库定义了4种事务状态，IN_PROGRESS,COMMITED,ABORTED,SUB_COMMITED

提交日志是如何工作的呢？

CLOG在逻辑上是一个数组。在共享内存中由一系列8k页面组成。数组的序号索引对应着相应事务的标识。其内容则是事务的状态。

提交日志的维护

CLOG会写入pg_xact，被命名为0000，,0001等，文件最大尺寸256KB。
数据库启动时会加载pg_xact,用于初始化clog
clog会不断增长，vacuum会定期清理旧数据。

### 事务快照

事务快照是一个数据集。存储者某个特定事物在某个特定时间点所看到的事务状态信息：哪些事务是活跃的。

函数 txid_current_snapshot查看当前事务的快照。

```sql
SELECT txid_current_snapshot();
txid_current_snapshot 
 -----------------------
100:104:100,102
(1 row)
```

txid_current_snapshot的文本表示形式为“xmin：xmax：xip_list“，这些内容描述如下。

* **xmin**最早的还在活动的txid。所有之前的事务要么提交且可见，要么回滚而无效。
* **xmax**尚未分配的txid。所有大于或等于此值的txid在快照时间之前尚未启动，因此不可见。
* **xip_list**在快照时间活动的txid。该list只包含xmin和xmax之间的活动txid。

**事务快照由事务管理器提供。在READ COMMITTED隔离级别中，只要执行SQL命令，事务就会获得快照; 除此之外(REPEATABLE READ或SERIALIZABLE)，事务只会在执行第一个SQL命令时获取快照。获取的事务快照用于元组的可见性检查。**

ref [Transaction_Isolation](./Transaction_Isolation.md)，事务隔离的实现就是依据事务快照实现的。

<!--
详细机制参考ref [The Internals of PostgreSQL](http://www.interdb.jp/pg/)
-->

### 可见性检查

可见性检查即如何为给定的事务挑选堆元组恰当版本。是多版本并发控制的体现。通过使用元组（tuple）的t_xmin和t_xmax、clog和事务快照来确定每个元组（tuple）对事务是否可见 。这些规则太复杂，以下仅作简单的说明。共选取了10个规则

* t_xmin状态为ABORTED

t_xmin状态为ABORTED的元组始终是不可见的(Rule 1)，因为插入此元组的事务已被中止

```sql
/* t_xmin status = ABORTED */
Rule 1: IF t_xmin status is 'ABORTED' THEN
      RETURN 'Invisible'
    END IF
```

该规则明确表示为以下表达式。

**Rule 1:** If Status(t_xmin) = ABORTED ⇒ Invisible

#### t_xmin状态为IN_PROGRESS

t_xmin状态为IN_PROGRESS的元组基本上是不可见的(Rule 3和4)，有一个情况下例外。

```sql
/* t_xmin status = IN_PROGRESS */
  IF t_xmin status is 'IN_PROGRESS' THEN
    IF t_xmin = current_txid THEN
Rule 2:   IF t_xmax = INVALID THEN
        RETURN 'Visible'
Rule 3:   ELSE /* this tuple has been deleted or updated by the current transaction itself.*/
        RETURN 'Invisible'
      END IF
Rule 4: ELSE   /* t_xmin ≠ current_txid */
      RETURN 'Invisible'
    END IF
  END IF
```

如果这个元组被另一个事务插入，并且t_xmin的状态是IN_PROGRESS，这个元组显然是不可见的(Rule 4)。
如果t_xmin等于当前txid(即该元组被当前事务插入)并且t_xmax**不**是INVALID，则该元组不可见，因为它已被当前事务更新或删除(Rule 3)。
<!--txid=0=INVALID-->

例外情况是由当前事务插入此元组并且t_xmax为INVALID的情况。在这种情况下，这个元组在当前事务中是可见的(Rule 2)。

* **Rule 2:** If Status(t_xmin) = IN_PROGRESS ∧ t_xmin = current_txid ∧ t_xmax = INVAILD ⇒ Visible
* **Rule 3:** If Status(t_xmin) = IN_PROGRESS ∧ t_xmin = current_txid ∧ t_xmax ≠ INVAILD ⇒ Invisible
* **Rule 4:** If Status(t_xmin) = IN_PROGRESS ∧ t_xmin ≠ current_txid ⇒ Invisible

#### t_xmin状态为COMMITTED

此时该 Tuple 在大部分情况下都是可见的，除了该 Tuple 被更新或者删除。
t_xmin状态为COMMITTED的元组可见(Rules 6,8, 和 9)，但有三种情况例外。

```sql
/* t_xmin status = COMMITTED */
        IF t_xmin status is 'COMMITTED' THEN
Rule 5:     IF t_xmin is active in the obtained transaction snapshot THEN
                RETURN 'Invisible'
Rule 6:     ELSE IF t_xmax = INVALID OR status of t_xmax is 'ABORTED' THEN
                RETURN 'Visible'
            ELSE IF t_xmax status is 'IN_PROGRESS' THEN
Rule 7:         IF t_xmax =  current_txid THEN
                    RETURN 'Invisible'
Rule 8:         ELSE  /* t_xmax ≠ current_txid */
                    RETURN 'Visible'
                END IF
            ELSE IF t_xmax status is 'COMMITTED' THEN
Rule 9:         IF t_xmax is active in the obtained transaction snapshot THEN
                    RETURN 'Visible'
Rule 10:        ELSE
                    RETURN 'Invisible'
                END IF
            END IF
        END IF
```

Rule 6很明显，因为t_xmax是INVALID或ABORTED。下面描述了三种例外情况以及Rule 8和9。
第一个例外情况是t_xmin在获得的事务快照中处于活动状态(Rule 5)。在这种情况下，这个元组是不可见的，因为t_xmin应该被视为in progress。
第二个例外情况是t_xmax是当前的txid(Rule 7)。在这种情况下，和Rule 3一样，这个元组是不可见的，因为它已经被这个事务本身更新或删除。
相反，如果t_xmax的状态是IN_PROGRESS并且t_xmax不是当前的txid(Rule 8)，则该元组可见，因为它尚未被删除。
第三个例外情况是t_xmax的状态是COMMITTED，并且t_xmax在获得的事务快照中不活动(Rule 10)。在这种情况下，这个元组是不可见的，因为它已被另一个事务更新或删除。
相反，如果t_xmax的状态为COMMITTED，但t_xmax在获取的事务快照中处于活动状态(Rule 9)，则该元组可见，因为t_xmax应视为in progress。

* **Rule 5:** If Status(t_xmin) = COMMITTED ∧ Snapshot(t_xmin) = active ⇒ Invisible
* **Rule 6:** If Status(t_xmin) = COMMITTED ∧ (t_xmax = INVALID ∨ Status(t_xmax) = ABORTED) ⇒ Visible
* **Rule 7:** If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = IN_PROGRESS ∧ t_xmax = current_txid ⇒ Invisible
* **Rule 8:** If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = IN_PROGRESS ∧ t_xmax ≠ current_txid ⇒ Visible
* **Rule 9:** If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = COMMITTED ∧ Snapshot(t_xmax) = active ⇒ Visible
* **Rule 10:** If Status(t_xmin) = COMMITTED ∧ Status(t_xmax) = COMMITTED ∧ Snapshot(t_xmax) ≠ active ⇒ Invisible

## 多版本并发控制的实现

数据的修改过程可简单描述为

1. 首先 backend 开启是一个事务,获得一个事务号 XID;
2. 在这个事务中对数据的任意修改，都被 XID 标记。
3. 其他 backend 在扫描数据时，会看到被这个 XID 修改过的数据，根据当前的隔离级别，选择对这些数据是否可见（默认的读已提交隔离级别看不到这些数据）。
4. 只有当此 XID 最后被标记成 commit （写 WAL commit log 和写 clog）后，其他的 backend 才能看到这个 XID 修改的数据。

数据可见性条件

1. 记录的头部XID信息比当前事务更早（ repeatable read或ssi有这个要求, read committed没有这个要求）
2. 记录的头部XID信息不在当前的XID_snapshot中 (即记录上的事务状态不是未提交的状态.)
3. 记录头部的XID信息在CLOG中应该显示为已提交

## mvcc维护

**通过以上的mvcc机制，可知，其一方面提高了并发，另一方面也会造成各种影响。所以需要通过引入vacuum机制解决此问题**

PostgreSQL的并发控制机制需要以下过程维护。
1. 删除dead tuple和指向对应的dead tuple的索引元组。
2. 删除clog不必要的部分。
3. 冻结旧txid。
4. 更新FSM、VM和统计信息。

## 从 MVCC 机制看 POSTGRESQL 的应用场景

PostgreSQL 数据库在大量 DELETE、UPDATE 操作后，表和索 引都会出现高水位大幅提升的问题。从而导致索引唯一性访问、索引范围扫描和全表扫描性 能的下降，而且下降的幅度还是比较大的。经过 VACUUM 后，高水位无法恢复，不过索引 访问和全表扫描的性能都可以大幅度恢复。而同样的测试场景，Mysql 数据库不存在类似的 问题。

PostgreSQL 使用了一种十分简单的方法实现了多副本控制机制，并没有像 Oracle、 MYSQL 一样引入专门的回滚段机制。这种 MVCC 机制实现十分简单，但是我们可以很快 发现这种机制存在的问题，因为 update 操作会在表中产生大量的 MVCC 版本，从而导致表 和索引碎片的大量产生，从而影响该表访问的性能。不过这种 MVCC 机制也不都是副作用， 对于删除操作，由于 PostgreSQL 只需要简单的标识，因此大批量删除的场景，PostgreSQL 的性能优于 Mysql。

由于 MVCC 机制的缺陷，PostgreSQL 数据库的应用场景也受到了一定的限制。如数据量较大，某些大表的 DML 较多，有较大并发量进行全表扫描的 7*24 场景
