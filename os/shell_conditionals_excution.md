# shell_conditionals_excution

**作者**

Chrisx

**日期**

2022-01-26

**内容**

shell条件测试

----

[toc]

## 条件测试



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

<!--
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

# 跳出循环
break       #跳出循环
continue    #继续循环


command | while read line

do

    …

done

如果你还记得管道的用法，这个结构应该不难理解吧。command命令的输出作为read循环的输入，这种结构常用于处理超过一行的输出，当然awk也很擅长做这种事
-->


## 其他

```shell
#! /bin/bash




# 退出状态
# 函数及命令退出状态用0表示成功，非0表示失败。
# 内置变量$?可以返回上一条语句的退出状态。
# 退出状态值
0       #成功
>0      #失败
126     #命令找到，但无法执行
127     #命令无法找到
>128    #命令收到信息死亡


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

```
