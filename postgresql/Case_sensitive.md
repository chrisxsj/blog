# Case sensitive

https://my.oschina.net/postgresqlchina/blog/5073939

PostgreSQL和Oracle一样，默认都是大小写不敏感的，但两者仍然存在区别：

Oracle：默认是大小写不敏感，表名、字段名等不区分大小写，小写字母会自动转换为大写字母； 需要用小写字母时需要使用双引号，或借助函數upper()和lower()；
PostgreSQL：默认是大小写不敏感，表名、字段名等不区分大小写，大写字母会自动转换为小写字母； 需要用大写字母时需要使用双引号，或借助函數upper()和lower()；


1、表、列名中的大小写敏感
例如我们创建表test，表名写成test、Test、TEST结果均是一样的：
列名也是同样如此


create table TEST(id int,INFO text);
select info from test;

那么如果我们想要指定表或者列名为大写该怎么办呢？

使用双引号即可。

但是可以看到这种方法也很麻烦，因为我们需要查询的时候也要用双引号，所以建议不要这么去使用。

drop table test;
create table "TEST" (id int,"INFO" text);
select * from "TEST";
select info from  "TEST";
select "INFO" from "TEST";

2、查询数据中的大小写敏感
当我们进行数据匹配查询时，是区分大小写的。

例如：

bill@bill=>insert into test values(1,'Bill');
INSERT 0 1
bill@bill=>select * from test where info = 'bill';
 id | info
----+------
(0 rows)
bill@bill=>select * from test where info = 'Bill';
 id | info
----+------
  1 | Bill
(1 row)
select * from test where lower(info) = 'bill';

可以看到，就是直接使用memcmp函数对字符直接进行比较，自然是会去区分大小写。所以想要不区分大小写除非我们数据写入的时候就不区分大小写。

因此我们可以使用citext模块来实现忽略大小写的查询

3、数据排序中的大小写敏感
排序也是Oracle一样，默认是区分大小写的。


