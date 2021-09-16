# allow_connections

allow_connections实现锁住数据库

highgo=# alter database hgrepmgr with allow_connections false;
ALTER DATABASE
highgo=#
 
 
highgo=# \c hgrepmgr highgo
致命错误:  数据库 "hgrepmgr" 当前不接受联接
Previous connection kept
highgo=#
 
 
 
highgo=# alter database hgrepmgr with ALLOW_CONNECTIONS true;
ALTER DATABASE
highgo=# \c hgrepmgr highgo
You are now connected to database "hgrepmgr" as user "highgo".
hgrepmgr=#