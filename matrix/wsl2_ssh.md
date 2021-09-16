
# wsl2_ssh

**作者**

Chrisx

**日期**

2021-09-13

**内容**

wsl2 ubuntu开启ssh服务

----

[toc]

## 安装

```sh
sudo apt-get purge openssh-server
sudo apt-get install openssh-server

```

## 配置

```sh
sudo nano /etc/ssh/sshd_config

PermitRootLogin no  #设置禁止root登录
PasswordAuthentication  #如果要使用密码登录，请确保设置为yes。
AllowUsers yourusername #然后在它下面添加一行说


sudo service ssh --full-restart #重启服务
```

使用像PuTTY这样的ssh客户端从Windows连接到Linux子系统。
