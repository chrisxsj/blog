# pg bouncer

参考[install](http://www.pgbouncer.org/install.html)

## 安装pgbouncer

pgbouncer[下载地址](http://www.pgbouncer.org/downloads)
libevent[下载地址](http://libevent.org)

安装

Building
PgBouncer depends on few things to get compiled:

GNU Make 3.81+
Libevent 2.0+
pkg-config
OpenSSL 1.0.1+ for TLS support
(optional) c-ares as alternative to Libevent’s evdns
(optional) PAM libraries

注意，依赖包的检查，pkg-config可忽略。官方文档中以上包都有链接。
rpm -q make libevent pkg-config openssl
yum install make libevent pkg-config openSSL


When dependencies are installed just run:

$ ./configure --prefix=/usr/local
$ make
$ make install
If you are building from Git, or are building for Windows, please see separate build instructions below.

## 配置pgbouncer

配置 这两个文件：pgbouncer.ini 和users.txt文件

pgbouncer.ini默认的配置和含义如下：

[databases]

[pgbouncer]
logfile = /var/log/pgbouncer/pgbouncer.log          # 日志文件位置
pidfile = /var/run/pgbouncer/pgbouncer.pid          # pid文件位置
listen_addr = 127.0.0.1                             # 监听的地址
listen_port = 6432                                  # 监听的端口
auth_type = trust                                   # 认证方式
auth_file = /etc/pgbouncer/userlist.txt             	#  认证文件
admin_users = postgres                              # 管理员用户名
stats_users = stats, postgres                      	 #  状态用户？stats和postgres
pool_mode = session                                 # 池的模式，默认session级别
server_reset_query = DISCARD ALL                    # 
max_client_conn = 100            	# 最大连接用户数，客户端到pgbouncer的链接数量
default_pool_size = 20                         # 默认池大小，表示建立多少
pool_size = 20				#配置连接池的大小，如果没有配置此项，连接池的大小将使用default_pool_size配置项的值。

默认情况下不配置任何数据库信息，从上面还可以看到，配置主要分为两部分：
第一部分是[databases]区域，是用来配置数据库连接相关信息的。
第二部分是[pgbouncer]，是pgbouncer自身的配置。

第一部分 [databases]配置示例：
forcedb=host=127.0.0.1 port=3000 user=baz password=foo client_encoding=UNIODE datestyle=ISO connect_query='SELECT 1'

基本格式：
对外提供的数据库名 = host=主机IP port=端口 user=用户 password=密码
其他的规则都类似，数据库名后面的等号旁边要有空格隔开，后面每个成对的数值之间用空格隔开。

这里面的主机和端口指的是PostgreSQL监听的地址和端口，而用户和密码就是用来连接PostgreSQL数据库的用户名和密码。

client_encoding

我们根据这个格式来建一个我们自己的配置：

testdb=host=192.168.1.244 port=5433 user=appuser dbname=appdb

[pgbouncer]区域使用默认配置，补充说明以下两个配置：
auth_type = trust                                   # 认证方式
auth_file = /etc/pgbouncer/userlist.txt                 # 认证文件

第一行是用于配置登录pgbouncer的认证方式，和PostgreSQL认证方式相同，默认是trust，即所有的都信任，还可以使用md5加密的形式。

第二行是用于配置认证用户的，即连接pgbouncer的用户名都保存在该文件中。

当第一行设置为md5加密时，则加密的密码也必须保存在第二行配置的文件中。
如果这个文件不存在，那么登录的时候，无论是哪个用户，都会提示下面的错误：

-bash-4.2$ psql -p 6432 testdb -h 127.0.0.1
psql: ERROR:  No such user: postgres-bash-4.2$ psql -p 6432 testdb -h 127.0.0.1 -U dbuser 
psql: ERROR:  No such user: dbuser

而这个认证文件默认情况下是没有的，因此需要手动生成。
在PostgreSQL的9.x版本中，所有的用户密码都是保存在pg_shadow表里。
PostgreSQL 8.x版本则是保存在数据库目录下，可以直接复制过来使用。

我们使用的9.5版本，因此需要手动生成这个文件。
生成这个认证文件有两种方式，如下：

1）SQL语句生成认证文件
之前我们说过，用户密码默认是保存在pg_shadow表里的，如下面所示：
postgres=# select usename, passwd from pg_shadow order by 1; 
 usename  |               passwd
----------+-------------------------------------
 dbuser   | md5baa6c789c3728a1a449b82005eb54a19
 postgres | 

usename和passwd两列里面保存的就是我们需要的账号和密码
我们使用copy命令将它们导出来：

postgres=# copy (select usename, passwd from pg_shadow order by 1) to '/var/lib/pgsql/9.5/auth_file';
COPY 2

我们打开这个auth_file文件，内容如下：
dbuser  md5baa6c789c3728a1a449b82005eb54a19
postgres        \N

里面保存有postgres的账号，一般不要使用这个超级管理员的身份，最好删掉。
然后保留可以连接数据库的用户账号和加密后的密码，将这个文件转移到上面配置项指定的位置。并且文件名称要和上面变量里定义的文件名一致，否则会提示找不到这个文件。
最后还要注意的一点是，默认导出的文件里用户名和密码的格式pgbouncer无法识别，需要用双引号引起来才能正确识别

如下所示：
"dbuser"  "md5baa6c789c3728a1a449b82005eb54a19"

2）使用mkauth.py来生成文件
这个文件是使用python编写的一个脚本，已经赋予了可执行权限。
执行的时候需要两个参数，基本格式是：

/etc/pgbouncer/mkauth.py   用户列表文件   "数据库连接参数"

示例：
/etc/pgbouncer/mkauth.py  /etc/pgbouncer/userlist.txt   "host=127.0.0.1  user=postgres password=123456"

这里比较重要的是后面那一段参数，=号两边不能有空格，两个键值对之间要用空格隔开，不能用逗号，否则会报错。用户必须是有查询pg_shadow表权限的用户请记住这里的限制条件。

如果没有错误的话，就会在/etc/pgbouncer/目录下生成userlist.txt文件。
文件内容如下所示：
"dbuser" "md5baa6c789c3728a1a449b82005eb54a19" ""
"postgres" "" ""

默认会备份出PostgreSQL数据库的pg_shadow表里的所有数据库，包括postgres用户。所有的用户名和密码都会用双引号引起来，比手动备份更方便。这里唯一麻烦的就是脚本后面的连接字符串。

配置实践
[databases]
testdb1= host= 192.168.12.32 port=5432 user=apuser dbname=testdb1
testdb2=host=192.168.12.33 port=5432 user=apuser dbname=testdb2

[pgbouncer]
logfile = /var/log/pgbouncer/pgbouncer.log          
pidfile = /var/run/pgbouncer/pgbouncer.pid         
listen_port=64321
listen_addr=127.0.0.1
auth_type=trust
admin_users = postgres
max_client_conn = 100          
default_pool_size = 20          

在装有psql的机器上使用命令：
psql -h 127.0.0.1 -p 64321 -U <用户名> <数据库名>(如数据库：testdb1、testdb2)

用户名为users.txt文件里的用户，如：
psql -h 127.0.0.1 -p 64321 -U apuserpostgres1 

即通过pgbouncer登录到主机为192.168.12.32的数据库为template1的机器上
Pgbouncer的配置文件有映射关系，如上例所示

## 管理pgbouncer

### 启动

当用户文件配置好以后，就可以启动pgbouncer来使用了。
使用linux发行版自带的包管理工具安装pgbouncer的时候，它会自动创建一个pgbouncer用户
如果是自己编译的话，则需要手动创建这个用户。创建完成以后。
需要切换到这个用户下来启动pgbouncer，pgbouncer是不允许在root用户下启动的。

切换完成后，它的启动命令格式是：
[pgbouncer@vlnx107001 ~]$ pgbouncer -d /etc/pgbouncer/pgbouncer.ini -v
[pgbouncer@vlnx107001 ~]$ ps -ef |grep pgbou

-d 表示是以后后台进程的方式运行，后面跟的是配置文件的路径。
启动完成，pgbouncer默认监听6432端口。

然后就可以使用psql来登录了。

### 停止

目前pgbouncer还没有自主停止的脚本或者命令，只能通过kill命令来停止。

格式是：
kill `cat /var/run/pgbouncer/pgbouncer.pid`
或
cat /var/run/pgbouncer/pgbouncer.pid | xargs kill -9


登录 pgbouncer虚拟库(管理员终端维护操作）
psql -p 6432 -d pgbouncer -U postgres -h 127.0.0.1

如果修改了一些配置参数，可以不用重启 pgbouncer 而是 reload 使其生效

> 注意：
只有在配置了参数 admin_users 或者 stats_users才会连接到控制台。

连接到控制台可以使用命令停止

停止： cd /usr/local/pgsql/bin
./psql -p 6432 -U pgbadmin -h 192.168.100.122 pgbouncer
shutdown;
加载配置： cd /usr/local/pgsql/bin
./psql -p 6432 -U pgbadmin -h 192.168.100.122 pgbouncer
reload;

### 日志信息

/var/log/pgbouncer/pgbouncer.log

in b/s：这个比较好读懂，每秒读入字节数。
out b/s：和in b/s一样，表示每秒读出的字节数。
query us：平均每个查询话费的时间，单位微秒。us应该是used的缩写。
wait time : 等待耗时 微秒
xacts/s： 每秒多少个事务操作
queries/s：每秒多少次请求数
xact  us：每个事务耗时多少微秒

### 查看连接信息

pgbouncer对外提供了一个虚拟数据库pgbouncer，之所以成为虚拟数据库，是因为它可以提供像PostgreSQL那样的数据库操作界面，但是这个数据库却并不是真实存在的。
而是pgbouncer虚拟出来的一个命令行界面。

登录命令是：
psql -p 6432  pgbouncer

登录以后可以使用：
show help; 		#查看所有的帮助命令信息

常用的两个命令是：
show clients ;	  #用来查看客户端连接信息
show pools;	  #用来查看连接池信息

查看pgbouncer管理内容
pgbouncer有一个虚拟的db存在，名称就是“pgbouncer”，执行如下命令进入到管理的终端：
cd /usr/local/pgsql/bin
./psql -U pgbadmin -p 6432 -h 192.168.100.122 pgbouncer
show config; 查看配置
show lists; 显示连接池的计数信息 
show databases; 查看库
show pools;查看连接池信息
show clients; 用来查看客户端连接信息

## 通过pgbouncer连接数据库

```bash

/usr/pgbouncer/bin/pgbouncer -R -d /usr/pgbouncer/etc/pgbouncer.ini

[hgadmin@hgdw1 etc]$ psql -h 172.17.105.139 -p 6432 -U hgadmin -d pgbouncer
psql (9.4.24, server 1.11.0/bouncer)
Type "help" for help.

pgbouncer=# \q
[hgadmin@hgdw1 etc]$ psql -h 172.17.105.139 -p 6432 -U pgbouncer -d pgbouncer
psql (9.4.24, server 1.11.0/bouncer)
Type "help" for help.
```

cd /usr/local/pgsql/bin
./psql -h 192.168.100.122 -p 6432 -U pgbadmin -d benchmarksql
benchmarksql通过pgbouncer链接数据库
conn=jdbc:postgresql://192.168.100.122:6432/benchmarksql

```bash
[hgadmin@hgdw1 etc]$ psql -h 172.17.105.139 -p 6432 -U hgadmin -d pgb
psql (9.4.24)
Type "help" for help.

pgb=> SELECT current_database();
 current_database 
------------------
 bms
(1 row)


```



## error: Package requirements (libevent) were not met

```bash
checking for library containing gethostbyname... none required
checking for library containing hstrerror... none required
checking for lstat... yes
checking for LIBEVENT... no
configure: error: Package requirements (libevent) were not met:

No package 'libevent' found

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

Alternatively, you may set the environment variables LIBEVENT_CFLAGS
and LIBEVENT_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
[root@hgdw1 pgbouncer-1.12.0]# ls -atl /usr/libevent/libevent
total 20
drwxr-xr-x 3 root root 4096 Apr 13 12:00 lib
drwxr-xr-x 3 root root 4096 Apr 13 12:00 include
drwxr-xr-x 5 root root 4096 Apr 13 12:00 .
drwxr-xr-x 2 root root 4096 Apr 13 12:00 bin
drwxr-xr-x 3 root root 4096 Apr 13 12:00 ..
[root@hgdw1 pgbouncer-1.12.0]# echo $PKG_CONFIG_PATH


先安装libevent，

知道libevent的安装目录：

ls -atl
total 7844
drwxr-xr-x 2 root root    4096 Apr 13 12:00 pkgconfig
drwxr-xr-x 3 root root    4096 Apr 13 12:00 .
drwxr-xr-x 5 root root    4096 Apr 13 12:00 ..
-rw-r--r-- 1 root root  214346 Apr 13 12:00 libevent_openssl.a
......

pwd
/usr/libevent/libevent/lib


根据报错信息:Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

在环境变量中增加以下内容（后期使用普通用户，则在普通用户下添加)：

export PKG_CONFIG_PATH=/usr/libevent/libevent/lib/pkgconfig
export LIBEVENT_LIBS=/usr/libevent/libevent/lib


source ~/.bash_profile 

重新编译pgbouncer就即可，需指命libevent的目录

./configure --prefix=/usr/pgbouncer/ --with-libevent=/usr/libevent/libevent

make && make install
```

## error while loading shared libraries: libevent-2.1.so.7

```bash

/usr/pgbouncer/bin/pgbouncer -v /usr/pgbouncer/etc/pgbouncer.ini

[root@hgdw1 ~]# /usr/pgbouncer/bin/pgbouncer -v /usr/pgbouncer/etc/pgbouncer.ini
/usr/pgbouncer/bin/pgbouncer: error while loading shared libraries: libevent-2.1.so.7: cannot open shared object file: No such file or directory
[root@hgdw1 ~]# rpm qa |grep libevent
RPM version 4.11.3



export LD_LIBRARY_PATH=/usr/libevent/libevent/lib:$LD_LIBRARY_PATH



/usr/pgbouncer/bin/pgbouncer -d /usr/pgbouncer/etc/pgbouncer.ini


/usr/pgbouncer/bin/pgbouncer -R -d /usr/pgbouncer/etc/pgbouncer.ini

```


