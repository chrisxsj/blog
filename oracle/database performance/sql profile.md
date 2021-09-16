创建

1. 准备工作
a) 建议采用system 用户来创建，修改，删除 sql profile。创建、修改、删除sql profile的用户需要具有 create any sql sprofile,alter any sql profile,drop any sql profile 的权限。到 oracle 11G,不再建议使用上面这3个系统权限，建议使用 administer sql management object的系统权限。
b) 找出需要修改sql的 sql 文本
2. 执行过程
我们以如下查询为例。 object_id列上存在索引。查询默认的执行计划走了 object_i列上的索引。
select count(*) from wxh_tbd where object_id=:a
我们可能对于这个查询计划的固化有两种需求：
1）想继续用走索引的执行计划，为确保执行计划不走错，通过 sql profile来固化执行计划。步骤如下：
declare
v_hints sys.sqlprof_attr;
begin
———-HINT 部分
v_hints := sys.sqlprof_attr(’IND(WXH_TBD@SEL$1 WT_OI_IND)’);
———-SQL 语句部分
dbms_sqltune.import_sql_profile(’select count(*) from wxh_tbd where object_id=:a’,
v_hints,
—————-PROFILE 的名字
‘SQLPROFILE_NAME3′,
force_match => true);
end;
/
2)不想用走索引的执行计划，想让执行计划走全表扫描。可以通过如下方式操作：
declare
 v_hints sys.sqlprof_attr;
 begin
 v_hints := sys.sqlprof_attr(’full(wxh_tbd@sel$1)’);———-HINT部分
 dbms_sqltune.import_sql_profile(’select count(*) from wxh_tbd where object_id=:a’,———-SQL 语句部分 
v_hints,
 ‘SQLPROFILE_NAME3′,——————————–PROFILE 的名字
 force_match => true);
 end;
 /
除了上面介绍的方式来使用 sql profile，你还可以通过我提供的脚本 @profile来进行创建 sql profile。这个脚本的使用方法很简单。你只需要提供 sql_id和hint 就可以了。由于 sql profile的hint 需要指定 query block,因此需要dba 具备查询块的相关知识。 @profile的脚本给你提供了原始执行计划的 query block供你参考，绝大多数时候，这些已经能够提供给你需要的 query block的name 了。@profile脚本里的 hint可以接受多个hint，之间用空格隔开就可以了。例如：
full(@”SEL$1″ “WXH_TBD”@”SEL$1″)  full(@”SEL$2″ “T”@”SEL$2″)
3. 验证方案
explain plan for
select count(*) from wxh_tbd where object_id=:a;


Execution Plan
———————————————————-
Plan hash value: 853361775


—————————————————————————
| Id  | Operation          | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
—————————————————————————
|   0 | SELECT STATEMENT   |         |     1 |    13 |   144   (3)| 00:00:01 |
|   1 |  SORT AGGREGATE    |         |     1 |    13 |            |          |
|*  2 |   TABLE ACCESS FULL| WXH_TBD |   198 |  2574 |   144   (3)| 00:00:01 |
————————————————————————–
Note
—–
- SQL profile “SQLPROFILE_NAME3″ used for this statement
从note部分我们看到 sql profile已经 起作用了




删除sql profile
exec dbms_sqltune.drop_sql_profile(’ SQLPROFILE_NAME3′);


==============================
1 找到有问题的sql
如：
--查找用户 USER I/O等待事件
select c.SPID,a.sid,b.SQL_TEXT,b.SQL_FULLTEXT,a.USERNAME,a.SQL_ID,a.logon_time,a.EVENT,a.STATUS,a.PROGRAM,a.CLIENT_INFO,a.PADDR
 from v$session a,v$sql b,v$process c where a.sql_id=b.sql_id and a.PADDR=c.ADDR and a.wait_class ='User I/O'
 and a.USERNAME in ('PCS_YYK_DTCX','PCS_YYK_SD','QBPT_BJLC','PCS_YYK_QQFW')
 order by a.LOGON_TIME,a.EVENT
或 awr addm等




2 在v$sqlarea中找到这个sql
select * from v$sqlarea where sql_id='9y3yqcwfz1xum';
  select * from v$sqlarea where sql_text like '%SELECT COUNT(1) FROM V_WBZY_BZ_JNLKXX WHERE XM  =%';

3 找到正确的plan(cursor)
select * from table(dbms_xplan.display_awr('9y3yqcwfz1xum')) --Plan hash value: 3628282337
select * from table(dbms_xplan.display_cursor('9y3yqcwfz1xum')) --Plan hash value: 3628282337


4 如果plan不正确
使用sql profile 固定plan
是的,需要好的Plan存在shared pool中(也就是从v$sql中可见的时候)才能生成它的profile.
使用sqlt
1. 使用sqlt的工具来生成profile 
$ cd sqlt/utl 
$ sqlplus / as sysdba 
SQL> START coe_xfr_sql_profile.sql 9y3yqcwfz1xum 497120792 

它会生成一个 coe_xfr_sql_profile_9y3yqcwfz1xum_497120792.sql 的文件 

2. 执行生成的那个文件 

coe_xfr_sql_profile_9y3yqcwfz1xum_497120792.sql 


5 查看sql profile
可以检查 DBA_SQL_PROFILES 的 status 字段看它是否被enable了. 


6 取消sql profile


删除它 

SQL> begin 
dbms_sqltune.drop_sql_profile ( 
name => 'coe_73mbfggjnxfd9_1218056957', 
ignore => true); 
end; 
/ 


=============================================================


--拿到好的plan的outline data   （v$sql）
select sql_id, plan_hash_value from v$sql where plan_hash_value=1218056957; 
select address,hash_value,object_status from v$sql where sql_id='9y3yqcwfz1xum'


--找不到正确的plan 依据outline data使用hint，生成正确的plan
select
 /*+
 NO_ACCESS(V_WBZY_BZ_JNLKXX)
 INDEX(T_WBZY_BZ_JNLK_TS_OLD (T_WBZY_BZ_JNLK_TS_OLD.XM T_WBZY_BZ_JNLK_TS_OLD.CSRQ T_WBZY_BZ_JNLK_TS_OLD.XB T_WBZY_BZ_JNLK_TS_OLD.SCBJ))
 INDEX(T_WBZY_BZ_JNLK_TS (T_WBZY_BZ_JNLK_TS.XM T_WBZY_BZ_JNLK_TS.CSRQ T_WBZY_BZ_JNLK_TS.XB T_WBZY_BZ_JNLK_TS.SCBJ))
 INDEX(T_WBZY_BZ_JNLKXX (T_WBZY_BZ_JNLKXX.XM T_WBZY_BZ_JNLKXX.CSRQ T_WBZY_BZ_JNLKXX.XB T_WBZY_BZ_JNLKXX".SCBJ))
 */
 COUNT(1) FROM pcs_yyk_sd.V_WBZY_BZ_JNLKXX WHERE XM = '许德民' AND CSRQ >= to_date('20000101' , 'YYYY-MM-DD') AND CSRQ <= to_date('20140101' , 'YYYY-MM-DD') and ROWNUM<=500








