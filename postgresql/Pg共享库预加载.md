# Pg共享库预加载
Shared Library Preloading
PostgreSQL支持通过动态库的方式扩展PG的功能，pg在使用这些功能时需要预加载相关的共享库。
有几种设置可用于将共享库预加载到服务器中，如下
+ local_preload_libraries (string)
+ session_preload_libraries (string)
+ shared_preload_libraries (string)
## 1、local_preload_libraries (string)
+ `用户建立连接时加载`，通常使用客户端上的 PGOPOPS 环境变量或使用 ALTER 角色 SET 设置此参数。
+ 任何用户都可以设置此选项，因此限定只能加载$libdir/plugins下面的so文件。可以显示的指定目录，如$libdir/plugins/passwordcheck；或者只指定库的名字，如passwordcheck。其会自动到$libdir/plugins/中搜索
```
postgres=> alter role test set local_preload_libraries=passwordcheck;
ALTER ROLE
postgres=> alter role test set local_preload_libraries='$libdir/plugins/passwordcheck';
ALTER ROLE
postgres=# alter role test reset local_preload_libraries;
ALTER ROLE
 
```
## 2、session_preload_libraries (string)
+ `用户建立连接时加载`这个参数只允许超级用户修改
+ 能动态加载所有目录下面的so文件，如果未指定相对目录，自动到dynamic_library_path指定的目录中搜索so。
## 3、shared_preload_libraries (string)
+ `数据库启动时加载`，配置shared_preload_libraries参数，必须重启数据库。
```
postgres=# alter system set shared_preload_libraries=pg_pathman, pg_stat_statements, passwordcheck;
ALTER SYSTEM
```
注意：
+ 在连接开始时加载一个或多个共享库，用逗号分隔列表。条目之间的空白会被忽略，如果要在名称中包含空格或逗号，库名需要加双引号。此参数只在服务器启动时生效。如果找不到指定的库，服务器无法启动。
+ 多个参数不要放在单引号中，如
```
alter system set shared_preload_libraries='pg_pathman,pg_stat_statements';
```
+ $libdir路径通过以下命令查看
```
[pg@pg ~]$ pg_config |grep LIBDIR
LIBDIR = /opt/postgres/lib
PKGLIBDIR = /opt/postgres/lib
[pg@pg ~]$
```
