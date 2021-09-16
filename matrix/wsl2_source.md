# wsl2_source

**作者**

Chrisx

**日期**

2021-09-15

**内容**

wsl2配置软件源

----

[toc]

## 配置源

1. 国内源网站

[中国科学技术大学开源软件镜像](https://mirrors.ustc.edu.cn/repogen/)
[清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/)

2. 更换源

```sh
cp /etc/apt/sources.list /etc/apt/sources.list.bak  #备份

sudo vi /etc/apt/sources.list   #替换源

sudo apt-get update&& apt-get upgrade   #更新软件列表和系统软件包
```