
RHEL7 – Configuring GFS2 on Pacemaker/Corosync Cluster



Linux 配置GFS2
GFS2：
全局文件系统第二版，GFS2是应用最广泛的集群文件系统。它是由红帽公司开发出来的，允许所有集群节点并行访问。元数据通常会保存在共享存储设备或复制存储设备的一个分区里或逻辑卷中。
CLVM
集群化的 LVM （Clustered LVM，CLVM）是 LVM 的一个集群方面的扩展。允许一个集群的计算机通过 LVM 管理共享存储。clvmd 守护进程是 CLVM 的核心。clvmd 守护进程在每个集群计算机上运行，并更新 LVM 元数据，让集群的每个计算机上的 LVM 信息都保持一致，用 CLVM 在共享存储上建立的逻辑卷对于访问过该共享存储的计算机都是可视的。CLVM 允许一个用户在共享存储上配置逻辑卷时，锁住正被配置的物理存储设备。CLVM 使用锁服务来保证基础信息方面的一致性。CLVM 要求改变 lvm.conf 以使用 cluster-wide 的锁服务。
配置CLVM和GFS2
1、安装CLVM和GFS2软件包
本地yum源配置
[rhel]
name=rhel
baseurl=file:///mnt/
enabled=1
gpgcheck=1
gpgkey=file:///media/rhel/RPM-GPG-KEY-redhat-release
[rhellvm]
name=rhellvm-local
baseurl=file:///mnt/addons/ResilientStorage
enabled=1
gpgcheck=1
#gpgkey=file:///media/rhel/RPM-GPG-KEY-redhat-release
# yum install lvm2-cluster gfs2-utils
 
2、配置CLVM,开机启动clvm服务
各节点LVM功能默认不是开启集群功能的，需要手动配置使用，可以用lvmconf --enable-cluster命令开启，这命令实际上是使得/etc/lvm/lvm.conf配置文件里的locking_type为3（默认为1），如下：
# lvmconf --enable-cluster
reboot 重启生效
 
3、创建CLVM并且格式化成GFS2
fdisk /dev/sde
分区
更改分区类型（t）
pvcreate /dev/sde1
vgcreate -cy vg_cluster /dev/sdb1
lvcreate -l100%FREE -n lv_cluster vg_cluster
mkfs.gfs2 -p lock_dlm -t ha_cluster:gfs2 -j 2 /dev/vg_cluster/lv_cluster
参数说明：
mkfs.gfs2
    -j #: 指定日志区域的个数，有几个就能够被几个节点所挂载；
    -J #: 指定日志区域的大小，默认为128MB;
    -p {lock_dlm|lock_nolock}：所使用的锁协议名称，集群需要使用lock_dlm；
    -t <name>: 锁表的名称，格式为clustername:fsname, clustername为当前节点所在的集群的名称，这也是为什么要使用RHCS；fsname文件系统名称，自定义，要在当前集群惟一，这也叫锁表名称，表明是分布式锁的范围。
需要提前配置RHCS/PACEMAKER！！！！！！！！！
RHEL7 – Configuring GFS2 on Pacemaker/Corosync Cluster
2017年06月29日 11:16:07 hshl1214 阅读数：1015更多
个人分类： HA
http://www.unixarena.com/2016/01/rhel7-configuring-gfs2-on-pacemakercorosync-cluster.html
This article will briefly explains about configuring the GFS2 filesystem between two cluster nodes. As you know that GFS2 is cluster filesystem and it can be mounted on more than one server at a time . Since multiple servers can mount the same filesystem, it uses the DLM (Dynamic Lock Manager) to prevent the data corruption. GFS2 requires a cluster suite to configure & manage. In RHEL 7 , Pacemaker/corosync provides the cluster infrastructure. GFS2 is  a native file system that interfaces directly with the Linux kernel file system interface (VFS layer). For your information, Red Hat supports the use of GFS2 file systems only as implemented in the High Availability Add-On (Cluster).
 
Here is the list of activity  in an order to configure the GFS2 between two node cluster (Pacemaker).
	1. 
Install GFS2 and lvm2-cluster packages.
	2. 
Enable clustered locking for LVM
	3. 
Create DLM and CLVMD resources on Pacemaker
	4. 
Set the resource ordering and colocation.
	5. 
Configure the LVM objects & Create the GFS2 filesystem
	6. 
Add logical volume & filesystem in to the pacemaker control.  (gfs2 doesn’t use /etc/fstab).


 
Environment: 
	* 
RHEL 7.1
	* 
Node Names : Node1 & Node2.
	* 
Fencing/STONITH: Mandatory for GFS2.
	* 
Shared LUN “/dev/sda”
	* 
Cluster status:


