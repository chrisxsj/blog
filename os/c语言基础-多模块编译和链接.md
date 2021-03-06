# c语言基础-多模块编译和链接

多模块编译和链接

---

[toc]

## c程序编译运行过程

### 编译运行过程

1. 源文件（.c）:源文件包括一些头文件，系统的标准头文件位置/usr/include,头文件对应函数库文件，系统标准函数库文件位置/usr/lib/*.so
2. 通过c编译器（gcc）
3. 目标文件（.o）+ 函数库+ 其他目标文件 + 针对不同系统启动代码
4. 链接器（linker）
5. 生成可执行文件

### 编译环境

c程序转换成特定平台可执行程序 需要经历以下阶段
预处理阶段>编译阶段>汇编阶段>链接阶段

```sh
1. 预处理阶段

* 将声明在头文件的内容加到生成的.i文件（文本）
* 删除注释
* 宏替换
* 条件编译

gcc -E -o src/example.i src/example.c

2. 编译阶段

将.i文件内容编译成汇编语言生成.s文件（文本）

gcc -S -o src/example.s src/example.i

3. 汇编阶段

将.s文件内容汇编成机器语言生成.O文件（二进制）

gcc -O -o obj/example.o -c src/example.s

4. 链接阶段

将.o文件链接生成可执行文件（二级制）

gcc -o bin/example obj/example.o

objdump反汇编，可对二进制文件反汇编
objdump -xd obj/example.o

通常直接将源文件编译成可执行文件，中间阶段会在缓存中完成。完成后被清理。
gcc -o bin/example src/example.c

```

### 运行环境

运行可执行程序的环境

## 多模块编译

多数软件会被分割成多个源文件，每个文件成为一个模块。

多模块软件设计
将大程序根据其功能划分成若干小模块。每个小模块均是一个源文件.c,单独存放，单独编译，分别形成.o目标文件。最后将这些.o目标文件链接成一个大的可执行程序。
多模块编译优缺点
优点：较小程序易于管理、维护。模块化编译
缺点：必须知道所有的文件，及文件的依赖性。需要跟踪所有文件修改时间戳。编译命令很长。

## 静态库和共享库

函数库

* 函数库，是系统预建立的具有一定功能的函数集合。
* linux中标准c函数库放在/usr/lib下。以文件形式存放。（.so、.a）
* 用户可以自己建立函数库
* 函数分为静态库（.a）和共享库（动态链接库）

库函数

* 存放在函数库中的函数
* 库函数源代码一般不可见，但在对应头文件中可以看到他的对外接口。

静态库概念

* 静态库是.o目标文件的集合。以.a结尾
* 静态库在程序链接时使用。链接器会将程序中使用的函数代码。从库文件中拷贝到可执行文件中。
* 由于使用静态库的程序需要拷贝所有代码，所以生成的可执行文件较大。

静态库创建

ar rcs /usr/lib库文件名.a 目标文件.o

静态库使用

gcc -o bin/可执行文件 -Iinclude src/源文件.c -Ldir -lname

gcc -o bin/mymath -Iinclude src/mymath.c -Llib -lmymath

* -Ldir 将指定库文件所在目录放入库搜索路径中。默认库搜索路径在/usr/lib中
* -lname (前缀lib不要加上，后缀.a不要加上)标识库搜索路径下的libname.a或libname.so。如果不是libname.a命名，则需要加上全名，如库名字为hello。a。则需要-lhello替换为-lhello.a
* 删除库文件不影响可执行文件执行，其已经被拷贝到可执行文件。

共享库的概念

* 共享库即动态链接库，linux中以.so（share object）后缀，windows中以.dll后缀
* 共享库链接时不需要拷贝所有函数代码，只是做标记。加载程序时，加载所需函数。（在内存中加载）
* 可执行程序运行时仍然需要共享库支持。
* 共享库链接出来的文件比静态库小得多
* 标准共享库位置/usr/lib

共享库创建

gcc -shared -fPCI -o lib库文件.so 目标文件.o

共享库使用

gcc -o bin/可执行文件 -Iinclude src/源文件.c -Ldir -lname

库文件找不到问题
cp libhello.so /usr/lib (root用户)
or
export LD_LIBRARY_PATH=库文件路径