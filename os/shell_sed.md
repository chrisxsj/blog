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

| 参数 | 描述                |
| ---- | ------------------- |
| -n   | 静默输出            |
| -e   | 允许多点编辑        |
| -f   | 将sed写在配置文件中 |
| -r   | 支持扩展正则表达式  |
| -i   | 直接修文件内容      |

常用命令选项

| 参数 | 描述                                            |
| ---- | ----------------------------------------------- |
| a    | 新增，a后面可以接字符串，这些字符串在新一行出现 |
| c    | 替换，接替换的字符串                            |
| d    | 删除                                            |
| i    | 插入，插入新的字符串，这些字符串在新一行出现    |
| p    | 打印，常与sed -n一起运作                        |
| s    | 替换，直接替换，支持正则                        |

高级命令选项

高级命令选项与缓冲区有关

| 参数 | 描述                                                |
| ---- | --------------------------------------------------- |
| h    | 拷贝pattern space内容到holding buffer（特殊内存）   |
| H    | 追加pattern space内容到holding buffer（特殊内存）   |
| g    | 获得holding buffer内容，并替换pattern space文本     |
| G    | 获得holding buffer内容，并追加到pattern space的后面 |
| P    | 打印pattern space的第一行（大写）                   |
| q    | 退出sed                                             |
| =    | 打印当前行号                                        |

## 替换标志

| 参数 | 描述                                              |
| ---- | ------------------------------------------------- |
| g    | 在行内进行全局替换                                |
| w    | 将行写入文件                                      |
| x    | 交换缓冲区与模式空间内容。                        |
| y    | 将字符转换成灵异字符（不能对正则表达式使用y命令） |

## 行替换

替换

```sh
sed 's#要替换的字符串#新的字符串#g' # 这里#是分隔符，也可以使用!或者/。要替换的字符串可以用正则表达式

sed 's#root#ROOT#' /etc/passwd      #行部分替换。替换行中遇到的第一个匹配的值
sed 's#root#ROOT#2' /etc/passwd     #行部分替换。替换行中遇到的指定的第二个匹配的值
sed "s#$i#$p#" /etc/passwd          #行部分替换。替换部分使用环境变量，将单引号替换为双引号
sed "s#root#ROOT#g" /etc/passwd       #行全部替换。替换行中所有匹配的值
sed -n "s#root#ROOT#g p" /etc/passwd      #-n + p仅将替换内容打印到屏幕
sed -n "s#root#ROOT#g w /tmp/passwd_sed_out" /etc/passwd     # 与-n + p类似，但将替换内容打印到指定文件
sed -i 's#ROOT#root#g' /tmp/passwd_sed_out   #直接修改源文件替换

sed -r -n 's#^root#xxx#g p' /etc/passwd   #使用正则，替换以root开头的行
sed -r -n 's#false$#xxx#g p' /etc/passwd   #使用正则，替换以false结尾的行
sed -r -n 's#[0-9][0-9]#xxx#g p' /etc/passwd   #使用正则，替换包括两位数字的行
```

### 行寻址

行寻址，可以对应所有命令，包括替换，删除，增加等

```sh
sed -n '3 s/bin/BIN/g p' /etc/passwd          #将第3行中的所有bin替换为BIN
sed -n '3,5 s/bin/BIN/g p' /etc/passwd        #将第3-5行中的所有bin替换为BIN
sed -n '10,$ s/bin/BIN/g p' /etc/passwd        #将第10行到结尾中的所有bin替换为BIN
```

### 使用文本过滤器过滤行

sed允许指定文本过滤出命令作用的行

```sh
/pattern1/,/pattern2/ command

```

* 使用/将指定文本包含起来。
* 两个pattern之间是过滤区间，从第一个pattern1开始，到pattern2结束

```sh
sed -r -n '/root/s#bin#xxx#g p' /etc/passwd   #寻找包含root的行，并将bin替换为xxx
sed -n '/^log/p' $PGDATA/postgresql.conf     #查询log开头的行
sed -n '/log/p' $PGDATA/postgresql.conf    #查询包括关键字log所在所有行
```

## 行删除

使用d删除特定的行，可以使用行寻址和文本过滤

```sh

sed -i '52,295d' /opt/HighGo4.3.4.7-see/etc/hgdb-see-4.3.4.7  #删除52-295行
sed -i '1d' $PGDATA/pg_hba.conf              #删除第一行 
sed -i '$d' $PGDATA/pg_hba.conf              #删除最后一行
df -h |sed '1d'                              #删除第一行 
sed -i '/reject/d' $PGDATA/pg_hba.conf  #删除包括reject的所有行
sed -i '/^$/d' $PGDATA/pg_hba.conf      #删除空行

```

## 行插入

使用i和a增加文本，i在指定行前增加新行，a在是定行后增加新行。可以使用行寻址和文本过滤

```sh
sed '[address][i|a]\newtext' file

sed -i '$a host \t all \t all \t 0.0.0.0/0 \t md5' $PGDATA/pg_hba.conf   #在文件末尾增加一行,\t是制表符
sed -n '1i\/xxx' /etc/passwd   #在文件末尾增加一行
```

* -i,编辑文件
* $a,末尾
* \t,TAB的表示方式

## 行修改

使用命令c可将整行文本修改为新行。可以使用行寻址和文本过滤

```sh
sed '[address][c]\newtext' file

sed -n '/root/ c\/root/newline' /etc/passwd   #查找包含root的行，并将整行替换为/root/newline
sed -n '1 c\string' /etc/passwd   #将第一行替换为sting
```

## 字符转换

使用y可以对文本进行逐字符转换

```sh
sed '[address]y/oldchar/newchar/'

echo abcde |sed 'y/abc/ABC/'    #从a开始逐个字符替换。将abc替换为ABC
```

:warning: oldchar和newchar字符数需一致

## 写入文件

使用w将内容写入文件

```sh
sed '[address]w file'

sed -n '1,2 w /tmp/sed_out' /etc/passwd    #将第1行到第2行写入文件/tmp/sed_out
```

## 从文件读取

使用r读取文件内容，并插入到指定的行末尾。类似a

```sh
sed '[address]w file'

sed -n '$ r /tmp/sed_out' /etc/passwd    #从文件/tmp/sed_out读入行，并插入到文件末尾
```

## 模式空间和保持空间


## 使用

所有文件都可以使用sed非交互修改。