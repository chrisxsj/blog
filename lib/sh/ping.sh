#! /bin/bash
#######################################
# author，Chrisx
# date，2022-01-17
# Copyright 2022 All rights reserved"
# description,ping test
#######################################

function fping {
while true
do
DATE=`date +'%Y-%m-%d'`
#DATE=`date +'%F'`
#read -p "Input ip: " ip
# Replace $ip
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
}

#fping