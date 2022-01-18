# octet_length

**作者**

Chrisx

**日期**

2022-01-17

**内容**

计算字符占用的字节长度

----

[toc]

## 字节长度

数据库最小存储单元是page，出入一个字符，就会分配一个page。默认page是8192byte

那么一个字符占用多少字节长度呢？

pg提供字符串函数octet_length。octet_length(string) int 计算字符串中的字节数

```sql
select zh,octet_length(zh),en,octet_length(en),pg_column_size(zh) from test_length;

postgres=# select zh,octet_length(zh),en,octet_length(en),pg_column_size(zh) from test_length;
  zh  | octet_length |  en   | octet_length | pg_column_size
------+--------------+-------+--------------+----------------
 地球 |            6 | earth |            5 |              7
(1 row)

```
