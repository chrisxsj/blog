# Transaction Isolation

**作者**

Chrisx

**日期**

2021-05-28

**内容**

事务的ACID特性

事务的隔离级别

ref [Transaction Isolation](https://www.postgresql.org/docs/13/transaction-iso.html)

---

[TOC]

## 事务的ACID特性

| ACID                  | 描述                                                                             | 实现技术             |
| --------------------- | -------------------------------------------------------------------------------- | -------------------- |
| 原子性（atomicity）   | 事务是一个工作单元，事务中的操作要么不做，要么全做                               | MVCC                 |
| 一致性（consistency） | 从一个状态转变到另外一个状态                                                     | 约束（主键、外键等） |
| 隔离性（isolation）   | 事务内部操作及数据变化与其他并发事务是隔离的。并发执行的各事务之间不能相互干扰。 | MVCC                 |
| 持久性（durability）  | 事务提交后，对数据的更改时永久的，接下来的其他操作都不应对其结果产生影响         | WAL                  |

## 事务的隔离级别

并发过程中会出现以下现象

* 脏读
一个事务读取了另一个并行未提交事务写入的数据。
* 不可重复读
一个事务重新读取之前读取过的数据，发现该数据已经被另一个事务（在初始读之后提交）修改。
* 幻读
一个事务重新执行符合一个搜索条件的查询，返回的行集合不一致， 发现满足条件的行集合因为另一个最近提交的事务而发生了改变。
* 序列化异常
成功提交一组事务的结果与这些事务所有可能的串行执行结果都不一致。

数据库会使用一种并发控制技术来实现并发控制。如pg/oracle使用mvcc技术，并发控制技术可以避免以上三种异常情况。即并发控制技术可以设置不同的隔离级别，从不同程度来解决这三种异常情况。

事务与事务隔离是现代关系型数据库的重要基础，通过所需要的事务隔离级别，来确保 应用系统读取到的数据是符合业务逻辑的。事务隔离级别包含 read uncommitted(level 0， 脏读)、read committed(level 1，提交读)、repeatable read(level 2，可重复读)、 serializable(level 3，串行化)。其中脏读可以读取任何脏数据，因此不需要任何锁或者 其他并发控制机制支持，并发性最好，串行化强制事务串行执行，并发能力最弱。提交读-Read committed 也叫一致性读，是目前在线联机事务（OLTP）系统中最为常见的事务隔离级别。隔离级别越高，并发越差，隔离级别越低，并发越高。

隔离级别如下

| 隔离级别 | 脏读               | 不可重复读 | 幻读                | 序列化异常 |
| -------- | ------------------ | ---------- | ------------------- | ---------- |
| 读未提交 | 允许，但不在 PG 中 | 可能       | 可能                | 可能       |
| 读已提交 | 不可能             | 可能       | 可能                | 可能       |
| 可重复读 | 不可能             | 不可能     | Y允许，但不在 PG 中 | 可能       |
| 可序列化 | 不可能             | 不可能     | 不可能              | 不可能     |

在PostgreSQL中，你可以请求四种标准事务隔离级别中的任意一种，但是内部只实现了三种不同的隔离级别，即 PostgreSQL 的读未提交模式的行为和读已提交相同。

要设置一个事务的事务隔离级别，使用SET TRANSACTION命令。

## 事务隔离级别修改

查看事务隔离级别

```sql
test=> SELECT name, setting FROM pg_settings WHERE name ='default_transaction_isolation';
             name              |    setting
-------------------------------+----------------
 default_transaction_isolation | read committed
(1 row)
```

修改事务隔离级别

```sql
alter system set default_transaction_isolation to 'REPEATABLE READ';    --修改全局事务隔离级别
SELECT current_setting('transaction_isolation');    --查看当前会话事务隔离级别
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    --修改当前会话事务隔离级别
START TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; --设置当前事务的事务隔离级别
```

### 读已提交隔离级别

读已提交是PostgreSQL中的默认隔离级别。 当一个事务运行使用这个隔离级别时， 一个查询（没有FOR UPDATE/SHARE子句）只能看到`查询开始之前已经被提交的数据`， 而无法看到未提交的数据或在查询执行期间其它事务提交的数据。实际上，SELECT查询看到的是一个在查询开始运行的瞬间该数据库的一个快照。不过SELECT可以看见在它自身事务中之前执行的更新的效果，即使它们还没有被提交。还要注意的是，即使在同一个事务里两个相邻的SELECT命令可能看到不同的数据， 因为其它事务可能会在第一个SELECT开始和第二个SELECT开始之间提交。

因为上面的规则，正在更新的命令可能会看到一个不一致的快照： 它们可以看到并发更新命令在它尝试更新的相同行上的作用，但是却看不到那些命令对数据库里其它行的作用。 这样的行为令读已提交模式不适合用于涉及复杂搜索条件的命令。不过，它对于更简单的情况是正确的。

| transaction1                                | transaction2                                     |
| ------------------------------------------- | ------------------------------------------------ |
| begin;                                      |                                                  |
| select name from test_isolation where id=1; |                                                  |
|                                             | begin;                                           |
|                                             | update test_isolation set name='tom' where id=1; |
| select name from test_isolation where id=1; |                                                  |
|                                             | commit; /* lock-based dirty read */              |
| select name from test_isolation where id=1; |                                                  |
| end;                                        |                                                  |

如上，
transaction1中的第1个select无法读取transaction2的更改，
transaction1中的第2个select无法读取transaction2的更改，如果可以读取，那就是脏读。而读已提交隔离级别可以避免脏读。
transaction1中的第3个select可以读取transaction2的更改，

### 可重复读隔离级别

可重复读隔离级别只看到在`事务开始之前被提交的数据`；它从来看不到未提交的数据或者并行事务在本事务执行期间提交的修改。
这个级别与读已提交不同之处在于，一个可重复读事务中的查询可以看见在事务中第一个非事务控制语句开始时的一个快照，而不是事务中当前语句开始时的快照。因此，在一个单一事务中的后续SELECT命令看到的是相同的数据，即它们看不到其他事务在本事务启动后提交的修改。

| transaction1                                | transaction2                                     |
| ------------------------------------------- | ------------------------------------------------ |
| begin;                                      |                                                  |
| select name from test_isolation where id=1; |                                                  |
|                                             | begin;                                           |
|                                             | update test_isolation set name='tom' where id=1; |
| select name from test_isolation where id=1; |                                                  |
|                                             | commit; /* lock-based dirty read */              |
| select name from test_isolation where id=1; |                                                  |
| end;                                        |                                                  |

如上，
transaction1中的第1个select无法读取transaction2的更改，
transaction1中的第2个select无法读取transaction2的更改，
transaction1中的第3个select无法读取transaction2的更改，如果可以读取，那就是不可重复读。而可重复读隔离级别可以避免不可重复读。

| transaction1                                    | transaction2                                 |
| ----------------------------------------------- | -------------------------------------------- |
| begin;                                          |                                              |
| select count(*) from test_isolation where id=1; |                                              |
|                                                 | begin;                                       |
|                                                 | insert into test_isolation values (4,'ddd'); |
| select count(*) from test_isolation where id=1; |                                              |
|                                                 | commit; /* lock-based dirty read */          |
| select count(*) from test_isolation where id=1; |                                              |
| end;                                            |                                              |

如上，
transaction1中的第1个select读取结果不变
transaction1中的第2个select读取结果不变
transaction1中的第3个select读取结果不变，如果结果改变，那就是幻读。而可重复读隔离级别在PG中可以避免幻读。

### 可序列化隔离级别

可序列化隔离级别提供了最严格的事务隔离。这个级别为所有已提交事务模拟序列事务执行；就好像`事务被按照序列一个接着另一个被执行，而不是并行地被执行。`

例如，考虑一个表mytab，它初始时包含：

 class | value
-------+-------
     1 |    10
     1 |    20
     2 |   100
     2 |   200

假设可序列化事务 A 计算：

SELECT SUM(value) FROM mytab WHERE class = 1;

并且接着把结果（3）作为一个新行的value插入，新行的class = 2。同时，可序列化事务 B 计算：

SELECT SUM(value) FROM mytab WHERE class = 2;

并且接着把结果300作为一个新行的value插入，新行的class = 1。。然后两个事务都尝试提交。如果其中一个事务运行在可重复读隔离级别，两者都被允许提交；但是由于没有执行的序列化顺序能在结果上一致，使用可序列化事务将允许一个事务提交并且将回滚另一个并伴有这个消息：

ERROR:  could not serialize access due to read/write dependencies among transactions
