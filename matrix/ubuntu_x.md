# ubuntu_x

**作者**

Chrisx

**日期**

2021-12-22

**内容**

本地显示Linux GUI程序

ref [Stand-alone windows in Multipass](https://discourse.ubuntu.com/t/stand-alone-windows-in-multipass/16340)

----

[toc]

## 服务端安装Ubuntu桌面

linux需要桌面环境支持

```sh
sudo apt-get update && sudo apt-get upgrade #更新系统
echo "y"|sudo apt-get install gnome #安装桌面组件
sudo shutdown -r now #重启
```

## 客户端安装X Server

下载并安装VcXsrv，安装之后桌面会出现两个快捷方式分别为VcXsrv和XLaunch。

## 配置

1. 打开Windows主系统桌面的XLaunch图标，并按照图示操作。直到最后一步完成。

XLaunch的一些选项

* Multiple windows,and set the display number; leaving it in -1 
* Start no client
* Disable access control

ipconfig查看本机ip

2. 在linux系统设置环境变量

环境变量配置

```sh
export DISPLAY=xx.xx.xx.xx:0.0  #xx.xx.xx.xx是ipconfig结果
xhost +

```

测试

```sh
sudo apt install x11-apps
xlogo &

```
