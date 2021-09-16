# wslg_gui

**作者**

Chrisx

**日期**

2021-09-13

**内容**

你现在可以在完全集成的桌面体验中预览适用于 Linux 的 Windows 子系统 (WSL) 支持，用于在) 上运行 Linux GUI 应用程序 (X11 和 Wayland Windows。

WSL 2 使 Linux GUI 应用程序能够感受到 Windows 上使用的本机和自然。

从 Windows 启动 Linux 应用 "开始"菜单
将 Linux 应用固定到 Windows 任务栏
使用 alt-tab 在 Linux 与 Windows 应用之间切换
跨 Windows 和 Linux 应用进行剪切和粘贴
你现在可以将 Windows 和 Linux 应用程序集成到工作流中，以获得无缝的桌面体验。

ref [在适用于 Linux 的 Windows 子系统 (预览版上运行 Linux GUI 应用)](https://docs.microsoft.com/zh-cn/windows/wsl/tutorials/gui-apps)

:warning: Linux GUI 应用仅支持 WSL 2，不适用于为 WSL 1 配置的 Linux 分发版。 阅读有关 如何将分发从 WSL 1 更改为 WSL 2的信息。

----

[toc]

## 先决条件

需要 Windows 11 版本22000或更高 版本才能访问此功能。 可以加入 Windows 预览体验计划，以获取最新的预览版。

安装了 vGPU 的驱动程序

若要运行 Linux GUI 应用，你应该首先安装与你的系统匹配的预览驱动程序。 这使你能够使用虚拟 GPU (vGPU) 以便你可以从硬件加速 OpenGL 呈现中获益。

[Intel WSL 的 GPU 驱动程序](https://developer.nvidia.com/cuda/wsl)
[AMD WSL 的 GPU 驱动程序](https://www.amd.com/en/support/kb/release-notes/rn-rad-win-wsl-support)
[NVIDIA WSL 的 GPU 驱动程序](https://developer.nvidia.com/cuda/wsl)

以我的amd显卡为例

## 现有 WSL 安装

如果已在计算机上安装了 WSL，则可以通过从提升的命令提示符运行 update 命令，更新到包含 Linux GUI 支持的最新版本。

```powershell
wsl --update
wsl --shutdown


```

## 运行 Linux GUI 应用

```sh
sudo apt install gedit -y   #安装gedit
sudo apt install x11-apps -y    #安装x11应用（xcalc, xclock, xeyes等）
```

调用

```sh
gedit

```

下载[microsoft-edge-beta](https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-beta/)
sudo apt install /opt/software/microsoft-edge-beta_94.0.992.9-1_amd64.deb -y   #安装

## 安装桌面（可选）

xface4: 轻量级桌面环境
sudo apt-get install xfce4
ubuntu-desktop
sudo apt-get install ubuntu-desktop

<!--


ref [Run any Desktop Environment in WSL](https://github.com/Microsoft/WSL/issues/637)

## 安装X Server

下载并安装VcXsrv，安装之后桌面会出现两个快捷方式分别为VcXsrv和XLaunch。

## 安装Ubuntu桌面

在Windows系统中安装X Server后，开始在WSL中通过命令行安装Ubuntu桌面组件，步骤如下：

1. #更新系统
sudo apt-get update && sudo apt-get upgrade 

2. 安装桌面组件，该过程需要一些时间，请坐和放宽~~

echo "y"|sudo apt-get install ubuntu-desktop

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
-->