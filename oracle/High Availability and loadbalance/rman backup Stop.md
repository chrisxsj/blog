Stop rman backup


1 查看rman脚本运行的进程号
ps -ef |grep rman
subsdb1:~ # ps -ef | grep rman
root     10102  9603  0 17:36 pts/11   00:00:00 grep rman
subsdb1:~ # ps -ef | grep 26246
root     10213  9603  0 17:36 pts/11   00:00:00 grep 26246
2 查看rman channel进程号
查看RMAN分配的各个通道的进程号
SELECT
    sid,
    spid,
    client_info
FROM
    v$process p,
    v$session s
WHERE
    p.addr = s.paddr
    AND client_info LIKE '%rman%';
 
根据第（1）（2）中得到的进程号，终止RMAN备份
注：这里既要kill 掉RMAN备份脚本的PID，也要kill 掉RMAN中分配的各个通道的PID
 
# kill -9 26224
此时RMAN备份操作已经被终止。查看（2）中的SQL语句时，结果为空。
说明：如果单单kill掉RMAN的进程号，那么RMAN备份并没有停止，而是要连channel进程也一起掉才可以！
 