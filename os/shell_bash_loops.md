# shell_loops

**作者**

Chrisx

**日期**

2022-01-26

**内容**

shell循环结构

----

[toc]

## for循环控制

for是最简单的循环,遍历列表执行操作

```sh
for name in list    #name是变量。list值集合
do
    command              #执行与$name相关的操作
done

```

* for 每次从值集合中取一个值赋给变量
* do...done 将值带入命令得到结果
* 重复操作，直到得到所有结果，循环结束。

```sh
#! /bin/sh
dir=/opt
cd $dir
for k in $(ls $dir)
do
   [ -d $k] && du -sh $k
done

```

## while循环

允许代码段在某些条件为真时重复运行

```sh
while condition     #condition为真时，进入循环，否则退出
do
    statement
done

```

* while首先进行条件测试，如果传回值为真（0），则进入循环，否则退出。
* 如果条件一直为真，则进入死循环。

```sh
#! /bin/sh
declare -i i=1
declare -i sum=0
while ((i<=10))
do
   let sum=sum+1
   let i++
done
echo $sum
```

## until循环

until与while语句正好相反，当until条件测试为假（非0）则进入循环。

## 跳出循环

break       #跳出循环
continue    #继续循环
