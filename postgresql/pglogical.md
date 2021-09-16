# pglogical

**作者**

Chrisx

**日期**

2021-05-01

**内容**

pglogical

ref [pglogical](https://github.com/2ndQuadrant/pglogical)

ref [pglogical docs](https://www.2ndquadrant.com/en/resources/pglogical/pglogical-docs/)

---

[toc]

## Installation

```sh
tar -zxvf pglogical-REL2_3_3.tar.gz
cd pglogical-REL2_3_3

PATH=/opt/pg1016/bin:$PATH make clean all
PATH=/opt/pg1016/bin:$PATH make install

```

查看已安装插件

```sh
postgres=# select * from pg_available_extensions where name like '%logical%';;
       name       | default_version | installed_version |                              comment
------------------+-----------------+-------------------+--------------------------------------------------------------------
 pglogical_origin | 1.0.0           |                   | Dummy extension for compatibility when upgrading from Postgres 9.4
 pglogical        | 2.3.3           |                   | PostgreSQL Logical Replication
(2 rows)

```

## Usage

server，provider

1. configured to support logical decoding

```sql
alter system set wal_level = 'logical';
alter system set max_worker_processes = 10;
alter system set max_replication_slots = 10;
alter system set max_wal_senders = 10;
alter system set shared_preload_libraries = 'pglogical';

```

If you are using PostgreSQL 9.5+ (this won't work on 9.4) and want to handle conflict resolution with last/first update wins (see Conflicts), you can add this additional option to postgresql.conf:

```sql
alter system set track_commit_timestamp = 'on';
```

:warning: 主备库均配置

2. pg_hba.conf has to allow replication connections from localhost.

3. Next the pglogical extension has to be installed on all nodes

```sql
CREATE EXTENSION pglogical;
```

4. Now create the provider node

```sql
SELECT pglogical.create_node(
    node_name := 'provider_11',
    dsn := 'host=192.168.6.11 port=5434 dbname=postgres'
);

select * from pglogical.node;   --查看node名字
select * from pglogical.node_interface ; --查看node信息

```

:warning: 创建node需要提供密码，使用密码文件或password参数

5. Add all tables in public schema to the default replication set

```sql
SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

select * from pglogical.replication_set_table; --查看复制集的表

```

6. Once the provider node is setup, subscribers can be subscribed to it. First the subscriber node must be created

```sql
SELECT pglogical.create_node(
    node_name := 'subscriber_12',
    dsn := 'host=192.168.6.12 port=5434 dbname=postgres'
);

```

:warning: 创建node需要提供密码，使用密码文件或password参数

<!--
2021-05-06 03:27:12.279 UTC [21563] LOG:  starting pglogical database manager for database postgres
2021-05-06 03:27:13.281 UTC [21564] LOG:  manager worker [21564] at slot 1 generation 1 detaching cleanly

-->

7. And finally on the subscriber node you can create the subscription which will start synchronization and replication process in the background

```sql

select pglogical.create_subscription(
        subscription_name := 'subscription_12',
        replication_sets := array ['default'],
        --synchronize_data := false,
        provider_dsn := 'host=192.168.6.11 port=5434 dbname=postgres',
        forward_origins := array []::text []
    );

SELECT pglogical.wait_for_subscription_sync_complete('subscription_12');

select * from pglogical.subscription ; --查看订阅的状态

```

8. 查看同步状态

```sql
select * from pglogical.tables ; --查看同步的表
select * from pglogical.local_sync_status;  --查看表同步状态

```

9.  复制集添加、移除表

```sql
select pglogical.replication_set_add_table ('default','test_pgl3');
select pglogical.replication_set_remove_table ('default','test_pgl3');

```

## 问题

报错信息

创建订阅报错

select pglogical.create_subscription(
        subscription_name := 'subscription1',
        replication_sets := array ['default'],
        provider_dsn := 'host=192.168.6.11 port=5434 dbname=postgres',
        forward_origins := array []::text []
    );

ERROR:  could not connect to the postgresql server: fe_sendauth: no password supplied

解决方案

使用密码文件.pgpass，填写订阅节点的密码信息

or

订阅节点创建时提供密码，加上password=pg1016

SELECT pglogical.create_node(
    node_name := 'subscriber1',
    dsn := 'host=192.168.6.12 port=5434 dbname=postgres password=pg1016'
);

## 其他问题

初始化需清空数据，不支持有数据的初始化部署
双向同步问题。先同步空库
