PostgreSQL 12中 vacuum 选项的增强 index_cleanup 说明
VACUUM的作用
收回由被删除那些已经标示为删除的数据并释放空间。在PostgreSQL操作中，删除或者更新操作后废弃的元组并没有在物理上从它们的表中移除，它们将一直存在直到下一次VACUUM被执行。因此有必要自动或者手工方式周期性地做VACUUM，特别是在频繁被更新的表上。
index_cleanup 选项说明
PostgreSQL索引页重用和堆表有所不同，表在 VACUUM 清理回收后空间可以直接使用，而索引页的中值是有序的，只有相邻边界内的值才可以插入。如果遇到索引膨胀，最好的方法就是使用 Concurrently 方式定期重建索引使其页面结构紧凑，而不是通过 VACUUM 进行索引页面的回收。通过上述描述在之前的版本对相关表执行VACUUM 无法排除对表上的索引进行清理，在PG12版本开始目前有两种方式:
1. 可以通过ALTER TABLE table_name SET ( vacuum_index_cleanup =FALSE) 在表级别设置.
2. 通过 VACUUM 命令 指定 (INDEX_CLEANUP false)将索引排除在外。
# 测试准备：
‐‐创建测试表
create table h01 (id bigint,info text,h_time timestamp);
insert into h01 select generate_series(1,1000000), 'h01_'||md5(random()::text), clock_timestamp(); 
alter table h01 add constraint id_h01_pk primary key (id);
update h01 set info='p01_'||md5(random()::text) where id in (select (random()*3000)::int from generate_series(1,500)); 
 select count(id) from h01;
‐‐正常情况对表进行VACUUM
vacuum verbose h01;
INFO: index "pg_toast_26278_index" now contains 0 row versions in 1 pages
DETAIL: 0 index row versions were removed.
0 index pages have been deleted, 0 are currently reusable.
‐‐在表级别设置（vacuum_index_cleanup = FALSE）排除索引回收
update h01 set info='p02_'||md5(random()::text) where id in (select (random()*3000)::int from generate_series(1,500)); 
ALTER TABLE h01 SET (vacuum_index_cleanup = FALSE);
vacuum verbose h01; /**已经跳过索引页**/
‐‐通过 VACUUM 命令在参数中设置排除索引回收
update h01 set info='p02_'||md5(random()::text) where id in (select (random()*3000)::int from generate_series(1,500));
VACUUM (INDEX_CLEANUP FALSE,VERBOSE) h01; /**已经跳过索引页**/
# 执行完表的 VACUUM 后可在线重建索引
reindex table concurrently h01;
# tips（小提示）：
1. REINDEX TABLE 将重建表上的所有索引，实际使用中建议执行 REINDEX INDEX 指定相应索引。
1. vacuum full 不支持。