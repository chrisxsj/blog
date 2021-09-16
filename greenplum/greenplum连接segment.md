

直连greenplum segment节点的方法, utility模式 :
使用这种方式，不与其他节点通讯，只操作当前节点。也没有数据分布的概念。
如果使用utility模式连接的是master节点，写入数据时，数据不会分布到segment，使用正常模式连接后，写入master的数据也查不出来。
$ PGOPTIONS='-c gp_session_role=utility' psql -p 25432 -d postgres
 
[gpadmin@ps1 ~]$ PGOPTIONS='-c gp_session_role=utility' psql -p 25432 -d postgres
psql (8.3.23)
Type "help" for help.
 
postgres=# \l
                  List of databases
   Name    |  Owner  | Encoding |  Access privileges 
-----------+---------+----------+---------------------
 postgres  | gpadmin | UTF8     |
 template0 | gpadmin | UTF8     | =c/gpadmin         
                                : gpadmin=CTc/gpadmin
 template1 | gpadmin | UTF8     | =c/gpadmin         
                                : gpadmin=CTc/gpadmin
 tyyw_test | gpadmin | UTF8     |
(4 rows)
 
postgres=# show port;
 port 
-------
 25432
(1 row)
 
postgres=#
 
> 注意，使用PGOPTIONS='-c gp_session_role=utility'后，只操作连接的本地节点
> 注意，port是segment的端口，可以在hgstat -c中查看
