# wc

**作者**

Chrisx

**日期**

2021-08-18

**内容**

wc使用技巧

----

[toc]

## 使用

wc --help

用法：wc [选项]... [文件]...

* -c, --bytes           输出字节数统计
* -m, --chars           输出字符数统计
* -l, --lines           输出行数统计
    * --files0-from=文件 从指定文件读取以空字符（NUL）终止的名称；
                       * 如果该文件被指定为 - 则从标准输入读文件名
* -L, --max-line-length  显示最长行的长度
* -w, --words            显示单词计数

## 用法

```sh
wc -c /etc/passwd*
wc -l /etc/passwd
```
