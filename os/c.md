# c

c语言概述

[toc]

## 程序、算法和流程图

程序是计算机语言和人的语言的翻译者。为了让计算机执行某些操作而编写的一系列有序指令的集合。
程序主要由算法和数据结构组成
算法主要解决某些问题
数据结构主要处理相关数据。

算法是解决问题的具体方法和步骤。（如何计算长方形面积）
算法优劣由空间复杂度和时间复杂度来衡量
流程图是算法的一种图形化表示，有利于直观、清理表达算法

## c语言简介和简单c程序

机器语言，0和1
汇编语言，使用助记符号sub，依赖于硬件环境
高级语言，面向过程的语言，如c语言，处理复杂逻辑，用于内核层面、系统层面，如驱动
高级语言，面向对象的语言，如java、c++。用于大型应用系统程序。

c语言的起源和特点。

特点，自上而下结构，结构化编程，模块化设计。适合开发系统软件

基本结构

```c
#include <stdio.h>
int main(void)
{
    printf("hello world!\n");
    return 0;
}

/*
 * # include 预处理指令 ;<stdio.h> 头文件,将头文件包括的函数导入，自定义头文件用“”
 * 主函数main，返回类型为int，void表示不接受任何参数。
 * {}里面是函数体，每条语句以;结尾，return返回一个整形数值。0正常，非0，不正常状态。printf就是stdio.h里的标准输出函数。
 */

```

## 第一个c程序

```sh
$ cat hello_world.c
#include <stdio.h>
int main(void)
{
    printf("hello world!\n");
    return 0;
}

gcc -o hello_world hello_world.c

$ ./hello_world
hello world!
```

## 注释

/**/，多行注释
//，单行注释

多行注释可嵌套单行注释。单行可嵌套多行，多行不可嵌套多行

## 开发流程

* 分析问题
* 编写程序（源文件.c）
* 编译（目标文件.o）
* 链接（链接器将目标文件.o，生成可执行文件，格式为elf，二进制）
* 调试运行

## gcc

```sh
mkdir c
cd c
mkdir src bin obj include

src 主要存放c源文件
bin 存放可执行文件
obj 存放目标文件
include 存放自定义头文件

gcc -o bin/hello_world src/hello_world.c

gcc -o obj/hello_world.o -c src/hello_world.c
gcc -o bin/hello_world2 obj/hello_world.o

优化选项
-O1、-O2、-O3

```

## gdb

gdb调试程序
debug 程序。支持断点，逐行执行代码

调试的是可执行文件，而不是源文件

```sh
gcc -g -o bin/hello_world src/hello_world.c #-g加入调试信息
gdb bin/hello_world

标准输入scanf是键盘，标准输出printf是屏幕终端

l 28    #查看28行附件代码
r       #运行程序
b 28    #在28行处断点
info b  #查看断点
b main  #在函数main处断点
c       #继续运行
p size  #打印变量值
n       #单步运行，不进入此函数
s       #单步运行，进入此函数运行
quit    #退出
```

## c程序编译运行过程

编译运行过程

1. 源文件（.c）:源文件包括一些头文件，系统的标准头文件位置/usr/include,头文件对应函数库文件，系统标准函数库文件位置/usr/lib/*.so
2. 通过c编译器（gcc）
3. 目标文件（.o）+ 函数库+ 其他目标文件 + 针对不同系统启动代码
4. 链接器（linker）
5. 生成可执行文件

编译环境

c程序转换成特定平台可执行程序 需要经历以下阶段
预处理阶段>编译阶段>汇编阶段>链接阶段



1. 预处理阶段

gcc -E -o hello_world.i src/hello_world.c

运行环境

运行可执行程序的环境