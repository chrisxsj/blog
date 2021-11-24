# pg_hint_plan

**作者**

Chrisx

**日期**

2021-11-23

**内容**

pg_hint_plan使用

----

[toc]

## 安装

下载[pg_hint_plan](https://github.com/ossc-db/pg_hint_plan)

:warning: 下载时选择对应版本的branches

unzip pg_hint_plan-PG12.zip

<!--
/*+ Set temp_file_limit='20MB' */


小结
用户使用递归语句时一定要注意防止死循环，通过设置会话级别的temp_file_limit可以预防，还有一种方法是使用pg_hint_plan，在语句中使用HINT，例如：
/*+ 
  Set (temp_file_limit='10MB')
*/
with recursive t(c1,c2,info) as (select * from test where c1=9 union all select t2.* from test t2 join t on (t.c2 =t2.c1) ) select count(*) from t;

祝大家玩得开心，欢迎随时来 阿里云促膝长谈 业务需求 ，恭候光临。

阿里云的小伙伴们加油，努力做 最贴地气的云数据库 。
-->
