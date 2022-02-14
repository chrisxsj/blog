# apt

**作者**

Chrisx

**日期**

2021-05-12

**内容**

apt指南

apt是一个命令行实用程序，用于在Ubuntu，Debian和相关Linux发行版上安装，更新，删除和管理deb软件包。它结合了apt-get和apt-cache工具中最常用的命令以及某些选项的不同默认值。

apt专为交互使用而设计。最好在您的Shell脚本中使用apt-get和apt-cache

----

[toc]

## 常用命令

```sh
sudo apt update #APT软件包索引是一个数据库，其中包含系统中启用的存储库中可用软件包的记录。要更新软件包索引
sudo apt upgrade    #升级软件包，该命令不会升级需要删除已安装软件包的软件包。
sudo apt upgrade package_name   #指定软件包升级
sudo apt full-upgrade   #全面升级，升级整个系统，会删除已安装的软件包。使用此命令时要格外小心。
sudo apt install package_name   #安装软件包
sudo apt install package1 package2  #安装多个软件包
sudo apt install /full/path/file.deb    #安装本地软件包
sudo apt remove package_name    #删除软件包
sudo apt remove package1 package2   #删除多个软件包
sudo apt purge package_name #删除软件包残留的配置文件
sudo apt autoremove #删除用不到的依赖包
sudo apt list | grep package_name   #列出已安装软件包
sudo apt list –upgradable    #列出软件包的可用升级包
sudo apt search package_name    #搜索软件包
sudo apt show package_name    #查看软件包信息

```

