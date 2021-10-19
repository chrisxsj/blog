# sed

**作者**

Chrisx

**日期**

2021-09-07

**内容**

sed的使用

----

[TOC]

## 介绍

sed是一个很好的文件处理工具，本身是一个管道命令，主要是以行为单位进行处理，可以将数据行进行替换、删除、新增、选取等特定工作，下面先了解一下sed的用法

sed --help

## 使用

查询

```sh
sed -n '/log/p' $PGDATA/postgresql.conf    #查询包括关键字log所在所有行
sed -n '/^log/p' $PGDATA/postgresql.conf     #查询log开头的行

```

增加

```sh
sed -i '$a host\tall\tall\t0.0.0.0/0\tmd5' $PGDATA/pg_hba.conf   #在文件末尾增加一行

-i,编辑文件
$a,末尾
\t,TAB的表示方式


```

删除

```sh
sed -i '52,295d' /opt/HighGo4.3.4.7-see/etc/hgdb-see-4.3.4.7  #删除52-295行
sed -i '1d' $PGDATA/pg_hba.conf              #删除第一行 
sed -i '$d' $PGDATA/pg_hba.conf              #删除最后一行
sed -i '/reject/d' $PGDATA/pg_hba.conf  #删除包括reject的所有行
```

替换

代替一行或多行

```sh
sed -i '1c chrisx' parameter.conf                #整行替换。第一行代替为xxx
sed -i '1,2c chrisx' parameter.conf     #多行替换。第一行到第二行代替为xxx
sed -i 's#rainx#chrisx#g' pa.conf   #部分替换。格式：sed 's#要替换的字符串#新的字符串#g'（要替换的字符串可以用正则表达式）
sed -i "s#$i#$p#g" pa.conf   #部分替换。替换部分使用环境变量，将单引号替换为双引号

```
