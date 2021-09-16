#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
######################################
# introduction, whether the database is the recovery mode
######################################
#
function pg_is_in_recovery() {
    recovery=$(psql --pset=pager=off -At -c 'select pg_is_in_recovery()')
    if [ $recovery"x" = "f""x" ] ;then
	    echo "`date`	Database is not in recovering,so can be backup now."
    else
	    echo "`date`	Database is in recovering ,backup failed,the shell will exit now."
	    exit 5
    fi
}

#
function log_directory() {
    log=$(psql --pset=pager=off -At -c 'show log_directory')
    echo "`date`	Database log directory is $log"
}