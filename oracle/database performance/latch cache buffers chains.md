http://blog.csdn.net/guoyjoe/article/details/8585391

latch 是ns
 等待事件是ms
buffer pin锁2次


create table gyj_cbc1(id int,name varchar2(100));

 begin
 for i in 1 .. 10000
   loop
    insert into gyj_cbc1 values(i,'GYJ'||i);
 end loop;
 commit;
 end;
 /

 create index idx_cbcid1 on gyj_cbc1(id);

 =====================================================

 SQL> select dbms_rowid.rowid_relative_fno(rowid) file#,dbms_rowid.rowid_block_number(rowid) block#,id,name from gyj_cbc1 where id=1;
      FILE#     BLOCK#           ID NAME
 ---------- ---------- ---------- --------------------
      4       526            1 GYJ1


 select hladdr from x$bh where dbarfil=4 and dbablk= 590;
 HLADDR
 ----------------
 0000000077BFE868


 select NAME from v$latch_children where addr='0000000077BFE868';
 NAME
 ----------------------------------------------------------------
 cache buffers chains

 select obj from x$bh where HLADDR='0000000077BFE868';
        OBJ
 ----------
        527
      76874
      18
        225
        476
 4294967295

 select object_name,object_type from dba_objects where data_object_id in (527,76874);

 OBJECT_NAME                 OBJECT_TYPE
 ------------------------------ -------------------
 OBJ$                      TABLE
 IDL_UB1$                 TABLE
 WRI$_OPTSTAT_HISTGRM_HISTORY   TABLE
 SYS_C00644                 INDEX
 GYJ_CBC                  TABLE

 select file#,dbablk,owner,data_object_id,object_name,object_type from x$bh a,dba_objects b where hladdr='0000000077BFE868' and a.obj=b.data_object_id and object_type='TABLE';
      FILE#     DBABLK OWNER             DATA_OBJECT_ID OBJECT_NAME            OBJECT_TYPE
 ---------- ---------- -------------------- -------------- -------------------- -------------------
      1     69155 SYS                    2 ATTRCOL$            TABLE
      1     69155 SYS                    2 ATTRCOL$            TABLE
      1     69155 SYS                    2 TYPE_MISC$            TABLE
      1     69155 SYS                    2 TYPE_MISC$            TABLE
      4       590 HR                   76878 GYJ_CBC1            TABLE
 ================================================================
 GYJ_CBC1
 select DBMS_ROWID.ROWID_CREATE(1,76878,4,590,0) from dual;
 DBMS_ROWID.ROWID_C
 ------------------
 AAASxOAAEAAAAJOAAA

 TYPE_MISC$
 select DBMS_ROWID.ROWID_CREATE(1,2,1,69155,0) from dual;
 DBMS_ROWID.ROWID_C
 ------------------
 AAAAACAABAAAQ4jAAA

 IDL_UB1$
 select DBMS_ROWID.ROWID_CREATE(1,225,1,74192,0) from dual;

 DBMS_ROWID.ROWID_C
 ------------------
 AAAADhAABAAASHQAAA


 select * from gyj_cbc where rowid='AAADXbAAEAAAAmBAAA';

 declare
   dbnum1 number;
 begin
   for i in 1 ..10000000 loop
   select count(*) into dbnum1 from HR.GYJ_CBC1 where rowid='AAASxOAAEAAAAJOAAA';
 end loop;
 end;
 /


 declare
   dbnum3 number;
 begin
   for i in 1 ..10000000 loop
   select count(*) into dbnum3 from SYS.TYPE_MISC$ where rowid='AAAAACAABAAAQ4jAAA';
 end loop;
 end;
 /

 declare
   dbnum2 number;
 begin
   for i in 1 ..10000000 loop
   select count(*) into dbnum2 from sys.IDL_UB1$ where rowid='AAAADhAABAAASHQAAA';
 end loop;
 end;
 /

 select sid,event,p1raw,p2raw from v$session where wait_class<>'Idle' order by 2;
 select sid,event,p1raw,p2raw from v$session where event like '%LATCH%';

        SID EVENT
 ---------- ----------------------------------------------------------------
 P1RAW          P2RAW
 ---------------- ----------------
      41 SQL*Net message to client
 0000000062657100 0000000000000001

      26 latch: cache buffers chains
 0000000077BFE868 000000000000009B

      29 latch: shared pool
 0000000060106EB8 0000000000000133 

全表扫描
一致性读 都可以造成此问题
