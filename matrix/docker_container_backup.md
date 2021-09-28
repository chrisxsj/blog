# docker_container_backup

**作者**

chrisx

**时间**

2021-05-24

**内容**

docker容器备份恢复

---

[toc]

## 制作新的镜像

```sh
docker ps   #查看运行的所有容器
#docker ps -a    #查看所有容器
docker stop t11 #停止 Docker 容器
sudo docker commit -a 'chrisx' -m 'include pg and hgdb,20210910' t11 20210910-c79dbt11    #找到我们需要备份的容器后，需要先创建该容器的镜像快照
docker images   #查看镜像

```

现在，上面的快照已经作为Docker镜像保存了。对于备份该快照，我们有两个选择，一个是我们可以登录进Docker注册中心，并推送该镜像到自己的Repositories中；另一种选择是是我们可以将Docker镜像打包成tar包备份到本地。

## 镜像导入导出

```sh
docker save de3115a69fc3 > 20210910imaget11.tar  #镜像导出
docker load < 20210910imaget11.tar   #镜像导入

```

> 注意，可使用此镜像创建新的container，映射新的端口。

## 容器导出导入

镜像导出的文件比容器导出文件大哦。

```sh
docker export 8cfba0c9a15f > 20210910containert11.tar   #容器导出
docker import 20210910containert11.tar #容器导入,导入后会创建一个镜像，依据镜像启动容器

```

## 镜像和容器 导出和导入的区别

save 和 export区别：
1）save 保存镜像所有的信息-包含历史，可以回滚到之前的层（layer）。所以文件比较大
2）export 只导出当前的信息，文件较小。docker export 的应用场景：主要用来制作基础镜像，比如我们从一个 ubuntu 镜像启动一个容器，然后安装一些软件和进行一些设置后，使用 docker export 保存为一个基础镜像。然后，把这个镜像分发给其他人使用，比如作为基础的开发环境。
