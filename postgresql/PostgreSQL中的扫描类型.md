# PostgreSQL中的扫描类型

## 文档用途

介绍PostgreSQL中的扫描类型详细信息

### 全表扫描

全表扫描在PostgreSQL中也称为顺序扫描（seq scan），全表扫描就是把表的所有数据块从头到尾读一遍，然后筛选出符合条件的数据块。
全表扫描在explain命令输出结果中用“Seq Scan”表示，如下所示

```bash
highgo=# explain select * from emp;
QUERY PLAN
------------------------------------------------------
Seq Scan on emp (cost=0.00..1.14 rows=14 width=116)(1 行记录)
```

### 索引扫描索

引通常是为了加快查询数据的速度而增加的。索引扫描，就是在索引中找出需要的数据行的物理位置，然后再到表的数据块中把相应的数据读出来。 索引扫描在explain命令输出结果中用"Index Scan"表示，如下

```bash
highgo=# explain select * from people where id=14;
QUERY PLAN
---------------------------------------------------------------------
Index Scan using inx_id on people (cost=0.44..8.45 rows=1 width=8)Index Cond: (id = 14)(2 行记录)
```

### 位图扫描

位图扫描也是走索引的一种方式。方式是扫描索引，把满足条件的行或块在内存中建一个位图，扫描完索引后，再根据位图列表的数据文件把相应的数据读出来。如果走了两个索引，可以把两个索引形成的位图进行"and"或"or"计算，合并成一个位图，再到表的数据文件中把数据读出来。 当执行计划的结果中行数很多时会进行位图扫描，如非等值查询、IN子句或有多个条件都可以走不同的索引时。 以下示例是返回值较多

```bash
highgo=# explain select ename from test where empno=7499;
QUERY PLAN
----------------------------------------------------------------------------
Bitmap Heap Scan on test (cost=79.79..613.59 rows=4064 width=5)Recheck Cond: (empno = 7499)
  -> Bitmap Index Scan on inx_empno (cost=0.00..78.77 rows=4064 width=0)Index Cond: (empno = 7499)(4 行记录)
```

在位图扫描中，可以看到"Bitmap Index Scan"先在索引中找到符合条件的行，然后在内存中建立位图，之后再到表中扫描，也就是看到" Bitmap Heap Scan"。 

### 条件过滤

条件过滤，一般就是在where条件上加的过滤条件，当扫描数据行时，会找出满足过滤条件的行。条件过滤在执行计划中显示为"Filter"，示例如下

```bash
highgo=# explain select ename from emp where empno=7499;
QUERY PLAN
----------------------------------------------------
Seq Scan on emp (cost=0.00..1.18 rows=1 width=38)Filter: (empno = 7499)(2 行记录) 
```

### Nestloop Join

嵌套循环（Nestloop Join）是在两个表连接时一种连接方式。在嵌套循环中，`内表被外表驱动`，外表返回的每一行都要在内表中检索找到与它匹配的行，因此整个查询返回的结果集不能太大，要把返回子集较小的表作为外表，且内表的连接字段上要有索引。 执行过程：确定一个驱动表（outer table），另一个表为inner table，驱动表中每一行与inner table中的相应记录关联。 示例如下：

```bash
highgo=# explain select * from people,dept where dept.deptno=people.id;
QUERY PLAN
---------------------------------------------------------------------------
Nested Loop (cost=0.44..5719.30 rows=680 width=100)
  -> Seq Scan on dept (cost=0.00..16.80 rows=680 width=92)
    -> Index Scan using inx_id on people (cost=0.44..8.38 rows=1 width=8)Index Cond: (id = dept.deptno)(4 行记录) 
```

### Hash Join

优化器使用两个比较的表，并利用连接键在内存中建立散列表，然后扫描较大的表并探测散列表，找出与散列表匹配的行。 这种方式适用于较小的表可以完全放于内存中的情况，这样总成本就是访问两个表的成本之和。但如果表很大，不能完全放入内存，优化器会将它分割成若干不同的分区，把不能放入内存的部分写入磁盘的临时段，此时要有较大的临时段以便提高I/O的性能。 示例如下：

```bash
highgo=# explain select * from test,dept where dept.deptno=test.deptno;
QUERY PLAN
--------------------------------------------------------------------
Hash Join (cost=25.30..1870.22 rows=57344 width=127)Hash Cond: (test.deptno = dept.deptno)
  -> Seq Scan on test (cost=0.00..1056.44 rows=57344 width=35)
    -> Hash (cost=16.80..16.80 rows=680 width=92)
      -> Seq Scan on dept (cost=0.00..16.80 rows=680 width=92)(5 行记录) 
```

因为dept表小于test表，所以Hash Join先在较小的表dept上建立散列表，然后扫描较大的表test，并探测散列表，找出与之相匹配的行。 

### Merge Join

通常情况下，散列连接的效果比合并连接好，但如果源数据上有索引，或者结果已经被排过序，在执行排序合并连接时，就不需要排序了，这时合并连接的性能会优于散列连接。 下面示例中，people的id字段和dept01的depto字段都有索引，且从索引扫描的数据已经排好序，可以直接走Merge Join：

```bash
highgo=# explain select people.id from people,dept01 where people.id=dept01.deptno;
QUERY PLAN
-------------------------------------------------------------------------------------------------
Merge Join (cost=0.86..64873.59 rows=1048576 width=4)Merge Cond: (people.id = dept01.deptno)
  -> Index Only Scan using people_pkey on people (cost=0.44..303935.44 rows=10000000 width=4)
    -> Index Only Scan using idx_deptno on dept01 (cost=0.42..51764.54 rows=1048576 width=2)(4 行记录) 
```

删除dept01上的索引，会发现执行计划中先对dept01排序后在走Merge Join，示例如下：

```bash
highgo=# explain select people.id from people,dept01 where people.id=dept01.deptno;
QUERY PLAN
-------------------------------------------------------------------------------------------------
Merge Join (cost=136112.80..154464.29 rows=1048576 width=4)Merge Cond: (people.id = dept01.deptno)
  -> Index Only Scan using people_pkey on people (cost=0.44..303935.44 rows=10000000 width=4)
    -> Materialize (cost=136112.36..141355.24 rows=1048576 width=2)
      -> Sort (cost=136112.36..138733.80 rows=1048576 width=2)Sort Key: dept01.deptno
        -> Seq Scan on dept01 (cost=0.00..16918.76 rows=1048576 width=2)(7 行记录) 
```

上面执行计划中，可看到“Sort Key: dept01.deptno”，这就是对表dept01的id字段进行排序。

手册50.5.1生成可能的计划： 如果查询需要连接两个或更多关系，在所有扫描单个关系的可能计划都被找到后，连接计划将会被考虑。三种可用的连接策略是： 嵌套循环连接NESTED LOOP: 对左关系找到的每一行都要扫描右关系一次。这种策略最容易实现但是可能非常耗时（但是，如果右关系可以通过索引扫描，这将是一个不错的策略。因为可以用左关系当前行的值来作为右关系上索引扫描的键）。 归并连接MERGE JOIN：在连接开始之前，每一个关系都按照连接属性排好序。然后两个关系会被并行扫描，匹配的行被整合成连接行。由于这种连接中每个关系只被扫描一次，因此它很具有吸引力。它所要求的排序可以通过一个显式的排序步骤得到，或使用一个连接键上的索引按适当顺序扫描关系得到。 哈希连接HASH JOIN：右关系先被扫描并且被载入到一个哈希表，使用连接属性作为哈希键。接下来左关系被扫描，扫描中找到的每一行的连接属性值被用作哈希键在哈希表中查找匹配的行。