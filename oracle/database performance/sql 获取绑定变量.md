SELECT plan_hash_value,
       TO_CHAR(RAWTOHEX(child_address)),
       TO_NUMBER(child_number),
       id,
       LPAD(' ', DEPTH) || operation operation,
       options,
       object_owner,
       object_name,
       optimizer,
       cost,
       access_predicates,
       filter_predicates
  FROM V$SQL_PLAN =================>>>sql在shared pool中时.
 WHERE sql_id = 'bkcyk7bf380t6'
 ORDER BY 1, 3, 2, 4;
 
重点关注optimizer列，filter_predicates列。
 
 
若是该sql不在shared pool中时，改为执行如下的sql：
 
set linesize 500
set pagesize 500
col plan_hash_value format 9999999999
col id format 999999
col operation format a30
col options format a15
col object_owner format a15
col object_name format a20
col optimizer format a15
col cost format 9999999999
col access_predicates format a15
col filter_predicates format a15
 
SELECT plan_hash_value,
         id,
         LPAD (' ', DEPTH) || operation operation,
         options,
         object_owner,
         object_name,
         optimizer,
         cost,
         access_predicates,
         filter_predicates
    FROM dba_hist_sql_plan =================>>>当sql在awr中时.
   WHERE sql_id = 'b79fhz9cspd53'
ORDER BY plan_hash_value, id;


和 @?/rdbms/admin/awrsqrpt;

==============================
获取绑定变量的真实值
alter session set nls_date_format = 'yyyy-mm-dd,hh24:mi:ss';
set linesize 400
col sql_Id format a20
col name format a20
col datatype_string format a14
col value_string format a20
select sql_id,name, datatype_string, last_captured,value_string from v$sql_bind_capture where sql_id='dxfcacn4t4ppw' order by LAST_CAPTURED,POSITION;
--在出问题的实例上执行，当前的sql
select instance_number,  sql_id,name, datatype_string, last_captured,value_string from dba_hist_sqlbind where sql_id='fahv8x6ngrb50'order by LAST_CAPTURED,POSITION;
---在出问题的实例上执行，之前的sql




