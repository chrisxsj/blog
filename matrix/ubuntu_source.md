# ubuntu_source

**作者**

Chrisx

**日期**

2021-09-15

**内容**

wsl2配置软件源，通常ubuntu等linux安装完成后，建议更换为国内源，更新下载软件更快速。

----

[toc]

## 配置源

以下为常用国内源

[清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/)
[中国科学技术大学开源软件镜像](https://mirrors.ustc.edu.cn/repogen/)

选择对应版本的镜像源地址，下面以ubuntu 20.04 LTS为例

```sh ubuntu 20.04
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
```

2. 更换源

```sh
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak  #备份

sudo vi /etc/apt/sources.list   #替换源

sudo apt-get update&& apt-get upgrade   #更新软件列表和系统软件包
```
