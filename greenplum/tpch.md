# gp_tpch

<!--
ref[TPC-H PostgreSQL benchmark](https://github.com/digoal/gp_tpch)

## Preparing dbgen and qgen

First, download the TPC-H benchmark from http://tpc.org/tpch/default.asp and extract it to a directory

$ wget http://tpc.org/tpch/spec/tpch_2_14_3.tgz
$ mkdir tpch
$ tar -xzf tpch_2_14_3.tgz -C tpch

and then prepare the Makefile - create a copy from makefile.suite

$ cd tpch/dbgen
$ cp makefile.suite Makefile
$ nano Makefile

and modify it so that it contains this (around line 110)

CC=gcc
DATABASE=ORACLE
MACHINE=LINUX
WORKLOAD=TPCH
and compile it using make as usual. Now you should have dbgen and qgen tools that generate data and queries.

-->

## Generating data
Right, so let's generate the data using the dbgen tool - there's one important parameter 'scale' that influences the amount of data. It's roughly equal to number of GB of raw data, so to generate 10GB of data just do

copy gp_tpch dir to big file system and then:  
$ ln -s `pwd` /tmp/dss-data
$ ./dbgen -s 10
which creates a bunch of .tbl files in Oracle-like CSV format

$ ls *.tbl
and to convert them to a CSV format compatible with PostgreSQL, do this

$ for i in `ls *.tbl`; do sed 's/|$//' $i > ${i/tbl/csv}; echo $i; done;
Finally, move these data to the 'dss/data' directory or somewhere else, and create a symlink to /tmp/dss-data (that's where tpch-load.sql is looking for for the data from).

It's a good idea to place this directory on a ramdrive so that it does not influence the benchmark (e.g. it's a very bad idea to place the data on the same drive as PostgreSQL data directory).

## Generating queries
Now we have to generate queries from templates specified in TPC-H benchmark. The templates provided at tpch.org are not suitable for PostgreSQL. So I have provided slightly modified queries in the 'dss/templates' directory and you should place the queries in 'dss/queries' dir.

use the correct SF when dbgen -s specified.

SF=?
mkdir dss/queries
for q in `seq 1 22`
do
    DSS_QUERY=dss/templates ./qgen -s $SF $q > dss/queries/$q.sql
    sed 's/^select/explain select/' dss/queries/$q.sql > dss/queries/$q.explain.sql
done
   NOTE: modify query's interval syntax. Now you should have 44 files in the dss/queries directory. 22 of them will actually run the queries and the other 22 will generate EXPLAIN plan of the query (without actually running it).

## Running the benchmark
The actual benchmark is implemented in the 'tpch.sh' script. It expects an already prepared database and four parameters - directory where to place the results, database and user name. So to run it, do this:

$ ./tpch.sh ./results ip port tpch-db tpch-user password {row|column|redshift|pg|pg10|citus}

Redshift (copy by ssh):
// add manifest file to s3 first
// manifest file must in $S3/${table}.manifest
$ ./tpch.sh ./results ip port tpch-db tpch-user password redshift S3 EC2_ID EC2_KEY
and wait until the benchmark. (pg 10: no indexes)

## Processing the results
All the results are written into the output directory (first parameter). To get useful results (timing of each query, various statistics), you can use script process.php. It expects two parameters - input dir (with data collected by the tpch.sh script) and output file (in CSV format). For example like this:

# yum install -y php
$ php process.php ./results output.csv
This should give you nicely formatted CSV file.



=====================
auto_tpch.sh

bindir=/data/gptpch/gp_tpch-master
datadir=/data/gptpch/tpchdata

generate_tbl_data(){
	cd $bindir
	make
	$bindir/dbgen -h
	$bindir/dbgen -s 1024 -f
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
	#cd $bindir 
	SF=1
	mkdir dss/queries	
	for q in `seq 1 22`
	do
		DSS_QUERY=dss/templates $bindir/qgen -s $SF $q > dss/queries/$q.sql
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
	cd /home/hgadmin/gptpch/gp_tpch-master
	chmod +x tpch.sh
	$bindir/tpch.sh $bindir/results 192.168.1.1 5433 hgtpch hgtpch "hgtpch" row
}

#main入口函数
main_tpch(){
	generate_tbl_data
	generate_csv_data
	soft_link
	generate_sql_files
#	create_gp_db
#	gp_config
#	execute_tpchsh
#	cd $bindir/results
#	tail -f bench.log
}

main_tpch
