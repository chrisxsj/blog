# Streaming Replication Protocol

**作者**

Chrisx

**日期**

2021-05-06

**内容**

流复制协议测试

ref[Streaming Replication Protocol](https://www.postgresql.org/docs/13/protocol-replication.html)

---

[toc]

## 测试流复制协议连通性

备库执行流复制协议连接主库，测试流复制协议连通性

```sql
psql "replication=true dbname=$pgdatabase hostaddr=$bakhost user=$pguser port=$pgport " -Atc "SHOW PORT;"

```

:warning: 注意

1. 备库只读，但是可以执行alter system修改参数