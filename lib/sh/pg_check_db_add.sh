###################################################
:<< EOF
  # 暂时没有加入main
  function relation_bucket() { 
  echo "###### 用户对象占用空间的柱状图"
  for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do 
  psql -d $db --pset=pager=off -q -c 'select current_database(),
      buk this_buk_no,
      cnt rels_in_this_buk,
      pg_size_pretty(min) buk_min,
      pg_size_pretty(max) buk_max
  from(
          select row_number() over (
                  partition by buk
                  order by tsize
              ),
              tsize,
              buk,
              min(tsize) over (partition by buk),
              max(tsize) over (partition by buk),
              count(*) over (partition by buk) cnt
          from (
                  select pg_relation_size(a.oid) tsize,
                      width_bucket(pg_relation_size(a.oid), tmin -1, tmax + 1, 10) buk
                  from (
                          select min(pg_relation_size(a.oid)) tmin,
                              max(pg_relation_size(a.oid)) tmax
                          from pg_class a,
                              pg_namespace c
                          where a.relnamespace = c.oid
                              and nspname !~ $$ ^ pg_ $$
                              and nspname <> $$information_schema$$
                      ) t,
                      pg_class a,
                      pg_namespace c
                  where a.relnamespace = c.oid
                      and nspname !~ $$ ^ pg_ $$
                      and nspname <> $$information_schema$$
              ) t
      ) t
  where row_number = 1;'
  done

  echo -e "\n"
}

