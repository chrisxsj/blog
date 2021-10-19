#! /bin/bash
######################
# location：~/.bashrc
# source /opt/lib/task.sh
# crontab -l
# 30 9,12,16 * * * echo "\033[31m task1：测试 \033[0m" > /dev/pts/2
# 此脚本会替换/dev/pts/2,以向当前tty输入信息
#####################
function task() {
    tty=$(tty)
    ttys=($(ls -atl /dev/pts/* | awk '{print $10}'))
    ttyc=$(cat /var/spool/cron/crontabs/chrisx |grep pts |awk '{print $NF}' |uniq)
# echo ${ttys[*]}
        for i in ${ttys[*]} ; do
# echo "$i"
         if [ $i == $tty ]; then
            sudo sed -i "s#$ttyc#$tty#g" /var/spool/cron/crontabs/chrisx
         else
            echo "`date` error" > /dev/null 2>&1
         fi
    done
}

task

##########################################
#source /opt/lib/task.sh就可以
#sh /opt/lib/task.sh会报错？未知原因