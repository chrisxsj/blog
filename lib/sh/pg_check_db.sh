#! /bin/bash
#########################################
# author，Chrisx
# date，2021-06-18
# Copyright (C): 2021 All rights reserved"
#########################################
# variable
source ~/.bash_profile
DATE=`date +"%Y%m%d%H%M"`
########################################

function comm () {
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                       数据库通用信息                     |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### db Compile info"
  pg_config
  
  echo "###### 网络访问控制"
  cat $PGDATA/pg_hba.conf |grep -v '#'
  echo "--->>> 建议先设置白名单(超级用户允许的来源IP, 可以访问的数据库), 再设置黑名单(不允许超级用户登陆, reject), 再设置白名单(普通应用)"
  echo "--->>> 注意trust和password认证方法的危害"
  
  echo "###### 获取pg_hba.conf md5值"
  md5sum $PGDATA/pg_hba.conf
  echo "--->>> 主备md5值一致(判断主备配置文件是否内容一致的一种手段, 或者使用diff)."
  
  echo "###### control file info"
  pg_controldata
  
  echo "###### control file info"
  pg_controldata
  echo "###### 获取postgresql.conf md5值"
  md5sum $PGDATA/postgresql.conf
  
  echo "###### 获取postgresql.conf配置"
  cat $PGDATA/postgresql.conf | grep -E '^[a-z]' 
  
  echo "###### 获取postgresql.auto.conf配置"
  cat $PGDATA/postgresql.auto.conf | grep -E '^[a-z]'

  echo -e "\n"
}

########################################

