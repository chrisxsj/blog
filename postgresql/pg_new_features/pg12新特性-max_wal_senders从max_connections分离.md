# pg12新特性-max_wal_senders从max_connections分离

**作者**

chrisx

**时间**

20210302

**内容**

pg12新特性，max_wal_senders从max_connections分离

---

[toc]

## 官方文档说明

[官方文档](https://www.postgresql.org/docs/12/release-12.html)

Make max_wal_senders not count as part of max_connections (Alexander Kukushkin)

## 参数说明

* `max_connections`-数据库实例允许的最大并发连接数
* `max_wal_senders`-通过 pg_basebackup 备份或流复制备库和主库同步占用主库的最大并发连接数
* `superuser_reserved_connections`-给超级用户预留连接数

max_wal_senders和superuser_reserved_connections需要的连接数都从max_connections中来。受max_connections限制。当连接数占满时，使用max_wal_senders连接的流复制、逻辑复制、数据库备份(pg_basebackup)都会收到影响。
从pg12开始，max_wal_senders从max_connections分离出来，不再受max_connections限制，可单独控制，因此很好解决了上面的问题。

## 示例

### pg11

设置 postgresql.conf 参数，如下:

```shell
max_connections = 3
superuser_reserved_connections = 0
max_wal_senders = 2

```

连接两个会话，占用两个连接。

之后在数据库主机上执行 pg_basebackup 命令备份数据库，如下:

```shell
$ pg_basebackup -D backup -Ft -P
pg_basebackup: could not connect to server: FATAL:  sorry, too many clients already

```

pg_basebackup 命令消耗的是 max_wal_senders 设置的连接数，max_wal_senders 连接数是 max_connections 的子集，由于pg_basebackup 备份数据库需占用两个连接，因此以上报连接数不足。

### Pg12

设置 postgresql.conf 参数，如下:

```shell
max_connections = 3
superuser_reserved_connections = 0
max_wal_senders = 2

```

连接两个会话，占用两个连接。

之后在数据库主机上执行 pg_basebackup 命令备份数据库，如下:

```shell
$ pg_basebackup -D backup -Ft -P
3963845/3963845 kB (100%), 1/1 tablespace

```

备份正常，验证了 12 版本 max_wal_senders 参数不受 max_connections 参数影响。
