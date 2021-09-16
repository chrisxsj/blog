mount: wrong fs type, bad option

[root@OABACK ~]# mount -a
mount: wrong fs type, bad option, bad superblock on /dev/sdb1,
       missing codepage or helper program, or other error
       In some cases useful info is found in syslog - try
       dmesg | tail  or so
[root@OABACK ~]#
You have mail in /var/spool/mail/root
[root@OABACK ~]#
[root@OABACK ~]# fsck -y /dev/sdb
sdb   sdb1  
[root@OABACK ~]# fsck -y /dev/sdb
sdb   sdb1  
[root@OABACK ~]# fsck -y /dev/sdb1
fsck from util-linux-ng 2.17.2
e2fsck 1.41.12 (17-May-2010)
Superblock last mount time (Fri Oct 19 11:17:09 2018,
    now = Sun Jan  6 08:52:56 2013) is in the future.
Fix? yes
Superblock last write time (Fri Oct 19 11:22:51 2018,
    now = Sun Jan  6 08:52:56 2013) is in the future.
Fix? yes
/dev/sdb1 has filesystem last checked time in the future, check forced.
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/sdb1: ***** FILE SYSTEM WAS MODIFIED *****
/dev/sdb1: 1513/13107200 files (22.7% non-contiguous), 40417250/52428119 blocks
[root@OABACK ~]#