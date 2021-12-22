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
