# wsl2_systemd

**作者**

Chrisx

**日期**

2021-09-13

**内容**

安装systemd。据说gnome桌面是基于systemd，而WSL不支持systemd，所以需要先安装systemd，ref [ubuntu-wsl2-systemd-script](https://github.com/DamionGans/ubuntu-wsl2-systemd-script)

----

[toc]

## usage

1. 安装daemonize

```sh
sudo apt-get install daemonize

```

2. 执行以下命令开启

```sh
sudo daemonize /usr/bin/unshare --fork --pid --mount-proc /lib/systemd/systemd --system-unit=basic.target

exec sudo nsenter -t $(pidof systemd) -a su - $LOGNAME
```