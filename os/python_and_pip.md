
# python_and_pip

**作者**

Chrisx

**日期**

2021-08-27

**内容**

python和pip的安装使用

----

[toc]

## 1. 安装python

```sh
python3 --version
```

下载[python](https://www.python.org/downloads/)

configure编译环境及需要的安装包，yum配置ref[yum_repository_local](./yum_repository_local.md)

```sh
yum install gcc zlib zlib-devel openssl openssl-devel libffi libffi-devel

```

编译安装

```sh
cd Python-3.9.6
./configure --prefix=/opt/python
make && make install

```

## 2. 确保可以使用pip

```sh
/opt/python/bin/python3 -m pip --version

```

如果pip不可用，从标准库引导它：

```sh
/opt/python/bin/python3 -m ensurepip --default-pip

```

:warning: python3的引用，可以将/opt/python/bin加入到$PATH中

## 3. 确保 pip, setuptools, and wheel更新到最新

```sh
python3 -m pip install --upgrade pip setuptools wheel

```

## 4. 使用pip安装

或者pip安装

```sh
python3 -m pip install "patroni"  #安装最新版本
python3 -m pip install "patroni==2.1.1" #安装指定版本
python3 -m pip install --upgrade patroni  #升级安装包
python3 -m pip install -e <path>  #本地源码安装
python3 -m pip install ./downloads/SomeProject-1.0.4.tar.gz #本地压缩包安装
```

pip安装可以支持源码和wheels。Wheels是一种预构建的发行版格式，与源码版（sdist）相比，它提供了更快的安装速度，尤其是当项目包含编译的扩展时。

这里选择本地安装

如

```sh
python3 -m pip install /tmp/patroni-2.1.1-py3-none-any.whl #本地压缩包安装

```

使用pip可手动指定源，如

```sh
pip install ydiff -i https://pypi.mirrors.ustc.edu.cn/simple --trusted-host pypi.mirrors.ustc.edu.cn

```

此外使用时如果出现以下告警，则说明没有配置trusted-host，需要在命令行手动需添加参数 --trusted-host pypi.douban.com

WARNING: The repository located at pypi.douban.com is not a trusted or secure host and is being ignored. If this repository is available via HTTPS we recommend you use HTTPS instead, otherwise you may silence this warning and allow it anyway with '--trusted-host pypi.douban.com'.

## 5. 问题

问题1，无法连接网络服务器

```sh
WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'NewConnectionError('<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7f3c21fc28e0>: Failed to establish a new connection: [Errno -2] Name or service not known')': /simple/pycodestyle/

```

解决方案

网络安装需要配置DNS

```sh
# cat /etc/resolv.conf
nameserver 192.168.110.184
nameserver 8.8.8.8

```

问题2，ssl报错

```sh
WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'SSLError("Can't connect to HTTPS URL because the SSL module is not available.")': /simple/psycopg2/

```

解决方案

安装 openssl，openssl-devel 重新编译

```sh
yum install openssl openssl-devel
cd Python-3.9.6
./configure --prefix=/opt/python
make && make install

```

问题3，模块缺失

```sh
ModuleNotFoundError: No module named '_ctypes'

```

解决方案

安装 libffi，libffi-devel 重新编译

```sh
yum install libffi libffi-devel
cd Python-3.9.6
./configure --prefix=/opt/python
make && make install

```
