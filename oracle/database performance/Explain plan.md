Explain plan 命令：查看Oracle优化器用来执行SQL语句的查询执行计划，对提高SQL语句的性能很有帮助
它并非真正地执行SQL语句，只是列出使用的执行计划，并插入一个Oracle表中，主要用来做查询（select）优化！

Explain plan对比SQL trace
SQL语句不需要被执行，查询SQL执行计划，快捷方便，使用Explain plan不需要等待SQL运行结束。

》Explain plan使用

1 运行脚本，创建PLAN TABLE
@$ORACLE_HOME/rdbms/admin/utlxplan

以运行Explain plan命令的用户执行该脚本，该脚本会创建一个PLAN_TABLE

2 执行Explain plan命令
explain plan for
select employee_id,salary from hr.employees;

SQL语句放在Explain plan的for子句之后

3 对优化的查询使用标记（tag）
explain plan
set statement_id='CUS' for
select employee_id,salary from employees;

set statement_id='your_identifier'   做标记，此标记会填充到PLAN_TABLE

4 查看PLAN_TABLE

可以自己编写查询语句及格式
select operation,options,object_name,id,parent_id from plan_table;

建议使用Oracle提供的脚本查看
@?/rdbms/admin/utlxpls.sql
or
@?/rdbms/admin/utlxplp.sql



SQL> @?/rdbms/admin/utlxpls.sql

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
Plan hash value: 1445457117

-------------------------------------------------------------------------------
| Id  | Operation      | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |          |   107 |   856 |     3    (0)| 00:00:01 |
|   1 |  TABLE ACCESS FULL| EMPLOYEES |   107 |   856 |     3    (0)| 00:00:01 |
-------------------------------------------------------------------------------

explain plan 必须从最内侧往最外侧读

》配合autotrace生成Explain plan
sqlplus 提供autotrace 功能，其能够方便的提供Explain plan，但autotrace确实执行了查询（类似与sql trace）

set autotrace on    --打开autotrace
set autotrace off    --关闭autotrace
set autotrace on exp    --仅显示Explain plan
set autotrace on stat    --仅显示统计信息
set autot trace    --不显示查询结果

使用autotrace的用户必须拥有PLUSTRACE角色

SQL> set autotrace on
SP2-0618: Cannot find the Session Identifier.  Check PLUSTRACE role is enabled
SP2-0611: Error enabling STATISTICS report

使用自带脚本生成角色
@$ORACLE_HOME/rdbms/admin/plustrce.sql    --11G没有这个脚本？？


create role plustrace;
grant select on v_$sesstat to plustrace;
grant select on v_$statname to plustrace;
grant select on v_$mystat to plustrace;
grant plustrace to dba with admin option;
grant PLUSTRACE to hr;








