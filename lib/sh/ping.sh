#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
#######################################
DATE=`date +'%Y-%m-%d'`
while true
do
# 替换目标IP地址
ping=`ping -c 1 192.168.6.143 |grep loss |awk -F "%" '{print $1}' |awk -F "," '{print $NF}' `
if [ "$ping" -eq 100 ]
then
   echo `date` Destination Host Unreachable >> /tmp/ping$DATE.log
   count=`cat /tmp/ping$DATE.log |wc -l`
   if [ "$count" -gt 10 ]
   then
      break
   fi
fi
#sleep 1s
done
