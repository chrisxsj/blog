#! /bin/bash
function task() {
    tty=$(tty)
    ttys=($(ls -atl /dev/pts/* | awk '{print $10}'))
# echo ${ttys[*]}
        for i in ${ttys[*]} ; do
# echo "$i"
         if [ $i == $tty ]; then
            echo -e "\033[31m task1：审核文档 \033[0m" > $i
         else
            echo "`date` error" > /dev/null 2>&1
         fi
    done
}

task

#source /opt/lib/task.sh就可以
#sh /opt/lib/task.sh会报错？未知原因