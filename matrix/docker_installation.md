# docker_installation

**作者**

chrisx

**时间**

2021-04-15

**内容**

wsl2中安装使用docker

ref [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

---

[toc]

## 安装

download [docker](https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/)

```sh

sudo apt-get update

sudo apt-get install \
   apt-transport-https \
   ca-certificates \
   curl \
   gnupg \
   lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

```

## 配置服务自启动

```sh
sudo service docker start #手动启动命令，自启动配置讲此命令添加到~/.bashrc

```

## 测试

```sh

sudo docker run hello-world
```

## 镜像

[centos镜像库](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)

```sh
sudo docker search centos #查找需要的镜像
sudo docker pull centos:centos7.9.2009  #拉取镜像,具体镜像参考镜像库
```

## 问题

```sh
chris@hg-cx:/mnt/c/Users/chris$ sudo docker pull postgres
Using default tag: latest
Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 172.20.48.1:53: read udp 172.20.63.22:57601->172.20.48.1:53: i/o timeout

```

解决方案

修改文件 /etc/resolve.conf

添加dns

```sh
nameserver 8.8.8.8

```
