# shell_base

**作者**

Chrisx

**日期**

2022-01-26

**内容**

shell介绍

----

[toc]

## unix简史

unix由贝尔实验室开发（bell labs）。完整历史信息可在以下链接中找到 [The Creation of the UNIX* Operating System](http://www.bell-labs.com/history/unix)
由于没有盈利压力，unix大都小型、优雅。但随着unix流行，各种版本出现，标准不一致，导致shell脚本移植性变得困难。
幸好，POSIX标准逐渐成熟，几乎所有商用或免费的unix都兼容POSIX。

linux设计思想，一切皆文件
文件类型，-表示普通文件，d表示目录，c表示字符设备，d表示块设备，l表示符号链接文件
unix的哲学KISS(keep it simple，stupid)

## 编程语言

* 机器语言，运行最快，语言复杂，开发效率低
* 汇编语言，运行速度快，语言复杂，开发效率低
* 高级语言
    编译，编译成机器语言。执行运行速快，跨平台性差，依赖机器环境。c、c++、java
    解释，跨平台性强，一份代码，到处使用。执行速度慢。依赖解释器运行。shell

shell经过posix标准化。基本可以与各unix系统通用。shell脚本写一次即可应用于各系统上。
shell脚本：简单、可移植、开发容易。

## 认识shell

* 含义，shell是“壳”，相对于kernel内核来说。shell是面向用户的一个命令接口。shell是用户与机器之间的桥梁。通过shell对计算机操作和交互。
* 表现，linux是内核与界面分离的。可以脱离界面单独运行。也可以在内核基础上运行图形化桌面。因此shell可以是无图形界面下的终端，也可以是图形化界面中的终端窗口。
* 运行命令，命令行或脚本
* 分类，linux中默认shell是/bin/bash或dash

## 命令与参数

* 以空白（space or tab）隔开命令行中各个组成部分
* 命令名称是命令行的第一个项目，后面会跟着选项（option），
* 选项开头通常使用"-"后面接一个字母，选项开头可有可无。可将多个选项参数合并。如ls -atl
* 长选项“--”表示，现在使用越来越普遍，特别是标准工具GUN版本。如patch --verbose
* 分号（; ）可以用来分割一行里的多条命令。shell会依次执行这些命令。
* 使用&而不是分号，shell将在后台执行前面的命令，这意味着shell不用等待前面的命令执行完成就可以执行下一个命令
* 每一个可通过help和man得到指导

## 编写标准

* 风格规范

第一行的#！，指定使用哪种解析器，sh一般设成bash的软链

```shell
#! /bin/sh

#! /bin/bash #调用哪bash解析器
#! /usr/bin/python #调用python程序
```

查看可支持的解析器

```sh
cat /etc/shells

```

* 注释。注释用于解释说明
* 变量。变量通常放在脚本的开头，可调用系统变量

```sh
source ~/.bashrc
export dt=`date +%Y-%m-%d`
```

* 缩进。需要有缩进，简单明了
* 命名。规范命名，以.sh结尾；名称有意义；同一风格，小写字符加下划线
* 编码统一。utf8
* 日志和回显。记录日志，回显加特效
* 密码要移除
* 太长要分行（\）
* 代码要有效率。代码过长会导致效率降低
* 学会查路径。dir=$(cd $(dirname $0) && pwd)
* 技巧
    路径尽量使用绝对路径
    优先使用bash变量代替sed，awk
    简单if判断尽量是&&，||写成单行。如[[x>2]] && echo x
    利用/dev/null过滤不友好的信息。
    读取文件时，不要使用for loop，而使用wile read

## 国际化与本地化

在unix中，控制让那种语言或文化环境生效的功能叫做locale
一般设置LC_ALL强制设置单一的locale，而LANG设置locale的默认值。应避免设置任意的LC_XXX参数。

locale -a：列出所有locale名称
LC_ALL=C：强制使用传统的locale
