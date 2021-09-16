#!/bin/bash
#############################################################################################
# 1、备份改用pg_basebackup
# 2、支持对备份进行打包或压缩
# 3、SM机把第一行再加个“#”
# 4、脚本不支持dash，如系统是Ubuntu、Deepin、UOS等系统，使用下面两种方式运行脚本:
#    (1)sudo dpkg-reconfigure dash  选择no。这样会修改为bash为默认shell
#    (2)直接使用bash 脚本名调用
# 5、调整检测逻辑，在流复制备机运行时，不创建任何文件
# 6、调整读取密码文件逻辑，密码文件同一个用户有多行时，进取一行
#############################################################################################
source ~/.bash_profile
#需要修改的参数
hguser=sysdba                                       #安全版换成sysdba或其他权限足够的用户
defdb=highgo                                        #备份使用的数据库名称，默认使用highgo
PORT=5866                                           #数据库端口
num=3                                               #备份保留数量
archdir=/opt/dbbak/archive                          #归档文件存放路径
PGHOME=/opt/HighGo4.5.2-see                         #数据库安装目录，末尾不要带“/”
master_db_cluster=/opt/HighGo4.5.2-see/data         #数据文件路径，默认指向$PGHOME/data
backup_db_cluster=/opt/dbbak                        #备份存放路径
bakhost=localhost                                   #服务器ip，本地使用localhost即可
issm=no                                             #是否为SM机环境，如果不是，且crontab可用，此处填写no
baktime=23:00                                       #如果issm是no，这个不生效
istar=no                                            #是否将备份打包为tar包
iscompressed=no                                     #是否将备份进行压缩，需要先设置istar为yes，使用gz压缩
#冗余备份选项
re_bak=yes                                          #是否启用冗余备份，yes/no
rebak_dir=/rebak/dbbak                              #备份文件存放路径，本地及远程存储均按实际路径填写
rearch_dir=/rebak/arch                              #冗余归档目录
rebak_num=4                                         #冗余备份保留份数

#################################################################################以下内容不要修改##########################################################################################
bakdate=`date +%Y%m%d`
olddate=`date +%Y%m%d --date="-$num day"`
reolddate=`date +%Y%m%d --date="-$rebak_num day"`
[ -d $backup_db_cluster ] || mkdir -p $backup_db_cluster
if [ -d $backup_db_cluster ] ;then
    cd $backup_db_cluster
    if [ `ls -l $backup_db_cluster/ |grep '^d'|grep $bakdate|wc -l` -gt 0 ];then
        tmp=`ls -l $backup_db_cluster/ |grep '^d'|grep $bakdate|awk '{print $9}'|sort -nr -k 3 -t'_'|head -1|awk -F '_' '{print $3}'`
        bh=$((tmp + 1))
    else
        bh=1
    fi
    bakname="hgdbbak_"$bakdate"_"$bh
    logfile="hgdbbak_"$bakdate"_"$bh".log"
    test_write_file="test_write_file"`date +%Y%m%d%H%S`.tmp
    touch $backup_db_cluster/$test_write_file
    if [ ! -f $test_write_file ];then
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	can not find "$backup_db_cluster" , or do not have Permission to write to "$backup_db_cluster "job will stop.">> $backup_db_cluster/$logfile
        return 1
    fi
    rm -f $backup_db_cluster/$test_write_file
else
    echo "can not create "$backup_db_cluster "job will stop.">> $backup_db_cluster/$logfile
    return 1
