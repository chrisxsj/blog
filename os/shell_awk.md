# awk

**作者**

Chrisx

**日期**

2022-02-21

**内容**

awk的使用

----

[TOC]

## 介绍

awk是一个编程语言，相对于grep的查找，sed的编辑，awk操作更细粒度，可以对行数据操作。简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。

## 用法

```sh
awk --help
awk [-F field-seperator] 'command' input-files

```

* command是awk命令
* -F，可选，指定域的分隔符，默认为空格
* input-files，需要处理的文件

参数说明

| 参数         | 说明                                           |
| ------------ | ---------------------------------------------- |
| -F fs        | 指定文件域分隔符，fs可以使字符串或者正则表达式 |
| -v var=value | 定义变量                                       |
| -f scripfile | 读取awk脚本文件                                |
| -mf nnn      | 限制分配给nnn的最大块数                        |
| -mr nnn      | 限制记录的最大数目                             |
| -W compact   | 在兼容模式下运行awk，类似gawk                  |
| -V           | 打印版本信息                                   |

## print和printf

print是正常打印，printf是格式化打印

```sh
print item1,item2,...
printf "FORMAT" ,item1,item2,...

```

* 逗号分隔符，打印后显示时是空格
* item可以是字符串，可以是域标识$1,$2
* item省略就是$0
* print默认\n换行，而printf默认不会换行，需要指定格式



## 正则匹配

| 参数           | 说明                   |
| -------------- | ---------------------- |
| ~              | 表示匹配开始           |
| //             | 中间是匹配值           |
| $0             | 匹配所有域             |
| $1             | 匹配第1个字段（域）    |
| $n             | 匹配第n个字段（域）    |
| $NF            | 匹配最后一个字段（域） |
| {IGNORECASE=1} | 忽略大小写             |
| !              | 匹配值取反             |

```sh
awk -F : '$1 ~ /^root/ {print $1,$4}' /etc/passwd  #以:分割域，$1，第1个域，匹配以root开头的，打印第1列和第4列
awk '{IGNORECASE=1} /root/' /etc/passwd    #忽略大小写，输出包含root的行
awk '$0 !~ /^root/' /etc/passwd    #$0 匹配整行，不包括root开头的行
awk -F ":" '{print $NF}' /etc/passwd    #打印指最后一个域
```




## 示例


[oracle@rhel63single ~]$ rm `ls -l --time-style=full-iso | awk '/2012/{print $9}' `
删除 
截取 完全日期显示格式 文件命令符合2012 以空格为截断点显示第九列
的文件
ls -atlr | awk '/root/{print $9}

[oracle@rhel63single ~]$ ls -l --time-style=full-iso 
total 664
-rw-r--r--. 1 oracle oinstall  48583 2013-02-21 11:14:22.834404645 +0800 ashrpt_1_0221_1114.html
-rw-r--r--. 1 oracle oinstall 429882 2013-02-20 10:06:08.815839174 +0800 awrrpt_1_1_3.html
drwxr-xr-x. 8 oracle oinstall   4096 2011-09-22 16:57:44.000000000 +0800 database
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Desktop
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Documents
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Downloads
-rw-r--r--. 1 oracle oinstall    919 2013-02-20 13:47:41.736856696 +0800 imp_tts_tentbs_10g_to_linux.log
-rw-r--r--. 1 oracle oinstall 137316 2013-02-21 12:41:24.978557370 +0800 monitor_sql.html
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Music
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Pictures
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Public
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Templates
-rw-r--r--. 1 root   root          0 2012-02-24 00:00:19.169470455 +0800 test_lei
-rw-r--r--. 1 oracle oinstall   4096 2013-02-20 15:44:15.000000000 +0800 tts_tentbs_to_linux.dmp
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Videos
-rw-r--r--. 1 oracle oinstall  16384 2013-02-21 17:12:25.771401759 +0800 vtest.dmp
[oracle@rhel63single ~]$ ls -l --time-style=full-iso | awk '/2012/{print $9}'
test_lei
[oracle@rhel63single ~]$ rm `ls -l --time-style=full-iso | awk '/2012/{print $9}' `
rm: remove write-protected regular empty file `test_lei'? y
[oracle@rhel63single ~]$ ls -l --time-style=full-iso 
total 664
-rw-r--r--. 1 oracle oinstall  48583 2013-02-21 11:14:22.834404645 +0800 ashrpt_1_0221_1114.html
-rw-r--r--. 1 oracle oinstall 429882 2013-02-20 10:06:08.815839174 +0800 awrrpt_1_1_3.html
drwxr-xr-x. 8 oracle oinstall   4096 2011-09-22 16:57:44.000000000 +0800 database
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Desktop
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Documents
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Downloads
-rw-r--r--. 1 oracle oinstall    919 2013-02-20 13:47:41.736856696 +0800 imp_tts_tentbs_10g_to_linux.log
-rw-r--r--. 1 oracle oinstall 137316 2013-02-21 12:41:24.978557370 +0800 monitor_sql.html
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Music
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Pictures
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Public
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Templates
-rw-r--r--. 1 oracle oinstall   4096 2013-02-20 15:44:15.000000000 +0800 tts_tentbs_to_linux.dmp
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Videos
-rw-r--r--. 1 oracle oinstall  16384 2013-02-21 17:12:25.771401759 +0800 vtest.dmp