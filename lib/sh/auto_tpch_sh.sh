generate_tbl_data(){
	cd /home/gpadmin/tpch_liz/gp_tpch-master
	make
	./dbgen -h
	./dbgen -s 1 -f
	ls -h *.tbl
}

generate_csv_data(){
	#cd /home/gpadmin/tpch_liz/gp_tpch-master
	for i in `ls *.tbl`; do sed 's/|$//' $i > ${i/tbl/csv}; done
	ls -rth *.csv
}

soft_link(){
	ln -s `pwd` /tmp/dss-data
}

generate_sql_files(){
	#cd /home/gpadmin/tpch_liz/gp_tpch-master
	SF=1
	mkdir dss/queries	
	for q in `seq 1 22`
	do
		DSS_QUERY=dss/templates ./qgen -s $SF $q > dss/queries/$q.sql
		sed 's/^select/explain select/' dss/queries/$q.sql > dss/queries/$q.explain.sql
	done
}

create_gp_db(){
	psql postgres -c "create user hgtpch superuser password 'hgtpch';"
	psql postgres -c "create database hgtpch owner hgtpch;"
}

gp_config(){
	gpconfig -c enable_nestloop -v off
	gpconfig -c work_mem -v 256MB
	gpstop -u
}

execute_tpchsh(){
	cd /home/gpadmin/tpch_liz/gp_tpch-master
	chmod +x tpch.sh
	./tpch.sh ./results 192.168.100.124 5438 hgtpch hgtpch "" row
}

#main入口函数
main_tpch(){
	generate_tbl_data
	generate_csv_data
	soft_link
	generate_sql_files
	create_gp_db
	gp_config
	execute_tpchsh
	cd /home/gpadmin/tpch_liz/gp_tpch-master/results
	tail -f bench.log
}

main_tpch