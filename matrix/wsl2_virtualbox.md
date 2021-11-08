# wsl2 docker

**作者**

chrisx

**时间**

2021-04-15

**内容**

wsl2中安装使用virtualbox

---

## WSL 2 和其他第三方虚拟化工具兼容性

ref[WSL 2 和其他第三方虚拟化工具](https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-faq)
ref[Windows 10 (2004) 启用wsl2, 并与VirtualBox 6.0+共存](https://blog.csdn.net/qq_36992069/article/details/104750248?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.control)

1. 前提要求

Windows 版本: 2004+
VirtualBox 版本: 6.0+
CPU启用虚拟化
注 : 本文中提到的命令一般都需要管理员权限

2. VirtualBox启用hyper-v支持（vbox新版本已经支持，无需修改）

指定vbox下的虚拟系统开启这个功能
./VBoxManage.exe setextradata "<虚拟机名字>" "VBoxInternal/NEM/UseRing0Runloop" 0

或指定vbox所有虚拟系统开启
./VBoxManage.exe setextradata global "VBoxInternal/NEM/UseRing0Runloop" 0

VBoxManage.exe setextradata global "VBoxInternal/NEM/UseRing0Runloop" 0


## 问题

```sh
[root@datanode2 ~]# virtualbox
WARNING: The vboxdrv kernel module is not loaded. Either there is no module
         available for the current kernel (3.10.0-327.el7.x86_64) or it failed to
         load. Please recompile the kernel module and install it by

           sudo /sbin/vboxconfig

         You will not be able to start VMs until this problem is fixed.

```

## 解决方案

```sh
yum install gcc perl make

yum install kernel-devel

rcvboxdrv setup
```