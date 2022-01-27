#! /bin/bash
#######################################
# author，Chrisx
# date，2022-01-17
# Copyright 2022 All rights reserved"
# description,ping test
#######################################
DATE=`date +'%Y-%m-%d'`
read -p "Input ip: " ip
while true
do
ping -c 5 $ip > /dev/null
if [ $? != 0 ];then
   echo `date` Destination Host Unreachable >> /tmp/ping$DATE.log
   count=`cat /tmp/ping$DATE.log |wc -l`
   if [ "$count" -gt 10 ]
   then
   break
   fi
fi
sleep 10s
done