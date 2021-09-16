# hgdb_password_lock

**作者**

Chrisx

**日期**

2021-06-22

**内容**

清理密码超次数限制

---

[toc]

hgdb

密码有效期决定了用户密码更新的频率，默认密码有效期是 7 天。用户每次
修改密码后，新的密码在 7 天后到期，用户必须修改一个新密码，或者由安全员
重新设置到期时间才能继续登录数据库。密码有效期参数是 hg_PwdValidUntil，
安全管理员可以修改这个参数，允许的设置范围是 1~365，单位是天。
需要注意的是，在初始化数据库后，三个管理员都是有 7 天的密码有效期的，
建议修改密码，修改后安全员将不再有有效期限制。
用户执行修改密码操作时，新的密码必须与旧密码不同，否则无法修改成功。

安全版密码有效期到期或这密码尝试失败次数超限

可用以下方法解决

## hgdb45之前

1、检查日志，如果是后台应用不断尝试连接数据库，请暂时关掉应用连接。
2、协调通知同网络内其他用户断开连接或通过修改pg_hba.conf文件暂时关闭网络访问。
清理密码超次数限制：
syssso用户

select clear_user_limit('username');
username小写，替换成实际用户名

此外
也可以修改限制次数（需要重启）
修改次数限制（例如设置为7次验证）：

SELECT set_secure_param(‘hg_PwdErrorLock’, ’7’);

相关函数查询：

SELECT show_secure_param();

如果密码有效期到期，需要延长密码有效
延长密码到期时间，除syssso用户以外最长时间为一年有效期。
syssso用户

alter user sysdba valid until '2019-12-31';

## hgdb45及之后

取消密码超次数限制：
\c highgo syssso
SELECT set_secure_param('hg_idcheck.pwdlock','0');
\c - sysdba
select pg_reload_conf();

再改回5次密码限制
\c highgo syssso
SELECT set_secure_param('hg_idcheck.pwdlock','5');
\c - sysdba
select pg_reload_conf();

hg_idcheck.pwdlock,密码连续输入错误多少次后账户被锁，默认 5 次。参数范围值为 0-10次,设置为 0 表示不限制密码错误次数，重启后密码连续错误次数重新计
算。参数值动态（不重启）生效。

## 非常规途径

将$PGDATA/global/1121_lgx 重命名，然后再次尝试登陆

## 企业版解锁

管理员帐户执行以下命令解锁
select user_unlock('username');

username替换成实际用户名，username小写
