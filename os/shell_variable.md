# shell_variable

**作者**

Chrisx

**日期**

2022-01-26

**内容**

shell变量是用固定的字符串标识不固定的内容。

shell变量类型包括自定义变量、环境变量、位置变量、预定义变量

----

[toc]

## 自定义变量

* 定义变量。变量本质是个键值对，变量名=值，两边不要有空格。
  * 变量名必须以字母或下划线开头；
  * 变量可以为空值（echo $var），值包含空格时需要加引号
  * 变量分为全局变量和局部变量。局部变量用local声明，仅在代码块或函数中生效；全局变量不需要修饰词，默认，全局范围可见。
  * 变量仅对当前shell生效
* 引用变量。
  * 查看变量：echo $变量名。或者使用printf $变量名
  * 取消变量：unset $变量名
  * $var和${var},$var是缩写形式
  * 单引号（''）是弱引用，变量会被禁止;双引号（""）是强引用，变量不会被禁止

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

## 位置变量

${123456789(10)},代表第几个变量

使用示例：

创建loc.sh

```sh
#! /usr/bin/sh
echo "第二个位置变量 $2"
echo "第一个位置变量 $1"
echo "第四个位置变量 $4"
```

运行

```sh
bash loc.sh 1 2 3 4 5
第二个位置变量 2
第一个位置变量 1
第四个位置变量 4
```

1会被赋予第一个变量$1；2会被赋予第二个变量$2

## 预定义变量

```shell
echo "$0"               #显示脚本名
echo "$*"               #显示所有参数，将所有参数作为一个整体显示
echo "$@"               #显示所有参数，将所有参数分开显示
echo "$?"               #显示最后命令退出状态，0表示没有错误，其他表示错误。
echo "$# parameters"    #(#)显示参数个数
echo "$$"               #显示当前进程id号
echo "$1、2、3"         #位置参数，代表第1、2、3个参数
```

## 变量查看

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

## 变量运算符

```shell
一般情况下，$var与${var}是没有区别的，但是用${}会比较精确的界定变量名称的范围。参数位置超过10个时，必须使用后一种
echo $AB      #表示变量AB
echo ${A}B    #表示变量A后连接着B

# 命令替换
echo `pwd`      #将命令输出字符传递给echo
```

## 变量算术运算,整数

```shell
echo `expr $num1 + $num2`            #适用于整数运算，+(加) -(减) *(乘) /(除) %(取余)  
echo "scale=2;$num1 + $num2" |bc     #适用于整数和小数运算，+(加) -(减) *(乘) /(除) %(取余)  
echo "$us $sy" |awk "{print int($us+$sy)}"  #适用于整数，小数等。更灵活，建议使用

i=2
let i=i+8
echo $i                     #统计循环计数
```

## 变量替换运算符

```shell
var=/etc/ssh/ssh_config
echo ${var:-word}       #变量存在且非null，返回变量值，否则返回word（用于如果变量不存在，则返回默认值）
echo ${var:=word}       #变量存在且非null，返回变量值，否则将变量设置为word（用于如果变量不存在，则设置为默认值）
echo ${var:?word}       #变量存在且非null，返回变量值，否则打印word并退出脚本（用于捕捉变量未定义造成的错误）
echo ${var:+word}       #变量存在且非null，返回word，否则返回null（用于测试变量是否存在）
```

## 变量匹配运算符

```shell
var=/dir1/dir2/dir3/my.file.txt
echo ${var#*/}          #模式*/表示匹配/和前面的内容，从变量取值开头处，删除第1个/和前面的内容（dir1/dir2/dir3/my.file.txt）
echo ${var##*/}         #模式*/表示匹配/和前面的内容，从变量取值开头处，删除最后1个/和前面的内容（my.file.txt）
echo ${var%.*}          #模式.*表示匹配.和后面的内容，从变量取值结尾处，删除第1个.和后面的内容（/dir1/dir2/dir3/my.file）
echo ${var%%.*}         #模式.*表示匹配.和后面的内容，从变量取值结尾处，删除最后1个.和后面的内容（/dir1/dir2/dir3/my）
#一个符号是最小匹配，两个符号是最大匹配。指定字符分隔号，与*配合，决定取哪部分

echo ${var%?}           #去掉最后一个字符

```

## 变量取子串及替换

```shell
var=/dir1/dir2/dir3/my.file.txt
echo ${var:0:5}         #提取最左边的 5 个字节(/dir1)
echo ${var:5:5}         #提取第 5 个字节右边的连续 5 个字节(/dir2)
echo ${var/dir/path}    #将第一个 dir 提换为 path(/path1/dir2/dir3/my.file.txt)
echo ${var//dir/path}   #将全部 dir 提换为 path(/path1/path2/path3/my.file.txt)
echo ${#var}    　　　 　#获取变量长度(27)     
```

## 数组变量操作

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



## shell常用变量

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