function pg_database_info () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                       数据库信息                        |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### version"
  psql --pset=pager=off -c 'select version()'
  
  echo "###### 有多少数据库"
  psql --pset=pager=off -c 'select datname,datdba,encoding,datcollate,datctype,dattablespace,datacl from pg_database;'
  
  echo "###### 创建的扩展extention"
  for db in `psql --pset=pager=off -qtA -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),* from pg_extension'
  done
  
  echo "###### 用户使用了多少种数据类型"
  for db in `psql --pset=pager=off -qtA -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      b.typname,
      count(*)
  from pg_attribute a,
      pg_type b
  where a.atttypid = b.oid
      and a.attrelid in (
          select oid
          from pg_class
          where relnamespace not in (
                  select oid
                  from pg_namespace
                  where nspname ~ $$ ^ pg_ $$
                      or nspname = $$information_schema$$
              )
      )
  group by 1,
      2
  order by 3 desc'
  done
  
  echo "###### 用户创建了多少对象"
  for db in `psql --pset=pager=off -qtA -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      rolname,
      nspname,
      relkind,
      count(*)
  from pg_class a,
      pg_authid b,
      pg_namespace c
  where a.relnamespace = c.oid
      and a.relowner = b.oid
      and nspname !~ $$ ^ pg_ $$
      and nspname <> $$information_schema$$
  group by 1,
      2,
      3,
      4
  order by 5 desc'
  done

  echo -e "\n"
}

#########################################
function pg_database_parameter () {
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库参数                             |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 用户在数据库级别定制参数"
  psql --pset=pager=off -q -c 'select * from pg_db_role_setting'
  echo "--->>> 定制参数需要关注, 优先级高于数据库的启动参数和配置文件中的参数, 特别是排错时需要关注. "
  
  echo "###### 用户当前参数配置"
  psql --pset=pager=off -q -c 'select name,setting,unit,context,current_setting(name) from pg_settings;'

  echo -e "\n"
}
#######################################
function pg_space_usage () {
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库空间使用分析                    |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 表空间对应目录及大小"
  psql --pset=pager=off -q -c 'select spcname,
      pg_tablespace_location(oid),
      round(pg_tablespace_size(oid) / 1024 / 1024 / 1024, 2) || $$GB$$ as size
  from pg_tablespace
  order by pg_tablespace_size(oid) desc;'
  
  echo "###### 数据库大小"
  psql --pset=pager=off -q -c 'select a.datname,
      b.rolname,
      pg_encoding_to_char(ENCODING) as ENCODING,
      a.datcollate,
      a.datctype,
      pg_database_size(a.datname) / 1024 / 1024 / 1024 as "size(GB)"
  from pg_database a,
      pg_authid b
  where a.datdba = b.oid
  order by "size(GB)" desc;'
  
  echo "###### 对象总大小（TOP10）"
  for db in `psql --pset=pager=off -qtA -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql --pset=pager=off -q -c '
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
          SELECT ($$"$$ || table_schema || $$"."$$ || table_name || $$"$$) AS table_name
          FROM information_schema.tables
      ) AS all_tables
      ORDER BY total_size DESC
  ) AS pretty_sizes limit 10;'

  echo "###### 表大小（TOP10）"
  for db in `psql --pset=pager=off -qtA -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql --pset=pager=off -q -c 'select current_database(),
      b.nspname,
      c.relname,
      c.relkind,
      pg_size_pretty(pg_table_size(c.oid)) as table_size,
      a.seq_scan,
      a.seq_tup_read,
      a.idx_scan,
      a.idx_tup_fetch,
      a.n_tup_ins,
      a.n_tup_upd,
      a.n_tup_del,
      a.n_tup_hot_upd,
      a.n_live_tup,
      a.n_dead_tup
  from pg_stat_all_tables a,
      pg_class c,
      pg_namespace b
  where c.relnamespace = b.oid
      and c.relkind = $$r$$
      and a.relid = c.oid
  order by pg_relation_size(c.oid) desc
  limit 10;'
  done
  echo "--->>> 单表超过8GB, 并且这个表需要频繁更新 或 删除+插入的话, 建议对表根据业务逻辑进行合理拆分后获得更好的性能, 以及便于对膨胀索引进行维护; 如果是只读的表, 建议适当结合SQL语句进行优化. "
  
  echo "###### 索引大小（TOP10）"
  for db in `psql --pset=pager=off -qtA -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql --pset=pager=off -q -c 'select current_database(),
      b.nspname,
      c.relname,
      c.relkind,
      pg_size_pretty(pg_indexes_size(c.oid)) as indexes_size,
      a.seq_scan,
      a.seq_tup_read,
      a.idx_scan,
      a.idx_tup_fetch,
      a.n_tup_ins,
      a.n_tup_upd,
      a.n_tup_del,
      a.n_tup_hot_upd,
      a.n_live_tup,
      a.n_dead_tup
  from pg_stat_all_tables a,
      pg_class c,
      pg_namespace b
  where c.relnamespace = b.oid
      and c.relkind = $$i$$
      and a.relid = c.oid
  order by pg_relation_size(c.oid) desc
  limit 10;'
  done

  echo -e "\n"
}
#######################################
function pg_connect () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库连接                            |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 当前活跃度"
  psql --pset=pager=off -q -c 'select now(),state,count(*) from pg_stat_activity group by 1,2'
  echo "--->>> 如果active状态很多, 说明数据库比较繁忙. 如果idle in transaction很多, 说明业务逻辑设计可能有问题. 如果idle很多, 可能使用了连接池, 并且可能没有自动回收连接到连接池的最小连接数."
  
  echo "###### 剩余连接数"
  psql --pset=pager=off -q -c 'select max_conn,
      used,
      res_for_super,
      max_conn - used - res_for_super res_for_normal
  from (
          select count(*) used
          from pg_stat_activity
      ) t1,
  (
          select setting::int res_for_super
          from pg_settings
          where name = $$superuser_reserved_connections$$
      ) t2,
  (
          select setting::int max_conn
          from pg_settings
          where name = $$max_connections$$
      ) t3;'
  echo "--->>> 给超级用户和普通用户设置足够的连接, 以免不能登录数据库."
  
  echo "###### 用户连接数限制"
  psql --pset=pager=off -q -c 'select a.rolname,
      a.rolconnlimit,
      b.connects
  from pg_authid a,
  (
          select usename,
              count(*) connects
          from pg_stat_activity
          group by usename
      ) b
  where a.rolname = b.usename
  order by b.connects desc;'
  echo "--->>> 给用户设置足够的连接数, alter role ... CONNECTION LIMIT ."
  
  echo "###### 数据库连接数限制"
  psql --pset=pager=off -q -c 'select a.datname,
      a.datconnlimit,
      b.connects
  from pg_database a,
  (
          select datname,
              count(*) connects
          from pg_stat_activity
          group by datname
      ) b
  where a.datname = b.datname
  order by b.connects desc'
  echo "--->>> 给数据库设置足够的连接数, alter database ... CONNECTION LIMIT ."

  echo -e "\n"
}

