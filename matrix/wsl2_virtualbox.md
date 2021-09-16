# wsl2 docker

**作者**

chrisx

**时间**

2021-04-15

**内容**

wsl2中安装使用virtualbox

---

## 问题

[root@datanode2 ~]# virtualbox
WARNING: The vboxdrv kernel module is not loaded. Either there is no module
         available for the current kernel (3.10.0-327.el7.x86_64) or it failed to
         load. Please recompile the kernel module and install it by

           sudo /sbin/vboxconfig

         You will not be able to start VMs until this problem is fixed.

解决方案

yum install gcc perl make

yum install kernel-devel

rcvboxdrv setup