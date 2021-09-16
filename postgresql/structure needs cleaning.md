structure needs cleaning



[postgres@pgha1 ~]$ pg_ctl start
waiting for server to start....2018-10-10 15:28:27.085 CST [20516] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2018-10-10 15:28:27.085 CST [20516] LOG:  listening on IPv6 address "::", port 5432
2018-10-10 15:28:27.119 CST [20516] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2018-10-10 15:28:27.241 CST [20516] FATAL:  could not open log file "pg_log/postgresql-2018-10-10_152827.log": Structure needs cleaning
2018-10-10 15:28:27.361 CST [20516] LOG:  database system is shut down
stopped waiting
pg_ctl: could not start server
Examine the log output.
[postgres@pgha1 ~]$
[root@pgha1 data]# cd pg_log
[root@pgha1 pg_log]# ls -l
ls: cannot access postgresql-2018-09-28_213435.log: Structure needs cleaning
ls: cannot access postgresql-2018-09-28_213435.csv: Structure needs cleaning
ls: cannot access postgresql-2018-09-29_000000.log: Structure needs cleaning
 
-????????? ? ? ? ?            ? postgresql-2018-10-15_000000.csv
-????????? ? ? ? ?            ? postgresql-2018-10-15_000000.log
-????????? ? ? ? ?            ? postgresql-2018-10-15_204938.csv
-????????? ? ? ? ?            ? postgresql-2018-10-15_204938.log
-????????? ? ? ? ?            ? postgresql-2018-10-15_211244.csv
-????????? ? ? ? ?            ? postgresql-2018-10-15_211244.log
 
[root@pgha1 ~]# umount /data/
[root@pgha1 ~]# xfs_repair -L /dev/mapper/datavg-datalv
 
来自 <https://blog.csdn.net/luguifang2011/article/details/73792280>