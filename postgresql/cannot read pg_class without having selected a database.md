# cannot read pg_clas

## 问题描述

*HGDB安全版*在做流复制如果用到pg_basebackup的话，默认情况下会报错

```bash
[highgo@node2 ssha]$ pg_basebackup -h 10.10.10.115 -p 5866 -U repuser -D /home/highgo/ssha/data/ -Fp -P -R -v -l highgobak -W
Password:
pg_basebackup: could not connect to server: 致命错误:  cannot read pg_class without having selected a database
第1行select rolvaliduntil from pg_roles where rolname = 'repuser'
                                 ^
查询:  select rolvaliduntil from pg_roles where rolname = 'repuser'
pg_basebackup: removing contents of data directory "/home/highgo/ssha/data/"
```

## 解决方案

```bash
highgo=> \c highgo syssso
select set_secure_param('hg_ShowLoginInfo' ,'off');
pg_ctl restart
```

此时再次执行pg_basebackup是没有问题的