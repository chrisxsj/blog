# idle_in_transaction

**作者**

Chrisx

**日期**

2021-10-19

**内容**

如何判断后台进程状态，进程是否可以kill

----

[toc]

## 进程状态

判断进程状态，查看视图pg_stat_activity.state

state text

* Current overall state of this backend. Possible values are:
* active: The backend is executing a query.
* idle: The backend is waiting for a new client command.
* idle in transaction: The backend is in a transaction, but is not currently executing a query.
* idle in transaction (aborted): This state is similar to idle in transaction, except one of the statements in the transaction caused an error.
* fastpath function call: The backend is executing a fast-path function.
* disabled: This state is reported if track_activities is disabled in this backend.

以上是对进程状态的描述

## idle进程状态的判断

* idle: 进程空闲等待连接
* idle in transaction: 已经连接，但空闲，没有事务运行
* idle in transaction (aborted): 已经连接，但空闲，事务中有sql语句运行错误导致空闲，无法继续运行

对于idle的事务，可以查看以下两个状态，协助判断

backend_xid xid
Top-level transaction identifier of this backend, if any.
backend_xid没有值，因为它没有对数据库有任何写操作所以不需要申请事务号，因此backend_xid为空。

backend_xmin xid
The current backend's xmin horizon.
backend_xmin没有值，当前没有SQL在执行，目前没有事务快照信息

backend_xid 或 backend_xmin 为空，则说明没有事务运行，没有东西需要提交，可kill