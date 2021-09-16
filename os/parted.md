# parted

**作者**

Chrisx

**日期**

2021-09-02

**内容**

linux上使用parted分区

----

[toc]

## 介绍

fdisk分区格式为MBR，不支持创建GPT分区，
parted支持创建GPT分区，GPT支持大于2TB分区

介绍2种分区表：
MBR分区表：（MBR含义：主引导记录）
所支持的最大卷：2T （T; terabytes,1TB=1024GB）
对分区的设限：最多4个主分区或3个主分区加一个扩展分区。

GPT分区表：（GPT含义：GUID分区表）
支持最大卷：18EB，（E：exabytes,1EB=1024TB）
每个磁盘最多支持128个分区

所以如果要大于2TB的卷或分区就必须得用GPT分区表。

## 使用

下面是用parted工具对/dev/sda做GPT分区的过程

```sh
# parted /dev/sda

GNU Parted 2.3
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
 
(parted) mklabel gpt
Warning: The existing disk label on /dev/sda will be destroyed and all data on this disk
will be lost. Do you want to continue?
Yes/No? yes
   
(parted) mkpart primary 1MB 1024GB
(parted) mkpart second 1024Gb 2048GB

or

(parted) mkpart
name? gispart
type?  ext3
start? 1
end? 2048GB
quit

删除用
rm
1

```

fdisk工具用的话，会有下面的警告信息

```sh
WARNING: GPT (GUID Partition Table) detected on '/dev/sda'! The util fdisk doesn't support GPT. Use GNU Parted.
```