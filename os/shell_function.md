# shell_function

**作者**

Chrisx

**日期**

2022-01-26

**内容**

function函数是一段可重复使用的函数代码。函数写好后，放在指定位置，可直接调用接口。函数复用是优质代码的特征。

----

[toc]

## 函数定义

```sh
function name{
    commands
    [return value]
}

```

* function,关键字，定义函数
* name，函数名
* commands，执行的代码命令
* return value，函数返回值，可选

函数的优势

* 方便、整洁，可n次调用。
* 减少代码量，修改代码时，只需修改一次函数即可
* 使用快捷，将函数写入文件，可直接调用。

## 函数调用

直接输入函数名，不带括号

```sh
functionname    #不带参数
functionname arg1 arg2  #带参数
```

从文件调用，使用source

```sh
#! /bin/sh
fpath=/opt/sh.sh    #定义包括函数的文件
if [ -f ${fpath} ]
    then
    source $fpath   #加载函数
    check           #调用函数
else
    echo "error: file not exist"
fi
```

## 函数使用原则

* shell执行命令的顺序：系统别名->函数->系统命令->可执行文件等
* 函数执行时可以调用脚本的全局共享变量，也可以为函数设定局部变量(local)。
* 在shell函数里，return是退出函数，exit是退出脚本。return返回一个值给函数，exit返回一个值给当前脚本。
* return命令返回函数被调用的位置，如果没有指定return，则函数返回最后一条命令的退出状态。
* 如果将函数单独放到一个文件，加载时使用source或.
* 函数自动加载需写入启动文件（.bash_profile）
* 函数可递归调用
    declare -F  #找当前会话中定义的函数。
    declare -f fun  #打印函数定义
* type 查看命令来源，函数、别名或是外部命令
    type ls

## 函数传参



<!--

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
eof

-->