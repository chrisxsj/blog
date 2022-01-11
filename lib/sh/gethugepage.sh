# !/bin/bash
# author，chrisx
# date，2021-05-13
# usage，Start the database before executing this script
pid=`head -1 $PGDATA/postmaster.pid`
echo "Pid:            $pid"
#peak=`grep ^VmPeak /proc/$pid/status | awk '{ print $2 }'`
peak=`pmap $pid | awk '/rw-s/ && /zero/ {print $2}'`
peaks=`echo ${peak%?}`
echo "VmPeak:            $peaks"
hps=`grep ^Hugepagesize /proc/meminfo | awk '{ print $2 }'`
echo "Hugepagesize:   $hps kB"
hp=$((peaks/hps))
echo Set Huge Pages:     $hp