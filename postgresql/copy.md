# copy

**作者**

Chrisx

**日期**

2021-10-25

**内容**

COPY — 在一个文件和一个表之间移动数据。COPY to 将表的内容复制到文件中, 而 COPY FROM 将数据从文件复制到表中

<!--
最大的优势就是速度。优势在让我们跳过shared buffer,wal buffer。直接写文件。
-->

ref[copy](https://www.postgresql.org/docs/12/sql-copy.html)

----

[toc]

## copy使用

* COPY TO只能被用于纯粹的表，不能用于视图。 不过你可以写COPY (SELECT * FROM viewname) TO ...来拷贝一个视图的当前内容。
* COPY FROM可以被用于普通表、外部表、分区表或者具有INSTEAD OF INSERT触发器的视图。
* COPY只处理提到的表，它不会从子表复制 数据或者复制数据到子表中。
* COPY需要有表的读取权和操作系统文件的读写权限。
* COPY和 psql指令 \copy有所不同。 COPY是服务器应用程序，且导出的文件要和数据库在同一个主机上，\COPY是psql命令，可以从远端数据库将数据直接导出到本地
* COPY会在第一个错误处停止操作。这在 COPY TO的情况下不会导致问题，但是 在COPY FROM中目标表将已经收到了一 些行。这些行将不会变得可见或者可访问，但是它们仍然占据磁盘空间。 如果在一次大型的复制操作中出现错误，这可能浪费相当可观的磁盘空间。 你可能希望调用VACUUM来恢复被浪费的 空间。

## 文件格式

1. 文本格式text

* 其中每一行就是表中的一行。一行中的列被定界字符分隔
* 反斜线 `\`可以被用作定界符，但必须前置一个反斜线，进行转义
* 特殊字符被用作列值时需要前置反斜线转义。如一个空值串（例如\N）不会与实 际的数据值\N（它会被表示为\\N）搞混。

2. CSV 格式

* 此格式选项用于导入和导出许多其他程序 (如电子表格) 使用的逗号分隔值 (CSV) 文件格式。
* 使用默认设置时, NULL 将被写入为一个不带引号的空字符串, 而空字符串数据值则用双引号 ("") 写入。

如果不导入comm列数据，可在列的列表中去掉。

3. 二进制格式

* 二进制格式选项会导致所有数据作为二进制格式而不是文本进行存储读取。它比文本和 CSV 格式快一些, 但二进制格式的文件在计算机体系结构和 PostgreSQL 版本中的可移植性较差。

## copy case

### copy from

1 csv格式的数据/tmp/test_copy.csv

``` bash
"eno","ename","job","mgr","hiredate","sal","comm","deptno"
"7499","ALLEN","SALESMAN","7698","1991-02-20","1600","300","30"
"7566","JONES","MANAGER","7839","1991-04-02","2975",null,"20"
"7654","MARTIN","SALESMAN","7698","1991/9/28","1250","1400","30"
"7498","JASON","ENGINEER","7724","1990/2/20","1600","300","10"
```

2 创建表结构

```sql
create table test_copy (eno int,ename varchar,job varchar,mgr varchar,hiredate timestamp,sal int,comm varchar,deptno int);

```

3 导入数据

```sql
psql
copy public.test_copy from '/tmp/test_copy.csv' with (FORMAT csv, DELIMITER ',', escape '\', header true, quote '"', null 'null', encoding 'UTF8');

```

这里, with后面括号中跟的是导入参数设置

* format指定导入的文件格式为csv格式
* delimiter指定了字段之间的分隔符号位逗号
* escape指定了在引号中的转义字符为反斜杠，这样即使在引号字串中存在引号本身，也可以用该字符进行转义，变为一般的引号字符，而不是字段终结
* header true：指定文件中存在表头。如果没有的话，则设置为false
* null,指定的空字符串用于代替空的列
* quote指定了以双引号作为字符串字段的引号，这样它会将双引号内的内容作为一个字段值来进行处理
* encoding指定了文件的编码格式为utf8, 如果是别的格式则修改为适当的编码格式.

> 注意,如果输入文件中的任何行包含的列数超过或少于预期值, COPY 将引发错误。

### copy to

导出可以指定行数据

```sql
psql
copy public.test_copy to '/tmp/test_copy_all.csv' (FORMAT csv, DELIMITER ',', escape '\', header true, quote '"', null 'null', encoding 'UTF8');
copy (select * from public.test_copy where sal>2000) to '/tmp/test_copy_2000.csv';

```
