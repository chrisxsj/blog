解决Linux NFS umount 'device is busy' and 'df -h' hang


公司开发、测试、准生产数据库的备份都是nfs挂载的nas盘和备份主机的本地磁盘，最近nas的权限做了调整后，导致nfs挂载点掉了。df -h看不到挂载的nas，并且导致操作hang住。
一、'df -h' hang
[root@develop119 ~]# df -h
文件系统 容量 已用 可用 已用% 挂载点
/dev/sda5 34G 10G 22G 32% /
/dev/sda7 76G 68G 4.1G 95% /oradata
/dev/sda3 34G 29G 2.9G 91% /u01
/dev/sda2 48G 24G 22G 52% /bakcup
/dev/sda1 145M 12M 126M 9% /boot
tmpfs 3.9G 0 3.9G 0% /dev/shm
192.168.101.119:/nfs_backup
197G 89G 99G 48% /bakcup/expdp_bk/dmp
这里df -h后，操作hang住，无法查看挂载点，查看/etc/fatab后，发现挂在的nfs磁盘丢失
 
解决办法：
查看挂载点：
[root@develop119 ~]# cat /proc/mounts
rootfs / rootfs rw 0 0
/dev/root / ext3 rw,data=ordered 0 0
/dev /dev tmpfs rw 0 0
/proc /proc proc rw 0 0
/sys /sys sysfs rw 0 0
/proc/bus/usb /proc/bus/usb usbfs rw 0 0
devpts /dev/pts devpts rw 0 0
/dev/sda7 /oradata ext3 rw,data=ordered 0 0
/dev/sda3 /u01 ext3 rw,data=ordered 0 0
/dev/sda2 /bakcup ext3 rw,data=ordered 0 0
/dev/sda1 /boot ext3 rw,data=ordered 0 0
tmpfs /dev/shm tmpfs rw 0 0
none /proc/sys/fs/binfmt_misc binfmt_misc rw 0 0
sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw 0 0
/etc/auto.misc /misc autofs rw,fd=7,pgrp=2854,timeout=300,minproto=5,maxproto=5,indirect 0 0
-hosts /net autofs rw,fd=13,pgrp=2854,timeout=300,minproto=5,maxproto=5,indirect 0 0
192.168.101.119:/nfs_backup /bakcup/expdp_bk/dmp nfs rw,vers=3,rsize=262144,wsize=262144,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=192.168.101.119 0 0
172.16.7.241:/db_bak /mnt nfs rw,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=172.16.7.241 0 0
发现nas盘的挂在目录是/mnt
umount挂载点
[root@develop119 ~]# umount -lf /mnt
[root@develop119 ~]# df -h
文件系统 容量 已用 可用 已用% 挂载点
/dev/sda5 34G 10G 22G 32% /
/dev/sda7 76G 68G 4.1G 95% /oradata
/dev/sda3 34G 29G 2.9G 91% /u01
/dev/sda2 48G 24G 22G 52% /bakcup
/dev/sda1 145M 12M 126M 9% /boot
tmpfs 3.9G 0 3.9G 0% /dev/shm
192.168.101.119:/nfs_backup
197G 89G 99G 48% /bakcup/expdp_bk/dmp
[root@develop119 ~]#
 
 
二、umount 'device is busy'
[root@mysql10 ~]# umount /mnt/
umount: /mnt: device is busy
umount: /mnt: device is busy
 
解决device is busy：
[root@mysql10 ~]# fuser -k /mnt/ --fuser 命令显示访问某个文件的进程的PID,-k 是kill 访问这个文件的进程。
[root@mysql10 ~]# umount /mnt/
[root@mysql10 ~]# df -h
Filesystem Size Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00
229G 111G 107G 51% /
/dev/sda1 99M 13M 82M 14% /boot
tmpfs 3.9G 0 3.9G 0% /dev/shm
 
 
三、重启nfs server端的portmap和nfs 后重新挂载
/etc/init.d/portmap restart 或者service portmap restart
/etc/init.d/nfs restart 或者service nfs restart
 
来自 <http://www.linuxidc.com/Linux/2013-12/93758.htm>
 
 
================================================
umount: 0506-349
 
如果一个文件系统打开了一个文件，那么必须在卸载之前将该文件关闭。例如：
# umount /home
umount: 0506-349 Cannot unmount /dev/hd1: The requested resource is busy.
如果显示umount busy
 
用如下命令
# fuser -x -c /home
/home: 11630
# ps -fp 11630
UID PID PPID C STIME TTY TIME CMD
guest 11630 14992 0 16:44:51 pts/1 0:00 -sh
# kill -1 11630
# umount /home
或者
终止使用给定文件系统的所有进程：
fuser -km /data
umount /data