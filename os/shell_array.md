# shell_array

**作者**

Chrisx

**日期**

2022-02-14

**内容**

shell数组

----

[toc]

## 介绍

shell数组就是把有限个元素用一个名字命名，然后用编号对他们区分的元素集合。这个名字就是数组名；用于区分不同内容的编号称为数组下标；有限个元素称为数组元素。有了数组就可以引用一系列的变量。数组的本质是变量。是一种特殊的变量形式。

## 数组赋值

* array=(v1,v2,v3)   #用小括号将元素赋值给数组变量，用逗号隔开
* array=($(command)) #动态定义数组变量，命令输出结果作为数组内容

```sh
A=(a b c def)   # 定义数组
A=([0]=a [1]=b [3]=c [4]=def)   # 采用键值对定义数组
```

## 数组常用的变量

```shell
A=(a b c def)   # 定义字符数组
${A[IDX]}       # 通过索引匹配数组值

echo ${A[0]}    #第一个元素(a)
echo ${A[2]}    #第三个元素(c)
echo ${A[@]}    #返回数组全部元素(a b c def)
echo ${A[*]}    #同上(a b c def)
echo ${A[0]}    #返回数组第一个元素(a)
echo ${#A[@]}   #返回数组元素总个数(4)
echo ${#A[*]}   #同上(4)
echo ${#A[3]}   #返回第四个元素的长度，即def的长度（3）
```

## 数组替换

替换的对象是元素

```sh
B=(1 2 3 4 5)   # 定义数组

echo ${B[*]/2/boy}    #替换下标为2的元素为boy(1 boy 3 4 5)，类似sed


```

## 数组元素的删除

删除的对象是元素。使用最短匹配删除，最长匹配删除，

```sh
C=(/opt/one /opt/two /opt/three /opt/four /opt/five)

echo ${C[*]#*/}    #从开头最短匹配删除，每个元素删除匹配到的第一个/和前面的内容（opt/one opt/two opt/three opt/four opt/five）
echo ${C[*]##*/}    #从开头最长匹配删除，每个元素删除匹配到的最后一个/和前面的内容（one two three four five）
echo ${C[*]%/*}     #从末尾最短匹配删除，每个元素删除匹配到的第一个/和后面的内容（/opt /opt /opt /opt /opt）
echo ${C[*]%%/*}     #从末尾最长匹配删除，每个元素删除匹配到的最后一个/和后面的内容（）
```

## 数组截取

截取的对象是元素

${array_name[*]:offset:number}

* array_name  #数组名
* [*] #所有元素
* offset  #第几个元素，数组元素从0开始
* number  #元素的个数

```shell
B=(1 2 3 4 5)   # 定义数组

echo ${B[*]:1:3}    #从下标为1的元素开始，共截取3个元素(2 3 4)


```

## 数组遍历

```sh a.sh
#! /bin/bash
a=(a b c d 1 2 3 4)
for i in ${a[*]}
do
    echo $i
done
```

```sh b.sh
#! /bin/bash
b=(a b c d 1 2 3 4)
i=0
while [ $i -lt ${#b[*]} ]   #当变量小于数组长度
do
    echo ${b[$i]}   #输出第$i个元素
    let i++
done
```

## 关联数组

bash默认支持普通数组，也支持关联数组，但需要提前声明

声明关联数组

```sh
declare -A a    #将变量a声明为关联数组

```

赋值

```sh
a=([one]=xiaoming [two]=xiaohong)   #内嵌索引赋值
a[one]=xiaoming     #单独索引赋值
```

查询数组元素

```sh
declare -A a
a=([one]=xiaoming [two]=xiaohong)
a[three]=daxiong
echo ${a[*]}
```