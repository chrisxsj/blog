# pg_auth_security

**作者**

Chrisx

**日期**

2021-07-06

**内容**

认证安全

---

[TOC]

## 1. 密码安全存储

密码始终以加密方式存储在系统目录中。加密方式可以通过password_encryption参数配置。

``` sql

--create role test with login encryped password 'test';
create role test with login ENCREPED password 'test'; --ENCREPED 关键字没有任何效果, 但被接受向后兼容。

show password_encryption;
password_encryption
---------------------
md5
(1 row)

select usename,passwd from pg_shadow where usename='test';
 usename |               passwd
---------+-------------------------------------
 test    | md505a671c66aefea124cc08b76ea6d30bb
(1 row)

```

## 2. 密码更换周期

pg支持密码有效期配置，可以通过配置密码有效期，制定密码更换周期。

``` sql
alter role test valid until '2020-04-24 10:10:00';

select usename,valuntil  from pg_user where usename='test';
 usename |        valuntil        
---------+------------------------
 test    | 2020-12-10 16:58:00+08

```

有效期超期报错

```sh
psql -h 192.168.6.10 -U test -d highgo
Password for user test:
psql: FATAL: password authentication failed for user "test"
```

infinity 设置用户密码永不过期

``` sql
alter user test with valid until 'infinity';
```

## 3. 密码复杂度策略

passwordcheck.so模块可以实现密码复杂度要求，此模块可以检查密码，如果密码太弱，他会拒绝连接创建用户或修改用户密码时，强制限制密码的复杂度，限制密码不能重复使用。例如密码长度，包含数字，字母，大小写，特殊字符等，同时排除暴力破解字典中的字符串

