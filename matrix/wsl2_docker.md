# wsl2 docker

**作者**

chrisx

**时间**

2021-04-15

**内容**

wsl2中安装使用docker

---

ref [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

## 安装

download [docker](https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/)

```sh
dpkg -i containerd.io_1.4.4-1_amd64.deb
dpkg -i docker-ce-cli_20.10.6~3-0~ubuntu-focal_amd64.deb  
dpkg -i docker-ce-rootless-extras_20.10.6~3-0~ubuntu-focal_amd64.deb
dpkg -i docker-ce_20.10.6~3-0~ubuntu-focal_amd64.deb
```

## 测试

```sh
chris@hg-cx:/mnt/c/Users/chris$ sudo docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete
Digest: sha256:f2266cbfc127c960fd30e76b7c792dc23b588c0db76233517e1891a4e357d519
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest
chris@hg-cx:/mnt/c/Users/chris$ sudo docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

chris@hg-cx:/mnt/c/Users/chris$
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
