首先连接原windows的oracle数据库，通过如下sql语句查询出表注释及字段注释：
表的注释：
SELECT 'comment on table ' || t.table_name || ' is ''' 
      || t.comments ||''';'
FROM user_tab_comments t;
输出结果如下：
comment on table A1 is ‘客户表’；
comment on table A1 is ‘信息表’；
comment on table A1 is ‘通讯表’；
          。
          。
          。
comment on table An is ‘工资表’         
字段注释：
SELECT 'comment on column ' || t.table_name || '.' || t.column_name || ' is ''' 
      || t.comments ||''';'
FROM user_col_comments t;
输出结果如下：
comment on column A1.ID is '员工编号';
comment on column A1.name is '员工姓名';
                 。
                 。
                 。
                 。
comment on column A2.sex is '员工性别';   
 
 
将输出结果通过spool 命令输出到.sql文件中
    
然后在PL/sql  developer中执行该脚本即可将原来为???????的注释全部更新。 （相当于将原来是？？？？的部分执行sql做了update）。


