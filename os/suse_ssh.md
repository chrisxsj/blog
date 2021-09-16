
# suse_ssh

**作者**

Chrisx

**日期**

2021-04-28

**内容**

suse配置ssh远程连接
suse12

---

[toc]

## 配置ssh

修改sshd_config

```sh
$ vi /etc/ssh/sshd_config

PermitRootLogin yes     # 允许root用户登录
PasswordAuthentication yes  # 开启密码验证

systemctl restart sshd  # 重启ssh


```

关闭防火墙

```sh
systemctl stop SuSEfirewall2    #suse里面的防火墙名称是SuSEfirewall2
systemctl disable SuSEfirewall2

```
