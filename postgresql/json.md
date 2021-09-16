json,jsonb区别
json和jsonb，而两者唯一的区别在于效率,json是对输入的完整拷贝，使用时再去解析，所以它会保留输入的空格，重复键以及顺序等。而jsonb是解析输入后保存的二进制，它在解析时会删除不必要的空格和重复的键，顺序和输入可能也不相同。使用时不用再次解析。两者对重复键的处理都是保留最后一个键值对。效率的差别：json类型存储快，查询慢，jsonb类型存储稍慢，查询较快(支持许多额外的操作符)。
 
From <https://www.cnblogs.com/zhangfx01/p/9506219.html>
 
 
\c test test
 
1.建表（包含jsonb）
create table test_json(t_txt char(32),t_json json,t_jsonb jsonb);
 
2.插入数据
 
insert into test_json(t_txt,t_json,t_jsonb) values(md5(random()::text),'{"t_xm":"张三","t_xm":{"t_ssdw":"一大队","t_dwbm":"11"}}','{"t_xm":"张三","t_xm":{"t_ssdw":"一大队","t_dwbm":"11"}}');
 
3.查询
普通查询
test=> select * from test_json;
              t_txt               |                          t_json                          |                    t_jsonb                    
----------------------------------+----------------------------------------------------------+------------------------------------------------
 0b1370a3ce3fc4bd47b8b1d787aa1a94 | {"t_xm":"张三","t_xm":{"t_ssdw":"一大队","t_dwbm":"11"}} | {"t_xm": {"t_dwbm": "11", "t_ssdw": "一大队"}}
(1 行记录)
查询json列内的数据
test=> select t_jsonb,t_jsonb->>'t_xm' as t_xm from test_json;
                    t_jsonb                     |                 t_xm                
------------------------------------------------+--------------------------------------
 {"t_xm": {"t_dwbm": "11", "t_ssdw": "一大队"}} | {"t_dwbm": "11", "t_ssdw": "一大队"}
(1 行记录)
 
 
t_json 11显示在最后，与输入顺序相同
t_jsonb 11显示在前面，与输入顺序不同，jsonb通过解析数据后存储。
 
 
=================
## 结语
 
1.在json和jsonb选择上，json更加适合用于存储，jsonb更加适用于检索。
 
2.可以对整个jsonb字段创建gin索引，同时也可以对jsonb中某个元素创建gin索引，或者btree。btree效率最高。
 
3.(j_jsonb ->> 'kxhbsl')返回的是一个text类型，所以可以在该属性上创建对应类型的索引，比如btree，gin索引。
 
4.对于元素值的模糊匹配可以创建单个元素的gin索引，也可以创建整个jsonb字段的gin索引，前者效率较高，后者适用所有元素。
 
From <https://www.cnblogs.com/zhangfx01/p/9506219.html>