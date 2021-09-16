# shell1

## unix简史

unix由贝尔实验室开发（bell labs）。完整历史信息可在以下链接中找到 [The Creation of the UNIX* Operating System](http://www.bell-labs.com/history/unix)
由于没有盈利压力，unix大都小型、优雅。但随着unix流行，各种版本出现，标准不一致，导致shell脚本移植性变得困难。
幸好，POSIX标准逐渐成熟，几乎所有商用或免费的unix都兼容POSIX。

## 入门

当使用计算机时，希望有不同的工具完成不同的需求。shell脚本最长用于系统管理工作。

* 大中型程序都是编译语言，如java，c，c++等。将源代码转换目标代码即可执行。编译语言的好处是高效。缺点是运作与底层，用来处理字节、整数、浮点等
* 脚本编程语言是解释型（interpreted），由解析器转换成内部代码在执行。

## 为什么要使用shell脚本

脚本编程语言运行在比编译语言更高的层级。能够轻易处理文件与目录对象。缺点是效率不如编译型语言。
shell经过posix标准化。基本可以与各unix系统通用。shell脚本写一次即可应用于各系统上。
shell脚本：简单、可移植、开发容易。

## 初识shell

echo.sh

```shell
#! /bin/sh
cd /tmp/
echo "my name is chris"

```

* sh一般设成bash的软链 ll /bin/sh
* 在一般的linux系统当中（如redhat），使用sh调用执行脚本相当于打开了bash的POSIX标准模式
* 也就是说 /bin/sh 相当于 /bin/bash --posix所以，sh跟bash的区别，实际上就是bash有没有开启posix模式的区别so，可以预想的是，如果第一行写成 #!/bin/bash --posix，那么脚本执行效果跟#!/bin/sh是一样的（遵循posix的特定规范，有可能就包括这样的规范：“当某行代码出错时，不继续往下解释”）
* 解析器的路径填写完全路径。

linux运行程序的方法包括sh、source等。source运行结果略有不同。命令文件授予+x权限后。运行命令文件时，linux内核命令fork一个进程执行脚本，如果这个命令文件是编译型文件（二进制），则linux内核知道如何执行文件，不幸的是，我们的命令文件不是编译型文件，而是文本文件，内核并不知道urhe执行。内核抛出“not executable format file”，shell接受到这个信息，则认定这是一个脚本文件。
shell知道是个脚本后，会启动一个新进程执行这个程序，但linux中往往有几个shell，该选择哪个呢？

```shell
#! /bin/bash #调用哪种shell
#! /usr/bin/python #调用python程序
#！/bing/more #调用more程序
```

## 命令与参数

* 以空白（space or tab）隔开命令行中各个组成部分
* 命令名称是命令行的第一个项目，后面会跟着选项（option），
* 选项开头通常使用"-"后面接一个字母，选项开头可有可无。可将多个选项参数合并。如ls -atl
* 长选项“--”表示，现在使用越来越普遍，特别是标准工具GUN版本。如patch --verbose
* 分号（; ）可以用来分割一行里的多条命令。shell会依次执行这些命令。
* 使用&而不是分号，shell将在后台执行前面的命令，这意味着shell不用等待前面的命令执行完成就可以执行下一个命令

## shell命令种类

linux shell可执行3种命令，内建命令，shell函数，外部命令

* 内建命令，没有进程创建和消亡（echo，cd）
* 外部命令，会创建一个当前shell的复制进程。（find，grep等程序）
* shell函数，可以像其他命令一样被引用

sh echo.sh不会改变目录，cd外部命令，会创建子进程，在子进程中执行cd后子进程消亡，父进程没有任何改变
source echo.sh会改变目录，source只影响脚本自身，不会创建子进程，直接在父进程执行，父进程通过cd命令改变了目录

## shell变量

* 变量本质是个键值对。如 var="hello"
* 变量名=值，两边不要有空格。值包含空格时需要加引号。
* 变量引用，在名称前加上$
* $var=${var},$var是缩写形式
* 单引号（''）是弱引用，变量会被禁止
* 双引号（""）是抢引用，变量不会被禁止

```shell
var=123
echo '$var'
echo "$var"

```

* 变量可以为空值（echo $var）
* 变量分为全局变量和局部变量

局部变量用local声明，仅在代码块或函数中生效
全局变量不需要修饰词，默认，全局范围可见

## echo输出变量

* echo可显示变量值，echo的任务就是产生输出
* 原始echo将参数打印到标准输出，参数间以空格隔开，并以换行符（newline）结尾。
* 使用-n参数时会省略换行符结尾。
* echo还可以使用很多转义字符，如 \a, \n, \r等。
* 比较复杂的输出用printf

``` bash
#-e 开启转义
x='this is ok'
echo -e "$x \n"
```

### export

* export设置当前环境变量，有效期仅维持到当前进程消亡为止，如果想永久保存，可以将export命令写入shell的启动文件中。

shell的启动文件
/etc/profile,系统范围，所有有sh衍生的shell都适用
$HOME/.bash_profile,用户首次登陆生效
$HOME/.bashrc,每次调用新的shell生效

* env可以去掉继承的环境变量

env -i PATH=$PATH echo.sh
-i清空所有父进程继承来的环境变量，仅设置指定的PATH变量

* unset删除环境变量
x=123
echo $x
unset -v x
echo $x

### 准备bin目录

shell会沿着$PATH寻找命令。$PATH是以目录间隔的目录列表。至少包括/bin, /usr/bin, /usr/local/bin
echo $PATH

如果要编写自己的脚本，最好准备自己的bin目录来存放他们，让shell能够自动找到他们。
只需建立自己的bin目录加入到$PATH中。

``` bash
mkdir bin
mv /tmp/user ~/bin/
PATH=$PATH:$HOME/bin

```

* $HOME/bin可调整位置，在前，中，后。表示查找时的先后顺序

## SHELL是解析型语言

计算机语言翻译的方式有两种

编译
解释

## 语法检测

shell的语法还是相当让人无语的，很多很容易疏忽遗漏的地方
命令格式： sh -n ***.sh 
若是没有异常输出，证明脚本没有明显的语法问题。

运行跟踪：

实践是检验整理的唯一标准，跑一把。
不过，可不是直接运行然后去看最终结果，这样会遗漏掉很多中间过程。
命令格式： sh -vx ***.sh
得到效果如下:
我们可以看到
每行代码原始命令（无+的）:[这是-v的效果]
代码执行时的情况（带+），包括运算结果，逻辑判断结果，变量赋值等等[-x的效果]
而我们所要关注的就是这些信息，主要是变量值和逻辑判断结果。

## 国际化与本地化

在unix中，控制让那种语言或文化环境生效的功能叫做locale
一般设置LC_ALL强制设置单一的locale，而LANG设置locale的默认值。应避免设置任意的LC_XXX参数。

locale -a：列出所有locale名称
LC_ALL=C：强制使用传统的locale
