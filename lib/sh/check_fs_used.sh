#! /bin/bash
#######################################
# author，Chrisx
# date，2022-01-17
# Copyright 2022 All rights reserved"
# description,判断fs使用率，超过80%告警提示
#######################################
function checkfs () {
    fs=$(df -k | sed '1d' | awk '{print $5}' |awk -F% '{print $1}')
    fsname=$(df -k | awk '{print $5}' | grep -v 'Use')
    fsused=($fs)
    for i in ${fsused[*]}
    do
        if [ $i -gt 80 ]
        then
        echo "The usage of fs is larger than 80%,current is $i%"
        else
        echo "The usage of fs is normal,current is $i%" | tee /dev/null
        fi
    done
}
