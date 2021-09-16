# Pg_privilege1

查看权限

## role系统权限

--看用户有哪些role权限

\du

or

********* QUERY **********
SELECT r.rolname, r.rolsuper, r.rolinherit,
  r.rolcreaterole, r.rolcreatedb, r.rolcanlogin,
  r.rolconnlimit, r.rolvaliduntil,
  ARRAY(SELECT b.rolname
        FROM pg_catalog.pg_auth_members m
        JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
        WHERE m.member = r.oid) as memberof
, r.rolreplication
, r.rolbypassrls
FROM pg_catalog.pg_roles r
WHERE r.rolname !~ '^pg_' and r.rolname='USERNAME' --替换成用户名
ORDER BY 1;

## 查看对象权限

\dp+

or

--1、查看某用户的表权限
select * from information_schema.table_privileges where grantee='USER_NAME' and table_name='TABLE_NAME';
--2、查看usage权限表
select * from information_schema.usage_privileges where grantee='user_name';
--3、查看存储过程函数相关权限表
select * from information_schema.routine_privileges where grantee='user_name';


> 管理员创建的schema，与用户同名，还必须将usage和所有操作权限授予用户。否则用户无法查看schema中的对象，即使search_path设置正确或者用户自己创建对应名字的schema，则自动拥有所有权限或者最直接的做法就是,更改schema的属主

alter schema NAME owner to NAME;

psql -d appdb -U postgres -c "create schema appuser;"
psql -d appdb -U postgres -c "grant usage on schema appuser to appuser;"
psql -d appdb -U postgres -c "grant usage on schema appuser to appuser;"

<!--
with pr as
(SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'S' THEN 'sequence' WHEN 'f' THEN 'foreign table' WHEN 'P' THEN 'partitioned table' END as "Type",
  pg_catalog.array_to_string(c.relacl, E'\n') AS "Access privileges",
  pg_catalog.array_to_string(ARRAY(
    SELECT attname || E':\n  ' || pg_catalog.array_to_string(attacl, E'\n  ')
    FROM pg_catalog.pg_attribute a
    WHERE attrelid = c.oid AND NOT attisdropped AND attacl IS NOT NULL
  ), E'\n') AS "Column privileges",
  pg_catalog.array_to_string(ARRAY(
    SELECT polname
    || CASE WHEN polcmd != '*' THEN
           E' (' || polcmd || E'):'
       ELSE E':'
       END
    || CASE WHEN polqual IS NOT NULL THEN
           E'\n  (u): ' || pg_catalog.pg_get_expr(polqual, polrelid)
       ELSE E''
       END
    || CASE WHEN polwithcheck IS NOT NULL THEN
           E'\n  (c): ' || pg_catalog.pg_get_expr(polwithcheck, polrelid)
       ELSE E''
       END    || CASE WHEN polroles <> '{0}' THEN
           E'\n  to: ' || pg_catalog.array_to_string(
               ARRAY(
                   SELECT rolname
                   FROM pg_catalog.pg_roles
                   WHERE oid = ANY (polroles)
                   ORDER BY 1
               ), E', ')
       ELSE E''
       END
    FROM pg_catalog.pg_policy pol
    WHERE polrelid = c.oid), E'\n')
    AS "Policies"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'v', 'm', 'S', 'f', 'P')
  AND n.nspname !~ '^pg_' AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1, 2
) select * from pr where "Access privileges" like '%修改成要查询的用户名注意大小写%';

-->

## schema和owner

数据库、模式、表都有自己的owner，他们都属于实例中的对象，数据库owner只是具有数据库这个对象的CTc权限。数据库的默认权限为：

允许public角色连接，即允许任何人连接。

不允许除了超级用户和owner之外的任何人在数据库中创建schema。

会自动创建名为public的schema，这个schema的所有权限已经赋予给public角色，即允许任何人在里面创建对象。

schema使用注意事项：schema的owner默认是该schema下的所有对象的owner，但是允许用户在别人的schema下创建对象，所以一个对象的owner和schema的owner可能不同，都有drop对象的权限。