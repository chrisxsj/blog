
查询lob字段大小


select owner,SEGMENT_NAME,SEGMENT_TYPE,bytes/1024/1024/1024 as mb from dba_segments order by mb desc;
 
 
 
select OWNER,SEGMENT_NAME,SEGMENT_TYPE,TABLESPACE_NAME from dba_extents where segment_name in
    (select '&&tab_name' from dual
      union
      select index_name from user_indexes where table_name='&&tab_name'
      union
      select segment_name from user_lobs where table_name='&&tab_name'
      union
      select index_name from user_lobs where table_name='&&tab_name');
 
select OWNER,SEGMENT_NAME,SEGMENT_TYPE,TABLESPACE_NAME from dba_extents e, where segment_name in
    (select 'TEST_TABLE' from dual
      union
      select index_name from dba_indexes where table_name='TEST_TABLE' and owner='HR'
      union
      select segment_name from user_lobs where table_name='TEST_TABLE' and owner='HR'
      union
      select index_name from user_lobs where table_name='TEST_TABLE' and owner='HR');
 
 
 
col COLUMN_NAME format a30
select OWNER,TABLE_NAME,COLUMN_NAME,SEGMENT_NAME,INDEX_NAME from dba_lobs where owner='HR' AND TABLE_NAME='TEST_TABLE';


SELECT COLUMN_NAME, SEGMENT_NAME
FROM DBA_LOBS
WHERE OWNER = 'HR' AND TABLE_NAME = 'TEST_TABLE';
 
select index_name,status,index_type,table_name from dba_indexes where table_name='TEST_TABLE';
 
SELECT
 (SELECT SUM(S.BYTES)                                                                                               
  FROM DBA_SEGMENTS S
  WHERE S.OWNER = UPPER('HR') AND
       (S.SEGMENT_NAME = UPPER('TEST_TABLE'))) +
 (SELECT SUM(S.BYTES)                                                                                                
  FROM DBA_SEGMENTS S, DBA_LOBS L
  WHERE S.OWNER = UPPER('HR') AND
       (L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME = UPPER('TEST_TABLE') AND L.OWNER = UPPER('HR'))) +
 (SELECT SUM(S.BYTES)                                                                                               
  FROM DBA_SEGMENTS S, DBA_INDEXES I
  WHERE S.OWNER = UPPER('HR') AND
       (I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME = UPPER('TEST_TABLE') AND INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('HR')))
  "TOTAL TABLE SIZE"
FROM DUAL;
 
 
 
SELECT SUM(S.BYTES)                                                                                               
  FROM DBA_SEGMENTS S
  WHERE S.OWNER = UPPER('HR') AND
       (S.SEGMENT_NAME = UPPER('TEST_TABLE'));
 
 
SELECT SUM(S.BYTES)
  FROM DBA_SEGMENTS S, DBA_LOBS L
  WHERE S.OWNER = UPPER('HR') AND
       (L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME = UPPER('TEST_TABLE') AND L.OWNER = UPPER('HR'));
  
SELECT SUM(S.BYTES)                                                                                               
  FROM DBA_SEGMENTS S, DBA_INDEXES I
  WHERE S.OWNER = UPPER('HR') AND
       (I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME = UPPER('TEST_TABLE') AND INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('HR'));