# shell_variable

**作者**

Chrisx

**日期**

2022-01-26

**内容**

* shell变量是用固定的字符串标识不固定的内容。
* shell变量类型包括自定义变量、环境变量、位置变量、预定义变量
* shell变量操作包括赋值、引用、变量算数运算、变量内容匹配、数组变量内容匹配

----

[toc]

## 自定义变量

* 定义变量。变量本质是个键值对，变量名=值，两边不要有空格。
  * 变量名必须以字母或下划线开头，区分大小写
  * 变量可以为空值（echo $var），值包含空格时需要加引号
  * 变量仅对当前shell生效
* 引用变量。
  * 查看变量：echo $变量名。或者使用printf $变量名
  * 取消变量：unset $变量名

## 环境变量

配置文件

* /etc/profile,全局变量配置文件，无论那个用户，第一次登录时,该文件被执行.并从/etc/profile.d目录的配置文件中搜集shell的设置.
* /etc/bashrc,/etc/bash.bashrc,全局变量配置文件，无论那个用户，打开bash shell时,该文件被读取。
* ~/.bash_login,用户配置文件，登录时读取
* ~/.bash_profile,用户配置文件，每次用户登录时，该文件被执行一次。
* ~/.bashrc,用户配置文件，每次打开shell时，该文件被读取
* ~/.bash_logout，用户配置文件，退出时读取

定义环境变量

* export设置当前环境变量，有效期仅维持到当前进程消亡为止，如果想永久保存，可以将export命令写入配置文件中。
* unset取消环境变量

## 预定义变量

```shell
echo "$0"               #显示脚本名
echo "$*"               #显示所有参数，将所有参数作为一个整体显示
echo "$@"               #显示所有参数，将所有参数分开显示
echo "$?"               #显示最后命令退出状态，0表示没有错误，其他表示错误。
echo "$#"               #(#)显示参数个数
echo "$$"               #显示当前进程id号
echo "$1-10"            #位置参数，代表第1-10个参数
```

使用示例：

创建pre.sh

```sh
#! /usr/bin/bash
echo "第二个位置变量 $2"
echo "第一个位置变量 $1"
echo "第四个位置变量 $4"

echo "所有参数是：$*"
echo "所有参数是：$@"
echo "参数的个数是：$#"
echo "当前进程id是：$$"

```

运行

```sh
bash pre.sh 1 2 3 4 5
第二个位置变量 2
第一个位置变量 1
第四个位置变量 4
所有参数是：1 2 3 4 5
所有参数是：1 2 3 4 5
参数的个数是：5
当前进程id是：9888
```

1会被赋予第一个变量$1；2会被赋予第二个变量$2

其他常用预定义变量

```shell
echo $PATH                  #命令搜索路径,冒号分隔符
echo $HOME                  #用户的家目录（~）
echo $COLUMNS               #命令行的长度
echo $HISTFILE              #命令历史文件
echo $HISTSIZE              #命令历史文件最大行数
echo $LOGNAME               #用户登录名
echo $TERM                  #终端类型
echo $TMOUT                 #shell自动退出时间，单位秒，设置为0则禁用shell自动退出
echo $PS1                   #主命令提示符，root是#，普通用户是$
echo $PS2                   #二级命令提示符，模式>，可根据需求更改
echo $MANPATH               #寻找手册的命令，冒号分隔
echo $LD_LIBRARY_PATH       #寻找库的命令，冒号分隔
echo $LANG                  #语言环境
echo $MAIL                  #邮件存放路径
```

## 变量赋值

1. 显示赋值

变量名=值

2. read从键盘读取变量值

read 变量名

read --help

* -p 在尝试读取之前输出 PROMPT
* -t 如果在 TIMEOUT 秒内没有读取一个完整的行则超时并且返回失败。
* -n 读取 nchars 个字符之后返回，而不是等到读取换行符

```sh
#! /bin/sh
read -p "name" name
echo $name

```

## 变量引用

* 单引号（''）是弱引用，变量会被禁止
* 双引号（""）是强引用，变量不会被禁止
* 反引号（``）是命令引用，等同于$(),反引号中的命令会先被执行。
* $var与${var}是没有区别的，但是用${}会比较精确的界定变量名称的范围。参数位置超过10个时，必须使用后一种

## 变量范围

* 变量分为全局变量和局部变量。局部变量用local声明，仅在代码块或函数中生效；全局变量不需要修饰词，默认，全局范围可见。

## 变量算术运算

* 整数运算使用expr，+(加) -(减) \*(乘) /(除) %(取余)
* 整数运算还可使用$(())、$[]、let

```shell
#! /bin/sh
num1=10
num2=5
echo "add=`expr $num1 + $num2`"
echo "subtract=`expr $num1 - $num2`"
echo "multiply=`expr $num1 \* $num2`"
echo "divide=`expr $num1 / $num2`"

i=2
let i=i+8
echo $i                     #统计循环计数

```

* 小数运算使用echo ""|bc，+(加) -(减) \*(乘) /(除) %(取余) 
* 小数运算还可以使用awk 'BEGIN{print 1/2}'，更灵活

```sh
echo "scale=2;1 + 2" |bc
awk 'BEGIN{print 1/2}'
```

## 变量“内容”匹配

```shell

var=/dir1/dir2/dir3/my.file.txt

echo ${#var}    　　　 　#获取变量长度(27)
echo ${var}    　　　 　 #获取变量值

# 变量替代
echo ${var-word}        #变量为null，则赋值wrod成功，变量非null，赋值失败，原变量值不变
echo ${var:-word}       #同${var-word}
echo ${var:=word}       #同${var-word}
echo ${var:+word}       #变量被赋值为word，不管变量null或非null

# 内容截取
echo ${var:0:5}         #提取最左边的 5 个字节(/dir1)
echo ${var:5:5}         #提取第 5 个字节右边的连续 5 个字节(/dir2)
echo ${var%?}           #去掉最后一个字符

# 内容替换
echo ${var/dir/path}    #将第一个 dir 提换为 path(/path1/dir2/dir3/my.file.txt)
echo ${var//dir/path}   #将全部 dir 提换为 path(/path1/path2/path3/my.file.txt)

# 内容匹配删除
echo ${var#*/}          #从前往后，最短匹配删除，模式*/表示匹配/和前面的内容，删除匹配的第1个/和前面的内容（dir1/dir2/dir3/my.file.txt）
echo ${var##*/}         #从前往后，最长匹配删除，模式*/表示匹配/和前面的内容，删除匹配额最后1个/和前面的内容（my.file.txt）
echo ${var%.*}          #从后往前，最短匹配删除，模式.*表示匹配.和后面的内容，删除匹配的第1个.和后面的内容（/dir1/dir2/dir3/my.file）
echo ${var%%.*}         #从后往前，最长匹配删除，模式.*表示匹配.和后面的内容，删除匹配的最后1个.和后面的内容（/dir1/dir2/dir3/my）


#i++和++i
i=1
let x=i++   #先赋值在运算
let y=++i   #选运算再赋值
echo $x #1
echo $y #3

```

## 数组变量“内容”匹配

```shell
A="a b c def"   # 定义字符串
A=(a b c def)   # 定义字符数组

echo ${A[@]}    #返回数组全部元素(a b c def)
echo ${A[*]}    #同上(a b c def)
echo ${A[0]}    #返回数组第一个元素(a)
echo ${#A[@]}   #返回数组元素总个数(4)
echo ${#A[*]}   #同上(4)
echo ${#A[3]}   #返回第四个元素的长度，即def的长度（3）
echo A[3]=xzy   #则是将第四个组数重新定义为（ xyz）
```
