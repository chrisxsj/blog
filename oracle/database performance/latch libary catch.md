软解析 85.95%，软解析比例不高，说明系统中存在一定数量的硬解析。


同时，使用如下 sql查询出很多不使用绑定变量的 sql：


SELECT a.pid,       a.sid,       a.name,       ss.machine,     
 ss.program,       ss.schemaname,       sq.sql_text
  FROM v$latchholder a, v$sqlarea sq, v$session ss
 WHERE a.sid = ss.sid AND ss.sql_id = sq.sql_id(+)


通过查询v$sga_resize_ops视图获得sga中各个组件的大小
set linesize 90
set pagesize 60
column component format a25
column Final format 99,999,999,999
column Started format A25
SELECT COMPONENT,       OPER_TYPE,
       FINAL_SIZE Final,       TO_CHAR (start_time, 'dd-mon hh24:mi:ss') Started
  FROM V$SGA_RESIZE_OPS;




由于 sql语句没有使用绑定变量导致 shared pool不断增大，进而导致latch争用情况。最彻底的解决方法就是让 GS软件开发商修改程序—使用绑定变量。


另外，我们强烈建议
alter system sga_max_size=32212254720 scope=spfile;--30G
alter system sga_target=32212254720 scope=spfile; --30G
alter system set shared_pool_size=5368709120 scope=spfile;--5G
alter system set db_cache_size=24696061952 scope=spfile;--23G


这么设置的原因是防止共享池抖动，减少对 db性能的冲击。
