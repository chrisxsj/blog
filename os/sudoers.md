# sudoers

使该用户在使用sudo时免密码输入。
例如对于用户 highgo，使用root用户编辑/etc/sudoers，并添加如下行:

```sh
## Same thing without a password--在这行下面添加
# %wheel    ALL=(ALL)   NOPASSWD: ALL
highgo  ALL=(ALL)       NOPASSWD: ALL
%highgo  ALL=(ALL)       NOPASSWD: ALL
```

测试
$ sudo tail -n 50 /var/log/messages
