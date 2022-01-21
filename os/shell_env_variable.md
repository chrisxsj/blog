# shell_env_variable

**作者**

Chrisx

**日期**

2021-06-21

**内容**

shell环境变量配置

----

[toc]

## 环境变量配置文件

环境变量配置

* /etc/profile,全局变量配置文件，无论那个用户，第一次登录时,该文件被执行.并从/etc/profile.d目录的配置文件中搜集shell的设置.
* /etc/bashrc,/etc/bash.bashrc,全局变量配置文件，无论那个用户，打开bash shell时,该文件被读取。
* ~/.bash_login,用户配置文件，登录时读取
* ~/.bash_profile,用户配置文件，每次用户登录时，该文件被执行一次。
* ~/.bashrc,用户配置文件，每次打开shell时，该文件被读取
* ~/.bash_logout，用户配置文件，退出时读取
