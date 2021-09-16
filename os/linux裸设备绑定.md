在linux下，如果要建立Oracle可以使用的裸设备，需要使用raw命令，将块设备绑定为字符类型。
[root@yangtk2 dev]# raw /dev/raw/raw1 /dev/sdb
/dev/raw/raw1: bound to major 8, minor 16
[root@yangtk2 dev]# raw -qa
/dev/raw/raw1: bound to major 8, minor 16
[root@yangtk2 dev]# ls -l /dev/raw
total 0
crw------- 1 root root 162, 1 Nov 8 08:14 raw1
现在已经建立了裸设备，如果要取消这个裸设备的绑定，可以重建绑定这个裸设备到0 0。
[root@yangtk2 dev]# raw /dev/raw/raw1 0 0
/dev/raw/raw1: bound to major 0, minor 0
[root@yangtk2 dev]# raw -qa
[root@yangtk2 dev]# ls -l /dev/raw
ls: /dev/raw: No such file or directory