#######################################
function pg_database_log () {
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库错误日志                         |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  #select pg_current_logfile();

  echo "###### 获取错误日志信息"
  log_dir=`psql --pset=pager=off -qAt -c 'show log_directory'`
  log=(`find $PGDATA/$log_dir -name "*.csv" -type f -mtime -7 -exec ls {} \;`)
  echo ${log[*]} 
  for l in ${log[*]}
  do
  cat $l |grep -E "^[0-9]" | grep -E "WARNING|ERROR|FATAL|PANIC" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 参考 http://www.postgresql.org/docs/current/static/errcodes-appendix.html ."
 
  echo "###### 获取连接请求信息"
  for l in ${log[*]}
  do
  cat $l |grep -E "^[0-9]" | grep "connection authorized" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 连接请求非常多时, 请考虑应用层使用连接池, 或者使用pgbouncer连接池."
 
  echo "###### 获取认证失败情况"
  for l in ${log[*]}
  do
  cat $l |grep -E "^[0-9]" | grep "password authentication failed" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 认证失败次数很多时, 可能是有用户在暴力破解, 建议使用auth_delay插件防止暴力破解. "

  echo -e "\n"
}

########################################
function pg_log_sql () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库日志记录sql                     |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 慢查询sql统计"
  log_dir=`psql --pset=pager=off -qAt -c 'show log_directory'`
  log=(`find $PGDATA/$log_dir -name "*.csv" -type f -mtime -7 -exec ls {} \;`)
  echo ${log[*]} 
  for l in ${log[*]}
  do
  cat $l |awk -F "," '{print $1" "$2" "$3" "$8" "$14}' |grep "duration:"|grep -v "plan:"|awk '{print $1" "$4" "$5" "$6}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 输出格式(条数,日期,用户,数据库,QUERY,耗时ms)."
  echo "--->>> 慢查询反映执行时间超过log_min_duration_statement的SQL, 可以根据实际情况分析数据库或SQL语句是否有优化空间."
  
  echo "###### 慢查询分布头10条的执行时间, ms"
  for l in ${log[*]}
  do
  cat $l |awk -F "," '{print $1" "$2" "$3" "$8" "$14}' |grep "duration:"|grep -v "plan:"|awk '{print $1" "$4" "$5" "$6" "$7" "$8}'|sort -k 6 -n|head -n 10
  done
  
  echo "###### 慢查询分布尾10条的执行时间, ms"
  for l in ${log[*]}
  do
  cat $l |awk -F "," '{print $1" "$2" "$3" "$8" "$14}' |grep "duration:"|grep -v "plan:"|awk '{print $1" "$4" "$5" "$6" "$7" "$8}'|sort -k 6 -n|tail -n 10
  done
  
  echo "###### auto_explain 分析统计"
  for l in ${log[*]}
  do
  cat $l |awk -F "," '{print $1" "$2" "$3" "$8" "$14}' |grep "plan:"|grep "duration:"|awk '{print $1" "$4" "$5" "$6}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 输出格式(条数,日期,用户,数据库,QUERY). "
  echo "--->>> 慢查询反映执行时间超过auto_explain.log_min_duration的SQL, 可以根据实际情况分析数据库或SQL语句是否有优化空间, 分析csvlog中auto_explain的输出可以了解语句超时时的执行计划详情. "
  
  echo -e "\n"
}

############################################

