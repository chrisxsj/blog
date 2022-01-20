# c语言基础-make和makefile

* make
* makefile

---

[toc]

## 概念

.c源文件可能由不同人员开发

makefile文件包括

1. 编译规则（gcc集合）
2. 依赖关系

makefile类似shell脚本，批量自动化执行gcc编译。
make是一个命令工具，能够解析执行makefile

## makefile编写规则

规则一（建议）

目标列表:关联性列表
<tab>命令列表

```makefile
powerrun:power.o compute.o
    gcc -o powerrun power.o compute.o
power.o:power.c
    gcc -o power.o power.c
compute.o:compute.c
    gcc -o compute.o compute.c

```

规则二

目标列表:关联性列表;命令列表

## makefile变量使用

简单变量

变量名:=[文本]  #定义
变量名+=[文本] 变量名:=[文本] [文本]    #添加

应用变量

$(变量名)
$单字符变量名

```makefile
c:=gcc
cflag:= -o
target:=powerrun
depend:=power.o
depend+=compute.o    
$target:$depend
    $c $(cflag) powerrun power.o compute.o
power.o:power.c
    $c $(cflag) power.o power.c
compute.o:compute.c
    $c $(cflag) compute.o compute.c

```

## makefile内置变量

使用内置变量会使您的工作更简单。

* $@ 目标列表
* $? 比目标列表更新的依赖性列表
* $< 依赖性列表i第一个文件
* $^ 所有依赖性列表

```makefile
c:=gcc
cflag:= -o
target:=powerrun
depend:=power.o
depend+=compute.o    
$target:$depend
    $c $(cflag) $@ $^
power.o:power.c
    $c $(cflag) $@ $<
compute.o:compute.c
    $c $(cflag) $@ $^

```

## 虚目标

clean 删除make all生成的所有文件

```makefile
c:=gcc
cflag:= -o
target:=powerrun
depend:=power.o
depend+=compute.o    
$target:$depend
    $c $(cflag) $@ $^
power.o:power.c
    $c $(cflag) $@ $<
compute.o:compute.c
    $c $(cflag) $@ $^

clean:
    rm -rf $(depend)

```

```sh
make clean -f makefilename
```

## 特殊目标

makefile中有一些预定义目标。

* .phony 允许指定一个不是文件的目标。声明虚目标

```makefile
c:=gcc
cflag:= -o
target:=powerrun
depend:=power.o
depend+=compute.o    
$target:$depend
    $c $(cflag) $@ $^
power.o:power.c
    $c $(cflag) $@ $<
compute.o:compute.c
    $c $(cflag) $@ $^

.PHONY:clean
clean:
    rm -rf $(depend)

```

## 默认模式规则

makefile默认规则

* %.o:%.c  将匹配到的所有.c编译成.o

```makefile
c:=gcc
cflag:= -o
target:=powerrun
depend:=power.o
depend+=compute.o    
$target:$depend
    $c $(cflag) $@ $^
%.o:%.c
    $c $(cflag) $@ $<
#compute.o:compute.c
#    $c $(cflag) $@ $^

.PHONY:clean
clean:
    rm -rf $(depend)

```
