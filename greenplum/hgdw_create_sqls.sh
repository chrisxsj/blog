# 依据一组csv文件批量生成sql
hgdw_srcipt_table () {
# gpfdist -d $GPHOME -p 5555  -l /tmp/gpfdist.log &
# localIp=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "add:"`
	sqldir=/home/hgadmin/gpfdist
	dir=`ls /home/hgadmin/gpfdist/bak`
	cd ~
    mkdir export_data
	echo -e "\\\\timing on" >> $sqldir/hgdw_table.sql
	echo -e "\\\\timing on" >> $sqldir/hgdw_external.sql
	echo -e "\\\\timing on" >> $sqldir/hgdw_insert.sql
	echo -e "\\\\timing on" >> $sqldir/hgdw_copy_from.sql
	echo -e "\\\\timing on" >> $sqldir/hgdw_copy_to.sql
    
	for i in $dir
        do
            str=`head -n +1 $sqldir/bak/$i`
            dd=$(echo $str | sed 's/\"//g')
            arr=(${dd//,/ })
            # arr=$(echo $dd |sed 's/,/ /g')
            num=${#arr[@]}
            res=""
            for j in "${!arr[@]}"
        #for((i=0;i<num;i++))
            do
                    ss=${arr[$j]}" VARCHAR, "
                    res=$res$ss
            done
            ww=${res%?}
            echo -e "CREATE TABLE ${i%.*} (${ww%?}) distributed by (ID);\n" >> $sqldir/hgdw_table.sql
            echo -e "CREATE EXTERNAL TABLE ext_${i%.*} (${ww%?}) LOCATION ('gpfdist://172.16.67.3:3500/testgplz/$i') format 'CSV' (HEADER) encoding 'GBK';\n" >> $sqldir/hgdw_external.sql
            echo -e "insert into ${i%.*} select * from ext_${i%.*};\n" >> $sqldir/hgdw_insert.sql
            echo -e "copy ${i%.*} from '$sqldir/bak/$i';\n" >> $sqldir/hgdw_copy_from.sql
			echo -e "copy (select * from  ${i%.*}) to '$sqldir/export_data/$i' with csv header  delimiter ',';\n" >> $sqldir/hgdw_copy_to.sql
            #以下^M需要的linux环境下替换，^M在Linux中命令行的输入方法是同时按下ctrl+v然后按下M
            sed -i 's/^M//g' $sqldir/hgdw_table.sql
            sed -i 's/^M//g' $sqldir/hgdw_external.sql
            sed -i 's/^M//g' $sqldir/hgdw_insert.sql

        done
}

#insert_data(){
#        psql highgodw -f $GPHOME/hgdw.sql
#        psql highgodw -f $GPHOME/hgdw_external.sql
#        psql highgodw -f $GPHOME/hgdw_insert.sql
#}
#
#backup(){
#	psql highgodw -f $GPHOME/hgdw_copy_to.sql
#}
#
#
#
#main_install(){
#	psql postgres -c "create user highgodw superuser password 'highgodw';"
#        psql postgres -c "create database highgodw owner highgodw;"
#        hgdw_srcipt_table
##        insert_data
##	backup
##	psql postgres -c "drop database highgodw;"
##	psql postgres -c "create database highgodw owner highgodw;"
##	insert_data
#}
#
#main_install

hgdw_srcipt_table 