function pg_performance () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库性能分析                         |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### TOP 5 SQL : total_cpu_time"
  psql --pset=pager=off -q -x -c 'select c.rolname,
      b.datname,
      a.total_time / a.calls per_call_time,
      a.*
  from pg_stat_statements a,
      pg_database b,
      pg_authid c
  where a.userid = c.oid
      and a.dbid = b.oid
  order by a.total_time desc
  limit 5'
  echo "--->>> 检查SQL是否有优化空间, 配合auto_explain插件在csvlog中观察LONG SQL的执行计划是否正确."
  
  echo "###### 索引数超过4并且SIZE大于10MB的表"
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      t2.nspname,
      t1.relname,
      pg_size_pretty(pg_relation_size(t1.oid)),
      t3.idx_cnt
  from pg_class t1,
      pg_namespace t2,
      (
          select indrelid,
              count(*) idx_cnt
          from pg_index
          group by 1
          having count(*) > 4
      ) t3
  where t1.oid = t3.indrelid
      and t1.relnamespace = t2.oid
      and pg_relation_size(t1.oid) / 1024 / 1024.0 > 10
  order by t3.idx_cnt desc'
  done
  echo "--->>> 索引数量太多, 影响表的增删改性能, 建议检查是否有不需要的索引."
  
  echo "###### 上次巡检以来未使用或使用较少的索引"
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      t2.schemaname,
      t2.relname,
      t2.indexrelname,
      t2.idx_scan,
      t2.idx_tup_read,
      t2.idx_tup_fetch,
      pg_size_pretty(pg_relation_size(indexrelid))
  from pg_stat_all_tables t1,
      pg_stat_all_indexes t2
  where t1.relid = t2.relid
      and t2.idx_scan < 10
      and t2.schemaname not in ($$pg_toast$$, $$pg_catalog$$)
      and indexrelid not in (
          select conindid
          from pg_constraint
          where contype in ($$p$$, $$u$$, $$f$$)
      )
      and pg_relation_size(indexrelid) > 65536
  order by pg_relation_size(indexrelid) desc'
  done
  echo "--->>> 建议和应用开发人员确认后, 删除不需要的索引."
  
  echo "###### 数据库统计信息, 回滚比例, 命中比例, 数据块读写时间, 死锁, 复制冲突"
  psql --pset=pager=off -q -c 'select datname,
    round(
        100 *(
            xact_rollback::numeric /(
                case
                    when xact_commit > 0 then xact_commit
                    else 1
                end + xact_rollback
            )
        ),
        2
    ) || $$ %$$ rollback_ratio,
    round(
        100 *(
            blks_hit::numeric /(
                case
                    when blks_read > 0 then blks_read
                    else 1
                end + blks_hit
            )
        ),
        2
    ) || $$ %$$ hit_ratio,
    blk_read_time,
    blk_write_time,
    conflicts,
    deadlocks
from pg_stat_database'
  echo "--->>> 回滚比例大说明业务逻辑可能有问题, 命中率小说明shared_buffer要加大, 数据块读写时间长说明块设备的IO性能要提升,"
  echo "--->>> 死锁次数多说明业务逻辑有问题, 复制冲突次数多说明备库可能在跑LONG SQL."

  echo "###### 检查点, bgwriter 统计信息"
  psql --pset=pager=off -q -x -c 'select * from pg_stat_bgwriter'
  echo "--->>> checkpoint_write_time多说明检查点持续时间长, 检查点过程中产生了较多的脏页."
  echo "--->>> checkpoint_sync_time代表检查点开始时的shared buffer中的脏页被同步到磁盘的时间, 如果时间过长, 并且数据库在检查点时性能较差, 考虑一下提升块设备的IOPS能力."
  echo "--->>> buffers_backend_fsync太多说明需要加大shared buffer 或者 减小bgwriter_delay参数."

  echo -e "\n"
}

################################################

