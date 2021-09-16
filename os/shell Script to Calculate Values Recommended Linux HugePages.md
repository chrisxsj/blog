Oracle Linux: Shell Script to Calculate Values Recommended Linux HugePages / HugeTLB Configuration (Doc ID 401749.1)


In this Document
 
Purpose
Requirements
Configuring
Instructions
Script
Sample Output
References
 
Applies to:
Oracle Database Cloud Schema Service - Version N/A and later
Oracle Database Exadata Cloud Machine - Version N/A and later
Oracle Cloud Infrastructure - Database Service - Version N/A and later
Oracle Database Cloud Exadata Service - Version N/A and later
Oracle Database Backup Service - Version N/A and later
Generic Linux
Purpose
This script is intended to compute values for the recommended HugePages/HugeTLB configuration for the current shared memory segments on Oracle Linux systems.
 
It does calculation for all shared memory segments available when the script is run, no matter it is an Oracle RDBMS shared memory segment or not.
 
For general information about HugePages / HugeTLB, please see Note 361323.1
 
Requirements
	* 
Oracle Database instance(s) are up and running
	* 
Oracle Database 11g Automatic Memory Management (AMM) is not setup  (See Note 749851.1)
	* 
The shared memory segments can be listed by command "ipcs -m"
	* 
Oracle Linux
	* 
Package 'bc' installed


Configuring
	1. 
Create a text file named hugepages_settings.sh
	2. 
Copy the contents below in the file
	3. 
Run:
$ chmod +x hugepages_settings.sh


Instructions
	1. 
Be sure that all applications that are meant to use HugePage / HugeTLB are running at the time the script is to be run. This includes the Oracle RDBMS instances and ASM instances in addition to other applications.
	2. 
Be sure that you have /bin and /usr/bin in $PATH
	3. 
Run:
$ ./hugepages_settings.sh


Caution
This sample code is provided for educational purposes only, and is not supported by Oracle Support. It has been tested internally, however, we do not guarantee that it will work for you. Ensure that you run it in your test environment before using.
Script
#!/bin/bash
#
# hugepages_settings.sh
#
# Linux bash script to compute values for the
# recommended HugePages/HugeTLB configuration
# on Oracle Linux
#
# Note: This script does calculation for all shared memory
# segments available when the script is run, no matter it
# is an Oracle RDBMS shared memory segment or not.
#
# This script is provided by Doc ID 401749.1 from My Oracle Support
# http://support.oracle.com
 
# Welcome text
echo "
This script is provided by Doc ID 401749.1 from My Oracle Support
(http://support.oracle.com) where it is intended to compute values for
the recommended HugePages/HugeTLB configuration for the current shared
memory segments on Oracle Linux. Before proceeding with the execution please note following:
 * For ASM instance, it needs to configure ASMM instead of AMM.
 * The 'pga_aggregate_target' is outside the SGA and
   you should accommodate this while calculating SGA size.
 * In case you changes the DB SGA size,
   as the new SGA will not fit in the previous HugePages configuration,
   it had better disable the whole HugePages,
   start the DB with new SGA size and run the script again.
And make sure that:
 * Oracle Database instance(s) are up and running
 * Oracle Database 11g Automatic Memory Management (AMM) is not setup
   (See Doc ID 749851.1)
 * The shared memory segments can be listed by command:
     # ipcs -m
 
 
Press Enter to proceed..."
 
read
 
# Check for the kernel version
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`
 
# Find out the HugePage size
HPG_SZ=`grep Hugepagesize /proc/meminfo | awk '{print $2}'`
if [ -z "$HPG_SZ" ];then
    echo "The hugepages may not be supported in the system where the script is being executed."
    exit 1
fi
 
# Initialize the counter
NUM_PG=0
 
# Cumulative number of pages required to handle the running shared memory segments
for SEG_BYTES in `ipcs -m | cut -c44-300 | awk '{print $1}' | grep "[0-9][0-9]*"`
do
    MIN_PG=`echo "$SEG_BYTES/($HPG_SZ*1024)" | bc -q`
    if [ $MIN_PG -gt 0 ]; then
        NUM_PG=`echo "$NUM_PG+$MIN_PG+1" | bc -q`
    fi
done
 
RES_BYTES=`echo "$NUM_PG * $HPG_SZ * 1024" | bc -q`
 
# An SGA less than 100MB does not make sense
# Bail out if that is the case
if [ $RES_BYTES -lt 100000000 ]; then
    echo "***********"
    echo "** ERROR **"
    echo "***********"
    echo "Sorry! There are not enough total of shared memory segments allocated for
HugePages configuration. HugePages can only be used for shared memory segments
that you can list by command:
 
    # ipcs -m
 
of a size that can match an Oracle Database SGA. Please make sure that:
 * Oracle Database instance is up and running
 * Oracle Database 11g Automatic Memory Management (AMM) is not configured"
    exit 1
fi
 
# Finish with results
case $KERN in
    '2.4') HUGETLB_POOL=`echo "$NUM_PG*$HPG_SZ/1024" | bc -q`;
           echo "Recommended setting: vm.hugetlb_pool = $HUGETLB_POOL" ;;
    '2.6') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    '3.8') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    '3.10') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    '4.1') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    '4.14') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    *) echo "Kernel version $KERN is not supported by this script (yet). Exiting." ;;
esac
 
# End
Sample Output
For 2.4 kernel systems:
$ ./hugepages_settings.sh
...
Recommended setting: vm.hugetlb_pool = 764
For 2.6 and later kernel systems:
$ ./hugepages_settings.sh
...
Recommended setting: vm.nr_hugepages = 67
Please see Document 361323.1 about how to do that setting.
References
NOTE:361323.1 - HugePages on Linux: What It Is... and What It Is Not...
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=358936728488316&id=401749.1&_adf.ctrl-state=4wjl154pq_114>
 