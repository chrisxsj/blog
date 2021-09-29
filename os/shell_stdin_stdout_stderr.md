# shell_stdn_stdout_stderr

**作者**

Chrisx

**日期**

2021-09-28

**内容**

shell从定向的使用

----

[toc]

## 标准

| 名称                | 类型                  | 文件描述符 | 操作   |
| ------------------- | --------------------- | ---------- | ------ |
| stdin 标准输入      | standard input        | 0          | <,<<   |
| stdout 标准输出     | standard output       | 1          | >,>>   |
| stderr 标准错误输出 | standard error output | 2          | 2>,2>> |

## io重定向

```sh
# 对于交互命令行来说，标准输入、输出，错误都是终端。
echo "output to file" > /tmp/output     #>改变标准输出，重定向到文件
cat < /tmp/output                       #<改变标准输入，标准输入修改为文件
echo "output to file two" > /tmp/output #>>输出追加到文件末尾
head -n 10 /etc/passwd |grep root       #|管道连接，命令1的输出与命令2的输入相连
# 习惯上，标准输入的文件描述符是0，标准输出的文件描述符是1，标准错误是2
2>&1                                    #标准错误重定向到标准输出。重定向到同一个文件
# /dev/null是个伪文件，代表空、黑洞
cat /etc/passwd |grep highgo > /tmp/pwd 2> /dev/null    #将错误输出抛弃
cat /dev/null > /tmp/pwd                #将空写入文件，清空文件
ln -s /dev/null /tmp/pwd                #所有pwd都被自动扔到黑洞中，自动清理
# /dev/zero是个伪文件，产生一个null数据流。初始化指定长度的文件，同时数据流写入/dev/zero会消失
dd if=/dev/zero of=/tmp/zero bs=1024 count=10   #用二进制0填充一个1MB大小的文件
# /dev/tty,重定向到当前终端
read pass </dev/tty                     #从终端读取密码
# linux设计思想，一切皆文件
# 文件类型，-表示普通文件，d表示目录，c表示字符设备，d表示块设备，l表示符号链接文件
# unix的哲学KISS(keep it simple，stupid)
```
