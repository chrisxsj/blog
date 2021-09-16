# suse_redline

**作者**

Chrisx

**日期**

2021-04-23

**内容**

suse安装readline-devel
suse12

---

[toc]

## 安装包需求

suse上安装postgresql，编译安装时需要以下的软件包。

* make
* gcc
* gzip
* readline
* readline-devel
* zlib
* zlib-devel

## 安装需求的软件包

配置本地源，进行安装。

```sh
zypper install make gcc gzip zlib-devel
zypper install readline

'readline' not found in package names. Trying capabilities.
'libreadline6' providing 'readline' is already installed.

zypper install readline-devel

'readline-devel' not found in package names. Trying capabilities.
No provider of 'readline-devel' found.

```

安装readline-devel时，报错readline-devel没有找到。Readline可以使用或不使用

Readline作用：
默认情况下使用GNU Readline库。它允许psql（PostgreSQL命令行SQL解释器）记住您键入的每个命令，并允许您使用箭头键调用和编辑以前的命令。这是非常有用的，强烈建议。如果不想使用它，则必须指定--without readline选项进行配置。

<!--
zypper if make gcc gzip readline readline-devel zlib zlib-devel

Name           : gzip
Installed      : Yes (automatically)

package 'readline' not found.

package 'readline-devel' not found.

package 'zlib' not found.
Builds binary package :
    S | Name        | Version
    --+-------------+------------
    i | libz1       | 1.2.11-1.27
    i | libz1-32bit | 1.2.11-1.27
      | zlib-devel  | 1.2.11-1.2

'zlib' not found in package names. Trying capabilities.
'libz1' providing 'zlib' is already installed.

Name           : zlib-devel
Status         : not installed

-->

## 不使用readline

编译时指定参数--without readline

## 使用libedit代替

libedit库与GNU Readline兼容，如果找不到libreadline，或者使用--with-libedit-preferred作为配置选项，则使用libedit库。

## 安装readline-devel

为了使用readline，需要单独下载,请注意您需要readline和readline-devel两个包，如果它们在您的发行版中是分开的。

如：

libreadline6-6.3-83.15.1.x86_64
readline-devel-6.3-83.15.1.x86_64.rpm

> 在suse中readline可以用libreadline代替

1. 查看已经安装的readline版本

```sh
# ls -atl libreadline6* #iso查看
libreadline6-32bit-6.3-83.15.1.x86_64.rpm  libreadline6-6.3-83.15.1.x86_64.rpm
# rpm -qa |grep readline #rpm查看
libreadline6-6.3-83.15.1.x86_64
readline-doc-6.3-83.15.1.noarch

```

2. 下载对应版本的readline-devel并安装

[readline-devel-6.3x](https://opensuse.pkgs.org/15.2/opensuse-oss-x86_64/readline6-devel-6.3-lp152.3.6.x86_64.rpm.html)

```sh
zypper install readline6-devel-6.3-lp152.3.6.x86_64.rpm

```

必要时创建软连接使用

```sh
cd /lib64
ln -s libreadline.so.6.3 libreadline.so

```

## 问题

安装readline-devel时，存在依赖ncurses-devel。

解决方案：

安装readline-devel前，需要先安装ncurses-devel

```sh
zypper in ncurses-devel
```
