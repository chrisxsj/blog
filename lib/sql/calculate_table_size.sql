-- 表大小top10
SELECT
    table_name,
    pg_size_pretty(table_size) AS table_size,
    pg_size_pretty(indexes_size) AS indexes_size,
    pg_size_pretty(total_size) AS total_size
FROM (
    SELECT
        table_name,
        pg_table_size(table_name) AS table_size,
        pg_indexes_size(table_name) AS indexes_size,
        pg_total_relation_size(table_name) AS total_size
    FROM (
        SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
        FROM information_schema.tables
    ) AS all_tables
    ORDER BY total_size DESC
) AS pretty_sizes limit 10;
 
 
/* 指定表名
SELECT
    table_name,
    pg_size_pretty(table_size) AS table_size,
    pg_size_pretty(indexes_size) AS indexes_size,
    pg_size_pretty(total_size) AS total_size
FROM (
    SELECT
        table_name,
        pg_table_size(table_name) AS table_size,
        pg_indexes_size(table_name) AS indexes_size,
        pg_total_relation_size(table_name) AS total_size
    FROM (
        SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
        FROM information_schema.tables
    ) AS all_tables where  table_name like '%test_t1%'
    ORDER BY total_size DESC
) AS pretty_sizes;
*/


/* 指定oid
select pg_relation_size(16407) , 
pg_relation_size(16407, 'main') as main,
pg_relation_size(16407, 'fsm') as fsm,
pg_relation_size(16407, 'vm') as vm,
pg_relation_size(16407, 'init') as init,
pg_total_relation_size(16387) as toast, --包括索引和toast，此处改为pg_relation_size(16387) as toast
pg_table_size(16407), 
pg_indexes_size(16407),
pg_total_relation_size(16407);
*/