# lxd

## 安装

https://linuxcontainers.org/lxd/getting-started-cli/#linux

sudo apt update
sudo snap install lxd

## Getting started with LXD

sudo lxd init

sudo lxc image list images: centos/7/   #查找网络镜像

sudo lxc launch images:1b8f8e664d3e c7  #创建

sudo lxc exec c7 bash    #进入

sudo lxc list
sudo lxc info

sudo lxc stop first
sudo lxc delete first

sudo lxc config show c7




## network

https://linuxcontainers.org/lxd/docs/master/networks

sudo lxc network show lxdbr0

sudo lxc network set <network> <key> <value>

sudo lxc network set lxdbr0 ipv4.address 192.168.80.1/24

sudo lxc network edit lxdbr0