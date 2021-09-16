How to Allow Only root User to Login Through SSH (Doc ID 1614856.1)

In this Document
 
Goal
Solution
Method 1 could be used to allow a few users to SSH login
Method 2 is quickest way to block all non-root users from SSH login
Method 3 could be used to allow a large number of users to login through SSH by providing a user list
 
Applies to:
Linux OS - Version Oracle Linux 5.0 and later
Linux x86-64
Linux x86
Goal
By default all users can SSH login the system with a valid password/public key.
 
For certain dedicated Servers, such as FTP Server, E-mail Server, etc. which have amount of user accounts shared authentication with Linux system, disabling non-root users to login through SSH will be a wise choice in this scenario.
Solution
Either of three ways below could achieve the goal in this document.
Note:
Hosts information:
host1 IP Address: 192.168.0.10
host2 IP Address: 172.16.16.10
 
Method 1 could be used to allow a few users to SSH login
Edit the file /etc/ssh/sshd_config (OpenSSH SSH daemon configuration file) and add keyword "AllowUsers" with argument "root":
AllowUsers root
 
Note: keywords are case-insensitive and arguments are case-sensitive.
 
Then restart sshd service:
[root@host1 ~]# service sshd restart
Stopping sshd:                                             [  OK  ]
Starting sshd:                                             [  OK  ]
 
Verify non-root users are not able to login through SSH:
[root@host2 ~]# ssh test@host1
test@host1's password:
Permission denied, please try again.
test@host1's password:
Permission denied, please try again.
test@host1's password:
Permission denied (publickey,gssapi-with-mic,password).
[root@host2 ~]# ssh root@host1
root@host1's password:
Last login: Thu Jan 16 08:40:43 2014 from host2
[root@host1 ~]#
 
System log in SSH server host1:
[root@host1 ~]# tail /var/log/secure
(snip)
Jan 16 09:00:49 host1 sshd[11248]: User test from host2 not allowed because not listed in AllowUsers
Jan 16 09:00:49 host1 sshd[11249]: input_userauth_request: invalid user test
Jan 16 09:00:54 host1 sshd[11248]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=host2  user=test
Jan 16 09:00:56 host1 sshd[11248]: Failed password for invalid user test from 172.16.16.10 port 39020 SSH2
Jan 16 09:01:07 host1 last message repeated 2 times
Jan 16 09:01:07 host1 sshd[11249]: Connection closed by 172.16.16.10
Jan 16 09:01:07 host1 sshd[11248]: PAM 2 more authentication failures; logname= uid=0 euid=0 tty=ssh ruser= rhost=host2  user=test
Jan 16 09:03:34 host1 sshd[11260]: Accepted password for root from 172.16.16.10 port 39055 SSH2
Jan 16 09:03:34 host1 sshd[11260]: pam_unix(sshd:session): session opened for user root by (uid=0)
 
Method 2 is quickest way to block all non-root users from SSH login
Create a file /etc/nologin.
[root@host1 ~]# touch /etc/nologin
[root@host1 ~]# ls -ctrl /etc/nologin
-rw-r--r-- 1 root root 0 Jan 16 09:14 /etc/nologin
 
Note:
If this file exists, only root user is allowed to login the system through SSH.
If the file /etc/nologin.txt exists, nologin displays its contents to the user instead of the default message.
 
Make sure the below line is in the file /etc/pam.d/sshd:
account    required     pam_nologin.so
 
Then restart sshd service:
[root@host1 ~]# service sshd restart
Stopping sshd:                                             [  OK  ]
Starting sshd:                                             [  OK  ]
 
Verify non-root user SSH login:
[root@host2 ~]# ssh test@host1
test@host1's password:
Connection closed by 192.168.0.10
[root@host2 ~]#
 
System log in SSH server host1:
[root@host1 ~]# tail  /var/log/secure
(snip)
Jan 16 09:17:00 host1 sshd[11429]: Failed password for test from 172.16.16.10 port 39253 SSH2
Jan 16 09:17:00 host1 sshd[11430]: fatal: Access denied for user test by PAM account configuration
Jan 16 09:19:54 host1 sshd[11437]: Accepted password for root from 172.16.16.10 port 39311 SSH2
Jan 16 09:19:54 host1 sshd[11437]: pam_unix(sshd:session): session opened for user root by (uid=0)
Method 3 could be used to allow a large number of users to login through SSH by providing a user list
 
Note: backup the file /etc/pam.d/sshd before modifying it.
 
Add root user to the file /etc/sshd/sshd.allow (if directory/file does not exist, create it manually), one user per line:
[root@host1 ~]# vi /etc/sshd/sshd.allow
[root@host1 ~]# cat /etc/sshd/sshd.allow
root
[root@host1 ~]#
 
Replace auth line as below in file /etc/pam.d/sshd:
auth required pam_listfile.so item=user sense=allow file=/etc/sshd/sshd.allow onerr=fail
 
Note:
auth required pam_listfile.so : Name of the module required while authenticating users.
item=user : Check item user name.
sense=allow : Allow user.
file=/etc/sshd/sshd.allow : User list file.
onerr=fail : If the user name is not in file it will not allow to login.
 
Then restart sshd service:
[root@host1 ~]# service sshd restart
Stopping sshd:                                             [  OK  ]
Starting sshd:                                             [  OK  ]
 
Verify non-root user SSH login:
[root@host2 ~]# ssh test@host1
test@host1's password:
Permission denied, please try again.
test@host1's password:
Permission denied, please try again.
test@host1's password:
Permission denied (publickey,gssapi-with-mic,password).
[root@host2 ~]# ssh root@host1
ssh root@host1's password:
Last login: Thu Jan 16 09:52:23 2014 from host2
[root@host1 ~]#
 
System log in SSH server host1:
[root@host1 ~]# tail /var/log/secure
(snip)
Jan 16 09:52:49 host1 sshd[11741]: pam_listfile(sshd:auth): Refused user test for service sshd
Jan 16 09:52:49 host1 sshd[11741]: Failed password for test from 172.16.16.10 port 40134 SSH2
Jan 16 09:52:53 host1 sshd[11741]: pam_listfile(sshd:auth): Refused user test for service sshd
Jan 16 09:52:53 host1 sshd[11741]: Failed password for test from 172.16.16.10 port 40134 SSH2
Jan 16 09:52:56 host1 sshd[11741]: pam_listfile(sshd:auth): Refused user test for service sshd
Jan 16 09:52:56 host1 sshd[11741]: Failed password for test from 172.16.16.10 port 40134 SSH2
Jan 16 09:52:57 host1 sshd[11742]: Connection closed by 172.16.16.10
Jan 16 09:53:10 host1 sshd[11743]: Accepted password for root from 172.16.16.10 port 40136 SSH2
Jan 16 09:53:10 host1 sshd[11743]: pam_unix(sshd:session): session opened for user root by (uid=0)
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=361452653445713&id=1614856.1&_adf.ctrl-state=4wjl154pq_297>