# seclabel

瀚高数据库用户的属主无法删除表，主要是安全标记限制

## 介绍

用户新建的表，都会在 pg_table_level 中增加一行记录，记下表的 oid 和
其 level。默认 level 是创建表的用户的 level。系统安全员 syssso 可以通过
set_table_level 函数修改表对应的安全敏感标记。

系统管理员sysdba新建的用户，都会在pg_user_level表中增加一行记录，
记下用户的 oid 和用户的 level。三个管理员默认的 level 是 0，普通用户默认
的 level 是 100。系统安全员 syssso 可以通过 set_user_level 函数修改用户的
敏感标记。

riil=> select * from hg_table_level where relname= 'part_alarm1_rut_20191219_0000';
  oid  |   nspname    |            relname            | level 
-------+--------------+-------------------------------+-------
 66148 | riil_product | part_alarm1_rut_20191219_0000 |     0
(1 row)

riil=>  select set_table_level(66148,100);
 set_table_level 
-----------------
 t
(1 row)

## 查看

syssso用户执行命令
select show_secure_param();

hg_macontrol 强制访问控制功能开关，默认 on，开
启强制访问控制；参数值为 min，表
示强访功能最小化，即只有自主访问
控制功能。参数值重启生效。
hg_rowsecure 行级强制访问功能开关。该参数只在
hg_macontrol 为 on 时生效。参数值为
on|off，on 为开启行级访问控制，off
为关闭行级访问控制，开启表级访问
控制。默认为 off。参数值重启生效。