# pg中文文档翻译错误的地方

**作者**

Chrisx

**日期**

2021-05-30

**内容**

postgresql 中文文档翻译错误的地方。

ref [PostgreSQL手册（翻译）](http://www.postgres.cn/docs/13/index.html)

---

[TOC]

## 1

原文 ref [13.2.3. Serializable Isolation Level](https://www.postgresql.org/docs/13/transaction-iso.html#XACT-READ-COMMITTED)

```sh
and obtains the result 300, which it inserts in a new row with class = 1.
```

翻译 ref [13.2.3. 可序列化隔离级别](http://www.postgres.cn/docs/13/transaction-iso.html)

```sh
并得到结果 300，它会将其与class = 1插入到一个新行中。
```

勘误

```sh
并且接着把结果300作为一个新行的value插入，新行的class = 1。
```

## 2

