#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
######################################
# introduction, 各种判断函数
######################################

# whether host user is root
function whether_root() {
	user=$(env | grep USER | cut -d "=" -f 2)
	if [ "$user" == "root" ]
	  then
	  	echo "`date`	current user is $user,you should switch user,job will exit."
		exit 5
		else
	    echo "`date`	current user is $user,you can run script"
	fi
}
#################################################
# whether dir exist
function whether_dir() {
	dir=$PGDATA
	if [ -d $dir ] ;then
	echo "`date`	the current node have pg database,data directory is $dir,"
	else
	echo "`date`	the current node have not pg database,job will exit."
	exit 10		
	fi
}
