# greenplum 拉链表

## 介绍

dw是一个面向主题、集成、稳定且反应历史变化的数据集合，用于支持管理决策。
由于需要反应历史变化，dw中数据通常包含历史信息。记录企业发展各阶段信息，通过这些信息，对企业发展历程和未来趋势做出定量分析和预测。
历史拉链表是一个数据模型。是针对数仓设计中表存储方式而定义的。其记录一个事务从开始一直到当前状态的所有变化信息。拉链表可以避免每天存储所有记录造成的海里存储问题。同时也是处理缓慢变化数据的一种常见方式。

## applies to

场景：一个企业有5000w会员信息，每天20w会员资料变更。需要在gp中记录会员表的历史变化以备数据挖掘分析使用。即每天保留一个快照，反应历史数据情况。此时，反应历史变化，如果保留快照，存储两年，需要2*365*5000w，约365亿。存储更长时间则需要更多的存储空间。使用拉链算法存储，每日向历史表中添加变化的数据，每日不超20w，存储2年，约1.5亿。相比快照，存储空间占比很小。

## 原理及步骤
拉链表中，每条数据都有一个生效日期（dw_beg_date）和失效日期（dw_end_date）。失效时间设置为无穷大，这里设置为数据库最大值（3000-12-31）

```csv
name,phone,dw_beg_date,dw_end_date
1001,13200000001,2020-04-01,3000-12-31
1002,13200000002,2020-04-01,3000-12-31
```

第二天数据发生变化
1001被删除了，1002phone被改为13300000002
为了保留历史，1001的dw_end_date被修改为2020-04-02，1002变成两条记录。

```csv
name,phone,dw_beg_date,dw_end_date
1001,13200000001,2020-04-01,2020-04-02
1002,13200000002,2020-04-01,2020-04-02
1002,13300000002,2020-04-01,3000-12-31
```

第三天新增了一条数据1003

```csv
name,phone,dw_beg_date,dw_end_date
1001,13200000001,2020-04-01,2020-04-02
1002,13200000002,2020-04-01,2020-04-02
1002,13300000002,2020-04-02,3000-12-31
1002,13300000002,2020-04-03,3000-12-31
```

如果查询最新的数据，只查询失效时间为3000-12-31数据即可
如果查询4.1历史数据，则筛选dw_beg_date=2020-04-01 and dw_end_date < 3000-12-31
如果查询4.2历史数据，则筛选dw_beg_date=2020-04-01 and dw_end_date < 3000-12-31

可以以dw_end_date为分区键，做分区表，减少i/o

以下是拉链表刷新步骤，需要几个表完成数据流向

mem_fat，数据表（做成分区表），dw_end_date为分区键，保留历史数据（牛啊 ），（假设当前数据分区p30001231）
mem_delta，当天变更的数据，action字段表示数据库变更类型，新增（I）、更新（U），删除（D）
mem_tmp0，刷新过程中的临时表，有两个分区，分别记录历史数据（当天失效的数据），另一个分区记录当前数据。
mem_tmp1，刷新过程中的临时表，主要是在交换分区时使用。

刷新过程就是，将当天的全量数据与变化数据进行关联，并对不同的变更类型进（action）行处理。最终生成最新数据以及当天变更的历史数据。

## 表结构

mem_fat，数据表
```sql
create table mem_fat (
    member_id int,  --会员ID
    phoneno varchar(20),    --电话号码
    dw_beg_date timestamp,  --生效日期
    dw_end_date timestamp,  --失效日期
    dw_type char(1),    --类型（历史数据H，当前数据C）
    dw_action char(1),  --数据操作类型（I,U,D)
    dw_ins_date timestamp   --插入日期
 ) with (appendonly=true,compresslevel=5)
 distributed by (member_id)
 partition by range(dw_end_date)
 (
 partition p202001 start ('2020-01-01') inclusive,
 partition p202002 start ('2020-02-01') inclusive,
 partition p202003 start ('2020-03-01') inclusive,
 partition p202004 start ('2020-04-01') inclusive,
 DEFAULT PARTITION pdefault
 );
    
```

