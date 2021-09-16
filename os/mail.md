**作者**

chrisx

**日期**

2021-06-11

**内容**

Mail（邮件服务）使用

----

[toc]

## 介绍

MUA：Mail User Agent，邮件用户代理，用来编写，收发邮件
MTA：Mail Transfer Agent，邮件传输代理，将邮件传输到正确目的地
MDA：Mail Delivery Agent，邮件分发代理，将邮件分发到正确目的用户

以一个例子来说明上面的关系。假如A用户使用的是QQ邮箱，B用户使用的是163邮箱，A要向B发送一封邮件。流程如下：

1、A用户通过MUA编写好邮件，并发送
2、该邮件通过MTA，首先发送到QQ邮件服务器
3、QQ邮件服务器分析到目的邮箱地址是163，所以再通过MTA传送到163邮件服务器
4、163邮件服务器收到该邮件
5、由于使用163邮箱的用户有很多，再通过MDA把该邮件发送到正确的用户
6、B用户通过MUA就可以查看A用户发送的邮件。

## 安装软件

```sh
yum install -y mailx sendmail
# mail是mailx的别名，mail是MUA，sendmail是MTA
```

## 配置

mail系统及配置文件为/etc/mail.rc，用户级配置文件为~/.mailrc。这里使用全局配置文件，在/etc/mail.rc文件最后添加如下内容：

```sh
set from=user@xxx.com               # 设置发信人邮箱和昵称
set smtp=smtps://smtp.xxx.com:465   # 这里填入smtp地址，这里的xxx为qq或者163等，如果用的云服务器，安全组策略要开放465端口，入站和出站都要开放该端口
set smtp-auth=login                 # 认证方式
set smtp-auth-user=user@xxx.com     # 这里输入邮箱账号
set smtp-auth-password=password     # 这里填入密码，这里是授权码而不是邮箱密码
set ssl-verify=ignore               # 忽略证书警告
set nss-config-dir=/etc/pki/nssdb   # 证书所在目录


```

## 启动sendmail

```sh
systemctl start sendmail
```

<!--

问题
systemctl status sendmail
sendmail[1251]: My unqualified host name (8cfba0c9a15f) unknown; sleeping for retry

解决方法：
1、vim /etc/hosts.allow 添加

sendmail:ecs-wdgp          #示例主机名称
sendmail:192.168.6.11      #示例主机ip

第一步就可以了。。。

2、vim /etc/hosts

192.168.6.11    8cfba0c9a15f

3、vim /etc/mail/access

Connect:localhost.localdomain           RELAY
Connect:localhost                       RELAY
Connect:127.0.0.1                       RELAY
Connect:192.168.6.11                       RELAY

4、vim /etc/mail/sendmail.cf

#找到以下内容，并添加
# SMTP daemon options
	
O DaemonPortOptions=Port=smtp,Addr=127.0.0.1, Name=MTA
	
O DaemonPortOptions=Port=smtp,Addr=192.168.1.95, Name=MTA

5、vim /etc/mail.rc

#添加
set from="******@qq.com"
set smtp="smtp.qq.com"
set smtp-auth-user="********@qq.com"
set smtp-auth-password="koqdeysdkxqz"	#SMTP授权码，不是登录密码
set smtp-auth=login

修改完成后重启sendmail服务来进行验证

-->

## 通过mail命令发送邮件

echo "正文" |mail -s "邮件标题" 收件人邮箱

mail -s '邮件标题' 收件人邮箱 < 附件内容.txt

## 管理

mailq 查看发邮件的队列
/var/log/mail/ 日志目录
