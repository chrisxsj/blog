# kill idle process
script

```bash
#!/bin/bash
####################################################################
##for postgresql backend processes
####################################################################
actype='idle'
actime=10
tran_id=$(ps -ef | grep postgres|grep "$actype"|awk '{print $2}')
for i in $tran_id
do
        atime=$(ps -eo pid,tty,user,comm,lstart,etimes|grep $i|awk '{print $10}')
echo $atime
echo $actime
        ((btime=$atime/$actime))
        if [ $btime -gt $actime ];then
               echo "$(date "+%Y%m%d %H:%M:%S") kill $actype session:$(ps -eo pid,tty,user,comm,lstart,etimes|grep $i)"
               ps -eo pid,tty,user,comm,lstart,etimes|grep $i >> /tmp/kill_idle.log
               kill -15 $i
        fi
done
```


crontab 
```

#!/bin/bash
####################################################################
#清理空闲进程，默认清理超过10小时的“idle in transaction”类型的连接。
#参数，0表示“idle in transaction”，1表示“idle”
#例，如需清理12小时的“idle”连接，用法为sh killidle.sh 1 12
####################################################################
j=$1
actype='idle in transaction'
actime=10
if [ -n $j ] && [ $j -eq 0 ];then
   actype='idle in transaction'
elif [ -n $j ]&&[ $j -eq 1 ];then
   actype='idle'
fi
if [ -n $2 ];then
        actime=$2
fi
tran_id=$(ps -ef | grep postgres|grep "$actype"|awk '{print $2}')
for i in $tran_id
do
        atime=$(ps -eo pid,tty,user,comm,lstart,etimes|grep $i|awk '{print $10}')
echo $atime
echo $actime
        ((btime=$atime/$actime))
        if [ $btime -gt $actime ];then
               echo "$(date "+%Y%m%d %H:%M:%S") kill $actype session:$(ps -eo pid,tty,user,comm,lstart,etimes|grep $i)"
               ps -eo pid,tty,user,comm,lstart,etimes|grep $i >> /tmp/kill_idle.log
               kill -15 $i
        fi
done


```