mem_delta，增量表
```sql
create table mem_delta (
    member_id int,  --会员ID  
    phoneno varchar(20),    --电话号码
    dw_action char(1), --数据操作类型（I,U,D)
    dw_ins_date timestamp   --插入日期
 ) with (appendonly=true,compresslevel=5)
 distributed by (member_id);
    
```

mem_tmp0，临时表
```sql
create table mem_tmp0 (
    member_id int,  --会员ID
    phoneno varchar(20),    --电话号码
    dw_beg_date timestamp,  --生效日期
    dw_end_date timestamp,  --失效日期
    dw_type char(1),    --类型（历史数据H，当前数据C）
    dw_action char(1),  --数据操作类型（I,U,D)
    dw_ins_date timestamp   --插入日期
 ) with (appendonly=true,compresslevel=5)
 distributed by (member_id)
 partition by list (dw_type)
 (
 partion ph values ('H'),
 partion pc values ('C'),
 default partition pdefault
 );
    
```

mem_tmp1，临时表
```sql
create table mem_tmp1 (
    member_id int,  --会员ID
    phoneno varchar(20),    --电话号码
    dw_beg_date timestamp,  --生效日期
    dw_end_date timestamp,  --失效日期
    dw_type char(1),    --类型（历史数据H，当前数据C）
    dw_action char(1),  --数据操作类型（I,U,D)
    dw_ins_date timestamp   --插入日期
 ) with (appendonly=true,compresslevel=5)
 distributed by (member_id)
 partition by list (dw_type)
 (
 partion ph values ('H'),
 partion pc values ('C'),
 default partition pdefault
 );
    
```

## demo
mem_fat，数据表
```csv

meber_id,phoneno,dw_beg_date,dw_end_date,dw_type,dw_action,dw_ins_date
001,13100000001,2020-04-01,3000-12-31,C,I,2020-04-01
002,13100000002,2020-04-01,3000-12-31,C,I,2020-04-01
003,13100000003,2020-04-01,3000-12-31,C,I,2020-04-01
004,13100000004,2020-04-01,3000-12-31,C,I,2020-04-01
005,13100000005,2020-04-01,3000-12-31,C,I,2020-04-01
006,13100000006,2020-04-01,3000-12-31,C,I,2020-04-01
007,13100000007,2020-04-01,3000-12-31,C,I,2020-04-01

```



mem_delta，增量表

```csv,2.6增量数据
member_id,phoneno,action,dw_ins_date
006,13100000006,I,2020-04-02
002,13100000002,D,2020-04-02
003,13100000003,U,2020-04-02

```
```csv,2.7增量数据
member_id,phoneno,action,dw_ins_date
007,13100000007,I,2020-04-03
004,13100000004,D,2020-04-03
005,13100000005,U,2020-04-03

```

## 数据加载

```sql

nohup gpfdist -d /home/gpadmin/exttab -p 8081 -t 600 >>/home/gpadmin/gpfdist.log 2>&1 &




create external table ext_mem_fat(
        member_id int,
        phoneno varchar(20),
        dw_beg_date timestamp,
        dw_end_date timestamp,
        dw_type char(1),
        dw_action char(1),
        dw_ins_date timestamp
) location('gpfdist://192.168.80.146:8081/mem_fat') format  'CSV'(
     header      DELIMITER ','       NULL as ''
)   encoding 'UTF8'   log errors segment reject limit 10 rows;




create table mem_fat (
    member_id int,
    phoneno varchar(20),
    dw_beg_date timestamp,
    dw_end_date timestamp,
    dw_type char(1),
    dw_action char(1),
    dw_ins_date timestamp
 ) with (appendonly=true,compresslevel=5)
 distributed by (member_id)
 partition by range(dw_end_date)
 (
 partition p202001 start ('2020-01-01') inclusive,
 partition p202002 start ('2020-02-01') inclusive,
 partition p202003 start ('2020-03-01') inclusive,
 partition p202004 start ('2020-04-01') inclusive,
 DEFAULT PARTITION pdefault
 );

insert into mem_fat select * from ext_mem_fat;





insert into mem_fat select * from ext_mem_fat;