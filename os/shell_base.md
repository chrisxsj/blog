# shell base

```shell
#! /bin/bash

alias mv="mv -i"        #mv进行提示

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
