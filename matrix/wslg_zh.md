
# wsl2

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
sudo locale-gen zh_CN.UTF-8 # 设置中文语言环境

```

## Fcitx框架，包括小企鹅输入法

```sh
sudo apt install fonts-noto fcitx fcitx-pinyin  #安装中文字体和输入法

#加入环境变量配置文件~/.bashrc

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx


fcitx &  # 运行fcitx，可将启动命令写入环境变量文件

fcitx-config-gtk3   #输入法设置界面
fcitx-config-gtk3》Global Config 》Trigger Input Method和Scroll between Input Method #切换输入法快捷键修改一下，避免和win快捷键冲突
 
```

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