参考[passwordcheck](https://www.postgresql.org/docs/11/passwordcheck.html)

### 启用模块

添加$libdir目录下的passwordcheck到参数shared_preload_libraries，重启生效

查看$libdir

``` sql

select name,setting from pg_settings where name like '%dynamic%';
name | setting
----------------------------+---------
dynamic_library_path | $libdir
dynamic_shared_memory_type | posix
(2 rows)
```

or

```sh
ls -atl `pg_config |grep LIBDIR |head -n 1 |awk '{printf $3}'`/postgresql/passwordcheck*
-rwxr-xr-x 1 postgres postgres 8616 Feb 27 10:09 /opt/pg122/lib/postgresql/passwordcheck.so
```

:warning: 默认so文件都存放在$libdir目录下

启用模块，配置参数shared_preload_libraries

```sql
alter system set shared_preload_libraries=passwordcheck;

```

重启生效

### 复杂度功能验证

密码复杂度检查模块Passwordcheck，可实现简单密码复杂度验证

验证创建的用户密码是否符合规则。

密码：最少8个字符；必须包含数字和字母；密码中不能含有用户名字段。

``` sql
alter role test with password 'test';
ERROR: password is too short
alter role test password '12345678';
ERROR: password must contain both letters and nonletters
alter role test with password 'test1234';
ERROR: password must not contain user name
alter role test with password 'tttt1234';
ALTER ROLE

```

### 复杂的密码复杂度需求自定义

需要修改 passwordcheck.c 文件。会c语言的可自行修改。

1. 长度要求，直接需修改为12，默认是8

``` bash
/* passwords shorter than this will be rejected */
#define MIN_PWD_LENGTH 12
```

2. 包含字符、数字、特殊字符，需要改写C文件

修改好的passwordcheck.c参考[passwordcheck](../lib/c/passwordcheck.c)，可直接使用。

参考[原文](https://github.com/Luckyness/passwordcheck/blob/master/passwordcheck.c)

其他密码复杂度需求，参考[passwordcheck.zip](../../highgo/support/passwordcheck.zip)

## 4. 密码验证失败延迟

auth_delay.so模块会导致服务器在报告身份验证失败之前短暂停留, 这个主要用于防止暴力破解. 验证失败后, 延迟一个时间窗口才能继续验证。请注意, 它不会阻止拒绝服务攻击, 甚至可能会加剧这些攻击, 因为在报告身份验证失败之前等待的进程仍将使用连接插槽。

### 启用模块

需要配置以下参数，实现密码验证延迟失败延迟

so文件存储在$libdir下

``` bash

ls -atl $PGHOME/lib/auth_delay*
-rwxr-xr-x 1 postgres postgres 8352 Feb 27 10:09 /opt/pg122/lib/postgresql/auth_delay.so
```

参数修改

``` sql

shared_preload_libraries --预加载模块
auth_delay.milliseconds (int) --指定延迟时间
alter system set shared_preload_libraries=passwordcheck,auth_delay;
重启生效
alter system set auth_delay.milliseconds=5000;
reload生效
```

:warning: auth_delay.milliseconds需要启用auth_delay后才可以设置

### 验证

``` bash
psql -h 192.168.6.10 -U test -p 5432 -d postgres
Password for user test:
--5s
psql: FATAL: password authentication failed for user "test"

输入密码后，如果密码不正确，会等待5s，然后返回密码失败提示
psql -h 192.168.6.12 -U test -p 5432 -d postgres
Password for user test:
psql (10.4)
Type "help" for help.
postgres=>

输入密码后，如果密码正确，没有等待。
```

:warning: 密码验证失败次数限制，失败后锁定, 以及解锁时间。目前PostgreSQL不支持这个安全策略, 目前只能使用auth_delay来延长暴力破解的时间.

## 5. 设置密码时防止密码被记录到日志中

密码的配置命令可能会被记录到history文件及csvlog日志文件中（如果开启了DDL或更高级别审计log_statement），这些文件明文记录了密码，可能造成密码泄露风险。

### 密码记录到3个地方

1. 介绍

* HISTFILE

The file name that will be used to store the history list. If unset, the file name is taken from the PSQL_HISTORY environment variable. If that is not set either, the default is ~/.psql_history, or %APPDATA%\postgresql\psql_history on Windows. For example, putting:
\set HISTFILE ~/.psql_history- : DBNAME
in ~/.psqlrc will cause psql to maintain a separate history for each database.
Note
This feature was shamelessly plagiarized from Bash. --

* csvlog

数据库错误日志

* pg_stat_statements模块

2. 记录情况查看

如以下命令，会记录到HISTFILE和csvlog日志中

``` sql
postgres=# alter role test with password 'tttt1234';
```

* history file记录

```sh
cat ~/.psql_history |grep tttt1234
alter role test with password 'tttt1234';
```

* csvlog记录

```sh
cat $PGDATA/postgresql.conf |grep log_statement
#log_statement = 'none'         # none, ddl, mod, all
log_statement = 'ddl'
#log_statement_stats = off

cat $PGDATA/pg_log/postgresql-2019-04-12_092557.csv |grep tttt1234
2019-04-12 09:33:23.036 CST, "pg", "postgres", 1309, "[local]", 5cafeadb.51d, 3, "idle", 2019-04-12 09:33:15 CST, 3/21, 0, LOG, 00000, "statement: alter role test with password 'tttt1234'; ", , , , , , , , , "psql"

```

### 解决方式

* 使用md5值设置密码
* 使用createuser命令行工具-W选项提示输入密码。
* 选择使用域认证或其他第三方认证方法，密码策略就交由第三方管理
* 调用pg_stat_statements_reset()来清除pg_stat_statements记录的SQL或者配置pg_stat_statements.track_utility=off，就不会跟踪记录DDL语句了

```sh
createuser -l -h 127.0.0.1 -p 5432 -U pg -W tuser
Password:

再次查看日志，密码没有被记录
cat $PGDATA/pg_log/postgresql-2019-04-12_092557.csv |grep tuser
2019-04-12 11:17:48.348 CST,"pg","postgres",1574,"localhost:42560",5cb0035c.626,3,"idle",2019-04-12 11:17:48 CST,3/236,0,LOG,00000,"statement: CREATE ROLE tuser NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;",,,,,,,,,"createuser"
```

:warning: 也可以使用psql工具元命令\password。

## 6. 客户端网络访问控制

在$PGDATA/pg_hba.conf文件中配置网络访问控制，可限制连接网段和IP地址

如：

``` 
# IP reject set
host       all           all           192.168.6.1/32             reject
host       all           all           192.168.6.0/24             reject
```

reload生效
pg_ctl reload

解释：
第一列：类型，host表示TCP/IP连接
第二列：数据库，all表示可以访问所有数据库
第三列：数据库用户，all表示允许所有数据库用户连接
第四列：地址，指定具体的主机名或IP地址
第五列：验证方式，reject表示拒绝连接

:warning: 每次连接尝试都会按顺序检查pg_hba.conf文件中的记录，因此限制IP记录应该放在靠前的位置

安全建议

* 任何情况下都不允许trust认证方法；
* 超级用户postgres只允许从本地连接，不允许从网络连接；
* 将dbname+username+ip限制到最小，"授权用户"只能从"授权IP"过来连接"授权数据库"；
* 使用最小权限范围鉴权, 尽量避免使用all, 0.0.0.0/0 这种大范围授权密码更换周期;
* 使用数据库密码认证，务必使用md5认证方法，网络传输的密码是md5+随机字符加密后的密文;
