# wsl2 docker

**作者**

chrisx

**时间**

2021-04-28

**内容**

wsl2中自动启动服务

---

[toc]

## 关闭WSL的sudo密码请求

ref [sudoers](../os/sudoers.md)

## 自动启动服务

vim ~/.bashrc

```sh
sudo service ssh start
sudo service docker start
```
