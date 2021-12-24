# ubuntu_input

**作者**

Chrisx

**日期**

2021-12-24

**内容**

配置中文输入法

----

[toc]

## 安装Fcitx小企鹅输入法

```sh

sudo apt install fcitx fonts-noto-cjk fonts-noto-color-emoji dbus-x11   #安装输入法核心和框架，cjk字体

sudo apt install fcitx-sunpinyin #安装输入法（fcitx-sunpinyin、fcitx-sunpinyin、fcitx-sunpinyin选一种）
 
```

## 环境变量配置

```sh
dbus-uuidgen > /var/lib/dbus/machine-id #首先使用root账号生成dbus机器码

```

/etc/profile.d/fcitx.sh

```sh
#!/bin/bash
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx

#可选，fcitx 自启
fcitx-autostart &>/dev/null
```

## fcitx-config-gtk3配置工具

* fcitx-config-gtk3   #输入法设置界面
* fcitx-config-gtk3》“+”  #可添加输入法
* fcitx-config-gtk3》Global Config 》Trigger Input Method和Scroll between Input Method #切换输入法快捷键修改一下，避免和win快捷键冲突

:warning: "fcitx &"写入环境变量配置文件中。登陆启动。

## 搜狗输入法

官网下载[sogou](https://pinyin.sogou.com/)

按照说明文档安装即可[安装指南](https://pinyin.sogou.com/linux/help.php)

如有依赖，使用以下命令安装

```sh
sudo apt -f install ./sogoupinyin_2.4.0.3469_amd64.deb

```

fcitx-config-gtk3   #输入法设置界面选择搜狗输入法个人版

## 百度输入法

官网下载[baidu](https://shurufa.baidu.com/)

暂时支持到ubuntu1910
