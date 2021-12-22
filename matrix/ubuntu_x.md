# ubuntu_x

**作者**

Chrisx

**日期**

2021-12-22

**内容**

本地显示Linux GUI程序

----

[toc]

## 服务端安装Ubuntu桌面

linux需要桌面环境支持

```sh
sudo apt-get update && sudo apt-get upgrade #更新系统
echo "y"|sudo apt-get install gnome #安装桌面组件

```

## 客户端安装X Server

下载并安装VcXsrv，安装之后桌面会出现两个快捷方式分别为VcXsrv和XLaunch。

## 配置桌面

1. 打开Windows主系统桌面的XLaunch图标，并按照图示操作。

one window without titlebar
display number： -1

2. 点击下一步保持默认设置直到最后完成

3. 切换到的bash窗口，执行以下命令配置端口，设置桌面环境并退出

export DISPLAY=localhost:0
sudo ccsm

将 wsl1 更新道到 wsl2 后，vcxsrv 需要重新配置冰并且配置方法变了

WSL1为：

export DISPLAY=localhost:0
WSL2为：

export DISPLAY=`cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`:0
随后打开Xlaunch，注意要勾选Disable access control，否则会报错如下

Authorization required, but no authorization protocol specified
Error: Can't open display

1. 切换到bash窗口，执行以下命令并切换回VcXsrv窗口查看效果

sudo service dbus restart
gnome-session
