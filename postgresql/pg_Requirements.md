# pg_Requirements

**作者**

Chrisx

**日期**

2021-11-29

**内容**

PostgreSQL支持的平台

ref [Requirements](https://www.postgresql.org/docs/13/install-requirements.html)

---

[toc]

## 需求

一般说来，一个现代的与 Unix 兼容的平台应该就能运行PostgreSQL。

### 编译pg必须的软件包

* 要求GNU make版本3.80或以上；
* 编译器GCC
* 解包tar或者gzip和bzip2
* 默认时将自动使用GNU Readline库。它允许psql（PostgreSQL的命令行 SQL 解释器）记住你输入的每一个命令并且允许你使用箭头键来找回和编辑之前的命令。需要readline和readline-devel两个包。如果你不想用它，那么你必需给configure声明--without-readline选项。libedit库是GNU Readline兼容的， 如果没有发现libreadline或者configure使用了--with-libedit-preferred选项，都会使用这个库。
* 默认的时候将使用zlib压缩库。 如果你不想使用它，那么你必须给configure声明--without-zlib选项。使用这个选项关闭了在pg_dump和pg_restore中对压缩归档的支持。

必须软件包

```sh
rpm -q make gcc gzip readline readline-devel zlib zlib-devel
check
make --version
which make tar gzip
yum install make gcc gzip readline* zlib*

```

:warning: suse参考[suse_readline](../os/suse_readline.md)

<!--
Ubuntu参考
dpkg -l make gcc gzip readline readline-devel zlib zlib-devel
apt-get install make 
apt-get install gcc 
apt-get install gzip 

需要先安装libreadline-gplv2-dev(代替readline，readline-devel )
apt-get install libreadline-gplv2-dev

在ubuntu软件源里zlib和zlib-devel叫做zlib1g zlib1g.dev 直接输命令后还是不能安装。这就要求我们先装ruby. 默认的安装源里没有zlib1g.dev。要在packages.ubuntu.com上找。
apt-get install ruby
apt-get install zlib1g  
apt-get install zlib1g-dev

dpkg -l make gcc gzip readline readline-devel zlib zlib-devel

-->

### 编译pg可选的软件包

* 要编译服务器端编程语言PL/Perl，你需要一个完整的 Perl安装，包括libperl 库和头文件。 所需的最低版本是Perl 5.8.3。
* 要编译服务器端编程语言PL/Perl，你需要一个完整的 Perl安装，包括libperl 库和头文件。 所需的最低版本是Perl 5.8.3。
* 要编译服务器端编程语言PL/Perl，你需要一个完整的 Perl安装，包括libperl 库和头文件。 所需的最低版本是Perl 5.8.3。
* 要打开本地语言支持（NLS），也就是说， 用英语之外的语言显示程序的消息，你需要一个Gettext API的实现。有些操作系统内置了这些（例如Linux、NetBSD、Solaris）， 对于其它系统，你可以从http://www.gnu.org/software/gettext/下载一个额外的包。
* 如果您想支持加密的客户端连接，则需要OpenSSL。最低要求的版本是0.9.8。
* 如果你想支持使用Kerberos、OpenLDAP和/或PAM服务的认证，那你需要相应的包。
......
完整列表ref[Requirements](https://www.postgresql.org/docs/13/install-requirements.html)

可选的软件包

```sh
rpm -q perl python tcl OpenSSL Kerberos OpenLDAP
yum install perl python tcl openssl openssl-devel kerberos openldap #可选

```

### 磁盘空间

source tree: 100 MB
installation directory: 20MB
empty database cluster: 35MB
databases: 大约是具有相同数据的平面文本文件的五倍

## 平台支持

支持的平台信息参考[supported-platforms](https://www.postgresql.org/docs/13/supported-platforms.html)

通常，PostgreSQL被期望能在这些 CPU 架构上工作：x86、 x86_64、IA64、PowerPC、PowerPC 64、S/390、S/390x、Sparc、Sparc 64、ARM、MIPS、MIPSEL和PA-RISC。存在对 M68K、M32R 和 VAX 的代码支持，但是这些架构上并没有近期测试的报告。通常也可以在一个为支持的 CPU 类型上通过使用--disable-spinlocks配置来进行编译，但是性能将会比较差。

PostgreSQL被期望能在这些操作系统上工作： Linux（所有最近的发布）、Windows（Win2000 SP4及以上）、 FreeBSD、OpenBSD、NetBSD、macOS、AIX、HP/UX 和 Solaris。其他类 Unix 系统可能也可以工作，但是目前没有被测试。

已经明确测试过的平台的列表 参考[members](https://buildfarm.postgresql.org/cgi-bin/show_members.pl)

CentOS
7.3
w.e.f. 2017-10-06: CentOS 7.4
w.e.f. 2017-10-10: 7.4
w.e.f. 2018-05-11: 7.5
w.e.f. 2018-12-03: 7.6
w.e.f. 2019-10-24: 7.7
w.e.f. 2020-05-21: 7.8
w.e.f. 2020-11-13: 7.9.2009

gcc
4.8.5

x86_64 (virtualized)
