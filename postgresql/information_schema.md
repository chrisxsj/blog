# information_schema

查询表的信息（类似dba_tables）

select * from information_schema.columns where table_schema='public' and table_name<>'pg_stat_statements';
select column_name from information_schema.tables where table_schema='public' and table_name ='test_bulkload';

指定表的列名

select column_name from information_schema.columns where table_schema='public' and table_name ='center_day_stock_cache';

