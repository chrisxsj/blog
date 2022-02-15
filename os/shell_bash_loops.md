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

## 循环控制

* break n      #n表示跳出循环次数，n省略则跳出整个循环
* continue n   #n表示退到第n层循环，n省略表示跳过本次循环，进入下一次循环
* exit n  #表示退出当前shell程序，并返回n，n可省略
* return  #用于返回一个退出值给调用的函数
* shift   #用于将参数列表list左移指定的次数，最左端的参数会被删除，后面的参数进入循环。

break示例

```sh
#! /bin/sh
for ((i=0;i<=5;i++))
    do
    if [ $i -eq 3 ];then
        break;
    fi
    echo $i
    done
echo "ok"
```

continue示例

```sh
#! /bin/sh
for ((i=0;i<=5;i++))
    do
    if [ $i -eq 3 ];then
        continue;
    fi
    echo $i
    done
echo "ok"
```