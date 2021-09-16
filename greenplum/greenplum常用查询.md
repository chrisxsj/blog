# gp 常用查询

## Gp 查询数据分布

查询数据分布

select gp_segment_id,count(*) from product group by gp_segment_id;
select hg_segment_id,count(*) from sb_payment_detail group by hg_segment_id;

修改分布键
alter table sb_payment_detail add PRIMARY KEY (JFSBID);

alter table sb_payment_detail set distributed by(JFSBID);

## greenplum 查询配置

SELECT * from gp_segment_configuration ;

## gp 查询分布键

```sql
select d.nspname||'.'||a.relname as table_name,string_agg(b.attname,',') as column_name
from
pg_catalog.pg_class a
inner join
pg_catalog.pg_attribute b
on a.oid=b.attrelid
inner join
pg_catalog.gp_distribution_policy c
on a.oid=c.localoid
inner join pg_catalog.pg_namespace d
on a.relnamespace=d.oid
where a.relkind='r' and b.attnum=any(c.distkey)
and a.relname like '%test%'  --替换表名
group by table_name
order by table_name desc;
```
