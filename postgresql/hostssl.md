PostgreSQL has native support for using SSL connections to encrypt client/server communications for increased security. This requires that OpenSSL is installed on both client and server systems and that support in PostgreSQL is enabled at build time (see Chapter 16).
 
来自 <https://www.postgresql.org/docs/10/ssl-tcp.html>
 
 
[highgo@sec log]$ rpm -qa |grep openssl
openssl-1.0.2k-8.el7.ns7.01.x86_64
openssl-libs-1.0.2k-8.el7.ns7.01.x86_64
openssl-devel-1.0.2k-8.el7.ns7.01.x86_64
xmlsec1-openssl-1.2.20-5.el7.x86_64
 
 
[highgo@sec data]$ cat pg_hba.conf |grep -v ^#
 
 
 
 
local   all             all                                     md5
host    all             all             127.0.0.1/32           md5
hostssl    all             all             127.0.0.1/32            md5
hostssl        all                all                0.0.0.0/0                md5
 
 
 
[highgo@sec data]$ psql -h 192.168.6.18 -U sysdba -d highgo
用户 sysdba 的口令：
psql (4.3.4)
SSL 连接（协议：TLSv1.2，密码：ECDHE-RSA-AES256-GCM-SHA384，密钥位：256，压缩：关闭)
输入 "help" 来获取帮助信息.
 
highgo=#