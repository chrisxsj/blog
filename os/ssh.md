# ssh

**作者**

Chrisx

**日期**

2021-09-26

**内容**

centos7.x ssh 允许root登录

----

[toc]

## 安装

```sh
yum install openssh-server openssh-clients

```

## 启动

```sh
systemctl start sshd
systemctl enable sshd

```

## 允许root登录

vi /etc/ssh/sshd_config

```sh
PermitRootLogin yes
```
