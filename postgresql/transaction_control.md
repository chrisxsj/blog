# pg_transaction_control

**作者**

Chrisx

**日期**

2021-05-09

**内容**

事务控制

psql关闭自动自交（AUTOCOMMIT）

---

[toc]

## pg事务控制

Postgresql数据库中，每个语句都在其自己的事务中执行, 并且在语句的末尾隐式执行提交
如果想控制事务，手动提交，可使用以下语句

```sql
BEGIN;
work/transaction......
END/COMMIT/ROLLBACK;
```

- BEGIN — start a transaction block
BEGIN initiates a transaction block, that is, all statements after a BEGIN command will be executed in a single transaction until an explicit COMMIT or ROLLBACK is given. By default (without BEGIN), PostgreSQL executes transactions in “autocommit” mode, that is, each statement is executed in its own transaction and a commit is implicitly performed at the end of the statement (if execution was successful, otherwise a rollback is done).
- END — commit the current transaction
END=COMMIT

- SAVEPOINT
It's possible to control the statements in a transaction in a more granular fashion through the use of savepoints. Savepoints allow you to selectively discard parts of the transaction, while committing the rest. After defining a savepoint with SAVEPOINT, you can if needed roll back to the savepoint with ROLLBACK TO. All the transaction's database changes between defining the savepoint and rolling back to it are discarded, but changes earlier than the savepoint are kept.

```sql
begin;
insert into test_table values (2,'iii',now());
savepoint point1;
update test_table set info='aaa' where id=1;
-- forget this update
rollback to point1;
update test_table set info='bbb' where id=1;
commit;
```

:warning: note
1.事务内出现错误后，即使后面的指令和语法都是正确的，也将不会再有语句被接受
2.事务内可以使用保存点savepoint，事务内可以释放保存点。如果事务结束，事务的保存点也会释放。事务结束后无法返回到一个特定的保存点
3.事务性DDL，在pg中，可以在事务控制模块中运行DDL，这个特性在很多商业数据库系统中并不存在，如Oracle。

## psql工具中关闭autocommit

也可使用以下方式在psql工具中关闭autocommit，其只能针对基于此工具的会话生效
**psql工具默认开启自动提交功能（AUTOCOMMIT = 'on'）**

### 自动提交测试

```sql
select version();                                            
version
-----------------------------------------------------------------------------
PostgreSQL 10.4 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-28), 64-bit

insert into test values (2);

rollback;
WARNING:  there is no transaction in progress
ROLLBACK
select * from test;
 id
 ----
 1
 2

```

### 查看自动提交功能状态

```sql
\set
AUTOCOMMIT = 'on'

```

### 关闭自动提交功能

```sql
\set AUTOCOMMIT off
```

### 验证

```sql
insert into test values (3);
rollback;
ROLLBACK
select * from test;
  id
 ----
 1
 2
```

永久关闭

The autocommit-on mode is PostgreSQL's traditional behavior, but autocommit-off is closer to the SQL spec. If you prefer autocommit-off, you might wish to set it in the system-wide psqlrc file or your ~/.psqlrc file.
