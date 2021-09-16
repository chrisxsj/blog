#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-21
# Copyright (C): 2021 All rights reserved"
######################################
# introduction,自动查找日志路径，并从日志路径中抓取最近7天的日志，截取其中的WARNING|ERROR|FATAL|PANIC信息
######################################
function pg_database_log () {
  echo "###### 获取错误日志信息"
  log_dir=`psql --pset=pager=off -qAt -c 'show log_directory'`
  log=(`find $PGDATA/$log_dir -name "*.csv" -type f -mtime -7 -exec ls {} \;`)
  echo ${log[*]} 
  for l in ${log[*]}
  do
  cat $l |grep -E "^[0-9]" | grep -E "WARNING|ERROR|FATAL|PANIC" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 参考 http://www.postgresql.org/docs/current/static/errcodes-appendix.html ."
  echo "###### 获取连接请求信息"
  for l in ${log[*]}
  do
  cat $l |grep -E "^[0-9]" | grep "connection authorized" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 连接请求非常多时, 请考虑应用层使用连接池, 或者使用pgbouncer连接池."
  echo "###### 获取认证失败情况"
  for l in ${log[*]}
  do
  cat $l |grep -E "^[0-9]" | grep "password authentication failed" | awk -F "," '{print $12" , "$13" , "$14}'|sort|uniq -c|sort -rn
  done
  echo "--->>> 认证失败次数很多时, 可能是有用户在暴力破解, 建议使用auth_delay插件防止暴力破解. "

  echo -e "\n"
}
