# firewall

**作者**

chrisx

**日期**

2020-01-15

**内容**

linux firwall，firewall-cmd，firewalld.servic

---

[toc]

## disable

systemctl

```shell
[root@postgres init.d]# systemctl --help
systemctl [OPTIONS...] {COMMAND} ...

Query or send control commands to the systemd manager.

Unit Commands:
  list-units [PATTERN...]         List loaded units
  list-sockets [PATTERN...]       List loaded sockets ordered by address
  list-timers [PATTERN...]        List loaded timers ordered by next elapse
  start NAME...                   Start (activate) one or more units
  stop NAME...                    Stop (deactivate) one or more units
  reload NAME...                  Reload one or more units
  restart NAME...                 Start or restart one or more units
  try-restart NAME...             Restart one or more units if active
  reload-or-restart NAME...       Reload one or more units if possible,
Unit File Commands:
  list-unit-files [PATTERN...]    List installed unit files
  enable NAME...                  Enable one or more unit files
  disable NAME...                 Disable one or more unit files

# 禁用
systemctl status firewalld.service
systemctl stop firewalld.service
systemctl disable firewalld.service

```

## firewall-cmd

:warning: 使用图形化配置firewall-config

1. firewall-cmd，开启特定端口

```bash

[root@postgres init.d]# firewall-cmd --help

Usage: firewall-cmd [OPTIONS...]

1 state
firewall-cmd --state

2 add port
firewall-cmd --add-port=5432/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-ports

3 remove port
firewall-cmd --remove-port=5432/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-ports

4 add server
firewall-cmd --add-service=ntp --permanent
firewall-cmd --reload
firewall-cmd --list-services

5 remove server
firewall-cmd --remove-service=ntp --permanent
firewall-cmd --reload
firewall-cmd --list-services

```

2. 允许服务器通过firewalld

```shell
# firewall-cmd --permanent --add-service=high-availability
success
# firewall-cmd --reload
success
```

3. 允许网段

```sh
firewall-cmd --permanent --add-source=172.25.5.0/24 #永久允许172.25.5.0网段
firewall-cmd --reload #更新防火墙规则
firewall-cmd --list-all #查看所有信息
```
