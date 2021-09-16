# pg12新特性-max_wal_senders从max_connections分离

**作者**

chrisx

**时间**

20210302

**内容**

pg12新特性，新增 pg_promote() 函数用于激活备库

---

[toc]

## 官方文档说明

[官方文档](https://www.postgresql.org/docs/12/release-12.html)

Add function pg_promote() to promote standbys to primaries (Laurenz Albe, Michaël Paquier)
Previously, this operation was only possible by using pg_ctl or creating a trigger file.

## 函数说明

```shell
pg_promote(wait boolean DEFAULT true, wait_seconds integer DEFAULT 60)

Description

Promotes a physical standby server. With wait set to true (the default), the function waits until promotion is completed or wait_seconds seconds have passed, and returns true if promotion is successful and false otherwise. If wait is set to false, the function returns true immediately after sending SIGUSR1 to the postmaster to trigger the promotion. This function is restricted to superusers by default, but other users can be granted EXECUTE to run the function.

```

wait这只为true表示是否等待备库的 promotion 完成或者 wait_seconds 秒之后返回成功，默认值为 true。wait_seconds默认 60s。只有超级用户才有执行 pg_promote() 函数的权限，也可以单独将此函数的执行权限赋给其它用户。

## 示例

现在，备库promote可以使用以下两种方式

```shell
$ pg_ctl promote

```

or

```shell
postgres=# SELECT pg_promote(true,60);
 pg_promote
------------
 t

```

可在操作系统层或数据库层执行操作
