# shell_base

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
    * 编译，编译成机器语言。执行运行速快，跨平台性差，依赖机器环境。c、c++、java
    * 解释，跨平台性强，一份代码，到处使用。执行速度慢。依赖解释器运行。shell

shell经过posix标准化。基本可以与各unix系统通用。shell脚本写一次即可应用于各系统上。
shell脚本：简单、可移植、开发容易。

## 认识shell

* 含义，shell是“壳”，相对于kernel内核来说。shell是面向用户的一个命令接口。shell是用户与机器之间的桥梁。通过shell对计算机操作和交互。
* 表现，linux是内核与界面分离的。可以脱离界面单独运行。也可以在内核基础上运行图形化桌面。因此shell可以是无图形界面下的终端，也可以是图形化界面中的终端窗口。
* 运行命令，命令行或脚本
* 分类，linux中默认shell是/bin/bash或dash

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

第一行的#！，指定使用那种解析器

```shell
#! /bin/bash #调用哪种shell
#! /usr/bin/python #调用python程序
#！/bing/more #调用more程序
```

## shell命令种类

linux shell可执行3种命令，内建命令，shell函数，外部命令

* 内建命令，没有进程创建和消亡（echo，cd）
* 外部命令，会创建一个当前shell的复制进程。（find，grep等程序）
* shell函数，可以像其他命令一样被引用

linux运行程序的方法

* 提供可执行权限，直接运行文件
* 调用命令解析器，如sh
* source

sh echo.sh不会改变目录，cd外部命令，会创建子进程，在子进程中执行cd后子进程消亡，父进程没有任何改变
source echo.sh会改变目录，source只影响脚本自身，不会创建子进程，直接在父进程执行，父进程通过cd命令改变了目录

## 命令与参数

* 以空白（space or tab）隔开命令行中各个组成部分
* 命令名称是命令行的第一个项目，后面会跟着选项（option），
* 选项开头通常使用"-"后面接一个字母，选项开头可有可无。可将多个选项参数合并。如ls -atl
* 长选项“--”表示，现在使用越来越普遍，特别是标准工具GUN版本。如patch --verbose
* 分号（; ）可以用来分割一行里的多条命令。shell会依次执行这些命令。
* 使用&而不是分号，shell将在后台执行前面的命令，这意味着shell不用等待前面的命令执行完成就可以执行下一个命令
* 每一个可通过help和man得到指导

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

## bash特性

* bash-completion支持命令自动补全
* history命令历史记录 ref[history](./history.md)
* alias别名功能.ref[alias](./alias.md)
* 快捷键。ref[shell_shortcut_key](./shell_shortcut_key.md)
* 前后台作业.ref[shell_task](./shell_task.md)
* 输入输出重定向.ref[shell_stdin_stdout_stderr](./shell_stdin_stdout_stderr.md)
* 命令排序
* 通配符


## 其他

```shell
#! /bin/bash

# shell中特殊字符
~（主目录），
``（命令替换），
#（注释），
$（变量表示符号），
&（后台作业），
*（字符串通配符），
(（启动子shell），
)（结束子shell）
\（转义字符）
|（管道）
[(开始字符集通配)
]（结束字符集通配）
{（开始命令块）
}（结束命令块）
;（命令分隔）
''（强引用）
""（弱引用）
<（输入重定向）
>（输出重定向）
/（路径目录分隔）
?（单个任意字符）
!（管道行逻辑NOT）


# shell启动文件
# 启动文件用于创建一个运行环境，使用/bin/login读取/etc/passwd文件成功登陆后，启动一个交互登陆shell。命令行可以启动一个交互非登录shell，非交互shell通常是一个脚本。
/etc/profile,全局范围，用户登陆生效
$HOME/.bash_profile,用户首次登陆生效，覆盖全局设置
$HOME/.bashrc,每次调用新的shell生效

# 函数
# 函数是一段独立的代码，用于执行一个完整的单项工作。函数复用是优质代码的特征。
# shell执行函数时，并不独立创建子进程。

# shell执行命令的顺序
别名
关键字（if，for）
函数
内置命令
外部命令

type ls # type 查看命令来源，函数、别名或是外部命令

# 函数使用原则
# 在函数中使用exit会退出脚本，如果想退回调用函数的地方，使用return命令
# 如果函数保存在其他脚本中，可以使用source或dot命令将他们装入当前脚本中
# 函数可递归调用
declare -F  #查找当前会话中定义的函数。-f还会打印函数定义
# 函数自动加载需写入启动文件（.bash_profile）

# 函数返回方式使用return，return命令返回函数被调用的位置，如果没有指定return，则函数返回最后一条命令的退出状态。

# add.sh
#! /bin/bash
function add()
{
    let "sum=$1+$2" #位置参数
    return $sum #return返回值
}

source ~/bin/add.sh #加载add函数
add 2 8             #调用函数，并传参
echo $?             #查看返回值

# 条件控制与流程控制
# 条件控制if语句
if condition
then
statement
[elif condition
    then ......]
[else
statement]
fi

# 退出状态
# 函数及命令退出状态用0表示成功，非0表示失败。
# 内置变量$?可以返回上一条语句的退出状态。
# 退出状态值
0       #成功
>0      #失败
126     #命令找到，但无法执行
127     #命令无法找到
>128    #命令收到信息死亡

# 逻辑判断
!   #not，取反
&&  #and，&&左边的command1执行成功(返回0表示成功)后，&&右边的command2才能被执行。
||  #or，如果||左边的command1执行失败(返回1表示失败)，就执行右边的command2。

# 条件测试
# test进行表达式的值测试，可以与if连用，等同于[  ],“[”后和“]”前必须加空格
if test "2>3"   #两个语句相同
if [ "2>3" ]      #两个语句相同
# 注意，ne、gt、lt、le、eq等只能比较整数，如果比较小数就会报integer expression expected。

# 字符串比较
# 使用test比较，可以判断字符串的比较结果
str1=str2   #str1匹配str2
str1!=str2   #str1不匹配str2
str1<str2   #str1小于str2
str1>str2   #str1大于str2
-n str1     #str1为非null（长度大于0）
-z str1     #str1为null（长度为0）

# 文件属性检查
# 使用test检查文件属性
-d file     #file为目录
-e file     #file存在
-f file     #file为一般文件
-w file     #file可写
-s file     #file非空
-x file     #file可执行

# case
# case也是一个流程控制，可以用更精细的方式表达if-elif语句
case expression in
pattern1)
    statements;;
pattern2)
    statements;;
pattern3 | pattern4)
    statements;;
esac

# 循环控制
# for是最简单的循环,遍历列表执行操作

for name in list    #遍历list中的所有对象
do
......              #执行与$name相关的操作
done

# while，until循环
# 允许代码段在某些条件为真时重复运行

while condition     #condition为真时，循环继续，否则退出
do
statement
......
done

or

until condition     #condition为真时，循环退出，否则继续
do
statement
......
done


# 跳出循环
break       #跳出循环
continue    #继续循环

# 示例
path=$PATH
while true
do
if test -z $path    
then
break   #如果path为空则退出循环
fi
ls -ld ${path%%:*}
path=${path#*:}
done


command | while read line

do

    …

done

如果你还记得管道的用法，这个结构应该不难理解吧。command命令的输出作为read循环的输入，这种结构常用于处理超过一行的输出，当然awk也很擅长做这种事
```
