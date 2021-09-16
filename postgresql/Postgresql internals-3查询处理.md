# 查询处理
在PostgreSQL中，虽然9.6版本中实现的并行查询使用多个后台工作进程，但后端进程基本上处理连接客户端发出的所有查询。该后端由五个子系统组成，如下所示：
1. 编译器(Parser)
   解析器解析纯文本形式的SQL语句生成解析树(parse tree)。
2. 分析器(Analyzer/Analyser)
   分析器对解析树进行语义分析并生成查询树(query tree)。
3. 重写器(Rewriter)
   重写器使用存储在规则系统中的规则转换查询树。
4. 优化器(Planner)
   优化器从查询树中生成执行最优计划树(plan tree)。
5. 执行器(Executor)
   执行器通过按照计划树创建的顺序访问表和索引来执行查询。
 
# 优化器(planner)和执行器(exector)
优化器从重写器接收查询树并生成可由执行器最优处理的(查询)计划树。
PostgreSQL中的优化器是基于成本的优化；它不支持基于规则的优化和提示。此计划器是RDBMS中最复杂的子系统；因此，本章后面的部分将详细描述优化器。
> pg_hint_plan
>
> PostgreSQL不支持在SQL中规划提示，它将永远不被支持。如果您想在查询中使用提示，那么值得考虑引用*pg_hint_plan*扩展。请详细参考[官方网站](http://pghintplan.osdn.jp/pg_hint_plan.html)。
 
```sql
testdb=# EXPLAIN SELECT * FROM tbl;
                    QUERY PLAN                        
--------------------------------------------------------- 
Seq Scan on tbl  (cost=0.00..145.00 rows=10000 width=8)
(1 row)
```
在第4行中，该命令显示有关顺序扫描的信息。在成本部分，有两个值; 0.00和145.00。在这种情况下，启动成本和总成本分别为0.00和145.00。
 
## 3.2. 单表查询中的成本估算
PostgreSQL的查询优化基于成本。
成本通过[costsize.c](https://github.com/postgres/postgres/blob/master/src/backend/optimizer/path/costsize.c) 中定义的函数估算。执行器执行的所有操作都具有相应的成本估算函数。例如，顺序扫描和索引扫描的成本分别由cost_seqscan()和cost_index()进行估算。
在PostgreSQL中，有三种成本：**启动成本(start-up)**，**运行成本(run)**和**总成本(total)**。总成本是启动和运行成本的总和；因此，只有启动和运行成本是独立估算的。 
- **启动成本**是在获取第一个元组之前花费的成本。例如，索引扫描节点的启动成本是读取索引页以访问目标表中的第一个元组的开销。
- **运行成本**是获取所有元组的成本。
- **总成本**是启动成本和运行成本的总和。
[EXPLAIN](https://www.postgresql.org/docs/current/static/sql-explain.html)命令显示每个操作的启动和总成本。最简单的例子如下所示：
```sql
testdb=# EXPLAIN SELECT * FROM tbl;
                    QUERY PLAN                        
--------------------------------------------------------- 
Seq Scan on tbl  (cost=0.00..145.00 rows=10000 width=8)
(1 row)
```
在第4行中，该命令显示有关顺序扫描的信息。在成本部分，有两个值; 0.00和145.00。在这种情况下，启动成本和总成本分别为0.00和145.00。
在本节中，我们将详细探讨如何估计顺序扫描(sequential scan)，索引扫描(index scan)和排序操作(sort operation)。
在下面的描述中，我们使用如下所示的表和索引：
```sql
testdb=# CREATE TABLE tbl (id int PRIMARY KEY, data int);
testdb=# CREATE INDEX tbl_data_idx ON tbl (data);
testdb=# INSERT INTO tbl SELECT generate_series(1,10000),generate_series(1,10000);
testdb=# ANALYZE;
testdb=# \d tbl
      Table "public.tbl"
 Column |  Type   | Modifiers 
--------+---------+-----------
 id     | integer | not null
 data   | integer | 
Indexes:
    "tbl_pkey" PRIMARY KEY, btree (id)
    "tbl_data_idx" btree (data)
```
### 3.2.1. 顺序扫描
顺序扫描的成本由cost_seqscan()函数估计。在本小节中，我们将探讨如何估计以下查询的顺序扫描成本。
```sql
testdb=# SELECT * FROM tbl WHERE id < 8000;
```
在顺序扫描中，启动成本等于0，运行成本由以下公式定义：
   ‘run cost’ = ‘cpu run cost’ + ‘disk run cost’
       = (cpu_tuple_cost + cpu_operator_cost) × $N_ {tuple}$ + seq_page_cost × $N_ {page}$
 
其中[seq_page_cost](https://www.postgresql.org/docs/current/static/runtime-config-query.html#GUC-SEQ-PAGE-COST), [cpu_tuple_cost](https://www.postgresql.org/docs/current/static/runtime-config-query.html#GUC-CPU-TUPLE-COST)和[cpu_operator_cost](https://www.postgresql.org/docs/current/static/runtime-config-query.html#GUC-CPU-OPERATOR-COST)在postgresql.conf文件中设置，默认值分别为1.0, 0.01和0.0025; $N_ {tuple}$和$N_ {page}$分别是该表的所有元组和所有页面的编号，可以使用以下查询显示这些编号：
```sql
testdb=# SELECT relpages, reltuples FROM pg_class WHERE relname = 'tbl';
 relpages | reltuples 
----------+-----------
       45 |     10000
(1 row)
```
   (1) $N_ {page}$=10000,
   (2) $N_ {page}$=45.     
从而,
   ‘run cost’  =  (0.01 + 0.0025) × 10000 + 1.0 × 45 = 170.0.
最终,
   ‘total cost’ = 0.0 + 170.0 = 170.
为了确认，以上查询的EXPLAIN命令的结果如下所示：
 
```sql
testdb=# EXPLAIN SELECT * FROM tbl WHERE id < 8000;
                    QUERY PLAN                       
-------------------------------------------------------- 
Seq Scan on tbl  (cost=0.00..170.00 rows=8000 width=8)   
    Filter: (id < 8000)
(2 rows)
```
在第4行，我们可以发现启动和总成本分别是170.00和170.00， 据估计，将通过扫描所有行来选择8000行(tuple)。 在第5行中，显示了顺序扫描的过滤器‘Filter：(ID<8000)’。更准确地说，它被称为*table level filter predicate*。请注意，这种类型的过滤器是在读取表中的所有元组时使用的，并且它不会缩小page页的扫描范围。
 
 
!> 从运行成本估算中可以看出，PostgreSQL假设所有页面都将从存储中读取; 也就是说，PostgreSQL不会考虑扫描页是否在共享缓冲区中。
### 3.2.2. 索引扫描
尽管PostgreSQL支持许多[索引方法](https://www.postgresql.org/docs/current/static/indexes-types.html)，如BTree，[GiST](https://www.postgresql.org/docs/current/static/gist.html)，[GIN](https://www.postgresql.org/docs/current/static/gin.html)和[BRIN](https://www.postgresql.org/docs/current/static/brin.html)，但索引扫描的成本使用通用的成本函数cost_index()估算。
在本小节中，我们将探讨如何估计以下查询的索引扫描成本：
```sql
testdb=# SELECT id, data FROM tbl WHERE data < 240;
```
在估算成本之前，索引页和索引元组的数量, $N_{index,tuple}$ and $N_{index,page}$ 如下所示：
```sql
testdb=# SELECT relpages, reltuples FROM pg_class WHERE relname = 'tbl_data_idx';
 relpages | reltuples 
----------+-----------
       30 |     10000
(1 row)
```
(3) $N_{index,tuple}$=10000,
(4) $N_{index,page}$=30.
#### 3.2.2.1. 启动成本(Start-Up Cost)
索引扫描的启动成本是读取索引页以访问目标表中第一个元组的开销，它由以下公式定义：
   ‘start-up cost’ = {ceil($log_{2}$($Nindex,tuple$)) + ($Hindex$ + 1) × 50} × cpu_operator_cost,
$H_{index}$是索引树的高度。
在这种情况下，根据(3)，$N_{index,tuple}$为10000; $H_{index}$是1; cpu_operator_cost为0.0025(默认)。从而，
   (5) ‘start-up cost’ = {ceil($log_{2}($10000)) + (1 + 1) × 50} × 0.0025 = 0.285
#### 3.2.2.2. 运行成本(Run Cost)
索引扫描的运行成本是表和索引的CPU成本和IO(输入/输出)成本的总和：
   ‘run cost’ = (‘index cpu cost’ + ‘table cpu cost’) + (‘index IO cost’ + ‘table IO cost’).