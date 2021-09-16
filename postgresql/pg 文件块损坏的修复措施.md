# pg文件块损坏的修复措施

## 问题描述

pg没有文件块级别的数据库恢复操作。
http://bbs.pgsqldb.com/client/post_show.php?zt_auto_bh=54607

由于磁盘坏道或者是内存问题等硬件上的原因，有时候会导致数据库的数据文件的一些数据块的损坏，使得某些表不能正常访问，本文谈一下PostgreSQL数据块损坏时候，表数据的恢复方法。

PostgreSQL采用一个表存放在一个或者多个物理文件，所以数据块的损坏一般只会影响到一个表，使得该表的数据不能查询或者是备份，下面是一个常见的异常的例子：

select * from test;
ERROR: invalid page header in block 1 of relation base/34780/34781

这个错误是说数据所在的目录下面base子目录，oid为34780的数据库，表的文件id为34781的表（即上述例子的test）的第一页(注意是从0页开始)数据块的头出现了错误，所以数据库不能访问。

数据块的损坏的情形比较复杂，所以如何恢复，或者是能恢复到什么情形不能一概而论。最好的情况是丢失一个数据块里面的所有记录(也有可能只丢失某些记录， 但是方法比较复杂)，最坏也有可能整个表丢失。PostgreSQL没有提供像Oracle那样的文件恢复或者是块修复的功能，但也有一些方法可以修复 表，这里简单讨论一下一个数据块损坏的情况下，如何恢复。

最简单的方法是，用备份恢复！如果你有做备份和日志归档，则出现问题以后，恢复到最新即可。如果没有备份，则请参考下面的方法。

重要：在做下面的操作前，先把数据库的数据文件的目录先备份！！！！！

## 解决方法

方法1 利用参数zero_damaged_pages

PostgreSQL提供了一个隐藏参数zero_damaged_pages， 当这个参数为true的时候，会忽略所有数据有损坏的页面。设置的方法为：打开postgresql.conf文件，在文件的添加一个参数 zero_damaged_pages = true, 重起PostgreSQL。

设置完后，当访问表的时候，会提示说已经忽略损坏的页面：

select count(*) from test ;
WARNING: invalid page header in block 1 of relation base/34780/34781; zeroing out page

count
-------
760
(1 row)

该表原有1000条记录，由于一个页面损坏，丢失了240条记录。表可以访问以后，可以把表dump下来，或者是select到另外一张临时表，然后把原来的表删除掉重建。当然如果有其他外部约束的话，相关的表和索引也要处理，这里不详细讨论。

这种方法不会对物理文件作修改，只是把内存上，损坏页面的缓存变为0。

方法2 手动清除损坏的页面

在某些情形下，zero_damaged_pages可能不一定有些，这时可以尝试手动把坏的页面清除。

根据错误提示 ERROR: invalid page header in block 1 of relation base/34780/34781 我们可以找到相应的文件, 文件的路径为： 数据目录/base/34780/34781，只要用工具手动把上面提示的坏块清除即可。在Linux下面可以用dd工具把相应的页面清除：

$dd if=/dev/zero f=/home/postgres/data/base/34780/42995 bs=8192 seek=1 count=1 conv=notrunc

清除完后，查询表即可正常访问。

select count(*) from test ;

count
-------
760
(1 row)