[root@Node2-LAB ~]# pcs status
Cluster name: GFSCLUS
Last updated: Thu Jan 21 18:00:25 2016
Last change: Wed Jan 20 16:12:24 2016 via cibadmin on Node1
Stack: corosync
Current DC: Node1 (1) - partition with quorum
Version: 1.1.10-29.el7-368c726
2 Nodes configured
5 Resources configured
Online: [ Node1 Node2 ]
Full list of resources:
xvmfence (stonith:fence_xvm): Started Node1
PCSD Status:
Node1: Online
Node2: Online
Daemon Status:
corosync: active/enabled
pacemaker: active/enabled
pcsd: active/enabled
[root@Node2-LAB ~]#
 
Package Installation:
1. Login to the both cluster nodes and install gfs2 and lvm2 cluster packages.
[root@Node2-LAB ~]# yum -y install gfs2-utils lvm2-cluster
Loaded plugins: product-id, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Package gfs2-utils-3.1.6-13.el7.x86_64 already installed and latest version
Package 7:lvm2-cluster-2.02.105-14.el7.x86_64 already installed and latest version
Nothing to do
[root@Node2-LAB ~]# ssh Node1 yum -y install gfs2-utils lvm2-cluster
Loaded plugins: product-id, subscription-manager
Package gfs2-utils-3.1.6-13.el7.x86_64 already installed and latest version
Package 7:lvm2-cluster-2.02.105-14.el7.x86_64 already installed and latest version
Nothing to do
[root@Node2-LAB ~]#
 
Enable clustered locking for LVM:
1. Enable clustered locking for LVM on both the cluster ndoes
[root@Node2-LAB ~]# lvmconf --enable-cluster
[root@Node2-LAB ~]# ssh Node1 lvmconf --enable-cluster
[root@Node2-LAB ~]# cat /etc/lvm/lvm.conf |grep locking_type |grep -v "#"
locking_type = 3
[root@Node2-LAB ~]#
2. Reboot the cluster nodes.
 
Create DLM and CLVMD cluster Resources:
1.Login to one of the cluster node.
2.Create clone resources for DLM and CLVMD. Clone options allows resource to can run on both nodes.
[root@Node1-LAB ~]# pcs resource create dlm ocf:pacemaker:controld op monitor interval=30s on-fail=fence clone interleave=true ordered=true
[root@Node1-LAB ~]# pcs resource create clvmd ocf:heartbeat:clvm op monitor interval=30s on-fail=fence clone interleave=true ordered=true
 
3.Check the cluster status.
[root@Node1-LAB ~]# pcs status
Cluster name: GFSCLUS
Last updated: Thu Jan 21 18:15:48 2016
Last change: Thu Jan 21 18:15:38 2016 via cibadmin on Node1
Stack: corosync
Current DC: Node2 (2) - partition with quorum
Version: 1.1.10-29.el7-368c726
2 Nodes configured
5 Resources configured
 
Online: [ Node1 Node2 ]
Full list of resources:
xvmfence (stonith:fence_xvm): Started Node1
Clone Set: dlm-clone [dlm]
Started: [ Node1 Node2 ]
Clone Set: clvmd-clone [clvmd]
Started: [ Node1 Node2 ]
PCSD Status:
Node1: Online
Node2: Online
Daemon Status:
corosync: active/enabled
pacemaker: active/enabled
pcsd: active/enabled
[root@Node1-LAB ~]#
You could see that resource is on-line on both the nodes.
 
Resource ordering and co-location:
1.Configure the resource order.
[root@Node1-LAB ~]# pcs constraint order start dlm-clone then clvmd-clone
Adding dlm-clone clvmd-clone (kind: Mandatory) (Options: first-action=start then-action=start)
[root@Node1-LAB ~]#
 
2. configure the co-location for resources.
[root@Node1-LAB ~]# pcs constraint colocation add clvmd-clone with dlm-clone
[root@Node1-LAB ~]#
 