# 暂时没有加入main
function table_blot() {
  echo "###### 表引膨胀检查"
  for db in `psql --pset=pager=off -Atq -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -c 'SELECT
    current_database() AS db, schemaname, tablename, reltuples::bigint AS tups, relpages::bigint AS pages, otta,
    ROUND(CASE WHEN otta=0 OR sml.relpages=0 OR sml.relpages=otta THEN 0.0 ELSE sml.relpages/otta::numeric END,1) AS tbloat,
    CASE WHEN relpages < otta THEN 0 ELSE relpages::bigint - otta END AS wastedpages,
    CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::bigint END AS wastedbytes,
    CASE WHEN relpages < otta THEN $$0 bytes$$::text ELSE (bs*(relpages-otta))::bigint || $$ bytes$$ END AS wastedsize,
    iname, ituples::bigint AS itups, ipages::bigint AS ipages, iotta,
    ROUND(CASE WHEN iotta=0 OR ipages=0 OR ipages=iotta THEN 0.0 ELSE ipages/iotta::numeric END,1) AS ibloat,
    CASE WHEN ipages < iotta THEN 0 ELSE ipages::bigint - iotta END AS wastedipages,
    CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
    CASE WHEN ipages < iotta THEN $$0 bytes$$ ELSE (bs*(ipages-iotta))::bigint || $$ bytes$$ END AS wastedisize,
    CASE WHEN relpages < otta THEN
      CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta::bigint) END
      ELSE CASE WHEN ipages < iotta THEN bs*(relpages-otta::bigint)
        ELSE bs*(relpages-otta::bigint + ipages-iotta::bigint) END
    END AS totalwastedbytes
  FROM (
    SELECT
      nn.nspname AS schemaname,
      cc.relname AS tablename,
      COALESCE(cc.reltuples,0) AS reltuples,
      COALESCE(cc.relpages,0) AS relpages,
      COALESCE(bs,0) AS bs,
      COALESCE(CEIL((cc.reltuples*((datahdr+ma-
        (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)),0) AS otta,
      COALESCE(c2.relname,$$?$$) AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
      COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
    FROM
       pg_class cc
    JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname <> $$information_schema$$
    LEFT JOIN
    (
      SELECT
        ma,bs,foo.nspname,foo.relname,
        (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
        (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
      FROM (
        SELECT
          ns.nspname, tbl.relname, hdr, ma, bs,
          SUM((1-coalesce(null_frac,0))*coalesce(avg_width, 2048)) AS datawidth,
          MAX(coalesce(null_frac,0)) AS maxfracsum,
          hdr+(
            SELECT 1+count(*)/8
            FROM pg_stats s2
            WHERE null_frac<>0 AND s2.schemaname = ns.nspname AND s2.tablename = tbl.relname
          ) AS nullhdr
        FROM pg_attribute att 
        JOIN pg_class tbl ON att.attrelid = tbl.oid
        JOIN pg_namespace ns ON ns.oid = tbl.relnamespace 
        LEFT JOIN pg_stats s ON s.schemaname=ns.nspname
        AND s.tablename = tbl.relname
        AND s.inherited=false
        AND s.attname=att.attname,
        (
          SELECT
            (SELECT current_setting($$block_size$$)::numeric) AS bs,
              CASE WHEN SUBSTRING(SPLIT_PART(v, $$ $$, 2) FROM $$#"[0-9]+.[0-9]+#"%$$ for $$#$$)
                IN ($$8.0$$,$$8.1$$,$$8.2$$) THEN 27 ELSE 23 END AS hdr,
            CASE WHEN v ~ $$mingw32$$ OR v ~ $$64-bit$$ THEN 8 ELSE 4 END AS ma
          FROM (SELECT version() AS v) AS foo
        ) AS constants
        WHERE att.attnum > 0 AND tbl.relkind=$$r$$
        GROUP BY 1,2,3,4,5
      ) AS foo
    ) AS rs
    ON cc.relname = rs.relname AND nn.nspname = rs.nspname
    LEFT JOIN pg_index i ON indrelid = cc.oid
    LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
  ) AS sml order by wastedbytes desc limit 5'
  done

  echo "建议: "
  echo "    根据浪费的字节数, 设置合适的autovacuum_vacuum_scale_factor, 大表如果频繁的有更新或删除和插入操作, 建议设置较小的autovacuum_vacuum_scale_factor来降低浪费空间. "
  echo "    同时还需要打开autovacuum, 根据服务器的内存大小, CPU核数, 设置足够大的autovacuum_work_mem 或 autovacuum_max_workers 或 maintenance_work_mem, 以及足够小的 autovacuum_naptime . "
  echo "    同时还需要分析是否对大数据库使用了逻辑备份pg_dump, 系统中是否经常有长SQL, 长事务. 这些都有可能导致膨胀. "
  echo "    使用pg_reorg或者vacuum full可以回收膨胀的空间. "
  echo "    参考: http://blog.163.com/digoal@126/blog/static/1638770402015329115636287/ "
  echo "    otta评估出的表实际需要页数, iotta评估出的索引实际需要页数; "
  echo "    bs数据库的块大小; "
  echo "    tbloat表膨胀倍数, ibloat索引膨胀倍数, wastedpages表浪费了多少个数据块, wastedipages索引浪费了多少个数据块; "
  echo "    wastedbytes表浪费了多少字节, wastedibytes索引浪费了多少字节; "

  }


# 暂时没有加入main
function index_blot() {
  echo "###### 索引膨胀检查"
  for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
  do
  psql -d $db --pset=pager=off -q -x -c 'SELECT
    current_database() AS db, schemaname, tablename, reltuples::bigint AS tups, relpages::bigint AS pages, otta,
    ROUND(CASE WHEN otta=0 OR sml.relpages=0 OR sml.relpages=otta THEN 0.0 ELSE sml.relpages/otta::numeric END,1) AS tbloat,
    CASE WHEN relpages < otta THEN 0 ELSE relpages::bigint - otta END AS wastedpages,
    CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::bigint END AS wastedbytes,
    CASE WHEN relpages < otta THEN $$0 bytes$$::text ELSE (bs*(relpages-otta))::bigint || $$ bytes$$ END AS wastedsize,
    iname, ituples::bigint AS itups, ipages::bigint AS ipages, iotta,
    ROUND(CASE WHEN iotta=0 OR ipages=0 OR ipages=iotta THEN 0.0 ELSE ipages/iotta::numeric END,1) AS ibloat,
    CASE WHEN ipages < iotta THEN 0 ELSE ipages::bigint - iotta END AS wastedipages,
    CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
    CASE WHEN ipages < iotta THEN $$0 bytes$$ ELSE (bs*(ipages-iotta))::bigint || $$ bytes$$ END AS wastedisize,
    CASE WHEN relpages < otta THEN
      CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta::bigint) END
      ELSE CASE WHEN ipages < iotta THEN bs*(relpages-otta::bigint)
        ELSE bs*(relpages-otta::bigint + ipages-iotta::bigint) END
    END AS totalwastedbytes
  FROM (
    SELECT
      nn.nspname AS schemaname,
      cc.relname AS tablename,
      COALESCE(cc.reltuples,0) AS reltuples,
      COALESCE(cc.relpages,0) AS relpages,
      COALESCE(bs,0) AS bs,
      COALESCE(CEIL((cc.reltuples*((datahdr+ma-
        (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)),0) AS otta,
      COALESCE(c2.relname,$$?$$) AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
      COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
    FROM
       pg_class cc
    JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname <> $$information_schema$$
    LEFT JOIN
    (
      SELECT
        ma,bs,foo.nspname,foo.relname,
        (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
        (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
      FROM (
        SELECT
          ns.nspname, tbl.relname, hdr, ma, bs,
          SUM((1-coalesce(null_frac,0))*coalesce(avg_width, 2048)) AS datawidth,
          MAX(coalesce(null_frac,0)) AS maxfracsum,
          hdr+(
            SELECT 1+count(*)/8
            FROM pg_stats s2
            WHERE null_frac<>0 AND s2.schemaname = ns.nspname AND s2.tablename = tbl.relname
          ) AS nullhdr
        FROM pg_attribute att 
        JOIN pg_class tbl ON att.attrelid = tbl.oid
        JOIN pg_namespace ns ON ns.oid = tbl.relnamespace 
        LEFT JOIN pg_stats s ON s.schemaname=ns.nspname
        AND s.tablename = tbl.relname
        AND s.inherited=false
        AND s.attname=att.attname,
        (
          SELECT
            (SELECT current_setting($$block_size$$)::numeric) AS bs,
              CASE WHEN SUBSTRING(SPLIT_PART(v, $$ $$, 2) FROM $$#"[0-9]+.[0-9]+#"%$$ for $$#$$)
                IN ($$8.0$$,$$8.1$$,$$8.2$$) THEN 27 ELSE 23 END AS hdr,
            CASE WHEN v ~ $$mingw32$$ OR v ~ $$64-bit$$ THEN 8 ELSE 4 END AS ma
          FROM (SELECT version() AS v) AS foo
        ) AS constants
        WHERE att.attnum > 0 AND tbl.relkind=$$r$$
        GROUP BY 1,2,3,4,5
      ) AS foo
    ) AS rs
    ON cc.relname = rs.relname AND nn.nspname = rs.nspname
    LEFT JOIN pg_index i ON indrelid = cc.oid
    LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
  ) AS sml order by wastedibytes desc limit 5'
  done

  echo "建议: "
  echo "    如果索引膨胀太大, 会影响性能, 建议重建索引, create index CONCURRENTLY ... . "
  echo -e "\n"
  }


echo "----->>>---->>>  未引用的大对象: "
for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
do
vacuumlo -n $db -w
echo ""
done
echo "建议: "
echo "    如果大对象没有被引用时, 建议删除, 否则就类似于内存泄露, 使用vacuumlo可以删除未被引用的大对象, 例如: vacuumlo -l 1000 $db -w . "
echo "    应用开发时, 注意及时删除不需要使用的大对象, 使用lo_unlink 或 驱动对应的API . "
echo "    参考 http://www.postgresql.org/docs/9.4/static/largeobjects.html "
echo -e "\n"

echo "----->>>---->>>  SQL注入风险分析: "
cat *.csv | grep -E "^[0-9]" | grep exec_simple_query |awk -F "," '{print $2" "$3" "$5" "$NF}'|sed 's/\:[0-9]*//g'|sort|uniq -c|sort -n -r
echo "建议: "
echo "    调用exec_simple_query有风险, 允许多个SQL封装在一个接口中调用, 建议程序使用绑定变量规避SQL注入风险, 或者程序端使用SQL注入过滤插件. "
echo -e "\n"


echo "----->>>---->>>  普通用户对象上的规则安全检查: "
for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
do
psql -d $db --pset=pager=off -c 'select current_database(),a.schemaname,a.tablename,a.rulename,a.definition from pg_rules a,pg_namespace b,pg_class c,pg_authid d where a.schemaname=b.nspname and a.tablename=c.relname and d.oid=c.relowner and not d.rolsuper union all select current_database(),a.schemaname,a.viewname,a.viewowner,a.definition from pg_views a,pg_namespace b,pg_class c,pg_authid d where a.schemaname=b.nspname and a.viewname=c.relname and d.oid=c.relowner and not d.rolsuper'
done
echo "建议: "
echo "    防止普通用户在规则中设陷阱, 注意有危险的security invoker的函数调用, 超级用户可能因为规则触发后误调用这些危险函数(以invoker角色). "
echo "    参考 http://blog.163.com/digoal@126/blog/static/16387704020155131217736/ "
echo -e "\n"

echo "----->>>---->>>  普通用户自定义函数安全检查: "
for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
do
psql -d $db --pset=pager=off -c 'select current_database(),b.rolname,c.nspname,a.proname from pg_proc a,pg_authid b,pg_namespace c where a.proowner=b.oid and a.pronamespace=c.oid and not b.rolsuper and not a.prosecdef'
done
echo "建议: "
echo "    防止普通用户在函数中设陷阱, 注意有危险的security invoker的函数调用, 超级用户可能因为触发器触发后误调用这些危险函数(以invoker角色). "
echo "    参考 http://blog.163.com/digoal@126/blog/static/16387704020155131217736/ "
echo -e "\n"


echo "----->>>---->>>  继承关系检查: "
for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)'`
do
psql -d $db --pset=pager=off -q -c 'select inhrelid::regclass,inhparent::regclass,inhseqno from pg_inherits order by 2,3'
done
echo "建议: "
echo "    如果使用继承来实现分区表, 注意分区表的触发器中逻辑是否正常, 对于时间模式的分区表是否需要及时加分区, 修改触发器函数 . "
echo "    建议继承表的权限统一, 如果权限不一致, 可能导致某些用户查询时权限不足. "
echo -e "\n"

EOF