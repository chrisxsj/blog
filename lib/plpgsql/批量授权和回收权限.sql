===================
批量授权
===================
drop FUNCTION hg_grantdbtables;
CREATE OR REPLACE FUNCTION hg_grantdbtables(dbname text,schemaname text,permissions varchar(50),uername text)
RETURNS TEXT AS $$
DECLARE
  a_count_num  int :=0;
  s_count_num  int :=0;
  f_count_num  int :=0;
  row           RECORD;
BEGIN
  raise notice '%: 开始将%库中%模式下表的%权限赋予%用户.',clock_timestamp(),dbname,schemaname,permissions,uername;
  perform pg_sleep(1);  --休眠1秒
  BEGIN
CREATE temp table IF NOT EXISTS hg_grant_temp01  AS
  SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','p','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname <> 'information_schema'
      AND n.nspname !~ '^pg_toast'
  AND pg_catalog.pg_table_is_visible(c.oid);
  END;
  BEGIN
    FOR row IN select * from hg_grant_temp01 LOOP
        --raise notice 'GRANT %  ON TABLE  %  OWNER TO  %;',permissions,row."Name",username;
        EXECUTE 'GRANT ' || permissions || ' ON TABLE ' || row."Name" || ' TO ' ||  uername ||';';
        s_count_num := s_count_num + 1;
        --raise notice 's_count_num: %',s_count_num;
    END LOOP;
      select count(*) into a_count_num from hg_grant_temp01;
      --raise notice 'a_count_num: %',a_count_num;
      f_count_num := a_count_num - s_count_num;
      --raise notice 'f_count_num: %',f_count_num;
      raise notice '%: 共计%张表,%个赋权完成,%个赋权失败!',clock_timestamp(),a_count_num,s_count_num,f_count_num;
      drop table IF EXISTS hg_grant_temp01;
      return 'GRANT SUCCESSFUL ';
  END;
    EXCEPTION
    when others then
    raise notice '%: 共计%张表,%个赋权完成,%个赋权失败!',clock_timestamp(),a_count_num,s_count_num,f_count_num;
    drop table IF EXISTS hg_grant_temp01;
    return 'GRANT FAILED';
END;
$$
LANGUAGE PLPGSQL;

===========================================================================
执行效果如下：
===========================================================================
测试版：
===========================================================================
select hg_grantdbtables ('slb_test','public','select','b');
NOTICE:  开始将slb_test库中public模式下表的select权限赋予b用户.
NOTICE:  s_count_num: 1
NOTICE:  s_count_num: 2
NOTICE:  s_count_num: 3
NOTICE:  s_count_num: 4
NOTICE:  s_count_num: 5
NOTICE:  s_count_num: 6
NOTICE:  s_count_num: 7
NOTICE:  a_count_num: 7
NOTICE:  f_count_num: 0
NOTICE:  2021-10-24 21:53:01.878239+08: 共计7张表,7个赋权完成,0个赋权失败!
hg_grantdbtables  
-------------------
GRANT SUCCESSFUL
(1 row)
===========================================================================
正式版：
===========================================================================
slb_test=# select hg_grantdbtables ('slb_test','public','select','b');
NOTICE:  2021-10-24 22:19:39.64927+08: 开始将slb_test库中public模式下表的select权限赋予b用户.
NOTICE:  2021-10-24 22:19:40.65422+08: 共计7张表,7个赋权完成,0个赋权失败!
hg_grantdbtables  
-------------------
GRANT SUCCESSFUL
(1 row)


==============
批量回收权限
==============
drop FUNCTION hg_grantdbtables;
CREATE OR REPLACE FUNCTION hg_revokedbtables(dbname text,schemaname text,permissions varchar(50),uername text)
RETURNS TEXT AS $$
DECLARE
  a_count_num  int :=0;
  s_count_num  int :=0;
  f_count_num  int :=0;
  row           RECORD;
BEGIN
  raise notice '%: 开始将%库中%模式下表的%权限从%用户中收回.',clock_timestamp(),dbname,schemaname,permissions,uername;
  perform pg_sleep(1);  --休眠1秒
  BEGIN
CREATE temp table IF NOT EXISTS hg_grant_temp01  AS
  SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','p','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname <> 'information_schema'
      AND n.nspname !~ '^pg_toast'
  AND pg_catalog.pg_table_is_visible(c.oid);
  END;
  BEGIN
    FOR row IN select * from hg_grant_temp01 LOOP
        --raise notice 'GRANT %  ON TABLE  %  OWNER TO  %;',permissions,row."Name",username;
        EXECUTE 'REVOKE ' || permissions || ' ON TABLE ' || row."Name" || ' FROM ' ||  uername ||';';
        s_count_num := s_count_num + 1;
        --raise notice 's_count_num: %',s_count_num;
    END LOOP;
      select count(*) into a_count_num from hg_grant_temp01;
      --raise notice 'a_count_num: %',a_count_num;
      f_count_num := a_count_num - s_count_num;
      --raise notice 'f_count_num: %',f_count_num;
      raise notice '%: 共计%张表,%个回收权限完成,%个回收权限失败!',clock_timestamp(),a_count_num,s_count_num,f_count_num;
      drop table IF EXISTS hg_grant_temp01;
      return 'REVOKE SUCCESSFUL ';
  END;
    EXCEPTION
    when others then
    raise notice '%: 共计%张表,%个回收权限完成,%个回收权限失败!',clock_timestamp(),a_count_num,s_count_num,f_count_num;
    drop table IF EXISTS hg_grant_temp01;
    return 'REVOKE FAILED';
END;
$$
LANGUAGE PLPGSQL;

===========================================================================
执行效果如下：
===========================================================================
测试版：
===========================================================================
select hg_revokedbtables ('slb_test','public','select','b');
NOTICE:  开始将slb_test库中public模式下表的select权限从b用户中收回.
NOTICE:  s_count_num: 1
NOTICE:  s_count_num: 2
NOTICE:  s_count_num: 3
NOTICE:  s_count_num: 4
NOTICE:  s_count_num: 5
NOTICE:  s_count_num: 6
NOTICE:  s_count_num: 7
NOTICE:  2021-10-24 21:58:54.716591+08: 共计7张表,7个回收权限完成,0个回收权限失败!
hg_revokedbtables
-------------------
REVOKE SUCCESSFUL
(1 row)
===========================================================================
正式版：
===========================================================================
slb_test=# select hg_revokedbtables ('slb_test','public','select','b');
NOTICE:  2021-10-24 22:20:04.239652+08: 开始将slb_test库中public模式下表的select权限从b用户中收回.
NOTICE:  2021-10-24 22:20:05.244284+08: 共计7张表,7个回收权限完成,0个回收权限失败!
hg_revokedbtables  
--------------------
REVOKE SUCCESSFUL
(1 row)



附加：
测试环境
create table test01 (id int);
insert into test01 values (001);
create table test02 (id int);
insert into test02 values (002);
create table test03 (id int);
insert into test03 values (003);
create table test04 (id int);
insert into test04 values (004);
create table test05 (id int);
insert into test05 values (005);



alter table test02 owner to a;
alter table test03 owner to b;
alter table test04 owner to s;
alter table test05 owner to slb;