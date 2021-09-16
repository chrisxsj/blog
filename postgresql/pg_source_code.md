# pg_source_code

**作者**

Chrisx

**日期**

2021-07-27

**内容**

pg源码结构介绍

ref [PostgreSQL Source Code Documentation](https://doxygen.postgresql.org/)

ref [PostgreSQL Source Code](https://github.com/postgres/postgres)

----

[toc]

## 第一级目录结构

进入PostgreSQL的源码目录后，第一级的结构如下表所示。在这一级里，通过执行如下命令configure;make;make install可以立即进行简单的安装，实际上从PostgreSQL源码安装是极为简单的。

文件目录	说明
COPYRIGHT	版权信息
GUNMakefile	第一级目录的 Makefile
GUNMakefile.in	Makefile 的雏形
HISTORY        修改历史
INSTALL        安装方法简要说明
Makefile	Makefile模版
README	        简单说明
aclocal.m4	config 用的文件的一部分
config/	config 用的文件的目录
configure	configure 文件
configure.in	configure 文件的雏形
contrib/	contribution 程序
doc/	        文档目录
src/	        源代码目录

## src目录

PostgreSQL 的src下面有。

文件目录	说明
DEVELOPERS	        面向开发人员的注视
Makefile	        Makefile 
Makefile.global	make 的设定值（从configure生成的）
Makefile.global.in	Configure使用的Makefile.global的雏形
Makefile.port	        平台相关的make的设定值，实际是一个到makefile/Makefile的连接. （从configure生成的）
Makefile.shlib	        共享库用的Makefile
backend/	        后端的源码目录
bcc32.mak	        Win32 ポート用の Makefile (Borland C++ 用)
bin/	                psql 等 UNIX命令的代码
include/	        头文件
interfaces/	        前端相关的库的代码
makefiles/	        平台相关的make 的设置值
nls-global.mk	        信息目录用的Makefile文件的规则
pl/	                存储过程语言的代码
port/	                平台移植相关的代码
template/	        平台相关的设置值
test/	                各种测试脚本
timezone/	        时区相关代码
tools/	                各自开发工具和文档
tutorial/	        教程
win32.mak	        Win32 ポート用の Makefile (Visual C++ 用) 