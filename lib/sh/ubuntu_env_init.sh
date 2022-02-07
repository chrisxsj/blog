#! /bin/bash
#######################################
# Copyright 2021 by Chrisx.All rights reserved.
# Author，Chrisx
# Date，2021-01-19
# discription, ubuntu (wsl2) init, Common software installation
#######################################

##安装git
sudo apt install git -y
echo "`date` git successfully"

## 安装docker

sudo apt-get install \
   apt-transport-https \
   ca-certificates \
   curl \
   gnupg \
   lsb-release -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get install docker-ce docker-ce-cli containerd.io -y

echo "`date` dcoker successfully"


## 安装数据库
sudo apt install postgresql postgresql-contrib -y
echo "`date` postgresql successfully"

## 安装aria2
sudo apt-get install aria2 -y
echo "`date` aria2 successfully"

## 安装vlc
sudo apt-get install vlc -y
echo "`date` vlc successfully"

## gnome-boxes

sudo apt install gnome-boxes -y
echo "`date` gnome-boxes successfully"

:<<EOF
## 设置bash
sudo dpkg-reconfigure dash


## 安装vscode

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

首选项-配置编辑器-查找security.tls.version.min，并将值改为1；ssl/tls的验证方式选择普通密码

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

## pgadmin

https://www.pgadmin.org/download/pgadmin-4-apt/

## dbeaver

https://dbeaver.io/download/

## shotcut

EOF