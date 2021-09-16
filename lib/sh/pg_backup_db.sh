#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
#############################################################################################
# 1、备份使用pg_basebackup
# 2、支持对备份进行打包或压缩
# 3、脚本不支持dash，如系统是Ubuntu、Deepin、UOS等系统，使用下面两种方式运行脚本:
#    (1)sudo dpkg-reconfigure dash  选择no。这样会修改为bash为默认shell
#    (2)直接使用bash 脚本名调用
# 4、需要提前创建密码文件
# 5、调整读取密码文件逻辑，密码文件同一个用户有多行时，只取一行
# 6、远程备份时，远程机器需要安装pg软件
# 7、scp需要配置ssh免密
# 8、归档删除仅支持本地部署脚本，远程部署脚本无法删除归档
# 9、远程备份，建议把变量archdir注释掉
# note，脚本还有问题，先使用原版备份脚本
#############################################################################################
source ~/.bash_profile
#需要修改的参数################################################################################
#数据库连接参数选项
pguser=pg126                                       #数据库连接用户，建议使用管理员
pgdatabase=postgres                                #备份使用的数据库名称，默认使用postgres
pgport=5433                                        #数据库端口
num=2                                              #备份保留数量
archdir=/opt/pg126_arch                           #归档文件存放路径
PGHOME=/opt/pg126                                  #数据库安装目录，末尾不要带“/”
master_db_cluster=/opt/pg106_data                  #数据文件路径，默认指向$PGHOME/data,远程备份时填写主库data路径
backup_db_cluster=/opt/backup/pg126               #备份存放路径，远程备份时，填写本地备份目录
bakhost=192.168.6.11                              #服务器ip，本地使用localhost即可
#压缩备份选项
istar=no                                           #是否将备份打包为tar包 yes/no
iscompressed=no                                    #是否将备份进行压缩，需要先设置istar为yes，使用gz压缩。yes/no
#scp备份选项
scp_bak=no                                         #是否启用scp备份，yes/no
scp_host=192.168.6.141                             #scp远程服务器
scp_dir=/home/pg106/backup/scp                     #scp远程备份目录

##################################################################################################
bakdate=`date +%Y%m%d`
olddate=`date +%Y%m%d --date="-$num day"`
reolddate=`date +%Y%m%d --date="-$rebak_num day"`
bakname="hgdbbak_"$bakdate"_"$bh
logfile="hgdbbak_"$bakdate"_"$bh".log"
pgpasswd=`cat ~/.pgpass|grep $bakhost|grep $pgport|grep $pgdatabase|grep $pguser|awk -F ':' '{print $5}'|tail -n 1`
export PGPASSWORD=$pgpasswd
mkdir $backup_db_cluster/$bakname
#以下内容不要修改##########################################################################################

# 判断是否存在备份目录
function create_backup_db_cluster() {
    [ -d $backup_db_cluster ] || mkdir -p $backup_db_cluster
}

# 产生备份文件序列号
function backup_series() {
    if [ `ls -l $backup_db_cluster/ |grep '^d'|grep $bakdate|wc -l` -gt 0 ];then
        tmp=`ls -l $backup_db_cluster/ |grep '^d'|grep $bakdate|awk '{print $9}'|sort -nr -t'_' -k 3|head -1|awk -F '_' '{print $3}'`
        bh=$((tmp + 1))
    else
        bh=1
    fi
}

# 测试备份目录可写，不可写，则退出
function test_write_file() {
    touch $backup_db_cluster/test_write_file
    if [ ! -f $backup_db_cluster/test_write_file ];then
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	can not find "$backup_db_cluster" , or do not have Permission to write to "$backup_db_cluster "job will stop."
        return 1
    else 
        echo "backup directory is "$backup_db_cluster "job will start."
    fi
    rm -f $backup_db_cluster/test_write_file
}

