
# ubuntu_zh

**作者**

Chrisx

**日期**

2021-09-15

**内容**

wslg支持中文

----

[toc]

## 中文语言支持

```sh
locale  #查看当前系统语言环境
sudo apt-get install -y language-pack-zh-hans   # 安装中文语言支持
locale -a   #查看已安装的语言环境

```

## 设置中文语言环境

修改配置文件，设置中文

```sh
sudo vi /etc/default/locale

LANG=zh_CN.UTF-8

```
