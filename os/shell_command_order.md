# shell_command_order

**作者**

Chrisx

**日期**

2021-06-21

**内容**

shell环境命令顺序的逻辑判断

----

[toc]

## 命令顺序的逻辑判断

* &&  如果&&左边的command1执行成功(返回0表示成功)，&&右边的command2才能被执行。
* ||  如果||左边的command1执行失败(返回1表示失败)，就执行右边的command2。
* ;   没有判断，;左边和右边的命令都会执行。

```sh
ls /tmp/passwd10 && echo "scuccess"
ls /tmp/aaa && echo "scuccess"
ls /tmp/aaa || echo "scuccess"
ls /tmp/passwd10 || echo "scuccess"
ls /tmp/aaa ; echo "scuccess"
```
