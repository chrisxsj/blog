# shell_bash

**作者**

Chrisx

**日期**

2022-02-15

**内容**

shell，bash特性使用

----

[toc]

## bash-completion支持命令自动补全

## history命令历史记录

```sh
history #查看所有历史命令
history 8   #查看最近8个命令
history -d 8    #删除编号为8的历史命令
!8  #执行标号为8的命令
!!  #执行历史命令中的最近一条命令，即上一个命令
!ps #执行历史命令中最近一条以ps开头的命令
echo $HISTFILE  #显示历史命令文件
history -c  #删除所有历史命令
```

## alias别名功能

放入环境变量配置文件~/.bashrc

```sh
alias ssh151="ssh root@192.168.80.151"
alias ls='ls -atl'
alias rm='rm -i'        #rm进行提示
alias mv="mv -i"        #mv进行提示
```

查看

```sh
alias

```

## 快捷键

| 快捷键 | 描述                     |
| ------ | ------------------------ |
| ctrl+A | 将光标移到命令行开头     |
| ctrl+E | 将光标移到命令行结尾     |
| ctrl+C | 强制终止当前命令         |
| ctrl+L | 清屏，等于clear          |
| ctrl+U | 删除或剪切光标之前的命令 |
| ctrl+k | 删除或剪切光标之后的内容 |
| ctrl+Y | 粘贴ctrl+k或ctrl+l的内容 |
| ctrl+R | 在历史命令中搜索         |
| ctrl+D | 退出终端                 |
| ctrl+S | 暂停屏幕输出             |
| ctrl+Q | 恢复屏幕输出             |

## 命令排序

命令顺序的逻辑判断

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

## 通配符

常见通配符

| 字符        | 含义                              | 实例                                                                         |
| ----------- | --------------------------------- | ---------------------------------------------------------------------------- |
| *           | 匹配0个或多个任意字符             | a*b,a和b之间可以有任意多个字符。acb、ab、asdfdsd                             |
| ?           | 匹配1个任意字符                   | a?b,a和b之间有且只有一个字符。acb、adb                                       |
| [list]      | 匹配list中的任意单个字符          | a[xyz]b,a和b之间有且只能有一个[xyz]中的字符。azb、azb                        |
| [!list]     | 匹配除list中的任意单个字符        | a[!a-z]b,a和b之间有且只能有一个[!a-z]之外的字符。aAb、a2b                    |
| [!list]     | 匹配除list中的任意单个字符        | a[!a-z]b,a和b之间有且只能有一个[!a-z]之外的字符。aAb、a2b                    |
| [c1-cn]     | 匹配除c1-cn中的任意单个字符       | a[0-9]b,a和b之间有且只能有一个[0-9]之间的字符。a8b、a5b                      |
| {s1,s2,...} | 匹配除s1,s2,...中的任意单个字符串 | a[word,me,ttt]b,a和b之间有且只能有一个[word,me,ttt]中的字符串。awordb、atttb |

```sh
ls /etc/*.conf  #匹配所有以.conf后缀的文件
ls /etc/???.conf  #匹配所有以.conf后缀且只有3个字符的文件
touch file{1,2,3}   #创建3个文件，file1，file2，file3
rm file[1,2,3]  #删除文件file1，file2，file3

```

## 前后台作业及脱机管理

ref[shell_task](./shell_task.md)

## 输入输出重定向

ref[Redirection](./shell_Redirection.md)
