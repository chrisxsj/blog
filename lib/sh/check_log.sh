#! /bin/bash
#######################################
# author，Chrisx
# date，2022-02-21
# Copyright (C): 2021 All rights reserved"
######################################
# introduction,自动查找日志路径，并从日志路径中抓取最近7天的日志，分析错误信息和连接信息
######################################
function check_log_error () {
  log_dir=`psql --pset=pager=off -qAt -c 'show log_directory'`
  log=(`find $PGDATA/$log_dir -name "*.csv" -type f -mtime -7 -exec ls {} \;`)
  echo ${log[*]} 
  for l in ${log[*]}
  do
  echo "###### 获取$l错误日志信息"
  cat $l |grep -E "^[0-9]" | grep -E "WARNING|ERROR|FATAL|PANIC" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn
  echo "--->>> 参考 http://www.postgresql.org/docs/current/static/errcodes-appendix.html ."
  done

  echo -e "\n"
}

function check_log_connection () {
  log_dir=`psql --pset=pager=off -qAt -c 'show log_directory'`
  log=(`find $PGDATA/$log_dir -name "*.csv" -type f -mtime -7 -exec ls {} \;`)
  echo ${log[*]} 
  for l in ${log[*]}
  do
  echo "###### 获取$l连接请求信息"
  cat $l |grep -E "^[0-9]" | grep "connection authorized" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn  #连接成功次数
  cat $l |grep -E "^[0-9]" | grep "password authentication failed" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn #连接失败次数
  #cat $l |grep '^2022-02-09 18:' |grep authentication |awk '{print $1 ' ' $2}' |awk -F: '{pr
  cat $l | awk -F "," '{print $5}' |sed '/^$/d' |sed s/\"//g |awk -F ":" '{ipc[$1]++} END {for (i in ipc){print i,ipc[i]}}'|sort -k2 -rn | head -n 10 #获取连接数前十的ip
  #cat $l |grep ^[0-9] |awk '$2>=14:00:00 && $2<=16:10:00 {print $0}' | awk -F "," '{print $5}' |sed '/^$/d' |sed s/\"//g |awk -F ":" '{ipc[$1]++} END {for (i in ipc){print i,ipc[i]}}'|sort -k2 -rn | head -n 10 #指定时间段内，获取连接数前十的ip
  echo "--->>> 分析连接信息"
  done

  echo -e "\n"
}

#check_log_error
#check_log_connection
