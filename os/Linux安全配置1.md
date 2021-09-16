身份鉴别类
1 被测服务器账户口令未设最短、最长使用期限，口令最短长度要求设为5位，口令到期前7天开始通知用户口令即将到期，均为系统默认设置。
Linux: 编辑/etc/login.defs，修改以下参数：
PASS_MAX_DAYS、 PASS_MIN_DAYS、
PASS_MIN_LEN、PASS_WARN_AGE
建议：
先备份文件
cp /etc/login.defs /etc/login.defs.old
PASS_MAX_DAYS   9999
PASS_MIN_DAYS   0
PASS_MIN_LEN    6
PASS_WARN_AGE   8
操作系统用户密码最大天数无限制
操作系统用户密码可被修改
操作系统用户密码最小长度为6个字符
操作系统用户密码失效前8天告警提示
2 被测Linux服务器未在/etc/pam.d/system-auth中配置登录失败处理功能。
修改/etc/pam.d/system-auth参数，建立类似规则： “account required /lib/security/pam_tally.so deny=5 no_magic_root reset”
建议：
先备份文件
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.old
[root@db ~]# which pam_tally2
/sbin/pam_tally2
auth required pam_tally2.so deny=6 unlock_time=30 no_magic_root reset
account required pam_tally2.so
操作系统用户使用pam_tally2模块限制密码失败次数，失败6次后锁定，锁定时间为30s，root用户除外，密码正确后重置失败次数。
查看用户登录失败的次数
# pam_tally2 -u redhat
解锁指定用户
pam_tally2 -r -u redhat
3 
修改/etc/profile下的 TMOUT参数，设为标准值。