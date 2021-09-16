#https://github.com/digoal/blog/blob/master/201306/20130628_01.md
#
#PostgreSQL table exactly bloat monitor use freespace map data
#
#
#背景
#对PostgreSQL数据库有一定了解的朋友都知道PostgreSQL的UPDATE, DELETE操作是通过新增tuple版本提供高并发处理的. 这样带来一个问题是需要经常vacuum 表, 回收老版本占用的存储空间. 只有回收的空间才能被重复利用, 如果回收不及时将会造成表的膨胀效应.
#那么怎么知道数据表有没有膨胀呢?