# lvm-linux


**作者**

Chrisx

**日期**

2021-09-02

**内容**

linux上配置lvm

----

[toc]

基于linux的lvm
LVM———Logical Volume Manager(逻辑卷管理器)的简写。LVM可以帮助我们为应用与用户方便地分配存储空间。在LVM管理下的逻辑卷可以按需改变大小或添加移除。LVM也允许按用户组对存储卷进行管理，允许管理员用更直观的名称(如"sales', 'development')代替物理磁盘(如'sda', 'sdb')来标识存储卷。

linux lvm配置过程参考如下

## 1. 修改id（lvm格式）

fdisk 分区成功后，更改分区类型为lvm

```shell
[root@localhost ~]# fdisk /dev/sdb
Command (m for help): t
Partition number (1-6): 6
Hex code (type L to list codes): 8e
Changed system type of partition 6 to 8e (Linux LVM)
Command (m for help): w

```

或者

parted成功后，需要更改分区类型，改为LVM

```shell
parted /dev/sdb
GNU Parted 3.1
使用 /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted)

(parted) p
Model: AVAGO AVAGO (scsi)
Disk /dev/sdb: 4495GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name     标志
 1      1049kB  4494GB  4494GB  xfs          primary

（parted）toggle 1 lvm  #使用toggle 更改硬盘类型

```

## 2 创建pv

```shell
[root@www ~]# pvcreate /dev/hda{6, 7, 8, 9}
[root@www ~]# pvscan

```

更详绅的列示出系统上面每个 PV 的个别信息:

```shell
[root@www ~]# pvdisplay

```

## 3 将 /dev/hda6-8 建立成为一个 VG, 指定 PE 为512MB

```shell
[root@www ~]# vgcreate -s 512M highgovg /dev/hda{6, 7, 8} /dev/hdb1

```

信息查看

```shell
[root@www ~]# vgscan
[root@www ~]# pvscan
[root@www ~]# vgdisplay
[root@www ~]# vgextend vbirdvg /dev/hda9

```

## 4 将整个 vbirdvg分配给 vbirdlv

指定PE的方式。要注意, PE 共有 356 个。

```shell
[root@www ~]# lvcreate -l 356 -n vbirdlv vbirdvg

```

或者

指定大小的方式

```shell
# lvcreate -L 5.56G -n vbirdlv vbirdvg

```

查看

```shell
[root@www ~]# ll /dev/vbirdvg/vbirdlv
lrwxrwxrwx 1 root root 27 Mar 11 16:49 /dev/vbirdvg/vbirdlv ->/dev/mapper/vbirdvg-vbirdlv
[root@www ~]# lvdisplay

```

> 要特别注意的是, VG 的名称为 vbirdvg , 但是 LV 的名称必项使用全名!  后续的处理都是这样的! 这点刜次接触 LVM 的朋友容易搞错!

## 5 创建文件系统和挂载

查看文件系统类型

```shell
cat /etc/fstab

```

创建文件系统

```shell
[root@www ~]# mkfs -t xfs /dev/vbirdvg/vbirdlv <==注意 LV 全名!

```

创建挂载点并挂载

```shell
[root@www ~]# mkdir /mnt/lvm
[root@www ~]# mount /dev/vbirdvg/vbirdlv /mnt/lvm
[root@www ~]# df -h

```

> 注意，挂载后修改/dev/fstab！自动挂载

## 6 卸载

将 vbirdss 卸除幵移除 (因为里面的内容已经备仹起杢了)

```shell
[root@www ~]# umount /mnt/snapshot
[root@www ~]# lvremove /dev/vbirdvg/vbirdss
[root@www ~]# vgremove raidvg
[root@www ~]# pvremove /dev/md0
[root@www ~]# mdadm --stop /dev/md0
[root@www ~]# fdisk /dev/hda

```

> 注意，清理fstab！

## 在线动态扩展文件系统

```shell
lvextend -l +100 /dev/highgovg/hgsflv   --pe
lvextend -L +50G /dev/highgovg/hgsflv   --size

```

最后要使用resize2fs命令重新加载逻辑卷的大小才能生效 

```shell
resize2fs  /dev/highgovg/hgsflv

```

## 其他命令

```shell
[root@pgha2 ~]# lvs
  LV   VG   Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root rhel -wi-ao---- 45.80g                                                    
  swap rhel -wi-ao----  4.00g                                                    
[root@pgha2 ~]# vgs
  VG   #PV #LV #SN Attr   VSize  VFree
  rhel   1   2   0 wz--n- 49.80g    0

```
