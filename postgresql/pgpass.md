# pgpass

**作者**

Chrisx

**日期**

2021-04-25

**内容**

The Password File

ref [The Password File](https://www.postgresql.org/docs/current/libpq-pgpass.html)

---

[toc]

## 介绍

The file .pgpass in a user's home directory can contain passwords to be used if the connection requires a password (and no password has been specified otherwise). On Microsoft Windows the file is named %APPDATA%\postgresql\pgpass.conf (where %APPDATA% refers to the Application Data subdirectory in the user's profile). Alternatively, a password file can be specified using the connection parameter passfile or the environment variable PGPASSFILE.

This file should contain lines of the following format:

hostname:port:database:username:password

(You can add a reminder comment to the file by copying the line above and preceding it with #.) Each of the first four fields can be a literal value, or *, which matches anything.

On Unix systems, the permissions on a password file must disallow any access to world or group; achieve this by a command such as chmod 0600 ~/.pgpass.

## 示例

```sh
touch ~/.pgpass
chmod 0600 ~/.pgpass

vi ~/.pgpass

#hostname:port:database:username:password
127.0.0.1:5433:*:repuser:repuser

```

## win配置方式

官方文档中有关于windows上密码文件配置方式。参考官方文档即可。

在微软的 Windows 上该文件被命名为%APPDATA%\postgresql\pgpass.conf（其中%APPDATA%指的是用户配置中的应用数据子目录）。另外，可以使用连接参数passfile或者环境变量PGPASSFILE指定一个口令文件。

windows上密码文件的使用

1. D盘创建密码文件pgpass.conf

```powershell
#hostname:port:database:username:password
127.0.0.1:5433:*:repuser:repuser

```

2. 配置环境变量PGPASSFILE，参数值指定pgpass.conf文件路径

:warning: 如果不生效就使用环境变量PGPASSWORD