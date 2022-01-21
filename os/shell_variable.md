# shell_variable

**作者**

Chrisx

**日期**

2021-06-21

**内容**

shell中环境变量操作。

----

[toc]



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

## export

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

## shell特殊变量

```shell
echo "$# parameters"    #(#)显示参数数量
echo "$@"               #顺序显示向脚本传递的参数
echo "$$"               #显示当前进程id号
echo "$?"               #显示最后命令退出状态，0表示没有错误，其他表示错误。
echo "$0"               #显示脚本名
echo "$1、2、3"         #位置参数，代表第1、2、3个参数
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