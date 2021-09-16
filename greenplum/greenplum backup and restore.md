<2>database级别备份恢复
$ gp_dump testDB  --gp-d=/gpbackup/ --gp-r=/gpbackup/ 
# 模拟删除testDB
$ dropdb testDB
# 恢复前必须手动创建数据库，默认都是小写，如果要大些必须加双引号
test=# create database "testDB" with owner=gpadmin;
# 恢复数据
$ gp_restore  --gp-d=/gpbackup/ --gp-r=/gpbackup/ --gp-k=20160304153252
 
来自 <http://blog.chinaunix.net/uid-23284114-id-5675735.html>