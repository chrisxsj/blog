# performance_turning_sql

PostgreSQL部署上之后，经过一段时间的运行，我们比较关心那些SQL运行时间比较长，或者说那些SQL执行的特别慢，拖累的性能，只有找到这些SQL，才能有针对性地对这些SQL进行优化，提升PostgreSQL的性能。

## 抓取sql语句

### 错误日志记录方式

ref [error_log](./error_log.md)

## 插件的方式（pg_stat_statements）

ref [pg_stat_statements](./pg_stat_statements.md)

## 执行计划

ref [explain](./explain.md)