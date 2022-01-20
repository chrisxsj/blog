# history

**作者**

Chrisx

**日期**

2022-01-20

**内容**

history命令使用

----

[toc]

## 命令

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
