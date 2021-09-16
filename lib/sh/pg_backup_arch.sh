#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
############################################
# Declare environment variables
source ~/.bash_profile
export LANG=C
#################################################
# variable
#ARCHDIR=/opt/pg126_arch            # path of  archive logs
DATE=`date +%Y%m%d%H%m`
ARCHDIR_BAK=/opt/backup/pg126             # path of backup archive logs
ARCHDIR_BAK_NAME=arch$DATE             # path of backup archive logs
LOGDIR=/opt/backup/pg126                 # path of log
LOGFILE=arch_backup_log$DATE        # name of logfile
LOGFILE_TMP=.arch$DATE.tmp          # name of temp logfile
#############################################
# Function
# color
function purple(){
    echo -e "\033[45m\033[01m[ $@ ]\033[0m"
}
# select archive directory
function archdir() {
    archcomm=`psql -Atc "select setting from pg_settings where name='archive_command'" |awk '{print $4}'`
    archdir=${archcomm%/*}
    echo "$archdir"

}

# archive count.note,$archdir from function archdir()
function arch_count() {
   count=$(find $archdir -maxdepth 1 -name "0*"  |wc -l)
   echo "$count"
}

# backup archive info.note,$archdir from function archdir()
function arch_record() {
    find $archdir -maxdepth 1 -name "0*[A-Z0-9][A-Z0-9]" -ctime +1 -exec ls -l {} \;
}

# backup
function arch_backup() {
   cp -rpi $archdir $ARCHDIR_BAK/$ARCHDIR_BAK_NAME >> $LOGDIR/$LOGFILE
}

# archive delete
function arch_delete() {
   #$LOGDIR/$LOGFILE_TMP from 
   str=`cat $LOGDIR/$LOGFILE_TMP | head -n 1 | awk '{print $9}'`
   arch=${str##*/}
   arch_stat1=111
   pg_archivecleanup $archdir $arch >> $LOGDIR/$LOGFILE
   arch_stat1=$?
   if [ $arch_stat1 -eq 0 ] ;then
      echo `date` "archive del completed!"
   else
      echo `date` "archive del faid"
   fi
}

# delete *.backcup
function backup_suffix_delete() {
   find $ARCHDIR -maxdepth 1  -name "0*.backup" -a -ctime +7  -exec rm {} \;
}

###################################################
# main 

function main() {
echo "------------------------------------------------"
archdir
purple "archivelog direcotory is : $archdir"
arch_count
purple "archivelog count is : $count"
arch_record
arch_record > $LOGDIR/$LOGFILE_TMP
arch_backup
arch_delete
backup_suffix_delete
echo "----------------------------------------------"
}

main >> $LOGDIR/$LOGFILE

###########################################


: << EOF
有备份的情况下，直接调用一下命令删除归档。
ARCHDIR=/opt/pg126_arch
ARCH=$(pg_controldata  |grep file |awk -F : '{print $2}')
pg_archivecleanup $ARCHDIR $arch  >> $LOGDIR/$LOGFILE
EOF