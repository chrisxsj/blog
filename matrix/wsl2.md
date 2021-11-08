
# wsl2

**作者**

Chrisx

**日期**

2021-09-13

**内容**

安装使用wsl2

ref[适用于 Linux 的 Windows 子系统文档](https://docs.microsoft.com/zh-cn/windows/wsl/)

----

[toc]

## 安装

ref [安装wsl](https://docs.microsoft.com/zh-cn/windows/wsl/install)

```powershell
PS C:\Users\xsj> wsl --install
正在安装: 虚拟机平台
已安装 虚拟机平台。
正在安装: 适用于 Linux 的 Windows 子系统
已安装 适用于 Linux 的 Windows 子系统。
正在下载: WSL 内核
正在安装: WSL 内核
已安装 WSL 内核。
正在下载: GUI 应用支持
正在安装: GUI 应用支持
已安装 GUI 应用支持。
正在下载: Ubuntu
请求的操作成功。直到重新启动系统前更改将不会生效。
PS C:\Users\xsj>
```

## 最佳实践

ref [设置 WSL 开发环境的最佳做法](https://docs.microsoft.com/zh-cn/windows/wsl/setup/environment)

## 其他

### WSL 2 和其他第三方虚拟化工具兼容性

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

### wsl2与win相互访问文件

Windows 访问 Linux 文件

方法一：通过 \\wsl$ 访问 Linux 文件时将使用 WSL 分发版的默认用户。 因此，任何访问 Linux 文件的 Windows 应用都具有与默认用户相同的权限。
方法二：通过VS Code访问Linux文件

Linux 访问 Windows 文件

在从 WSL 访问 Windows 文件时，可以直接使用/mnt/{Windows盘符}进入对应的盘中。

### wsl2 ubuntussh连接
使用localhost可以直接链接wsl2

### ubuntu apt升级

终端执行：

sudo apt update
sudo apt upgrade
sudo systemctl reboot

如果报错：
E: The repository 'http://archive.ubuntu.com/ubuntu focal-backports Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.

更换软件源[wsl2_source](./wsl2_source.md)

### apt-get 查询软件包

dpkg -l |grep post

dpkg -l                             // 列出已安装的所有软件包

apt-cache search PackageName        // 搜索软件包
apt-cache show PackageName          // 获取软件包的相关信息, 如说明、大小、版本等

apt-cache depends PackageName       // 查看该软件包需要哪些依赖包
apt-cache rdepends PackageName      // 查看该软件包被哪些包依赖

apt-get check                       // 检查是否有损坏的依赖

### apt-get update返回NO_PUBKEY错误的解决方法

错误代码：


复制代码代码如下:

W: GPG error: http://security.ubuntu.com trusty-security Release: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 40976EAF437D05B5 NO_PUBKEY 3B4FE6ACC0B21F32

运行如下命令解决

复制代码代码如下:

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5

实际上类似的问题无论Key是什么只需要使用相同的代码替换到相对的Key的位置即可。

### Typora+PicGo+Gitee+坚果云实现Win+Linux+手机端完美Markdown云笔记套件

https://blog.csdn.net/Todobot/article/details/105667867?utm_medium=distribute.pc_relevant.none-task-blog-baidujs-4