# pg_hint_plan

**作者**

Chrisx

**日期**

2021-11-23

**内容**

pg_hint_plan使用,ref[pg-hint-plan](https://postgrespro.com/docs/enterprise/10/pg-hint-plan.html?spm=a2c4g.11186623.0.0.256f60f50ks8pd)
----

[toc]

## 安装

下载[pg_hint_plan](https://github.com/ossc-db/pg_hint_plan)

:warning: 下载时选择对应版本的branches

```sh
unzip pg_hint_plan-PG12.zip
make
make install

```

## 使用

1. 加载扩展
  
```sql
alter system set shared_preload_libraries = pg_hint_plan; --加载插件库
create extension pg_hint_plan;  --创建扩展

```

2. 重启生效

```sh
pg_ctl restart

```

3 使用

```sql

create table test_hint(id int);
insert into test_hint select * from generate_series(1,10);
create index idx_test_hint on test_hint (id);

/*+ IndexScan(test_hint) */ explain select * from test_hint where id=1; --使用索引
/*+ seqscan(test_hint) */ explain select  * from test_hint where id=10; --强制全表扫描

/*+ Set (temp_file_limit 10MB) */ --guc参数测试不起作用？
with recursive tree as (
    select dep.id,dep.name,dep.parent_id from department dep where dep.id =7
    union all
    select dep.id,dep.name,dep.parent_id from department dep inner join tree on tree.parent_id = dep.id
) select * from tree;


```

