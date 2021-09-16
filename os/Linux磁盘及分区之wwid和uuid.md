Linux磁盘及分区之wwid和uuid
背景描述，在Linux系统中，如果添加了新的SCSI磁盘或者映射SAN存储LUN操作，重启操作系统之后会出现磁盘标识符（sd*）错乱的情况。
例如之前添加的SAN存储LUN的磁盘标识符为/dev/sdd，重启之后发现变成/dev/sdh，特别是oracle RAC环境下我们是不希望出现这样的情况的。
解决这个问题之前，需要先搞清楚Linux系统中的wwid和uuid号。
一、wwid
根据SCSI标准，每个SCSI磁盘都有一个WWID，类似于网卡的MAC地址，要求是独一无二。
通过WWID标示SCSI磁盘就可以保证磁盘路径永久不变，Linux系统上/dev/disk/by-id目录包含每个SCSI磁盘WWID访问路径。
查看磁盘设备wwid方法1:
[root@rac01-node01 /]# ll /dev/disk/by-id/
total 0
lrwxrwxrwx. 1 root root 10 May 28 2017 dm-name-vg_rac01node01-LogVol01 -> ../../dm-0
lrwxrwxrwx. 1 root root 10 May 28 2017 dm-uuid-LVM-YWDtaD547sWxXQ2m9yF3Vl7gd42z61gqjQSRxV0GPavZDlE2D1dh26aPin6V59mz -> ../../dm-0
lrwxrwxrwx. 1 root root 9 May 27 19:01 scsi-360060160e2b0420004a53e678d42e711 -> ../../sdg
lrwxrwxrwx. 1 root root 9 May 27 19:01 scsi-360060160e2b04200c687b330c741e711 -> ../../sdh
lrwxrwxrwx. 1 root root 9 May 28 2017 scsi-3600605b00a8043c020b6bdd53057904d -> ../../sda
lrwxrwxrwx. 1 root root 10 May 28 2017 scsi-3600605b00a8043c020b6bdd53057904d-part1 -> ../../sda1
lrwxrwxrwx. 1 root root 10 May 28 2017 scsi-3600605b00a8043c020b6bdd53057904d-part2 -> ../../sda2
查看磁盘设备wwid方法2:
redhat7下获取WWID方式
2018年05月17日 10:23:09 kadwf123 阅读数：725
在 Linux 7下，可以使用如下命令：
# /usr/lib/udev/scsi_id -g -u /dev/sdb
在 Linux 6下，可以使用如下命令：
# /sbin/scsi_id -g -u /dev/sdb
在 Linux 5下，可以使用如下命令：
# /sbin/scsi_id -g -u -s /block/sdb/sdb
重启系统之后，如果要使磁盘标识符保持不变，需要对磁盘标识符和wwid做一个绑定，如下：
=======================================================================================
二、uuid
UUID是有文件系统在创建时候生成的，用来标记文件系统，类似WWID一样也是独一无二的。
因此使用UUID来标示SCSI磁盘，也能保证路径是永久不变的。Linux上/dev/disk/by-uuid可以看到每个已经创建文件系统的磁盘设备以及与/dev/sd*之间的映射关系。
查看文件系统uuid:
[root@rac01-node01 /]# ll /dev/disk/by-uuid/
total 0
lrwxrwxrwx. 1 root root 10 May 28 2017 3777-9E7C -> ../../sda1
lrwxrwxrwx. 1 root root 10 May 28 2017 414563cf-af5d-467a-bca9-81b8dad6e17f -> ../../dm-0
lrwxrwxrwx. 1 root root 10 May 28 2017 948ab5bc-f796-4f74-8cd5-84b6474d79ae -> ../../dm-1
lrwxrwxrwx. 1 root root 10 May 28 2017 9cbb7f73-582c-47e4-99d7-1c79fae90efc -> ../../sda2
重启系统之后，如果要使挂载的挂载的目录和文件系统绑定关系不变，在/etc/fstab里面应该使用uuid来标识，如下：
[root@rac01-node01 /]# cat /etc/fstab
# /etc/fstab
# Created by anaconda on Sun May 28 01:13:01 2017
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/vg_rac01node01-LogVol01 / ext4 defaults 1 1
UUID=9cbb7f73-582c-47e4-99d7-1c79fae90efc /boot ext4 defaults 1 2
UUID=3777-9E7C /boot/efi vfat umask=0077,shortname=winnt 0 0
/dev/mapper/vg_rac01node01-LogVol00 swap swap defaults 0 0
tmpfs /dev/shm tmpfs defaults 0 0
devpts /dev/pts devpts gid=5,mode=620 0 0
sysfs /sys sysfs defaults 0 0
proc /proc proc defaults 0 0
挂载文件系统之前，查看分区UUID，使用UUID mount文件系统时需要指定-t文件系统类型
[root@ca-mgmt ~]# blkid
/dev/vda1: UUID="d0bc3224-dfb4-4abd-9e04-91fe5af5c9b9" TYPE="xfs"
/dev/vda2: UUID="j7r6ci-03td-jY3T-nyKA-xI0t-9FK4-k3Bb1z" TYPE="LVM2_member"
/dev/mapper/rhel-root: UUID="a708a4d0-143e-46fe-8af9-1d5a2d330e2a" TYPE="xfs"
/dev/mapper/rhel-swap: UUID="4f927dbc-446e-49eb-939f-bc7790b823a4" TYPE="swap"
 
来自 <https://blog.csdn.net/kadwf123/article/details/80347052>