# pg_Single_User_Mode

**作者**

Chrisx

**日期**

2021-05-19

**内容**

单用户模式,密码忘记时可使用单用户修改密码。

ref [Single-User Mode](https://www.postgresql.org/docs/13/app-postgres.html#APP-POSTGRES-SINGLE-USER)

---

[toc]

## 介绍

postgres是PostgreSQL数据库服务器。一个客户端应用为了能访问一个数据库，它会（通过一个网络或者本地）连接到一个运行着的postgres实例。该postgres实例接着会开始一个独立的服务器进程来处理该连接。

也可以使用postgres启动一个单用户模式。如

```sh
postgres --single -D /usr/local/pgsql/data other-options my_database

```

用-D给服务器提供正确的数据库目录的路径，或者确保环境变量PGDATA被设置。同时还要指定你想在其中工作的特定数据库的名字。

要退出会话，输入EOF（通常是Control+D）。如果从上一个命令终止符以来已经输入了任何文本，那么EOF将被当作命令终止符，并且如果要退出则需要另一个EOF。

## 单用户模式下修改管理员密码

用户密码忘记之后，也可以使用单用户模式修改密码。步骤如下

单用户登陆

```sh
pg_ctl stop #需要先关闭数据库
postgres --single postgres  #单用户登陆，第二个postgres为数据库名

```

修改管理员密码

```sql
alter user pg126 with password 'pg126';
```

启动数据库

```sh
pg_ctl start
```

<!--

hgdb中，可在单用户模式下，修改密码。因此忘记密码可用此种方式重置密码。

可以修改所有用户密码，包括sysdba，syssso，syssao

[hgdb452@db ~]$ pg_ctl stop
waiting for server to shut down....2020-12-02 11:03:46.960 CST [3542] LOG:  received fast shutdown request
2020-12-02 11:03:46.963 CST [3542] LOG:  aborting any active transactions
2020-12-02 11:03:46.967 CST [3542] LOG:  background worker "logical replication launcher" (PID 3550) exited with exit code 1
2020-12-02 11:03:46.967 CST [3545] LOG:  shutting down
2020-12-02 11:03:46.981 CST [3542] LOG:  database system is shut down
 done
server stopped
[hgdb452@db ~]$ postgres --single highgo
2020-12-02 11:03:57.145 CST [3857] LOG:  data encryption performed by
2020-12-02 11:03:57.160 CST [3857] LOG:  Switchover the SSHA Role. Current is NONE

PostgreSQL stand-alone backend 12.1
backend> alter user syssso password '1';
backend> alter user sysdba password '1';
backend> [hgdb452@db ~]$
[hgdb452@db ~]$
[hgdb452@db ~]$
[hgdb452@db ~]$ pg_ctl start
-->
