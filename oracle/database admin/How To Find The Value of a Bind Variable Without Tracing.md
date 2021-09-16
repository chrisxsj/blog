How To Find The Value of a Bind Variable Without Tracing (Doc ID 273121.1)


PURPOSE
-------
 In this note we are going to demonstrate how
 to find the value of a bind variable without enabling
 sql_tracing.


 SCOPE & APPLICATION
 -------------------
 Often the need arises to find the value of a bind variable
 for diagnostic purposes.

 How To Find The Value of a Bind Variable
 ----------------------------------------
 SQL> variable bind varchar2(20);
 SQL> exec :bind := 'SMITH';

 PL/SQL procedure successfully completed.

 SQL> select * from emp where ename=:bind;

      EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM
 ---------- ---------- --------- ---------- --------- ---------- ----------
     DEPTNO
 ----------
       7369 SMITH      CLERK           7902 17-DEC-80        800
         20


 SQL> select sql_id, sql_text from v$sql where sql_text like 'select * from emp%';

 SQL_ID
 -------------
 SQL_TEXT
 --------------------------------------------------------------------------------
 d5c75d9t3yf8g
 select * from emp where ename=:bind


 SQL>  select value_STRING from v$sql_bind_capture where sql_id='d5c75d9t3yf8g';

 VALUE_STRING
 --------------------------------------------------------------------------------
 SMITH

 Please note that bind capture is disabled when the STATISTICS_LEVEL initialization parameter is set to BASIC
 *) The following restriction does apply as well:
 Oracle  Database Reference 11g Release 2 (11.2)
 V$SQL_BIND_CAPTURE

 Bind data
 One of the bind values used for the bind variable during a past execution of its associated SQL statement. Bind values are not always captured for this view. Bind values are displayed by this view only when the type of the bind variable is simple (this excludes LONG, LOB, and ADT datatypes) and when the bind variable is used in the WHERE or HAVING clauses of the SQL statement.


 RELATED DOCUMENTS
 -----------------
 10G Database Reference Part Number B10755-01




====================================================
alter session set nls_date_format = 'yyyy-mm-dd,hh24-mi-ss';
set linesize 400
col sql_Id format a20
col name format a20
col datatype_string format a14
col value_string format a20

select sql_id,name, datatype_string, last_captured,value_string from v$sql_bind_capture where sql_id='9v5ykt44apumn' order by LAST_CAPTURED;--在出问题的实例上执行。

select instance_number,  sql_id,name, datatype_string, last_captured,value_string from dba_hist_sqlbind where sql_id='18naypzfmabd6'order by LAST_CAPTURED;



