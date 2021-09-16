$PGDATA目录迁移--Windows
 
1 先查询当前的data目录
highgo=# show data_directory;
       data_directory
-------------------------------
 E:/highgo/database/5.6.5/data
2关闭数据库，关闭数据库服务：  开始->管理工具->服务, 找到 hgdb-se5.6.5 选中后点击停止

3、修改data目录下配置文件postgresql.conf：

data_directory = 'ConfigDir' ==> data_directory = 'F:/newdestination/data‘
注意：参数里面改成新的data目录,而且一定注意，windows下也必须是斜杠，反斜杠不会识别，后期启动时会报错找不到data目录并会要求手动initdb。
错误信息存在于系统日志 ( 开始->管理工具->服务器管理器->诊断->事件查看器->windows日志->应用程序) 中会提示找不到data目录
4.拷贝data目录至目标路径(F:\newdestination)下，同时将原data目录重命名（不建议删除）

5.在命令行启动数据库pg_ctl start,进行查询验证：

highgo=# show data_directory;
 data_directory
----------------
 F:/newdestination/data
(1 行记录)
验证无误之后，在命令行关闭数据库pg_ctl stop
6.修改注册表信息。若是不修改注册表，直接通过服务启动数据库,发现会报错,提示找不到data目录，

   删除原有服务，增加新服务。
(由于windows下封装的包,在安装时写入的data目录会注册到服务相对应的注册表中,所以修改了data目录就要修改相关的所有注册表,所以删除服务重新生成服务可以生成新的注册表,才能通过服务来启动数据库)
C:\Users\Administrator>   pg_ctl unregister -N hgdb-se5.6.5
C:\Users\Administrator>   pg_ctl register -N hgdb-se5.6.5 -U "NT AUTHORITY\NetworkService" -D " F:\newdestination\data" -s
C:\Users\Administrator>
刷新服务列表,启动数据库：    开始->管理工具->服务, 找到 hgdb-se5.6.5 选中后点击启动