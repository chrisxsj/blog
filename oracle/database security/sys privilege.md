以SYS用户进入Oracle，

 SQL> grant sysdba to username;

 grant sysdba to username

 *
 ERROR at line 1:
 ORA-01994: GRANT failed: password file missing or disabled

 首先，把初始化参数REMOTE_LOGIN_PASSWORDFILE的值改成EXCLUSIVE

 如果还是有问题，可能是缺少密码文件，用orapwd创建密码文件

 $ orapwd -h
 Usage: orapwd file=<fname> password=<password> entries=<users>

 where
 file - name of password file (mand),
 password - password for SYS (mand),
 entries - maximum number of distinct DBA and OPERs (opt),
 There are no spaces around the equal-to (=) character.

 这个命令很简单，密码文件一般放在$ORACLE_HOME/dbs目录下，命名规则为orapd+SID,

 orapwd FILE='/db/oracle/product/10.2.0/db_1/dbs/orapw+SID'  PASSWORD=oracle   ENTRIES=5  FORCE=y

 然后再执行

 SQL> grant sysdba to username;

 Grant succeeded.

 检查

 SQL> select * from v$pwfile_users;

 USERNAME                       SYSDB SYSOP
 ------------------------------ ----- -----
 SYS                            TRUE  TRUE
 ******                          TRUE  FALSE

 SYSDB那一栏是TRUE就对了

 然后就可以as sysdba连接了 
