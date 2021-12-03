# ssh

**作者**

Chrisx

**日期**

2021-09-26

**内容**

centos7.x ssh 允许root登录

----

[toc]

## 安装

```sh
yum install openssh-server openssh-clients

```

## 启动

```sh
systemctl start sshd
systemctl enable sshd

```

## 允许root登录

vi /etc/ssh/sshd_config

```sh
PermitRootLogin yes
```

## ssh互信

1. 两台机器生成各自的ssh key

```sh
ssh-keygen

ls ~/.ssh/
id_rsa  id_rsa.pub

```

会有一个公钥，一个私钥

2.用ssh-copy-id 把公钥复制到远程主机上

```sh
ssh-copy-id -i ./id_rsa.pub root@192.168.8.12

```

3. 验证

远程执行命令，无需输入密码

```sh
ssh root@192.168.80.151 "ip a |grep inet"


ssh root@192.168.80.151 "cat ~/.ssh/id_rsa.pub" >> ~/.ssh/authorized_keys #将远程服务器的id_rsa.pub文件的内容写入到本地的authorized_keys文件中

```

<!--

在客户端使用ssh-keygen生成一对密钥：公钥+私钥
将客户端公钥追加到服务端的authorized_key文件中，完成公钥认证操作
认证完成后，客户端向服务端发起登录请求，并传递公钥到服务端
服务端检索authorized_key文件，确认该公钥是否存在
如果存在该公钥，则生成随机数R，并用公钥来进行加密，生成公钥加密字符串pubKey(R)
将公钥加密字符串传递给客户端
客户端使用私钥解密公钥加密字符串，得到R
服务端和客户端通信时会产生一个会话ID(sessionKey)，用MD5对R和SessionKey进行加密，生成摘要（即MD5加密字符串）
客户端将生成的MD5加密字符串传给服务端
服务端同样生成MD5(R,SessionKey)加密字符串
如果客户端传来的加密字符串等于服务端自身生成的加密字符串，则认证成功
此时不用输入密码，即完成建连，可以开始远程执行shell命令了

ssh root@192.168.80.151 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys #将本地的id_rsa.pub文件的内容写入到远程服务器authorized_keys文件中..好像不对
-->
