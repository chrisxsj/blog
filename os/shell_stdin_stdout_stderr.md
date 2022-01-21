# shell_stdn_stdout_stderr

**作者**

Chrisx

**日期**

2021-09-28

**内容**

shell输入输出重定向的使用

----

[toc]

## 介绍

一般，输入从键盘，输出到终端。对于交互命令行来说，标准输入、输出，错误都是终端。

| 名称                | 类型                  | 文件描述符 | 操作   | 硬件   |
| ------------------- | --------------------- | ---------- | ------ | ------ |
| stdin 标准输入      | standard input        | 0          | <,<<   | 键盘   |
| stdout 标准输出     | standard output       | 1          | >,>>   | 显示器 |
| stderr 标准错误输出 | standard error output | 2          | 2>,2>> | 显示器 |

## 输入重定向

使用符号<

```sh
cat < /tmp/output                       #<改变标准输入，标准输入修改为文件

```

## 输出和错误重定向

* 符号>覆盖，>>追加
* 默认文件描述符是1时，可省略不写
* 文件描述符和操作（>,>>）之间不能有空格

```sh

echo "output to file" > /tmp/output     #>改变标准输出，重定向到文件
echo "output to file two" >> /tmp/output #>>改变标准输出，追加到文件末尾
echo "output to file" > /tmp/output 2>&1 #标准错误重定向到标准输出。标准输出和标准错误重定向到同一个文件
echo "output to file" > /tmp/output 2> /tmp/output2 #标准输出重定向到文件1，标准错误重定向到文件2，放到不同文件中
#&是标准输出和标准错误的集合
echo "output to file" &> /tmp/output    #标准输出和标准错误重定向到同一个文件，等于(> 2>&1)

```

## /dev/null

/dev/null是个伪文件，代表空、黑洞

```sh
cat /etc/passwd |grep highgo > /tmp/pwd 2> /dev/null    #将错误输出抛弃
cat /dev/null > /tmp/pwd                #将空写入文件，清空文件

```

## /dev/zero

/dev/zero是个伪文件，产生一个null数据流。初始化指定长度的文件，同时数据流写入/dev/zero会消失

```sh
dd if=/dev/zero of=/tmp/zero bs=1024 count=10   #用二进制0填充一个1MB大小的文件

```

## /dev/tty

/dev/tty,代表当前终端

```sh
read pass </dev/tty                     #从终端读取密码
```
