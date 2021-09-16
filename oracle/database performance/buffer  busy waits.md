create table gyj_cbc3(id int,name varchar2(100));

 begin
 for i in 1 .. 10000
   loop
    insert into gyj_cbc3 values(i,'GYJ'||i);
 end loop;
 commit;
 end;
 /

 create index idx_cbcid3 on gyj_cbc3(id);

========================================
A:
select * from gyj_cbc3 where id=1;
 select sid from mystat where rownum=1;


 declare
   dbnum5 number;
 begin
   for i in 1 ..10000000 loop
   select count(*) into dbnum5 from hr.gyj_cbc3 where id=1;
 end loop;
 end;
 /

 B:
 update gyj_cbc3 set id=id+1 where id=1;
 select sid from mystat where rownum=1;

 declare
   dbnum6 number;
 begin
   for i in 1 ..50000 loop
   update gyj_cbc3 set id=id+1 where id=1;
 end loop;
   commit;
 end;
 /


 select SID,event,TOTAL_WAITS from v$session_event where sid in(21,24) and event in('buffer busy waits');

 select SID,event,TOTAL_WAITS from v$session_event where event in('buffer busy waits'); 

A  select
B  dml
C  select

B dml 阻塞C select 造成。需要减少dml操作