function pg_mvcc () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库垃圾和年龄分析                   |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 对象膨胀bloat检查,TOP5 "
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c "WITH constants AS (
    SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 4 AS ma
  ), bloat_info AS (
    SELECT
      ma,bs,schemaname,tablename,
      (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
      (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        schemaname, tablename, hdr, ma, bs,
        SUM((1-null_frac)*avg_width) AS datawidth,
        MAX(null_frac) AS maxfracsum,
        hdr+(
          SELECT 1+count(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
        ) AS nullhdr
      FROM pg_stats s, constants
      GROUP BY 1,2,3,4,5
    ) AS foo
  ), table_bloat AS (
    SELECT
      schemaname, tablename, cc.relpages, bs,
      CEIL((cc.reltuples*((datahdr+ma-
        (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)) AS otta
    FROM bloat_info
    JOIN pg_class cc ON cc.relname = bloat_info.tablename
    JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
  ), index_bloat AS (
    SELECT
      schemaname, tablename, bs,
      COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
      COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
    FROM bloat_info
    JOIN pg_class cc ON cc.relname = bloat_info.tablename
    JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = bloat_info.schemaname AND nn.nspname <> 'information_schema'
    JOIN pg_index i ON indrelid = cc.oid
    JOIN pg_class c2 ON c2.oid = i.indexrelid
  )
  SELECT
    current_database(),type, schemaname, object_name, bloat, pg_size_pretty(raw_waste) as waste
  FROM
  (SELECT
    'table' as type,
    schemaname,
    tablename as object_name,
    ROUND(CASE WHEN otta=0 THEN 0.0 ELSE table_bloat.relpages/otta::numeric END,1) AS bloat,
    CASE WHEN relpages < otta THEN '0' ELSE (bs*(table_bloat.relpages-otta)::bigint)::bigint END AS raw_waste
  FROM
    table_bloat
      UNION
  SELECT
    'index' as type,
    schemaname,
    tablename || '::' || iname as object_name,
    ROUND(CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages/iotta::numeric END,1) AS bloat,
    CASE WHEN ipages < iotta THEN '0' ELSE (bs*(ipages-iotta))::bigint END AS raw_waste
  FROM
    index_bloat) bloat_summary
  ORDER BY raw_waste DESC, bloat DESC limit 5;"
  done

  echo "--->>> 大表如果频繁的有更新或删除和插入操作, 建议设置较小的autovacuum_vacuum_scale_factor来降低浪费空间. "
  echo "--->>> 如果索引膨胀太大, 会影响性能, 建议重建索引, create index CONCURRENTLY ... ."
  echo "--->>> 如果表膨胀太大，会影响全表扫描性能，建议在非业务时间段执行vacuum full回收膨胀的空间."
  echo "--->>> bloat对象膨胀倍数, waste对象浪费了多少字节"

  echo "###### 垃圾数据多的表,TOP5（基础数据大于1000条，死数据比例大约20%） "
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      schemaname,
      relname,
      n_dead_tup
  from pg_stat_all_tables
  where n_live_tup > 1000
      and n_dead_tup / n_live_tup > 0.2
      and schemaname not in ($$pg_toast$$, $$pg_catalog$$)
  order by n_dead_tup desc
  limit 5'
  done
  echo "--->>> 通常垃圾过多, 可能是因为无法回收垃圾, 或者回收垃圾的进程繁忙或没有及时唤醒, 或者没有开启autovacuum, 或在短时间内产生了大量的垃圾 . "
  echo "--->>> 可以等待autovacuum进行处理, 或者手工执行vacuum table . "


  echo "###### 数据库年龄"
  psql --pset=pager=off -q -c 'select datname,
      datfrozenxid,
      age(datfrozenxid),
      2 ^ 31 - age(datfrozenxid) age_remain,
  (2 ^ 31 - age(datfrozenxid)) / 2 ^ 31 age_remain_per
  from pg_database
  order by age(datfrozenxid) desc;'
  echo "--->>> 数据库的年龄正常情况下应该小于vacuum_freeze_table_age, 如果剩余年龄小于5亿, 建议人为干预, 将LONG SQL或事务杀掉后, 执行vacuum freeze ."


  echo "###### 表年龄"
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      rolname,
      nspname,
      relkind,
      relname,
      age(relfrozenxid),
      2 ^ 31 - age(relfrozenxid) age_remain
  from pg_authid t1
      join pg_class t2 on t1.oid = t2.relowner
      join pg_namespace t3 on t2.relnamespace = t3.oid
  where t2.relkind in ($$t$$, $$r$$)
  order by age(relfrozenxid) desc
  limit 5;'
  done
  echo "--->>> 表的年龄正常情况下应该小于vacuum_freeze_table_age, 如果剩余年龄小于5亿, 建议人为干预, 将LONG SQL或事务杀掉后, 执行vacuum freeze ."

  echo "###### 长事务查询和2pc事务（超过30min）,长链接,TOP5"
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      usename,
      query,
      state,
      xact_start,
      now() - xact_start xact_duration,
      query_start,
      now() - xact_start as query_duration
  from pg_stat_activity
  where now() - xact_start > interval $$30 min $$
      and query !~ $$^COPY$$
      and state <> $$idle$$
      and (
        backend_xid is not null
        or backend_xmin is not null
    )
  order by query_duration desc
  limit 5;'

  psql -d $db --pset=pager=off -q -c 'select name,
    statement,
    prepare_time,
    now() - prepare_time,
    parameter_types,
    from_sql
  from pg_prepared_statements
  where now() - prepare_time > interval $$30 min $$
  order by prepare_time desc
  limit 5;'
-- 长链接，事务启动时间，进程启动时间
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      usename,
      pid,
      query,
      state,
      xact_start,
      now() - xact_start xact_duration
  from pg_stat_activity
  where now() - xact_start > interval $$30 min $$
  and state = $$idle$$
  order by xact_start
  limit 5;'

  psql -d $db --pset=pager=off -q -c 'select current_database(),
      usename,
      pid,
      query,
      state,
      backend_start,
      now() - backend_start backend_duration
  from pg_stat_activity
  where now() - backend_start > interval $$30 min $$
  and state = $$idle$$
  order by backend_start
  limit 10;'

  done
  echo "--->>> 长事务查询和长2pc事务，长事务过程中产生的垃圾, 无法回收。会阻止vacuum，造成脏数据和年龄增长。对长查询分析是否异常，是有可以优化。"

  echo -e "\n"

  }

###############################################
function pg_replication () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库复制分析                       |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 流复制统计信息 "
  psql --pset=pager=off -q -x -c 'select pid,usename,application_name,client_addr,client_port,state,replay_lsn,replay_lag,sync_state from pg_stat_replication;'
  psql --pset=pager=off -q -x -c 'select * from pg_stat_wal_receiver;'
  echo "--->>> 如果延迟非常大, 建议排查网络带宽, 以及本地读wal的性能, 远程写wal的性能"

  echo "###### 流复制插槽 "
  psql --pset=pager=off -q -x -c 'select slot_name,plugin,slot_type,datoid,active,active_pid,restart_lsn,confirmed_flush_lsn from pg_replication_slots;'
  echo "--->>> 如果延迟非常大, 建议排查网络带宽, 以及本地读wal的性能, 远程写wal的性能"

  echo "###### 逻辑复制信息"
  psql --pset=pager=off -q -x -c 'select * from pg_publication;'
  psql --pset=pager=off -q -x -c 'select * from pg_subscription;'
  psql --pset=pager=off -q -x -c 'select subname,pid,received_lsn,latest_end_lsn,latest_end_time from pg_stat_subscription;'
  echo "--->>> 如果延迟非常大, 建议排查网络带宽, 以及本地读wal的性能, 远程写wal的性能"  

  echo -e "\n"
}

###############################################
function pg_backup () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库流复制分析                       |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 归档统计信息 "
  psql --pset=pager=off -q -c 'select pg_walfile_name(pg_current_wal_lsn()) now_wal, * from pg_stat_archiver;'
  echo "--->>> 如果当前的now_wal文件和最后一个归档失败的wal文件之间相差很多个文件, 建议尽快排查归档失败的原因, 以便修复, 否则pg_wal目录可能会撑爆."

  echo -e "\n"
}
###############################################
function pg_security () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   数据库安全及风险分析                   |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  echo "###### 角色权限密码有效期"
  psql --pset=pager=off -q -c 'select rolname,rolsuper,rolinherit,rolcreaterole,rolcreatedb,rolcanlogin,rolreplication,rolconnlimit,rolvaliduntil from pg_roles;'
  echo "--->>> 角色具有管理员权限，需要特别注意。"
  echo "--->>> 到期后, 用户将无法登陆, 记得及时修改密码,。"

  echo "###### 密码泄露检查-命令历史文件"
  cat ~/.psql_history |grep -i "password"  |grep -i -E "role|group|user"

  echo "###### 密码泄露检查-数据库日志文件"
  log_dir=`psql --pset=pager=off -qAt -c 'show log_directory'`
  log=(`find $PGDATA/$log_dir -name "*.csv" -type f -mtime -7 -exec ls {} \;`)
  echo ${log[*]} 
  for l in ${log[*]}
  do
  cat $l | grep -E "^[0-9]" | grep -i -r -E "role|group|user" |grep -i "password"|grep -i -E "create|alter"
  done

  echo "###### 密码泄露检查-恢复文件"
  cat $PGDATA/recovery.* |grep -i "password"

  echo "###### 密码泄露检查-数据库密码存储方式是明文还是密文"
  psql --pset=pager=off -q -c 'select rolname,rolcanlogin,rolpassword,rolvaliduntil from pg_authid where rolpassword !~ $$^md5$$;'

  echo "###### 密码泄露检查-pg_stat_statements"
  psql --pset=pager=off -q -c 'select query from pg_stat_statements where (query ~* $$group$$ or query ~* $$user$$ or query ~* $$role$$) and query ~* $$password$$'
  
  echo "###### 密码泄露检查-pg_user_mappings, pg_views :  "
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -c 'select current_database(),* from pg_user_mappings where umoptions::text ~* $$password$$'
  psql -d $db --pset=pager=off -c 'select current_database(),* from pg_views where definition ~* $$password$$ and definition ~* $$dblink$$'
  done

  echo "--->>> 明文密码存放会造成泄露,如果以上输出显示密码已泄露, 尽快修改"
  echo "--->>> 明文密码不安全, 建议使用create|alter role ... encrypted password."
  echo "--->>> 在fdw, dblink based view中不建议使用密码明文. "
  echo "--->>> 在recovery.*的配置中不要使用密码, 不安全, 可以使用.pgpass配置密码 . "

  echo "###### unlogged table和哈希索引"
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),t3.rolname,t2.nspname,t1.relname from pg_class t1,pg_namespace t2,pg_authid t3 where t1.relnamespace=t2.oid and t1.relowner=t3.oid and t1.relpersistence=$$u$$'
  psql -d $db --pset=pager=off -q -c 'select current_database(),pg_get_indexdef(oid) from pg_class where relkind=$$i$$ and pg_get_indexdef(oid) ~ $$USING hash$$'
  done
  echo "--->>> unlogged table和hash index不记录wal, 无法使用流复制或者log shipping的方式复制到standby节点, 如果在standby节点执行某些SQL, 可能导致报错或查不到数据. "
  echo "--->>> 在数据库CRASH后无法修复unlogged table和hash index, 不建议使用. "
  echo "--->>> PITR对unlogged table和hash index也不起作用. "

  echo "###### 剩余可使用次数不足1000万次的序列检查 "

  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off <<EOF
  create or replace function f(OUT v_datname name, OUT v_role name, OUT v_nspname name, OUT v_relname name, OUT v_times_remain int8) returns setof record as \$\$
  declare
  begin
    v_datname := current_database();
    for v_role,v_nspname,v_relname in select rolname,nspname,relname from pg_authid t1 , pg_class t2 , pg_namespace t3 where t1.oid=t2.relowner and t2.relnamespace=t3.oid and t2.relkind='S' 
    LOOP
      execute 'select (max_value-last_value)/increment_by from "'||v_nspname||'"."'||v_relname||'" where not is_cycled' into v_times_remain;
      return next;
    end loop;
  end;
  \$\$ language plpgsql;

  select * from f() where v_times_remain is not null and v_times_remain < 10240000 order by v_times_remain limit 10;
EOF
  done

  echo "--->>> 序列剩余使用次数到了之后, 将无法使用, 报错, 请开发人员关注. "

  echo "###### 触发器, 事件触发器: "
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),relname,tgname,proname,tgenabled from pg_trigger t1,pg_class t2,pg_proc t3 where t1.tgfoid=t3.oid and t1.tgrelid=t2.oid'
  psql -d $db --pset=pager=off -q -c 'select current_database(),rolname,proname,evtname,evtevent,evtenabled,evttags from pg_event_trigger t1,pg_proc t2,pg_authid t3 where t1.evtfoid=t2.oid and t1.evtowner=t3.oid'
  done
  echo "--->>> 请管理员注意触发器和事件触发器的必要性. "

  echo "----->>>---->>>  检查是否使用了a-z 0-9 _ 以外的字母作为对象名: "
  psql --pset=pager=off -q -c 'select distinct datname from (select datname,regexp_split_to_table(datname,$$$$) word from pg_database) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95'
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'select current_database(),relname,relkind from (select relname,relkind,regexp_split_to_table(relname,$$$$) word from pg_class) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2,3'
  psql -d $db --pset=pager=off -q -c 'select current_database(), typname from (select typname,regexp_split_to_table(typname,$$$$) word from pg_type) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2'
  psql -d $db --pset=pager=off -q -c 'select current_database(), proname from (select proname,regexp_split_to_table(proname,$$$$) word from pg_proc where proname !~ $$^RI_FKey_$$) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2'
  psql -d $db --pset=pager=off -q -c 'select current_database(),nspname,relname,attname from (select nspname,relname,attname,regexp_split_to_table(attname,$$$$) word from pg_class a,pg_attribute b,pg_namespace c where a.oid=b.attrelid and a.relnamespace=c.oid ) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2,3,4'
  done
  echo "--->>> 建议任何identify都只使用 a-z, 0-9, _ (例如表名, 列名, 视图名, 函数名, 类型名, 数据库名, schema名, 物化视图名等等)."

  echo "###### 锁等待: "
