# yum_repository_local

**作者**

chrisx

**日期**

2021-04-02

**内容**

本地yum源配置

---

[toc]

## 禁用互联网更新方式

先将已存在的*.repo移动到bak目录让系统找不到该文件，从而不能让yum安装时使用互联网的更新方式

```shell
mkdir bak
mv *.repo bak

```

## 挂载iso

```shell
mount -o loop -t iso9660 /opt/software/rhel-server-7.5-x86_64-dvd.iso /mnt

```

## 编辑yum配置文件x.repo

新建pg.repo

```shell
# cat /etc/yum.repos.d/pg.repo

[pg]                    #全局名 不重复，不要有空格
name=pg                 #自定义名字
baseurl=file:///mnt/    #支持三种协议：http、ftp、file，其中file表示本地文件，此路径指定为iso中Packages的父目录
enabled=1               #1表示启用，0表示禁用
gpgcheck=0              #禁用

[pg-addons]                                     #全局名 不重复，不要有空格
name=pg-addons                                  #自定义名字
baseurl=file:///mnt/addons/HighAvailability/    #支持三种协议：http、ftp、file，其中file表示本地文件，此路径指定为iso中Packages的父目录
enabled=1                                       #1表示启用，0表示禁用
gpgcheck=0                                      #禁用

```

:warning: 注意，iso镜像中有两个部分存放了程序包，如Packages（常用程序包）、addons（高可用程序包）这两个目录中都有repodata。

### centos8，需要配置两个目录AppStream和BaseOS

```shell
[pg-AppStream]
name=pg-AppStream
baseurl=file:///mnt/AppStream/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
 
[pg-BaseOS]
name=pg-BaseOS
baseurl=file:///mnt/BaseOS/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

```

## 重新加载yum

yum clean all
yum list all

## 错误

在redhat linux下有的时候用yum安装软件的时候最后会提示：
warning: rpmts_HdrFromFdno: Header V3 DSA signature: NOKEY, key ID*****
这是由于yum安装了旧版本的GPG keys造成的，解决办法就是
rpm --import /etc/pki/rpm-gpg/RPM*

来自 <http://blog.itpub.net/11134237/viewspace-694926/>