3. Verify the constraint.
[root@Node1-LAB ~]# pcs constraint
Location Constraints:
Ordering Constraints:
start dlm-clone then start clvmd-clone
Colocation Constraints:
clvmd-clone with dlm-clone
[root@Node1-LAB ~]#
 
 
Configure the LVM objects:
1.Login to one of the cluster node and create the required LVM objects.
2. In this setup , /dev/sda is shared LUN between two nodes.
3. Create the new volume group .
[root@Node1-LAB ~]# vgcreate -Ay -cy gfsvg /dev/sda
Physical volume "/dev/sda" successfully created
Clustered volume group "gfsvg" successfully created
[root@Node1-LAB ~]#
[root@Node1-LAB kvmpool]# vgs
VG #PV #LV #SN Attr VSize VFree
gfsvg 1 1 0 wz--nc 996.00m 96.00m
rhel 1 2 0 wz--n- 7.51g 0
[root@Node1-LAB kvmpool]#
4. Create the logical volume.
[root@Node1-LAB ~]# lvcreate -L 900M -n gfsvol1 gfsvg
Logical volume "gfsvol1" created
[root@Node1-LAB ~]#
[root@Node1-LAB kvmpool]# lvs -o +devices gfsvg
LV VG Attr LSize Pool Origin Data% Move Log Cpy%Sync Convert Devices
gfsvol1 gfsvg -wi-ao---- 900.00m /dev/sda(0)
[root@Node1-LAB kvmpool]#
5. Create the filesystem on the new volume.
[root@Node1-LAB ~]# mkfs.gfs2 -p lock_dlm -t GFSCLUS:gfsvolfs -j 2 /dev/gfsvg/gfsvol1
/dev/gfsvg/gfsvol1 is a symbolic link to /dev/dm-2
This will destroy any data on /dev/dm-2
Are you sure you want to proceed? [y/n]y
Device: /dev/gfsvg/gfsvol1
Block size: 4096
Device size: 0.88 GB (230400 blocks)
Filesystem size: 0.88 GB (230400 blocks)
Journals: 2
Resource groups: 4
Locking protocol: "lock_dlm"
Lock table: "GFSCLUS:gfsvolfs"
UUID: 8dff8868-3815-d43c-dfa0-f2a9047d97a2
[root@Node1-LAB ~]#
[root@Node1-LAB ~]#
	* 
GFSCLUS – CLUSTER NAME
	* 
gfsvolfs – FILESYSTEM NAME
	* 
“-j 2” = Journal- Since two node is going to access it.


 
Configure the Mount-point on Pacemaker:
1. Login to one of the cluster node.
2. Create the new cluster resource for GFS2 filesystem.
[root@Node1-LAB ~]# pcs resource create gfsvolfs_res Filesystem device="/dev/gfsvg/gfsvol1" directory="/kvmpool" fstype="gfs2" options="noatime,nodiratime" op monitor interval=10s on-fail=fence clone interleave=true
[root@Node1-LAB ~]#
 
3. Verify the volume status. It should be mounted on both the cluster nodes.
[root@Node1-LAB ~]# df -h /kvmpool
Filesystem Size Used Avail Use% Mounted on
/dev/mapper/gfsvg-gfsvol1 900M 259M 642M 29% /kvmpool
[root@Node1-LAB ~]# ssh Node2 df -h /kvmpool
Filesystem Size Used Avail Use% Mounted on
/dev/mapper/gfsvg-gfsvol1 900M 259M 642M 29% /kvmpool
[root@Node1-LAB ~]#
 
4. Configure the resources ordering and colocaiton .
[root@Node1-LAB ~]# pcs constraint order start clvmd-clone then gfsvolfs_res-clone
Adding clvmd-clone gfsvolfs_res-clone (kind: Mandatory) (Options: first-action=start then-action=start)
[root@Node1-LAB ~]# pcs constraint order
Ordering Constraints:
start clvmd-clone then start gfsvolfs_res-clone
start dlm-clone then start clvmd-clone
[root@Node1-LAB ~]# pcs constraint colocation add gfsvolfs_res-clone with clvmd-clone
[root@Node1-LAB ~]# pcs constraint colocation
Colocation Constraints:
clvmd-clone with dlm-clone
gfsvolfs_res-clone with clvmd-clone
[root@Node1-LAB ~]#
 
5. You could see that both the nodes able to see same filesystem in read/write mode.
[root@Node1-LAB ~]# cd /kvmpool/
[root@Node1-LAB kvmpool]# ls -lrt
total 0
[root@Node1-LAB kvmpool]# touch test1 test2 test3
[root@Node1-LAB kvmpool]# ls -lrt
total 12
-rw-r--r-- 1 root root 0 Jan 21 18:38 test1
-rw-r--r-- 1 root root 0 Jan 21 18:38 test3
-rw-r--r-- 1 root root 0 Jan 21 18:38 test2
[root@Node1-LAB kvmpool]# ssh Node2 ls -lrt /kvmpool/
total 12
-rw-r--r-- 1 root root 0 Jan 21 18:38 test1
-rw-r--r-- 1 root root 0 Jan 21 18:38 test3
-rw-r--r-- 1 root root 0 Jan 21 18:38 test2
[root@Node1-LAB kvmpool]#
We have successfully configured GFS2 on RHEL 7 clustered nodes.
 
Set the No Quorum Policy:
When you use GFS2 , you must configure the no-quorum-policy . If you set it to freeze and system lost the quorum, systems will not anything until quorum is regained.
[root@Node1-LAB ~]# pcs property set no-quorum-policy=freeze
[root@Node1-LAB ~]#