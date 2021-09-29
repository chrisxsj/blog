# information_schema

所有表的所有信息

select * from information_schema.columns where table_schema='public' and table_name<>'pg_stat_statements';

指定表的列名

select column_name from information_schema.columns where table_schema='public' and table_name ='center_day_stock_cache';