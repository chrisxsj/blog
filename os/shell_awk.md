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
awk [-F field-seperator] 'begin command end' input-files

```

* command是awk命令，begin，end可省略
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

printf参数介绍

| 参数  | 说明                                              |
| ----- | ------------------------------------------------- |
| %d    | 十进制有符号整数                                  |
| %u    | 十进制无符号整数                                  |
| %f    | 浮点数                                            |
| %s    | 字符串                                            |
| %c    | 单字符串                                          |
| %x    | 无符号十六进制整数                                |
| %o    | 无符号八进制整数                                  |
| %%    | 显示%自身                                         |
| #[.#] | 第一个数值显示宽度，.后面的数值显示小数点后的精度 |
| -     | 左对齐（默认右对齐）                              |
| +     | 显示数值的正负符号                                |

示例

```sh
awk '{print "hello"}' /etc/passwd
date |awk '{print "day: " $3 "\ntime: " $5}'



awk -F ":" '{printf "|%-15s| %-10s| %-15s\n",$1,$2,$3}' /etc/passwd
```

## awk运算符

| 运算符                  | 说明                             |
| ----------------------- | -------------------------------- |
| =,+=,-=,*=,/=,%=,^=,**= | 赋值                             |
| ?:                      | c条件表达式                      |
| \|\|                    | 逻辑或                           |
| &&                      | 逻辑与                           |
| ~,!~                    | 匹配正则表达式和不匹配正则表达式 |
| <,<=,>,>=,!=,==         | 关系运算                         |
| 空格                    | 连接                             |
| +,-,*,/,%               | 加减乘除和求余数                 |
| ^***                    | 幂运算                           |
| ++,--                   | 增加或减少前缀                   |
| $                       | 资源引用                         |
| in                      | 数组成员                         |

```sh
awk -F : '$1 ~ /^root/ {print $1,$4}' /etc/passwd  #以:分割域，$1，第1个域，匹配以root开头的，打印第1列和第4列
awk -F : '$3==2 {print $1,$3}' /etc/passwd  #第3列等于2的行，打印第1列和第3列
```

## awk变量

内置变量

| 参数           | 说明                                       |
| -------------- | ------------------------------------------ |
| ~和//          | 正则字符串匹配，表示匹配开始，中间是匹配值 |
| {IGNORECASE=1} | 忽略大小写                                 |
| !              | 匹配值取反                                 |
| \t             | 制表符                                     |
| \n             | 换行符                                     |
| $0             | 匹配所有域                                 |
| $1             | 匹配第1个字段（域）                        |
| $n             | 匹配第n个字段（域）                        |
| $NF            | 匹配最后一个字段（域）                     |
| ARGC           | 命令行参数的数目                           |
| ARGIND         | 命令行中当前文件位置（从0开始）            |
| ARGV           | 包含命令行参数数组                         |
| FS             | 字段分隔符                                 |
| OFS            | 输出字段分隔符                             |
| RS             | 记录分隔符                                 |
| ORS            | 输出记录分隔符                             |
| NF             | 一条记录字段的数目                         |
| NR             | 已经读出的记录数，就是行号，从1开始        |

```sh
awk -F : '$1 ~ /^root/ {print $1,$4}' /etc/passwd  #以:分割域，$1，第1个域，匹配以root开头的，打印第1列和第4列
awk '{IGNORECASE=1} /root/' /etc/passwd    #忽略大小写，输出包含root的行
awk '$0 !~ /^root/' /etc/passwd    #$0 匹配整行，不包括root开头的行
awk -F ":" '{print $NF}' /etc/passwd    #打印指最后一个域
awk -F ":" '{print $1"\t"$2}' /etc/passwd    #第一个域与第二个域之间加入制表符
awk '{print NR,FNR"\t" $1}' /etc/passwd    #输出行号
ls -atlr | awk '/root/{print $9}'
```

自定义变量，区分大小写

* 在'{}'前，使用-v配置变量。
* 引用外部变量使用gsub，替换变量

```sh
echo 2|awk -v a=1 -v b=2 '{print $1,$1+a+b}'    #设置变量a和b，使用

