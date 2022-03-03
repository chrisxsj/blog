
设置主键

alter table test_ttt add COLUMN u_id INTEGER;    --a表新增一个自诉案u_id
create sequence seq_auid start with 1 increment by 1;        --创建自增序列seq_auid 1开始步长为1
alter table test_ttt alter column u_id set default nextval('seq_auid');    ---u_id引用这个序列，注意：表中不允许有控制，可用于新建空表，否则新建字段违反主键的非空约束。
alter table test_ttt add constraint pk_uid primary key(u_id);    --将u_id设置为主键