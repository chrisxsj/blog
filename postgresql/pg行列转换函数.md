# pg行列转换函数
Pg提供相关行列转换函数string_agg和regexp_split_to_table。
## 1、行转列：string_agg
```
测试表
postgres=# select * from test.test_copy ;
eno | ename | job | mgr | hiredate | sal | comm | deptno
------+--------+----------+------+---------------------+------+------+--------
7499 | ALLEN | SALESMAN | 7698 | 1991-02-20 00:00:00 | 1600 | 300 | 30
7566 | JONES | MANAGER | 7839 | 1991-04-02 00:00:00 | 2975 | | 20
7654 | MARTIN | SALESMAN | 7698 | 1991-09-28 00:00:00 | 1250 | 1400 | 30
7498 | JASON | ENGINEER | 7724 | 1990-02-20 00:00:00 | 1600 | 300 | 10
(4 rows)
将部门为30的员工的姓名合并起来
postgres=# Select deptno,string_agg(ename,',') from test.test_copy group by deptno;
deptno | string_agg
--------+--------------
30 | ALLEN,MARTIN
10 | JASON
20 | JONES
(3 rows)
```
## 2、列转行：regexp_split_to_table
```
postgres=# select * from test.test_str;
no | name
----+------------
1 | a,b,c,d
2 | Jason Xian
(2 rows)
将列信息转换成行
postgres=# select regexp_split_to_table(name,',') from test.test_str where no=1;
regexp_split_to_table
-----------------------
a
b
c
d
(4 rows)
postgres=# select regexp_split_to_table(name,' ') from test.test_str where no=2;
regexp_split_to_table
-----------------------
Jason
Xian
(2 rows)
postgres=# select regexp_split_to_table('hello world', '\s+');
regexp_split_to_table
-----------------------
hello
world
(2 rows)
```