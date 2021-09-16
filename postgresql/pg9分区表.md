PostgreSQL中的分区表是通过表继承来实现的（表继承博客http://www.cnblogs.com/NextAction/p/7366607.html）。创建分区表的步骤如下：

partition table

（1）创建“父表”，所有的分区表都从这张表继承。“父表”中不存数据，也不要定义约束和索引。

（2）创建“子表”，所有“子表”都是从“父表”中继承而来。这些“子表”就是所谓的分区，其实它们也是PostgreSQL表。

（3）给分区表创建约束。

（4）在分区表上创建索引。

（5）创建触发器，把对“父表”的插入重定向到分区表中。

（6）确保postgresql.conf中constraint_exclusion的配置参数是打开状态。打开后，可以确保查询智能的只查询分区表，而不会对其他分区表进行查询。

下面是创建分区表的例子：
复制代码

--创建销售明细表，作为“父表”
create table sales_detail (
product_id    int    not null,
price         numeric(12,2),
amount        int    not null,
sale_date     date   not null,
buyer         varchar(40),
buyer_contact text
);

--根据销售日期sale_date字段，每个季度作为一个分区，创建分区表
create table sales_detail_Y2017Q01(check (sale_date >= date '2017-01-01' and sale_date < date '2017-04-01') ) inherits (sales_detail);

create table sales_detail_Y2017Q02(check (sale_date >= date '2017-04-01' and sale_date < date '2017-07-01') ) inherits (sales_detail);

create table sales_detail_Y2017Q03(check (sale_date >= date '2017-07-01' and sale_date < date '2017-10-01') ) inherits (sales_detail);

create table sales_detail_Y2017Q04(check (sale_date >= date '2017-10-01' and sale_date < date '2018-01-01') ) inherits (sales_detail);

--在分区键sale_detail上创建索引
create index sales_detail_Y2017Q01_sale_date on sales_detail_Y2017Q01 (sale_date);

create index sales_detail_Y2017Q02_sale_date on sales_detail_Y2017Q02 (sale_date);

create index sales_detail_Y2017Q03_sale_date on sales_detail_Y2017Q03 (sale_date);

create index sales_detail_Y2017Q04_sale_date on sales_detail_Y2017Q04 (sale_date);

--创建触发器，当向sales_detail表中插入数据时，可以重定向插入到分区表中
--或者创建规则rule

create or replace function sales_detail_insert_trigger()
returns trigger as $$
begin
    if (new.sale_date >= date '2017-01-01' and new.sale_date < date '2017-04-01') then
    insert into sales_detail_Y2017Q01 values (new.*);
    elsif (new.sale_date >= date '2017-04-01' and new.sale_date < date '2017-07-01') then
    insert into sales_detail_Y2017Q02 values (new.*);
    elsif (new.sale_date >= date '2017-07-01' and new.sale_date < date '2017-10-01') then
    insert into sales_detail_Y2017Q03 values (new.*);
    elsif (new.sale_date >= date '2017-10-01' and new.sale_date < date '2018-01-01') then
    insert into sales_detail_Y2017Q04 values (new.*);
    else 
    raise exception 'Date out of range.Fix the sales_detail_insert_trigger () function!';
  end if;
  return null;
end;
$$
language plpgsql;

create trigger insert_sales_detail_trigger 
before insert on sales_detail
for each row execute procedure sales_detail_insert_trigger ();

--设置constraint_exclusion参数为“partition”状态。此参数默认为“partition”
set constrait_exclusion 'partition'

复制代码

测试分区表：
复制代码

--向“父表”中插入一条数据
test=# insert into sales_detail values (1,23.22,1,date'2017-08-16','zhaosi','xiangyashan222hao');

--数据已经插入到分区表中
test=# select * from sales_detail_Y2017Q03;
 product_id | price | amount | sale_date  | buyer  |   buyer_contact   
------------+-------+--------+------------+--------+-------------------
          1 | 23.22 |      1 | 2017-08-16 | zhaosi | xiangyashan222hao
(1 row)

--并且查询“父表”也可以查到插入的数据
test=# select * from sales_detail;
 product_id | price | amount | sale_date  | buyer  |   buyer_contact   
------------+-------+--------+------------+--------+-------------------
          1 | 23.22 |      1 | 2017-08-16 | zhaosi | xiangyashan222hao
(1 row)

--通过查看执行计划，可以看出当查询数据时，数据库会自动的去sales_detail_Y2017Q03分区表中查找，而不会扫描所有的分区表。
test=# explain select * from sales_detail where sale_date=date'2017-08-16';
                                             QUERY PLAN                                             
----------------------------------------------------------------------------------------------------
 Append  (cost=0.00..9.50 rows=3 width=158)
   ->  Seq Scan on sales_detail  (cost=0.00..0.00 rows=1 width=158)
         Filter: (sale_date = '2017-08-16'::date)
   ->  Bitmap Heap Scan on sales_detail_y2017q03  (cost=4.16..9.50 rows=2 width=158)
         Recheck Cond: (sale_date = '2017-08-16'::date)
         ->  Bitmap Index Scan on sales_detail_y2017q03_sale_date  (cost=0.00..4.16 rows=2 width=0)
               Index Cond: (sale_date = '2017-08-16'::date)
(7 rows)

复制代码

总结：

删除分区表中的子表，不会使触发器失效，只是当向被删除表中插入数据时会报错。

创建分区表过程中的触发器，可以用“规则”来代替，但触发器比“规则”更有优势，再此不再赘述。


=============================

postgresql查询分区表怎么查


大家知道 PostgreSQL 的分区是通过继承来实现的，按分区方式，可以实现表的列表分区，范围分区，以及复合分区等，本文仅介绍关于

分区表的几个查询，方便维护和管理分区表。

查询指定分区表信息

SELECT
    nmsp_parent.nspname AS parent_schema ,
    parent.relname AS parent ,
    nmsp_child.nspname AS child ,
    child.relname AS child_schema
FROM
    pg_inherits JOIN pg_class parent
        ON pg_inherits.inhparent = parent.oid JOIN pg_class child
        ON pg_inherits.inhrelid = child.oid JOIN pg_namespace nmsp_parent
        ON nmsp_parent.oid = parent.relnamespace JOIN pg_namespace nmsp_child
        ON nmsp_child.oid = child.relnamespace
WHERE
    parent.relname = 'table_name';

查询库中所有分区表子表个数

SELECT
    nspname ,
    relname ,
    COUNT(*) AS partition_num
FROM
    pg_class c ,
    pg_namespace n ,
    pg_inherits i
WHERE
    c.oid = i.inhparent
    AND c.relnamespace = n.oid
    AND c.relhassubclass
    AND c.relkind = 'r'
GROUP BY 1,2 ORDER BY partition_num DESC;

备注：如果表是分区表，那么相应的 pg_class.relhassubclass 字段为 ‘t’，否则为 ‘f’，下面是我在生产库查询的例子。