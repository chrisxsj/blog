#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
######################################
# introduction, 判断fs使用率，超过80%告警提示
######################################
#
fs=`df -k | awk '{print $5}' | grep -v 'Use' |awk -F% '{print $1}'`
fsus=($fs)
function CHECKFS () {
