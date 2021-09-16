# Linux 导入导出卷组

原来是这样，看来需要先激活卷组，才可以。

```bash
Suse-linux:~ # vgdisplay
  --- Volume group ---
  VG Name               dataspace
  System ID
  Format                lvm2
  Metadata Areas        5
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                5
  Act PV                5
  VG Size               4.98 GiB
  PE Size               4.00 MiB
  Total PE              1275
  Alloc PE / Size       1275 / 4.98 GiB
  Free  PE / Size       0 / 0
  VG UUID               WSZQVa-oiDI-9JEv-P03w-iKBr-ur3w-EoFRuK
Suse-linux:~ # vgchange -a y dataspace
  1 logical volume(s) in volume group "dataspace" now active
Suse-linux:~ # lvdisplay
  --- Logical volume ---
  LV Name                /dev/dataspace/db2
  VG Name                dataspace
  LV UUID                MvSeQH-TnNJ-WOX5-0Ga2-aLBa-WFS5-6ZFAjm
  LV Write Access        read/write
  LV Status              available
  # open                 0
  LV Size                4.98 GiB
  Current LE             1275
  Segments               5
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     1024
  Block device           253:0
  

```  
  
磁盘在系统间移动
当磁盘在系统间移动的时候，除了需要停用激活卷组外，还需要执行卷组导出 / 倒入的操作。
清单 16. 导出卷组

* 停用卷组：
Linux:~# vgchange – a n /dev/system
     0 logical volume(s) in volume group “system” now active
* 导出卷组
Linux:~# vgexport /dev/system
Volume group “system” successfully exported

此时就可以将磁盘移动到其他系统。
清单 17. 导入并激活卷组

* 扫描 PV
Linux:~# pvscan
PV /dev/sdc      is in exported VG system [2.00 GB / 96.00 MB free]
Total: 1 [2.00 GB] / in use: 1 [2.00 GB] / in no VG: 0[0  ]

* 导入 VG
Linux:~# vgimport /dev/system
Volume group “system” successfully imported

* 激活卷组
Linux:~# vgchange – a y /dev/system
     1 logical volume(s) in volume group “system” now active

到此，卷组就可以恢复正常了。某些卷组可能是跨多块磁盘建立的，而磁盘移动可能只是针对其中的某些磁盘。在这种情况下，可以执行 pvmove 命令，把数据移动到指定磁盘上，然后针对
指定磁盘执行移动操作。
