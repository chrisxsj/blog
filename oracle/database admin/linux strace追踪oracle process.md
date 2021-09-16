监控oracle后台进程所做的工作

ps -ef |grep LOCAL=NO
[oracle@single fd]$ ps -ef |grep ckpt
oracle    3305     1  0 14:40 ?        00:00:02 ora_ckpt_train
oracle    6456  3673  0 16:43 pts/1    00:00:00 grep --color=auto ckpt
truncate table test1;
begin
  for i in 1..100
  loop
    insert into test1 values (i,'xsj'||i,sysdate);
  end loop;
  commit;
end;
[oracle@single fd]$ strace -fr -o /tmp/ckpt.log -p 3305
Process 3305 attached
[oracle@single fd]$ cat /tmp/ckpt.log |grep pwrite
3305       0.000226 pwrite(256, "\25\302\0\0\3\0\0\0\0\0\0\0\0\0\1\4`C\0\0\2\0\0\0\0\0\0\0;\0\0\0"..., 16384, 49152) = 16384
3305       0.005512 pwrite(257, "\25\302\0\0\3\0\0\0\0\0\0\0\0\0\1\4`C\0\0\2\0\0\0\0\0\0\0;\0\0\0"..., 16384, 49152) = 16384
3305       0.000197 pwrite(256, "\25\302\0\0\3\0\0\0\0\0\0\0\0\0\1\4_C\0\0\2\0\0\0\0\0\0\0;\0\0\0"..., 16384, 49152) = 16384
3305       0.004755 pwrite(257, "\25\302\0\0\3\0\0\0\0\0\0\0\0\0\1\4_C\0\0\2\0\0\0\0\0\0\0;\0\0\0"..., 16384, 49152) = 16384
[oracle@single fd]$ 
ckpt 进程往256，257进程写入数据 "\25\302\0\0\3\0\0\.....  写了16384个字节，写在49152/16384 =3 第三个数据块上。。
[oracle@single fd]$ cd /proc/3305/fd/
[oracle@single fd]$ ls -atl
total 0
lr-x------ 1 oracle oinstall 64 Jun 24 16:49 0 -> /dev/null
l-wx------ 1 oracle oinstall 64 Jun 24 16:49 1 -> /dev/null
lr-x------ 1 oracle oinstall 64 Jun 24 16:49 10 -> /dev/zero
lr-x------ 1 oracle oinstall 64 Jun 24 16:49 11 -> /dev/zero
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 12 -> /u01/app/oracle/product/11.2.0/dbhome_1/dbs/hc_train.dat
lr-x------ 1 oracle oinstall 64 Jun 24 16:49 13 -> /u01/app/oracle/product/11.2.0/dbhome_1/rdbms/mesg/oraus.msb
lr-x------ 1 oracle oinstall 64 Jun 24 16:49 14 -> /proc/3305/fd
lr-x------ 1 oracle oinstall 64 Jun 24 16:49 15 -> /dev/zero
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 16 -> /u01/app/oracle/product/11.2.0/dbhome_1/dbs/hc_train.dat
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 17 -> /u01/app/oracle/product/11.2.0/dbhome_1/dbs/lkTRAIN
lr-x------ 1 oracle oinstall 64 Jun 24 16:49 18 -> /u01/app/oracle/product/11.2.0/dbhome_1/rdbms/mesg/oraus.msb
l-wx------ 1 oracle oinstall 64 Jun 24 16:49 2 -> /dev/null
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 256 -> /oradata/train/control01.ctl
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 257 -> /u01/app/oracle/fast_recovery_area/train/control02.ctl
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 258 -> /oradata/train/system01.dbf
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 259 -> /oradata/train/sysaux01.dbf
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 260 -> /oradata/train/undotbs01.dbf
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 261 -> /oradata/train/users01.dbf
lrwx------ 1 oracle oinstall 64 Jun 24 16:49 262 -> /oradata/train/example01.dbf
其他进程可用相同的方法去分析研究！！