psql -x --pset=pager=off <<EOF
with    
t_wait as    
(    
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,    
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name   
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and not a.granted   
),   
t_run as   
(   
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,   
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name   
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and a.granted   
),   
t_overlap as   
(   
  select r.* from t_wait w join t_run r on   
  (   
    r.locktype is not distinct from w.locktype and   
    r.database is not distinct from w.database and   
    r.relation is not distinct from w.relation and   
    r.page is not distinct from w.page and   
    r.tuple is not distinct from w.tuple and   
    r.virtualxid is not distinct from w.virtualxid and   
    r.transactionid is not distinct from w.transactionid and   
    r.classid is not distinct from w.classid and   
    r.objid is not distinct from w.objid and   
    r.objsubid is not distinct from w.objsubid and   
    r.pid <> w.pid   
  )    
),    
t_unionall as    
(    
  select r.* from t_overlap r    
  union all    
  select w.* from t_wait w    
)    
select locktype,datname,relation::regclass,page,tuple,virtualxid,transactionid::text,classid::regclass,objid,objsubid,   
string_agg(   
'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||   
'Lock_Granted: '||case when granted is null then 'NULL' else granted::text end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , FastPath: '||case when fastpath is null then 'NULL' else fastpath::text end||' , VirtualTransaction: '||case when virtualtransaction is null then 'NULL' else virtualtransaction::text end||' , Session_State: '||case when state is null then 'NULL' else state::text end||chr(10)||   
'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||    
'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||    
'SQL (Current SQL in Transaction): '||chr(10)||  
case when query is null then 'NULL' else query::text end,    
chr(10)||'--------'||chr(10)    
order by    
  (  case mode    
    when 'INVALID' then 0   
    when 'AccessShareLock' then 1   
    when 'RowShareLock' then 2   
    when 'RowExclusiveLock' then 3   
    when 'ShareUpdateExclusiveLock' then 4   
    when 'ShareLock' then 5   
    when 'ShareRowExclusiveLock' then 6   
    when 'ExclusiveLock' then 7   
    when 'AccessExclusiveLock' then 8   
    else 0   
  end  ) desc,   
  (case when granted then 0 else 1 end)  
) as lock_conflict  
from t_unionall   
group by   
locktype,datname,relation,page,tuple,virtualxid,transactionid::text,classid,objid,objsubid ;   
EOF
echo "--->>> 锁等待状态, 反映业务逻辑的问题或者SQL性能有问题, 建议深入排查持锁的SQL. "
echo -e "\n"

  echo -e "\n"
}

###############################################

function pg_reset () {

  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
  echo "|                   重置统计信息                           |"
  echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"

  #echo "######  重置统计信息: "
  #for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  #do
  #psql -d $db --pset=pager=off -c 'select pg_stat_reset()'
  #done
  #psql --pset=pager=off -c 'select pg_stat_reset_shared($$bgwriter$$)'
  #psql --pset=pager=off -c 'select pg_stat_reset_shared($$archiver$$)'

  echo "###### 重置pg_stat_statements统计信息: "
  psql --pset=pager=off -Aq -c 'select pg_stat_statements_reset()'

  echo -e "\n"
}

##############################################
# main
function main() {
  comm
  pg_database_info
  pg_database_parameter
  pg_space_usage
  pg_connect
  pg_database_log
  pg_log_sql
  pg_performance
  pg_mvcc
  pg_replication
  pg_backup
  pg_security
  pg_reset
}

main > /tmp/pg_check_db$DATE 2>&1
