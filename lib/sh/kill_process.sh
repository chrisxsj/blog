#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
######################################
# if process exist（grep bin/post）
proc=`ps -ef | grep bin/post | grep -v grep | awk '{print $2}'`
# kill process
if test -n "$proc"
then
	ps -ef | grep bin/post | grep -v grep | awk '{print $2}' | xargs kill -15
else
	echo "proc not running."
fi
