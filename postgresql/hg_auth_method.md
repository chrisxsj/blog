# hg_auth_method

**作者**

Chrisx

**日期**

2021-06-29

**内容**

修改数据库认证方式

md5和sm3相互修改，混合使用

---

[toc]

## 确认密码保存格式

```sql
highgo=# select rolname,rolpassword from pg_authid ;
          rolname          |             rolpassword
---------------------------+-------------------------------------
 pg_monitor                |
 pg_read_all_settings      |
 pg_read_all_stats         |
 pg_stat_scan_tables       |
 pg_read_server_files      |
 pg_write_server_files     |
 pg_execute_server_program |
 pg_signal_backend         |
 syssao                    | MD538278e9432a2eebe731918dbe17e2705
 syssso                    | MD5b1d221182e56496ba633c4f4b0442f93
 sysdba                    | MD575c4c19e4a44a566c1852d1f24790f82
 taudit                    | MD5d89a1657ff40c07261434c174a75067b
(12 rows)
```

## 修改认证方法

1. 修改密码保存格式

全局修改

```sql
\c - sysdba
alter system set password_encryption ='sm3';
select pg_reload_conf();
alter user sysdba password 'PWD';
```

:warning: 建议统一修改所有用户

临时修改

```sql
sysdba登陆
set password_encryption ='md5';
alter user sysdba password 'PWD';
syssso登录
set password_encryption ='md5';
alter user syssso password 'PWD';
syssao登录
set password_encryption ='md5';
alter user syssao password 'PWD';

```

2. 修改认证方式

认证方式需要与密码保存格式一致

```sh
$ cat $PGDATA/pg_hba.conf |grep -E '^[a-z]'

local   all             all                                     sm3
host    all             all             127.0.0.1/32            sm3
host    all             all             ::1/128                 md5
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
host    all             sysdba          192.168.0.0/16          sm3
host    all             all             192.168.0.0/16          md5

$ pg_ctl reload

```

:warning: 已下3中登陆方式使用sm3验证登录，其他使用md5验证登录

```sh
local   all             all                                     sm3
host    all             all             127.0.0.1/32            sm3
host    all             sysdba          192.168.0.0/16          sm3
```

3. 确认密码格式

```sql
highgo=# select rolname,rolpassword from pg_authid ;
          rolname          |                             rolpassword
---------------------------+---------------------------------------------------------------------
 pg_monitor                |
 pg_read_all_settings      |
 pg_read_all_stats         |
 pg_stat_scan_tables       |
 pg_read_server_files      |
 pg_write_server_files     |
 pg_execute_server_program |
 pg_signal_backend         |
 syssao                    | md538278e9432a2eebe731918dbe17e2705
 sysdba                    | sm3aa39d5d018cd6ac979bb396b34c377850fdd8af9436c2b6bf5d64cdff66cf9d8
 syssso                    | md5b1d221182e56496ba633c4f4b0442f93
 taudit                    | md5d89a1657ff40c07261434c174a75067b
(12 rows)

```

## 登陆验证

sysdba密码格式sm3，使用的sm3验证方式，根据pg_hba，可以使用本机登录和远程登录。
syssso密码格式MD5，使用的md5验证方式，根据pg_hba，只能使用远程登录

```sh

[hgdb456@8cfba0c9a15f HighGo4.5.6-data]$ psql -U sysdba -W
Password:
NOTICE:
-------------------------------------------
Login User: sysdba
Login time: 2021-06-29 09:16:56.833439+00
Login Address: [local]
Last Login Status: SUCCESS
Login Failures: 0
Valied Until: 2021-07-06 08:48:36+00
-------------------------------------------

psql (4.5.6)
Type "help" for help.

highgo=# \q


[hgdb456@8cfba0c9a15f HighGo4.5.6-data]$ psql -U syssso -W -h 192.168.6.11
Password:
NOTICE:
-------------------------------------------
Login User: syssso
Login time: 2021-06-29 09:17:55.993589+00
Login Address: 192.168.6.11
Last Login Status: FAILED
Login Failures: 2
Valied Until:
-------------------------------------------

psql (4.5.6)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

highgo=>


```
