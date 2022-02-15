# shell_sed

**作者**

Chrisx

**日期**

2021-09-07

**内容**

sed的使用

----

[TOC]

## 介绍

* sed流编辑器。是一个很好的文件处理工具，主要是以行为单位进行处理，可以将数据行进行替换、删除、新增、选取等特定工作，下面先了解一下sed的用法

* sed是在线的、非交互式的编辑器，一次处理一行内容，处理时，把行存储在缓冲区中，称为模式空间（pattern space）。处理完成后，把缓冲区内容输送到屏幕。接着处理下一行。直到文件末尾。文件内容没有改变。简化对文件的反复操作。

* sed支持正则表达式。

## 使用

用法: sed [选项]... {脚本(如果没有其他脚本)} [输入文件]...

sed --help

常用选项

* -n 静默输出
* -e 允许多点编辑
* -f 将sed写在配置文件中
* -r 支持扩展正则表达式
* -i 直接修文件内容。

常用命令选项

* a\ 新增，a后面可以接字符串，这些字符串在新一行出现
* c\ 替换，接替换的字符串
* d  删除，
* i\ 插入，插入新的字符串，这些字符串在新一行出现
* p  打印，常与sed -n一起运作
* s  替换，直接替换，支持正则

高级命令选项

高级命令选项与缓冲区有关


## 示例

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
df -h |sed '1d'                              #删除第一行 
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

## 删除空行

/^$/d
/ - start of regex
^ - start of line
$ - end of line
/ - end of regex
d - delete lines which match
所以基本上找到任何空的行(起点和终点是相同的，例如没有字符)，并删除它们。