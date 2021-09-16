#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
######################################
# 记录用户登录的ip、时间、历史命令
# 退出，再登录的时候，/var/log/history下就会生成日志了
#!/bin/bash

#cat >> /etc/profile <<EOF
#
## history_ip
#
#EOF

# history_ip
# 将以下信息写入/etc/profile,并执行source命令
#如果要查看历史命令，可以查看/var/log/history 目录中相应系统用户下，每次ssh或者本地shell会话退出时都会将会话进行的操作保留并生成一个日志文件。其中#数据是unix时间戳可以通过linux 的date命令转换成可阅读时间格式 ，如date -d "@1279592730" 或者在线转换

ip=`who am i| awk '{print $NF}'|sed -e 's/[()]//g'`
username=`users`
time=`date +"%Y%m%d_%H:%M:%S"`
#login=`last |grep $username`
#lastlog=`lastlog |grep $username`
#lastlogtime=`ac -p |grep $username`
# ~/.bash_history记录时间ip
export HISTTIMEFORMAT=" $username@$ip %F %T "
# /var/log/message 记录cmd_log
export PROMPT_COMMAND="history 1 | logger -t cmd_log -p user.notice"

# 记录到新的history文件

log_dir=/var/log/history
if [ ! -d $log_dir ]
then
mkdir -p $log_dir
chmod 777 $log_dir
fi
if [ ! -d $log_dir/${username} ]
then
mkdir -p $log_dir/${username}
chmod 777 $log_dir/${username}
fi
export HISTSIZE=40960
export HISTFILE="$log_dir/${username}/${ip}-$time"