var=nice;echo 'hello world'|awk 'gsub(/hello/,"'"$var"'")'  #定义变量，然后gsub使用变量替换，变量引用需要使用单引号（"'""'"）、双引号(\"\")（依据gsub的引号格式）
```

## awk条件语句和循环

条件语句

```sh
放在BEGIN中

if (condition) 
    action1
else
    action2

放在{}中

{if (condition) else{ action}}
```

```sh

awk -F : 'BEGIN {
    n=10;
    if (n % 2 ==0) printf "%d 是偶数\n",n;
    else printf "%d 是奇数\n",n 
}'#判断奇偶数

awk -F : '{if($3==0){i++} else if($3>999){k++} else {j++}} END {print "管理员个数 "i;print "普通用户个数 "k;print "系统用户个数 "j}' /etc/passwd  #条件判断
```

循环语句

for、while、break、exit、next均支持

```sh
for (variable;condition;iteration process)
{
    statement1
    ...
}


```

```sh
awk 'BEGIN { for (i=1;i<=5;i++) print i }'
```

## awk函数

awk有很多内建函数，也支持用户自定义函数。

常用内建函数

| 函数               | 说明                                                                         |
| ------------------ | ---------------------------------------------------------------------------- |
| random()           | 返回0和1之间一个随机数                                                       |
| srand()            | 生成随机数种子                                                               |
| int()              | 取整数                                                                       |
| length([s])        | 返回指定字符串长度                                                           |
| sub(r,s,[t])       | 对t字符串搜索，r表示匹配的内容，将第一个匹配的内容替换为s                    |
| gsub(r,s,[t])      | 对t字符串搜索，r表示匹配的内容，将第全部匹配的内容替换为s                    |
| split(s,array,[r]) | 以r为分隔符，切割字符串s，将切割后的结果保存到数组array，数组索引下标从1开始 |
| substr(s,i,[n])    | 取子字符串，对字符串s，从i开始，取n个字符                                    |
| systime()          | 取当前系统时间                                                               |
| system()           | 调用shell命令                                                                |

自定义函数

```sh
function name (arg1,arg2,...) {
    statements
    return expr
}

```

## awk脚本

脚本格式

```sh
#! /bin/awk -f
BEGIN{} {} END{}

```

* BEGIN{},需要大写，存放执行前的语句
* {}，执行的命令
* END{}，执行完成后的语句

示例

```sh
cat score

Marry,11,88,84,77
Lisa,12,99,94,95
Jack,15,66,67,68
Tom,21,68,69,82
Mike,23,78,84,90

#! /bin/awk -f
# cal.awk
BEGIN {
    math=0
    eglish=0
    computer=0
    printf "NAME NO. MATH ENGLISH COMPUTER TOTAL \n"
    printf "-----------------------------------------------------\n"
} 
{
    math+=$3
    english+=$4
    computer+=$5
    printf "%-6s %-6d %6d %6d %6d %8d\n",$1,$2,$3,$4,$5,$3+$4+$5
} 
END {
    printf "-----------------------------------------------------\n"
    printf " TOTAL:%10d %8d %8d \n",math,english,computer
    printf " AVERAGE:%10.2f %8.2f %8.2f \n",math/NR,english/NR,computer/NR
}

awk -F "," -f cal.awk score 

```

## awk数组

```sh
array[index]=value  #数组语法
array[index]    #访问数组语法

awk -F ":" '{username[i++]=$1} END{print username[0]}' /etc/passwd  #将第一列的值赋予数组，读取第0个数组值
awk -F ":" '{username[i++]=$1} END{print username[1]}' /etc/passwd  #将第一列的值赋予数组，读取第1个数组值
awk -F ":" '{username[x++]=$1} END{for (i=0;i<x;i++) print i,username[i]}' /etc/passwd #遍历数组
```

