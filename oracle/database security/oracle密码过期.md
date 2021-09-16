1 密码过期
通常基于安全考虑，会配置profile限制用户密码。profile对用户密码的限制，常用的参数如下
PASSWORD_LIFE_TIME    180    --密码有效期，超过有效期密码会过期，阻止用户登陆。默认180天
PASSWORD_GRACE_TIME    7    --指定宽限期，密码到期前开始后发出警告并允许登录的天数。默认7天
FAILED_LOGIN_ATTEMPTS    10    --密码尝试失败的次数，达到上线即锁定账户。默认10次
PASSWORD_LOCK_TIME    1    --密码尝试失败达到最大次数后，锁定账户的时间。默认1天。

详细参考文档
https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_6010.htm#SQLRF01310

当设置了密码生命周期后，可以通过dba_user查询用户的锁定时间和过期时间
select USERNAME,ACCOUNT_STATUS,LOCK_DATE,to_char(EXPIRY_DATE,'yyyy-mm-dd hh24:mi:ss'),profile from dba_users where account_status like '%EXPIRED%'or account_status like '%LOCKED%';

如：JACT账户密码过期时间为 2019-01-30 15:09:28，账户状态为EXPIRED
SQL> select USERNAME,ACCOUNT_STATUS,LOCK_DATE,to_char(EXPIRY_DATE,'yyyy-mm-dd hh24:mi:ss') from dba_users where username='JACT';

USERNAME               ACCOUNT_STATUS            LOCK_DATE TO_CHAR(EXPIRY_DATE
------------------------------ -------------------------------- --------- -------------------
JACT                   EXPIRED                      2019-01-30 17:25:32

重置密码
alter user JACT identified by XXX;

重置密码后查询过期时间，依据profile设置，为180天以后
SQL> select USERNAME,ACCOUNT_STATUS,LOCK_DATE,to_char(EXPIRY_DATE,'yyyy-mm-dd hh24:mi:ss') from dba_users where username='JACT';

USERNAME               ACCOUNT_STATUS            LOCK_DATE TO_CHAR(EXPIRY_DATE
------------------------------ -------------------------------- --------- -------------------
JACT                   OPEN                      2019-07-30 09:43:17

2 为什么过期账户状态依然是open

但是有时候会发现账户已经超期，但其状态依然是open的。为什么呢？
SQL> select USERNAME,ACCOUNT_STATUS,LOCK_DATE,to_char(EXPIRY_DATE,'yyyy-mm-dd hh24:mi:ss') from dba_users where ACCOUNT_STATUS='OPEN';

USERNAME               ACCOUNT_STATUS            LOCK_DATE TO_CHAR(EXPIRY_DATE
------------------------------ -------------------------------- --------- -------------------
SYS                   OPEN                      2019-01-16 09:35:21
JIEP2018               OPEN                      2019-02-18 14:55:35
JGET                   OPEN                      2019-01-23 15:36:23

Hello,

An account has an account_status of OPEN but it's expiry date is very old (ex: 18-JUL-04)..

select username,account_status,expiry_date from dba_users where username='SCOTT'

SCOTT OPEN 18-JUL-04

I'm not sure how this could be possible...ANy clues?

Thanks for your time..

Scott hasn't logged on since 18-JUL-04


There is no process that combs through accounts to reset their status vis a vis expiry date. The next time scott logs on his status will be updated accordingly, and the grace period will begin.




3 修改为原来的密码
如果Oracle 数据库的用户密码过期，如何把密码修改为原来的密码？
This question has been Answered.

Silky-Oracle Jul 6, 2018 2:02 AM
我们都知道Oracle 数据库的用户的密码默认是有有效期限制的，特别是在Cloud上面的DB，有些用户是Cloud自动创建的，我们不知道原来的密码是什么，但是如果密码过期了，如果修改成新的密码，会影响已有的程序的正常运行，特别是在Java Cloud和SOA Cloud上面是肯定会影响服务的正常运行的，我们如何在不知道原来密码的情况下把这个密码修改为原来的密码呢？

Correct Answer
by Silky-Oracle on Jul 6, 2018 2:13 AM
请按照这个链接里的
http://www.ateam-oracle.com/avoiding-and-resetting-expired-passwords-in-oracle-databases/#respond
Option 2: restore previous password
进行修改，如果是12c的DB，只需要修改PDB的，不需要修改CDB的。


生成脚本
spool on;
set lines 300;
set echo off;
set heading off;
set feedback off;
SET   SERVEROUTPUT  OFF;
spool pwchangeo.sql;
select 'ALTER USER '|| USERNAME || ' identified by values ''' || spare4 || ''';' from dba_users,user$
where ACCOUNT_STATUS like '%EXPIRED%' and USERNAME=NAME;
spool off;

脚本内容如下：
[oracle@db ~]$ cat pwchangeo.sql
SQL> select 'ALTER USER '|| USERNAME || ' identified by values ''' || spare4 || ''';' from dba_users,user$
  2  where ACCOUNT_STATUS like '%EXPIRED%' and USERNAME=NAME;

ALTER USER OLAPSYS identified by values 'S:62B5D19290AE1EF1C7A9167834F7C6D78F29199256F54D36A8302F317C0C';                                                                                                                                                                                                   
ALTER USER SI_INFORMTN_SCHEMA identified by values 'S:C974F62018B80B18259C252016B65C68854264644A7A13F45AB03D1C188E';                                                                                                                                                                                        
ALTER USER MGMT_VIEW identified by values 'S:0F8FC5243FC12D55E464B0F443E5AE0D08A029B247EFBD551B8BAF71A3CE';                                                                                                                                                                                                 
ALTER USER OWBSYS identified by values 'S:1D338B0D7DBB78E7753B11E06478ACBEEC1579E97010C2EB9DC12526DBA2';  
......

修改为原密码
ALTER USER SCOTT identified by values 'S:07921277EB685F9816BA4776231FA31B0C0A84DD4DF70E5DEC761A6F6B53';   
