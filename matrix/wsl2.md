
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

### wsl 指定的服务未安装

执行wsl命令是提示，指定的服务未安装。一个奇怪的bug

1. 先卸载wsl
卸载 windows subsystem for linux update

2. 重新安装一下
ref [旧版 WSL 的手动安装步骤](https://docs.microsoft.com/zh-cn/windows/wsl/install-manual)
步骤 4 - 下载 Linux 内核更新包

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

