ctid： 表示数据记录的物理行当信息，指的是 一条记录位于哪个数据块的哪个位移上面。 跟oracle中伪列 rowid 的意义一样的；只是形式不一样。
   例如这有个一表test；查看每行记录的ctid情况

mydb=> select ctid,* from test;
 ctid  |  id  |  name  
-------+------+--------
 (0,1) | 1001 | lottu
 (0,2) | 1002 | rax
 (0,3) | 1003 | xuan
 (0,4) | 1004 | li0924
 (0,5) | 1001 | ak

    格式(blockid,itemid)：拿其中(0,1)来说；0表示块id；1表示在这块第一条记录。
 
  1. 去重：  我们知道rowid在oracle有个重要的作用；被用作表记录去重；同理 ctid在postgresql里面同样可以使用。例如test表id为1001有两条记录；现在演示下；

mydb=> delete from test where ctid not in (select min(ctid) from test group by id);
DELETE 1
mydb=> select ctid,* from test;
 ctid  |  id  |  name  
-------+------+--------
 (0,1) | 1001 | lottu
 (0,2) | 1002 | rax
 (0,3) | 1003 | xuan
 (0,4) | 1004 | li0924
(4 rows)

刚刚我们删除了(0,5)这条记录； 现在我们把这条记录插入下；看下；

mydb=> insert into test values (1001,'ak');
INSERT 0 1
mydb=> select ctid,* from test;
 ctid  |  id  |  name  
-------+------+--------
 (0,1) | 1001 | lottu
 (0,2) | 1002 | rax
 (0,3) | 1003 | xuan
 (0,4) | 1004 | li0924
 (0,6) | 1001 | ak
(5 rows)

奇怪了；为什么不是(0,5),而是(0,6)这个跟postgresql多版本事务有关；跟伪列cmin，cmax有关；跟本文讲的ctid没点关系；这是postgresql的特性；也就是这样；postgresql里面没有回滚段的概念；那怎么把(0,5)在显示呢；想这块(0,5)的空间再存放数据；postgresql里面有AUTOVACUUM进程；当然我们也可以手动回收这段空间；

mydb=> delete from test where name = 'ak';
DELETE 1
mydb=> vacuum test;          
VACUUM
mydb=> insert into test values (1001,'ak');
INSERT 0 1
mydb=> select ctid,* from test;
 ctid  |  id  |  name  
-------+------+--------
 (0,1) | 1001 | lottu
 (0,2) | 1002 | rax
 (0,3) | 1003 | xuan
 (0,4) | 1004 | li0924
 (0,5) | 1001 | ak
(5 rows)

2. 我们刚刚说道 0表示块id； test数据太少了；不好解释；新建一个表test2

mydb=> drop table test2;
DROP TABLE
mydb=> create table test2 (id int primary key, name varchar(10));
CREATE TABLE
mydb=> insert into test2 select generate_series(1,1000),'lottu' || generate_series(1,1000);
INSERT 0 1000

 我们看下id=1000的ctid的blockid是多少；答案是5；意思是说该表的记录记录到第6个块；（因为是从0开始的）

mydb=> select ctid,* from test2 where id = 1000;
  ctid  |  id  |   name    
--------+------+-----------
 (5,75) | 1000 | lottu1000
(1 row)

当然这样查表记录占了几个block；假如我这是随机插入的；那id=1000；就不一定是在第6块；
我们可以借助系统视图pg_class；其中relpages,reltuples分别代表块数，记录数！

mydb=> analyze test2;
ANALYZE
mydb=> select relpages,reltuples from pg_class where relname = 'test2';
 relpages | reltuples 
----------+-----------
        6 |      1000
(1 row)

总结： ctid存在的意义：表示数据记录的物理行当信息，指的是 一条记录位于哪个数据块的哪个位移上面。 跟oracle中伪列 rowid 的意义一样的；只是形式不一样。
vacuum: 回收未显示的物理位置；标明可以继续使用。
generate_series: 为一个序列函数；例如1-100；就是generate_series(1,100);0-100直接的偶数generate_series(0,100,2)
                          其中的0表示序列开始位置；100代表结束位置；2为偏移量。