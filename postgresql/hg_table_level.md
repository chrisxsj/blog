# hg_table_level

瀚高数据库用户的属主无法删除表

主要是安全标记限制

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