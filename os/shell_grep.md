# shell_grep

**作者**

Chrisx

**日期**

2022-02-15

**内容**

shell grep使用

----

[toc]

## 介绍

* grep是使用频率最高的文本查找命令。主要功能是在一个多个文本中查找特定字符串。如果匹配则输出整行，不匹配则不输出任何内容。grep不改变源文件。
* linux包括很多grep命令，包括grep、egrep、fgrep等
* grep可全局查找，支持正则表达式，输出打印包含表达式的行

## 命令格式和选项

```sh
grep [选项] pattern filename filename ...


```

* pattern是一个基本正则表达式。
* filename是要查找的文件
* 选项使用--help查看

* -E 可扩展正则表达式，等于egrep
* -i 忽略大小写
* -n 显示行号
* -v 不匹配选中的行

示例

```sh
cat t |grep ^a  #过滤打印以a开头的行
cat t |grep a$  #过滤打印以a结尾的行
ifconfig eth0 |grep "[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}"   #过滤打印IP地址（正则表达式）
cat t |grep "ad|th"  #过滤打印包含ad或th的行
cat t |grep -E ^[a-z]  #过滤打印包a-z开头的行
```