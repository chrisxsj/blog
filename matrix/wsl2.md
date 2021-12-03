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

### wsl2 ubuntu ssh连接

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

## 使用git

ref git*

## 使用docker

ref docker*

## 使用vscode

ref vscode*

## 使用邮件客户端

安装最新版thunderbird

Adding this PPA to your system
You can update your system with unsupported packages from this untrusted PPA by adding ppa:ubuntu-mozilla-daily/ppa to your system's Software Sources. (Read about installing)

sudo add-apt-repository ppa:ubuntu-mozilla-daily/ppa
sudo apt-get update
sudo apt-get install thunderbird

thunderbird

设置中文
preference-language(search for more language)-add chinese(china)

配置公司邮箱
ref [在升级到Thunderbird 78版后，不能收发电子邮件了](https://support.mozilla.org/zh-CN/kb/thunderbird-78-faq-cn#w_zai-sheng-ji-dao-thunderbird-78ban-hou-bu-neng-shou-fa-dian-zi-you-jian-liao)

首选项-配置编辑器-查找security.tls.version.min，并将值改为1-ssl/tls的验证方式选择普通密码

## 使用libreoffice

下载deb包[libreoffice](https://zh-cn.libreoffice.org/download/libreoffice/?type=deb-x86_64&version=7.2.3&lang=zh-CN)
下载[已翻译的用户界面语言包: 中文 (简体)]()

tar -zxvf LibreOffice_7.2.3_Linux_x86-64_deb.tar.gz
tar -zxvf LibreOffice_7.2.3_Linux_x86-64_deb_langpack_zh-CN.tar.gz
cd LibreOffice_7.2.3_Linux_x86-64_deb/DEBS
sudo dpkg -i ./lib*.deb
cd LibreOffice_7.2.3.2_Linux_x86-64_deb_langpack_zh-CN/DEBS
sudo dpkg -i ./lib*.deb

libreoffice7.2

## microsfto-edge

下载[edge](https://www.microsoft.com/zh-cn/edge?r=1#evergreen)

sudo apt-get install ./microsoft-edge-stable_96.0.1054.41-1_amd64.deb

## remmina

ref [how-to-install-remmina](https://remmina.org/how-to-install-remmina/#ubuntu)

sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
sudo apt update
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret

List available plugins with apt-cache search remmina-plugin

## OBS Studio

ref [OBS Studio](https://obsproject.com/wiki/install-instructions#linux)

obs

## shotcut

## gnome-boxes

sudo apt install gnome-boxes
sudo gnome-boxes

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
```