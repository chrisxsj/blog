# PostgreSQL 流复制监控脚本
_整理之前的脚本文档，搬家至博客园，梳理一下之前写的shell脚本_

_适用于PostgreSQL版本10、版本9替换函数名称即可_

_\_xlog_location<=> \_wal\_lsn_

_\_location <=> \_lsn_

# 1. 脚本输出效果
## 1.1 主节点显示效果
```
        STREAM_ROLE    : Master         
        ------------------------------
        Replication Client Info:
        ------------------------------
        PID            : 25424          
        CLIENT_ADDR    : 20.8.6.213     
        SYNC_STATE     : async          
        STATE          : streaming      
        WRITE_DIFF     : 0bytes         
        FLUSH_DIFF     : 0bytes         
        REPLAY_DIFF    : 0bytes         
        Replication Client Info:
        ------------------------------
        PID            : 24586          
        CLIENT_ADDR    : 20.8.6.212     
        SYNC_STATE     : sync           
        STATE          : streaming      
        WRITE_DIFF     : 0bytes         
        FLUSH_DIFF     : 0bytes         
        REPLAY_DIFF    : 0bytes
```         
## 1.2 从节点效果
```
STREAM_ROLE    : Slave          
------------------------------
Replication Info
------------------------------
CLUSTER_STATE  : in_archive_recovery
SERVER_ADDR    : 20.8.6.219     
USER           : replicator     
APP_NAME       : node12         
TARGET_TIMELINE:                
READ_ONLY      : on  
```


# 2. 功能说明
- 判定主机角色
- 如果为Master节点，则显示复制节点信息，及与主节点差值
- 如果为Replication节点，则显示为本节点相关信息


# 3. 使用说明
- 根据实际环境修改脚本pgdata=""
- postgres系统用户执行，保证有执行权限
- 本地执行脚本`sh pg10_stream.sh`

# 4. pg10_stream.sh脚本内容
```
#!/bin/bash
################################
## Author: andy_yhm@yeah.net
## Version: 1.0
## Date:    20181219
################################
clear
host_var="/tmp"
pgdata="/pgdb/pgdata"
work_dir=$(cd `dirname $0`;pwd)
cd $work_dir
is_master=$(psql -h $host_var -c 'select  pg_is_in_recovery();'| sed -n 3p)
if [ "$is_master" == " f" ];then
    rep=$(psql  -h $host_var -c 'select  pid, client_addr, sync_state, state,pg_size_pretty( pg_wal_lsn_diff(pg_current_wal_lsn(),write_lsn)) as write_diff, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(),flush_lsn)) as flush_diff, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(),replay_lsn)) as replay_diff      from pg_stat_replication;'| sed -n '3,$'p |tac  | sed -n '3,$'p | sed s/" *"//g )
    if [ ! "$rep" ];then
      echo "Waring! No Replication Client Found"
    else
      printf "\n\t%-15s: %-15s\n" "STREAM_ROLE" "Master"
      echo  -e "\t------------------------------"
      echo "$rep" | while read i
        do
          echo  -e "\tReplication Client Info:\n\t------------------------------"
          a=(null PID CLIENT_ADDR SYNC_STATE STATE WRITE_DIFF FLUSH_DIFF REPLAY_DIFF)
          for j in `seq 7`
            do
              k=${a[j]}
              echo -e "$i" | awk -v k=$k -v j=$j -F"|" '{printf "\t%-15s: %-15s\n",k,$j}'
            done
          echo ""
        done
      client_check_info=(`psql -h $host_var -c 'select client_addr from pg_stat_replication;' | sed -n '3,$'p |tac  | sed -n '3,$'p | sed s/" *"//g`)
      if [ ! -f pg_stream_client ]; then
        echo "$client_check_info" > pg_stream_client
      else
        client_before=(`cat pg_stream_client`)
        if [ ${#client_before[*]} -gt 0 ]; then
          for i in `seq ${#client_before[*]}`
            do
              index=$(expr $i - 1)
              if [ "${client_check_info[$index]}"x !=  "${client_before[$index]}"x ];then
                printf  "\tWarning! Replication Client Lost.\n"
              else
                echo "$client_check_info" > pg_stream_client
              fi
            done
         else
           printf  "\tAttention! No Client Info found in pg_stream_client.\n"
         fi
      fi
    fi
elif [ "$is_master" == " t" ];then
    declare -A connect_info_dict
    conninfo=$(cat $pgdata/recovery.conf| grep -i "^primary_conninfo" | awk -F"'" '{print $2}' |sed s/"  *"/" "/g |sed s/"="/"\"]=\""/g | sed s/" "/"\" [\""/g | sed s/^/"[\""/g |sed s/$/"\""/g|sed s/" "/"\n"/g)
    eval "connect_info_dict=($conninfo)"
    cluster_state=$(pg_controldata  | grep cluster | sed s/"  *"/" "/g | cut -d ":" -f2| sed s/"^ "//g|  sed s/" "/"_"/g)
    server_addr=${connect_info_dict["host"]}
    user=${connect_info_dict["user"]}
    application_name=${connect_info_dict["application_name"]}
    recovery_target_timeline=${connect_info_dict["recovery_target_timeline"]}
    read_only=$(psql  -h $host_var -c 'show  transaction_read_only;' | sed -n '3p')
    output(){
      printf "\t%-15s: %-15s\n" $1 $2
    }
    printf "\n\t%-15s: %-15s\n" "STREAM_ROLE" "Slave"
    echo  -e "\t------------------------------"
    echo  -e "\tReplication Info\n\t------------------------------"
    output "CLUSTER_STATE" $cluster_state
    output "SERVER_ADDR" $server_addr
    output "USER" $user
    output "APP_NAME" $application_name
    output "TARGET_TIMELINE" $recovery_target_timeline
    output "READ_ONLY" $read_only
    echo ""
else
    echo "Warning! Can't Connect to Database. Please Check Database Status "
fi
exit 0
psql  -c 'select application_name,client_addr ,sync_state from pg_stat_replication;' | sed -n '3,$'p |tac  | sed -n '3,$'p | sed s/" *"//g
```