fi
#冗余备份
function dbrebak(){
    if [ "x${re_bak}" == "xno" ];then
        return 1
    fi
    test_file="test_file"`date +%Y%m%d%H%S`.tmp
    touch $rebak_dir/$test_file
    if [ ! -f $rebak_dir/$test_file ];then
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	can not find "$rebak_dir" , or do not have Permission to write to "$rebak_dir "job will stop.">> $backup_db_cluster/$logfile
        return 1
    fi
    rm -f $rebak_dir/$test_file
    if [ "x${istar}" == "xyes" ] || [ "x{iscompressed}" == "xyes" ];then
        cp -rf $backup_db_cluster/$bakname $rebak_dir/
        cp -f $backup_db_cluster/$logfile $rebak_dir/
        locbakmd5=`md5sum $backup_db_cluster/$bakname`
        for i in {1..3}
        do
            rebakmd5=`md5sum $rebak_dir/$bakname`
            if [ "x${locbakmd5}" == "x${rebakmd5}" ];then
                break
            else
               rm -rf $rebak_dir/$bakname
               cp -rf $backup_db_cluster/$bakname $rebak_dir/
               cp -f $backup_db_cluster/$logfile $rebak_dir/
            fi
        done
    else
        for i in {1..3}
        do
            cp -rf $backup_db_cluster/$bakname $rebak_dir/
            cp -f $backup_db_cluster/$logfile $rebak_dir/
            tree -i --noreport $backup_db_cluster/$bakname|grep -v $bakname >$backup_db_cluster/locbak
            tree -i --noreport $rebak_dir/$bakname|grep -v $bakname >$backup_db_cluster/rebak
            chk=`diff -q $backup_db_cluster/locbak $backup_db_cluster/rebak|wc -l`
            if [ ${chk} -ge 1 ];then
                rm -rf $rebak_dir/$bakname
                cp -rf $backup_db_cluster/$bakname $rebak_dir/
                cp -f $backup_db_cluster/$logfile $rebak_dir/
            else
                break
            fi
            rm -f $backup_db_cluster/locbak
            rm -f $backup_db_cluster/rebak
        done
    fi
    if [ $tmp_s -gt 0 ];then
        baknum=`ls -l $rebak_dir |grep '^d'|grep -E 'hgdbbak_[0-9]{8}_[0-9]{1,10}'|awk '{print $9}'|wc -l`
        if [ $baknum -gt $rebak_num ];then
            delnum=$((baknum-rebak_num))
            for ((i=1;i<=$delnum;i++));
            do
                tmp_delbak=`ls -l $rebak_dir |grep '^d'|grep -E 'hgdbbak_[0-9]{8}_[0-9]{1,10}'|awk '{print $9}'|sort -n -k2 -k3 -t'_'|head -1|sed 's/ *//g'`
                if [ "x${tmp_delbak}" == "x" ];then
                    echo "`date  '+%Y-%m-%d %H:%M:%S'` There are no backups that need to be deleted." >> $rebak_dir/$logfile
                else
                    delbak=${tmp_delbak##*/}
                    dellog=$delbak".log"
                    if [ -f $rebak_dir/$dellog ];then
                        delarch=`cat $rebak_dir/$dellog |grep 'The name of the backup file is'|grep $delbak|grep '.backup'|awk -F '[:,.]' '{print $6}'`
                        delarchbk=`cat $rebak_dir/$dellog |grep 'The name of the backup file is'|grep $delbak|grep '.backup'|awk -F '[:,]' '{print $6}'`
                    else
                        echo "`date  '+%Y-%m-%d %H:%M:%S'` The log file to delete the backup was not obtained. $rebak_dir/$dellog" >> $rebak_dir/$logfile
                    fi
                    if [ "x${delarch}" == "x" ];then
                        echo "`date  '+%Y-%m-%d %H:%M:%S'` There are no archives to be deleted. $delarch" >> $rebak_dir/$logfile
                    else
                        echo "`date  '+%Y-%m-%d %H:%M:%S'` Archiving before $delarch is being deleted." >> $rebak_dir/$logfile
                        $PGHOME/bin/pg_archivecleanup $rearch_dir $delarch >> $rebak_dir/$logfile
                    fi
                    if [ -f $rearch_dir/$delarchbk ];then
                        echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting archive file $rearch_dir/$delarchbk" >> $rebak_dir/$logfile
                        rm -f $rearch_dir/$delarchbk
                    fi
                    if [ -d $rebak_dir/$delbak ];then
                        echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting backup file $rebak_dir/$delbak" >> $rebak_dir/$logfile
                        rm -rf $rebak_dir/$delbak
                    fi
                    if [ -f $rebak_dir/$dellog ];then
                        echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting backup log $rebak_dir/$dellog" >> $rebak_dir/$logfile
                        rm -f $rebak_dir/$dellog
                    fi
                fi
            done
        fi
    fi
}

#备份函数
function dbbak(){
    pgpasswd=`cat ~/.pgpass|grep $bakhost|grep $PORT|grep $defdb|grep $hguser|awk -F ':' '{print $5}'|tail -n 1`
    export PGPASSWORD=$pgpasswd
    ifbackup=`psql -U $hguser -h $bakhost -Atc "select pg_is_in_recovery()" -p $PORT $defdb`
    if [ $ifbackup"x" = "f""x" ];then
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	Database is not recovering and can be connected , so can be backup now.">> $backup_db_cluster/$logfile
    else
        echo "`date  '+%Y-%m-%d %H:%M:%S'`	Recovering or database is not running ,backup failed,the shell will exit now." >> $backup_db_cluster/$logfile
        rm -rf $backup_db_cluster/$bakname
        return 1
    fi
    echo "`date  '+%Y-%m-%d %H:%M:%S'` pg_basebackup will go now">> $backup_db_cluster/$logfile
    if [ -d $master_db_cluster ];then
        tbs=(`$PGHOME/bin/psql -U $hguser -h $bakhost -Atc "select pg_catalog.pg_tablespace_location(oid) FROM pg_catalog.pg_tablespace;" -p $PORT $defdb |sed '/^$/d'|grep -v "$master_db_cluster"`)
        if [ ${#tbs[*]} -gt 0 ];then
            for i in ${tbs[@]}
            do 
                j=${i##*/}
                str=$str" -T "$i"=$backup_db_cluster/$bakname/nodefault/$j"
                echo "`date  '+%Y-%m-%d %H:%M:%S'` Tablespace $i remaps to $backup_db_cluster/$bakname/nodefault/$j" >>$backup_db_cluster/$logfile
            done
        else
            echo "`date  '+%Y-%m-%d %H:%M:%S'` There do not have tablespace out of "$master_db_cluster" in this cluster ......" >>$backup_db_cluster/$logfile
        fi
        if [ x$iscompressed = 'xyes' ];then
            comp="t -z"
        elif [ x$istar = 'xyes' ];then
            comp="t"
        else
            comp="p"
        fi
        mkdir $backup_db_cluster/$bakname
        sleep 5 && $PGHOME/bin/psql -U $hguser -h $bakhost -Atc "checkpoint;" -p $PORT $defdb >/dev/null 2>&1 &
        $PGHOME/bin/pg_basebackup -D $backup_db_cluster/$bakname -F $comp -v -P -U $hguser $str >>$backup_db_cluster/$logfile 2>&1
        tmp_s=`cat $backup_db_cluster/$logfile|grep -E 'pg_basebackup: base backup completed|pg_basebackup: 基础备份已完成'|wc -l`
        #备份成功，清理旧文件
        if [ $tmp_s -gt 0 ];then
            archivename=`ls -lrt $archdir |grep -E '[0]{4}[0-9,A-F]{4}[0-9,A-F]{8}[0]{6}[0-9,A-F]{2}.[0-9,A-F]{8}.backup'|awk '{print $9}'|tail -n 1`
            echo "`date  '+%Y-%m-%d %H:%M:%S'` The name of the backup file is :$bakname,the name of the archive is:$archivename" >> $backup_db_cluster/$logfile
            baknum=`ls -l $backup_db_cluster |grep '^d'|grep -E 'hgdbbak_[0-9]{8}_[0-9]{1,10}'|awk '{print $9}'|wc -l`
            if [ $baknum -gt $num ];then
                delnum=$((baknum-num))
                for ((i=1;i<=$delnum;i++));
                do
                    tmp_delbak=`ls -l $backup_db_cluster |grep '^d'|grep -E 'hgdbbak_[0-9]{8}_[0-9]{1,10}'|awk '{print $9}'|sort -n -k2 -k3 -t'_'|head -1|sed 's/ *//g'`
                    if [ "x${tmp_delbak}" == "x" ];then
                        echo "`date  '+%Y-%m-%d %H:%M:%S'` There are no backups that need to be deleted." >> $backup_db_cluster/$logfile
                    else
                        delbak=${tmp_delbak##*/}
                        dellog=$delbak".log"
                        if [ -f $backup_db_cluster/$dellog ];then
                            delarch=`cat $backup_db_cluster/$dellog |grep 'The name of the backup file is'|grep $delbak|grep '.backup'|awk -F '[:,.]' '{print $6}'`
                            delarchbk=`cat $backup_db_cluster/$dellog |grep 'The name of the backup file is'|grep $delbak|grep '.backup'|awk -F '[:,]' '{print $6}'`
                        else
                            echo "`date  '+%Y-%m-%d %H:%M:%S'` The log file to delete the backup was not obtained. $backup_db_cluster/$dellog" >> $backup_db_cluster/$logfile
                        fi
                        if [ "x${delarch}" == "x" ];then
                            echo "`date  '+%Y-%m-%d %H:%M:%S'` There are no archives to be deleted. $delarch" >> $backup_db_cluster/$logfile
                        else
                            echo "`date  '+%Y-%m-%d %H:%M:%S'` Archiving before $delarch is being deleted." >> $backup_db_cluster/$logfile
                            $PGHOME/bin/pg_archivecleanup $archdir $delarch >> $backup_db_cluster/$logfile
                        fi
                        if [ -f $archdir/$delarchbk ];then
                            echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting archive file $archdir/$delarchbk" >> $backup_db_cluster/$logfile
                            rm -f $archdir/$delarchbk
                        fi
                        if [ -d $backup_db_cluster/$delbak ];then
                            echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting backup file $backup_db_cluster/$delbak" >> $backup_db_cluster/$logfile
                            rm -rf $backup_db_cluster/$delbak
                        fi
                        if [ -f $backup_db_cluster/$dellog ];then
                            echo "`date  '+%Y-%m-%d %H:%M:%S'` Deleting backup log $backup_db_cluster/$dellog" >> $backup_db_cluster/$logfile
                            rm -f $backup_db_cluster/$dellog
                        fi
                    fi
                done
            fi
        fi
    else
        echo "`date  '+%Y-%m-%d %H:%M:%S'` Master_db_cluster directory does not exist,backup will be exit.Please check the parameter settings" >> $backup_db_cluster/$logfile 2>&1
        exit 0
    fi
}

[ -d $backup_db_cluster ] || mkdir -p $backup_db_cluster
if [ -d $backup_db_cluster ];then
    if  [ -f $backup_db_cluster/runstat.info ];then
        pid=`cat $backup_db_cluster/runstat.info|awk '{print $2}'`
        nowpid=$$
        if [ ${pid} -ne ${nowpid} ];then
            pidcnt1=`ps -ef |grep ${pid}|grep -v grep|grep sleep|wc -l`
            pidcnt2=`ps -ef |grep ${pid}|grep -v grep|grep hgdbbak|wc -l`
            pidcnt3=`ps -ef |grep ${pid}|grep -v grep|grep db_backup|wc -l`
            if [ ${pidcnt1} -ge 1 ] || [ ${pidcnt2} -ge 1 ] || [ ${pidcnt3} -ge 1 ];then
                echo "`date  '+%Y-%m-%d %H:%M:%S'` The script is already running, and automatically exits"
                exit 0
            else
                echo "`date +"%Y%m%d%H%M%S"` $$" > $backup_db_cluster/runstat.info
            fi
        fi
    else
        echo "`date +"%Y%m%d%H%M%S"` $$" > $backup_db_cluster/runstat.info
    fi
else
    echo "can not create "$backup_db_cluster "job will stop."
    exit 0
fi

if [ x$issm = 'xyes' ];then
    pro=`ps -ef | grep db_backup | grep -v grep | awk '{print $2}'|wc -l`
    if [ $pro -gt 2 ];
    then
        echo "`date  '+%Y-%m-%d %H:%M:%S'` The script is already running, and automatically exits"
        exit 0
    else
      while true; do
        baktmp=`date -d $baktime +%s`
        nowtmp=`date +%s`
        if [ $baktmp -gt $nowtmp ];then
            TIME=$(($baktmp-$nowtmp))
            sleep ${TIME}
            dbbak
            dbrebak
        elif [ $baktmp -eq $nowtmp ];then
            dbbak
            dbrebak
        else
            TIME=$(($baktmp-$nowtmp+86400))
            sleep ${TIME}
            dbbak
            dbrebak
        fi
      done
    fi
else
    pro=`ps -ef | grep db_backup | grep -v grep | awk '{print $2}'|wc -l`
    if [ $pro -gt 2 ];
    then
        echo "`date  '+%Y-%m-%d %H:%M:%S'` The script is already running, and automatically exits"
        exit 0
    else
        dbbak
        dbrebak
    fi
fi