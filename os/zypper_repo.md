# zypper_repo

**作者**

Chrisx

**日期**

2021-04-23

**内容**

suse配置本地yum源，zypper

---

[toc]

## 挂载iso

```sh
mount -o loop -t iso9660 /opt/software/SLE-12-SP4-Server-DVD-x86_64-GM-DVD1.iso /mnt
```

## 配置本地源

repo目录位置
/etc/zypp/repos.d

配置本地repo命令如下

zypper ar file:///mnt/ pgrepo

<!--
hgcmm1:/etc/zypp/repos.d # zypper ar file:///mnt/ pgrepo
Adding repository 'pgrepo' ..................................................................................................................................[done]
Repository 'pgrepo' successfully added

URI         : file:/mnt/
Enabled     : Yes
GPG Check   : Yes
Autorefresh : No
Priority    : 99 (default priority)

Repository priorities are without effect. All enabled repositories share the same priority.
hgcmm1:/etc/zypp/repos.d # cat pgrepo.repo
[pgrepo]
enabled=1
autorefresh=0
baseurl=file:/mnt/
type=NONE
hgcmm1:/etc/zypp/repos.d #
-->

## zypper命令

```sh
zypper lr   #查找本地库
zypper rr   #删除源
zypper clean    清理本地缓存
zypper install  #安装软件包

```

## 问题

如果没有zypper命令

解决方案：

则到iso镜像中，使用rpm安装

```sh
cd /mnt/suse/x86_64

rpm -ivh openssl-1_0_0-1.0.2p-2.11.x86_64.rpm
rpm -ivh dirmngr-1.1.1-13.1.x86_64.rpm
rpm -ivh gpg2-2.0.24-9.3.1.x86_64.rpm
rpm -ivh libzypp-16.19.0-2.36.3.x86_64.rpm
rpm -ivh zypper-1.13.45-21.23.4.x86_64.rpm

```
