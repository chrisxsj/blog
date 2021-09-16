# lsn

**作者**

Chrisx

**日期**

2021-06-01

**内容**

lsn是什么

LSN与段文件的关系

ref [pg_lsn](https://www.postgresql.org/docs/13/datatype-pg-lsn.html)

ref [WAL Internals](https://www.postgresql.org/docs/13/wal-internals.html)

---

[toc]

## LSN

LSN 是一个指向WAL中的位置的指针

在内部，一个 LSN 是一个 64 位整数，表示在预写式日志流中的一个字节位置。它被打印成 两个最高 8 位的十六进制数，中间用斜线分隔，例如16/B374D848。 pg_lsn类型支持标准的比较操作符，如=和 >。两个 LSN 可以用-操作符做减法， 结果将是分隔两个预写式日志位置的字节数。

## LSN与段文件

1. 通过内置函数可以知道LSN对应的段文件

```sql
postgres=# SELECT pg_current_wal_lsn(),pg_walfile_name( pg_current_wal_lsn() );
 pg_current_wal_lsn |     pg_walfile_name
--------------------+--------------------------
 0/D015DF8          | 00000001000000000000000D
(1 row)
```

当前使用的wal段文件是00000001000000000000000D

2. lsn与段文件关系

LSN 由3部分组成 'X/YYZZZZZZ'

* X 表示WAL段文件名的中间部分，一个或两个符号；
* YY 表示WAL文件名的最后一部分；一个或两个符号；
* ZZZZZZ 是表示文件名内偏移量的六个符号。

如上，LSN 0/D015DF8，我们可以假设WAL文件名的中间部分将是0，最后一部分将是D，两者都是零填充到8个符号，因此分别是00000000和0000000D。它们串联在一起，为我们提供了一个以0000000 00000000D结尾的文件名。文件名的初始部分未知，初始部分代表服务器运行的时间线，在本例中为1，将零填充为其他部分，因此00000001为我们提供了最终名称00000001000000000000000D。

LSN的最后一部分是WAL文件中的偏移量，使用内置函数pg_walfile_name_offset()得到，也可转换成整数查看，

```sql
postgres=# SELECT pg_walfile_name_offset('0/D015DF8'),( x'015DF8' )::int AS offset;
      pg_walfile_name_offset      | offset
----------------------------------+--------
 (00000001000000000000000D,89592) |  89592
(1 row)

```

可以得到对应关系

| NAME | 时间线   | 中间部分 | 最后部分  | 偏移量 |
| ---- | -------- | -------- | --------- | ------ |
| LSN  |          | 0        | D         | 015DF8 |
| WAL  | 00000001 | 00000000 | 00000000D | 89592 |

:warning: 请注意，上面的示例只是展示这个概念，但是最好使用函数pg_walfile_name() 从LSN获取确切的WAL文件名，因为WAL切换可能导致LSN “手动解码” 的错误结果。

总而言之，给定一个特定的LSN，数据库能清楚地知道（而且必须清楚地知道）LSN所指的WAL文件段，以及在该文件中可以找到数据的确切偏移量。
