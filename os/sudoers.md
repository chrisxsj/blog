# sudoers

**作者**

Chrisx

**日期**

2021-05-12

**内容**

系统资源限制

----

[toc]

## sudo免密码登录

例如对于用户 highgo，使用root用户编辑/etc/sudoers，并添加如下行:

```sh
## Same thing without a password--在这行下面添加
# %wheel    ALL=(ALL)   NOPASSWD: ALL
highgo  ALL=(ALL)       NOPASSWD: ALL
%highgo  ALL=(ALL)       NOPASSWD: ALL
```

测试

```sh
$ sudo tail -n 50 /var/log/messages

```