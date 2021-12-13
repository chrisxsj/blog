# logical_replication_bi-directional

**作者**

Chrisx

**日期**

2021-12-12

**内容**

逻辑复制双向同步解决方案

---

[toc]

## 双向同步

![logical_replication_bi-directional](../image/20211212logical_replication_bi-directional.png)

## 解决方案1 pglogical

```sql
select pglogical.create_subscription(
        subscription_name := 'subscription_12',
        replication_sets := array ['default'],
        provider_dsn := 'host=192.168.6.11 port=5434 dbname=postgres',
        forward_origins := array []::text []
    );

forward_origins – array of origin names to forward, currently only supported values are empty array meaning don’t forward any changes that didn’t originate on provider node, or “{all}” which means replicate all changes no matter what is their origin, default is “{all}”

表示不转发非源于提供程序节点的任何更改。实现双向同步。

```

ref [pglogical](./pglogical.md)

## 解决方案2 使用复制源

复制源是为了更容易地在逻辑解码 上实现逻辑复制解决方案而设计。它们提供了对两种常见问题的解决方案：

* 如何安全地跟踪复制进度？
* 如何基于一行的来源更改复制行为？例如，阻止双向复制 设置中的循环

该会话 生成的改变和事务会被标记上该会话的复制源。这使得可以在输出插件中以不同的方式 对待它们，例如忽略除本地生成的行之外的所有行。

ref [Replication Progress Tracking](https://www.postgresql.org/docs/14/replication-origins.html)