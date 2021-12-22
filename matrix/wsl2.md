## wsl2

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

### wsl2 ubuntu ssh连接

使用localhost可以直接链接wsl2

## wsl2内存配置

这个解决方案来自github，简单来说就是创建一个%UserProfile%\.wslconfig文件来限制wsl使用的内存总量。比如说我在Windows中使用的用户是tinychen，那么我就在C:\Users\tinychen中创建了一个.wslconfig文件，在里面加入以下内容来限制wsl2的内存总大小

[wsl2]
memory=8GB  #限制最大物理内存
swap=8GB    #限制最大虚拟内存
processors=2    #限制最大cpu个数

## 环境变量

```sh
# chrisx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx
#fcitx &

# docker
sudo service docker start
# ssh
sudo service ssh start
# crontab
sudo service cron start
source /opt/lib/task.sh

# java conf
export JAVA_HOME=/opt/jdk-17.0.1
export CLASSPATH=.:$JAVA_HOME/lib
export PATH=$JAVA_HOME/bin:$PATH

# ssh
alias ssh151="ssh root@192.168.80.151"
alias ssh193="ssh root@192.168.80.193"
```