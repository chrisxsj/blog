#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
######################################
# introduction, 判断cpu使用率，超过80%告警提示
######################################
#
us=`top -n 1 |grep %Cpu |awk -F : '{printf $2}' | awk -F , '{printf $1}' | awk '{printf $2}'`
sy=`top -n 1 |grep %Cpu |awk -F : '{printf $2}' | awk -F , '{printf $2}' | awk '{printf $2}'`
cpu=`echo "$us $sy" |awk "{print int($us+$sy)}"`
function checkcpu () {
  if test $cpu -gt 80
  then
  echo "The usage of cpu is larger than 80%,current is $cpu%"
  else
  echo "The usage of cpu is normal,current is $cpu%" 
  fi 
}