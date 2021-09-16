Aix lvm



1 逻辑卷管理（LUM）概念
pv( physical volumes):物理卷，独立的硬盘,并有一个名字(如hdisk0)
vg(volume group):卷组,包括pv
pp(physical partation):物理分区，一个VG中的PV被分为相同大小的物理分区(PP)
lv(logical volumes):逻辑卷
每个VG中可以定义一个或多个逻辑卷(LV),LV是位于PV上的信息的组合,在LV上的数据可以连续或者不连续地出现在PV
lp（logical partation）： LV包含一个或多个逻辑分区，
每个LV相当至少一个PP,如果对LV指定了镜象,就要有双倍的PP被分配用来存储每个LP的备份
LV可以提供许多系统需要的服务(如页面空间),但是每个存储了一般系统/用户数据或程序的LV都包含一个单独的日志式的文件系统(JFS),每个JFS包含一群页面大小(4K)的块.AIX4.1以后,一个给出的文件系统可以被定义为拥有小于4k的片断.系统安装完毕后,有一个VG(rootvg),包含一套系统启动的基本的LV和其它在安装脚本中指定的VG.
2 逻辑卷管理器
操作系统命令/库子程序/其它工具允许建立和控制LV存储,成为逻辑卷管理器(LVM).LVM通过简单而灵活地在存储空间的逻辑视图和实际物理盘之间映射来管理磁盘资源.
3 PV配置: 三种方法
一个新盘必须被配置为PV才可使用.可以通过指派一个PVID使一个磁盘变为一个PV:chdev -l hdisk1 -a pv=yes.这个命令对于已经是PV的磁盘没有影响.
删除pv
如果一个PV可以从系统删除,那么它必须是没有配置的.使用rmdev命令把hdisk1的状态从available改变到defined状态:rmdev -l hdisk1.此后,该PV的定义将仍然保留在ODM中,如果加上-d参数,则从ODM中删除.
===============================================
# lsvg -o
--vg
# smit
> System Storage Management (Physical & Logical Storage)
> Logical Volume Manager
> Volume Groups
> Add a Volume Group
Move cursor to desired item and press Enter.
Add an Original Volume Group
Add a Big Volume Group
Add a Scalable Volume Group
Add a Scalable Volume Group
VOLUME GROUP name []
Physical partition SIZE in megabytes
* PHYSICAL VOLUME names []
Activate volume group AUTOMATICALLY at system restart? yes
--lv
# smit
> System Storage Management (Physical & Logical Storage)
> Add a Logical Volume
> Logical Volumes
> Add a Logical Volume
[Entry Fields]
Logical volume NAME [data]
* VOLUME GROUP name newdatavg
* Number of LOGICAL PARTITIONS [4000]
PHYSICAL VOLUME names []
Logical volume TYPE [jfs2]
--fs
# smit
> System Storage Management (Physical & Logical Storage)
>File Systems
＞　Add / Change / Show / Delete File Systems
＞　Enhanced Journaled File Systems
＞　Add an Enhanced Journaled File System on a Previously Defined Logical Volume
* LOGICAL VOLUME name
* MOUNT POINT []
Mount AUTOMATICALLY at system restart? yes
--mount point
# smit fs
Change / Show Characteristics of an Enhanced Journaled File System
File system name /bak
NEW mount point [/bak]
==========================================
更改lv or fs 文件系统大小
chfs -a size=+100G /oradata
查看lv属性
smit chlv
Change a Logical Volume
MAXIMUM NUMBER of LOGICAL PARTITIONS [512]
=================================================
手动挂在vg
varyonvg -f datavg
--发现裸盘
cfgmgr -v
rmdev -Rdl hdisk10 --删除设备
lsdev -Cc disk --查看设备可用
lspv
--查看裸盘大小
在AIX下可以通过getconf命令去得到裸盘的容量大小（MB）
getconf DISK_SIZE /dev/rhdisk1
or
bootinfo -s hdisk11
--为裸盘配置pvid
lspv
# chdev -l hdisk10 -a pv=yes
--建立vg lv
smit vg
smit lv