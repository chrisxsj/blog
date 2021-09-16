pg_hba.conf

A default pg_hba.conf file is installed when the data directory is initialized by initdb. It is possible to place the authentication configuration file elsewhere, however; see the hba_file configuration parameter.
 
From <https://www.postgresql.org/docs/11/auth-pg-hba-conf.html>
 
每个记录指定连接类型、客户端 IP 地址范围（如果与连接类型相关）、数据库名称、用户名以及用于匹配这些参数的连接的身份验证方法。具有匹配连接类型、客户端地址、请求数据库和用户名的第一条记录用于执行身份验证。没有"直通"或"备份"：如果选择了一条记录，并且身份验证失败，则不会考虑后续记录。如果没有记录匹配，则拒绝访问。
 
A record can have one of the seven formats

local      database  user  auth-method  [auth-options]
host       database  user  address  auth-method  [auth-options]
hostssl    database  user  address  auth-method  [auth-options]
hostnossl  database  user  address  auth-method  [auth-options]
host       database  user  IP-address  IP-mask  auth-method  [auth-options]
hostssl    database  user  IP-address  IP-mask  auth-method  [auth-options]
hostnossl  database  user  IP-address  IP-mask  auth-method  [auth-options]
 
来自 <https://www.postgresql.org/docs/10/auth-pg-hba-conf.html>
 
 
 
Since the pg_hba.conf records are examined sequentially for each connection attempt, the order of the records is significant. Typically, earlier records will have tight connection match parameters and weaker authentication methods, while later records will have looser match parameters and stronger authentication methods. For example, one might wish to use trust authentication for local TCP/IP connections but require a password for remote TCP/IP connections. In this case a record specifying trust authentication for connections from 127.0.0.1 would appear before a record specifying password authentication for a wider range of allowed client IP addresses.
 
From <https://www.postgresql.org/docs/11/auth-pg-hba-conf.html>
 
 
 
The pg_hba.conf file is read on start-up and when the main server process receives a SIGHUP signal. If you edit the file on an active system, you will need to signal the postmaster (using pg_ctl reload or kill -HUP) to make it re-read the file.
 
来自 <https://www.postgresql.org/docs/10/auth-pg-hba-conf.html>
 
The system view pg_hba_file_rules can be helpful for pre-testing changes to the pg_hba.conf file, or for diagnosing problems if loading of the file did not have the desired effects. Rows in the view with non-null error fields indicate problems in the corresponding lines of the file.
 
From <https://www.postgresql.org/docs/11/auth-pg-hba-conf.html>
 
 
Tip
To connect to a particular database, a user must not only pass the pg_hba.conf checks, but must have the CONNECT privilege for the database. If you wish to restrict which users can connect to which databases, it's usually easier to control this by granting/revoking CONNECT privilege than to put the rules in pg_hba.conf entries.
 
From <https://www.postgresql.org/docs/11/auth-pg-hba-conf.htm、、、、、

## 只允许用户连接指定的数据库

# configure

host    highgo          test            0.0.0.0/0               reject  《《《把连接其他数据库reject掉
host    all             all             0.0.0.0/0               md5
host    replication     all             0.0.0.0/0               md5
