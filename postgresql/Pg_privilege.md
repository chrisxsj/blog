# pg_privilege

**作者**

Chrisx

**日期**

2021-07-06

**内容**

权限控制

---

[TOC]

对于用户权限的分配，建议使用最小权限原则。只授予用户需要的权限。

## 权限管理

### 分组权限的管理

如果是针对对象的所有权限，建议统一使用schema进行管理，大体过程如下

```sql
create schema SCHEMA_NAME;  --新建一个schema
grant all on schema SCHEMA_NAME to USER_NAME;   --对用户授予管理这个schema的权限
alter database "benchmarksql" set search_path to "$user", public,SCHEMA_NAME; --设置将该schema加入到搜索路径
```

### 具体对象授权管理

具体对象授权参考相关的语法

可能用到的授权语句语法

1. 授予用户对某个schema下的部分表或所有表的操作权限

``` sql
GRANT { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES |TRIGGER }
[, ...] | ALL [ PRIVILEGES ] }
ON { [ TABLE ] table_name [, ...]
| ALL TABLES IN SCHEMA schema_name [, ...] }
TO role_specification [, ...] [ WITH GRANT OPTION ]
```

2. 将某个schema下的函数授予用户执行权限（EXECUTE）或所有权限（ALL）

``` sql
GRANT { EXECUTE | ALL [ PRIVILEGES ] }
ON { FUNCTION function_name [ ( [ [ argmode ] [ arg_name ] arg_type [, ...] ] ) ] [, ...]
| ALL FUNCTIONS IN SCHEMA schema_name [, ...] }
TO role_specification [, ...] [ WITH GRANT OPTION ]
```

3. 授予用户对某个schema下的部分SEQUENCE或所有SEQUENCE的操作权限

``` sql
GRANT { { USAGE | SELECT | UPDATE }
[, ...] | ALL [ PRIVILEGES ] }
ON { SEQUENCE sequence_name [, ...]
| ALL SEQUENCES IN SCHEMA schema_name [, ...] }
TO role_specification [, ...] [ WITH GRANT OPTION ]

```

4. 授予用户对某个数据库的管理权限

``` sql
GRANT { { CREATE | CONNECT | TEMPORARY | TEMP } [, ...] | ALL [ PRIVILEGES ] }
ON DATABASE database_name [, ...]
TO role_specification [, ...] [ WITH GRANT OPTION ]
```

5. 授予用户对外部数据的权限

``` sql
GRANT { USAGE | ALL [ PRIVILEGES ] }
ON FOREIGN DATA WRAPPER fdw_name [, ...]
TO role_specification [, ...] [ WITH GRANT OPTION ]

```

6. 授予用户对语言的使用权限，如pl/pgsql、PL/Tcl等

``` sql
GRANT { USAGE | ALL [ PRIVILEGES ] }
ON LANGUAGE lang_name [, ...]
TO role_specification [, ...] [ WITH GRANT OPTION ]

```

7. 授予用户管理schema的权限

``` sql
GRANT { { CREATE | USAGE } [, ...] | ALL [ PRIVILEGES ] }
ON SCHEMA schema_name [, ...]
TO role_specification [, ...] [ WITH GRANT OPTION ]
```

8. 授予用户管理表空间的权限

``` sql
GRANT { CREATE | ALL [ PRIVILEGES ] }
ON TABLESPACE tablespace_name [, ...]
TO role_specification [, ...] [ WITH GRANT OPTION ]
```

9. 授予用户管理数据类型的权限

``` sql
GRANT { USAGE | ALL [ PRIVILEGES ] }
ON TYPE type_name [, ...]
TO role_specification [, ...] [ WITH GRANT OPTION ]
where role_specification can be:
[ GROUP ] role_name
| PUBLIC
| CURRENT_USER
| SESSION_USER

```

10. 将一个用户的权限授予另一个用户

``` sql
GRANT role_name [, ...] TO role_name [, ...] [ WITH ADMIN OPTION ]
```

:warning: 在pg中用户是一个特殊的role。USAGE表示只有使用权限，WITH ADMIN OPTION表示接收权限者拥有对其他用户授予该对象的权限。

## 行级安全

限制普通用户只能操作表中的指定条件的记录


## 安全建议

使用超级用户创建数据库，SCHEMA，应用所需的对象（如表，索引，函数）
创建应用账号角色
回收数据库，schema，language，应用对象的public权限
将数据库，schema的使用权限赋予给应用账号
将应用需要访问的对象的相关权限赋予给应用账号
授予表的select,insert,update,delete权限, 函数的execute权限等
严控DROP，TRUNCATE，REPLACE等权限	
通过事件触发器禁止应用账号执行DDL
防被攻击后，用户DROP或TRUNCATE删除对象或清空数据 
防止执行不带条件的delete,update
在需要保护的表里，新增一条dummy记录，创建行触发器，当这条记录被更新或删除时，抛出异常。