# 抓取非默认表空间
function no_default_tbs() {
    tbs=(`$PGHOME/bin/psql -U $pguser -h $bakhost -Atc "select pg_catalog.pg_tablespace_location(oid) FROM pg_catalog.pg_tablespace;" -p $pgport $pgdatabase |sed '/^$/d'|grep -v "$master_db_cluster"`)
    if [ ${#tbs[*]} -gt 0 ];then
        for i in ${tbs[@]}
        do 
            j=${i##*/}
            str=$str" -T "$i"=$backup_db_cluster/$bakname/nodefault/$j"
            echo "`date  '+%Y-%m-%d %H:%M:%S'`  Tablespace $i remaps to $backup_db_cluster/$bakname/nodefault/$j"
        done
    else
        echo "`date  '+%Y-%m-%d %H:%M:%S'`  There do not have tablespace out of "$master_db_cluster" in this cluster ......"
    fi
}

#判断是否需要压缩
function is_compressed() {
    if [ x$iscompressed = 'xyes' ];then
        comp="t -z"
    elif [ x$istar = 'xyes' ];then
        comp="t"
    else
        comp="p"
    fi
}

#########################################################

# 判断数据库是否在运行状态或者数据库是否为主库，是则可以备份
function ifbackup() {
    ifbackup=`psql -U $pguser -h $bakhost -Atc "select pg_is_in_recovery()" -p $pgport $pgdatabase`
    if [ $ifbackup"x" = "f""x" ];then
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	Database is not recovering and can be connected , so can be backup now."
    else
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	Recovering or database is not running ,backup failed,the shell will exit now."
        #rm -rf $backup_db_cluster/$bakname
        return 1
    fi
}

# 执行checkpoint，不成功则退出
function checkpoint() {
    ifcheckpoint=`sleep 5 && $PGHOME/bin/psql -U $pguser -h $bakhost -p $pgport -d $pgdatabase -Atc "checkpoint;" `
    if [ $ifcheckpoint"x" = "CHECKPOINT""x" ];then
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	Database is exec checkpoint , so can be backup now."
        else
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	checkpoint is not successfully ,backup failed,the shell will exit now."
        rm -rf $backup_db_cluster/$bakname
        return 1
    fi
}

# 执行备份命令，流复制协议不成功则退出
function pg_basebackup() {
    ifbasebackup=`psql "replication=true dbname=$pgdatabase hostaddr=$bakhost user=$pguser port=$pgport " -Atc "SHOW PORT;"`
    if [ $ifbasebackup"x" = $pgport"x" ];then
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	replication protocol connect is successful , backup now."
        $PGHOME/bin/pg_basebackup -h $bakhost -p $pgport -U $pguser -D $backup_db_cluster/$bakname -F $comp -v -P -X fetch $str >> $backup_db_cluster/$logfile 2>&1
    else
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	replication protocol connect is not successful ,backup failed,the shell will exit now."
        rm -rf $backup_db_cluster/$bakname
        return 1
    fi 
}

# 删除冗余备份
function del_redundancy_bak() {
     baknum=`ls -l $backup_db_cluster |grep '^d'|grep -E 'hgdbbak_[0-9]{8}_[0-9]{1,10}'|awk '{print $9}'|wc -l`
     if [ $baknum -gt $num ];then
         delnum=$((baknum-num))
         
         for ((i=1;i<=$delnum;i++));
         do
             tmp_delbak=`ls -l $backup_db_cluster |grep '^d'|grep -E 'hgdbbak_[0-9]{8}_[0-9]{1,10}'|awk '{print $9}'|sort -n -k2 -k3 -t'_'|head -1|sed 's/ *//g'`

             if [ "x${tmp_delbak}" == "x" ];then
                 echo "`date  '+%Y-%m-%d %H:%M:%S'` There are no backups that need to be deleted."
             else
                 delbak=${tmp_delbak##*/}
                 dellog=$delbak".log"
                 if [ -d $backup_db_cluster/$delbak ];then
                     echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting backup file $backup_db_cluster/$delbak"
                     rm -rf $backup_db_cluster/$delbak
                 fi
                 if [ -f $backup_db_cluster/$dellog ];then
                     echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting backup log $backup_db_cluster/$dellog"
                     rm -f $backup_db_cluster/$dellog
                 fi
             fi
         done
     fi
}

# 删除归档
function del_arch() {
    tmp_s=`cat $backup_db_cluster/$logfile|grep -E 'pg_basebackup: base backup completed|pg_basebackup: 基础备份已完成'|wc -l`
        if [ $tmp_s -gt 0 ];then
            delarch=`ls -lrt $archdir |grep -E '[0]{4}[0-9,A-F]{4}[0-9,A-F]{8}[0]{6}[0-9,A-F]{2}.[0-9,A-F]{8}.backup'|awk '{print $9}'|tail -n 1`
            echo "`date  '+%Y-%m-%d %H:%M:%S'` The name of the backup file is :$bakname,the name of the lastest archive is:$delarch"
            
                if [ "x${delarch}" == "x" ];then
                    echo "`date  '+%Y-%m-%d %H:%M:%S'` There are no archives to be deleted. $delarch"
                else
                    echo "`date  '+%Y-%m-%d %H:%M:%S'` Archiving before $delarch is being deleted."
                    $PGHOME/bin/pg_archivecleanup $archdir $delarch >> $backup_db_cluster/$logfile
                fi
            else
            echo "`date  '+%Y-%m-%d %H:%M:%S'` there are no backup file or backup not successful."
        fi
}

# scp
function scp_bak() {
    if [ "x${scp_bak}" == "xno" ];then
        return 1
    fi
    tmp_scp=`cat $backup_db_cluster/$logfile|grep -E 'pg_basebackup: base backup completed|pg_basebackup: 基础备份已完成'|wc -l`
        if [ $tmp_scp -gt 0 ];then
        tmp_scpbak=`ls -l $backup_db_cluster |grep '^d'|grep -E 'hgdbbak_[0-9]{8}_[0-9]{1,10}'|awk '{print $9}'|sort -n -k2 -k3 -t'_'|tail -1|sed 's/ *//g'`
            if [ "x${tmp_scpbak}" == "x" ];then
                echo "`date  '+%Y-%m-%d %H:%M:%S'` There are no backups that need to scp."
            else
                scpbak=$tmp_scpbak
                scpbaklog=$scpbak".scplog"
                # scp命令输出看不到？？？
                #script $backup_db_cluster/$scpbaklog
                scp -r $scpbak $scp_host:$scp_dir
                #quit
                echo "`date  '+%Y-%m-%d %H:%M:%S'` scp backup completed."
            fi
        fi
}


# main函数##############################################################

function main() {

    create_backup_db_cluster
    backup_series
    test_write_file
    ifbackup       
    no_default_tbs
    is_compressed
    checkpoint
    is_compressed
    pg_basebackup
    del_redundancy_bak
    del_arch
    scp_bak
}

main >> $backup_db_cluster/$logfile
