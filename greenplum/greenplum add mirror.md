https://yq.aliyun.com/articles/695864
 
[gpadmin@ps1 ~]$ gpstate -p
20190419:11:03:06:124470 gpstate:ps1:gpadmin-[INFO]:-Starting gpstate with args: -p
20190419:11:03:06:124470 gpstate:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190419:11:03:06:124470 gpstate:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:--Master segment instance  /home/gpadmin/hgdata/master/hgdw-1  port = 15432
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:--Segment instance port assignments
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-----------------------------------
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   Host   Datadir                              Port
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps1    /home/gpadmin/hgdata/primary/hgdw0   25432
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps1    /home/gpadmin/hgdata/primary/hgdw1   25433
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps1    /home/gpadmin/hgdata/primary/hgdw2   25434
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps1    /home/gpadmin/hgdata/primary/hgdw3   25435
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps1    /home/gpadmin/hgdata/primary/hgdw4   25436
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps2    /home/gpadmin/hgdata/primary/hgdw5   25432
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps2    /home/gpadmin/hgdata/primary/hgdw6   25433
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps2    /home/gpadmin/hgdata/primary/hgdw7   25434
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps2    /home/gpadmin/hgdata/primary/hgdw8   25435
20190419:11:03:07:124470 gpstate:ps1:gpadmin-[INFO]:-   ps2    /home/gpadmin/hgdata/primary/hgdw9   25436
[gpadmin@ps1 ~]$
 
 
 
[gpadmin@ps1 ~]$ gpssh -h ps1 -h ps2 -e 'mkdir -p /home/gpadmin/mirror'
[ps2] mkdir -p /home/gpadmin/mirror
[ps1] mkdir -p /home/gpadmin/mirror
[gpadmin@ps1 ~]$
 
 
 
gpaddmirrors -o ./addmirror
 
[gpadmin@ps1 ~]$ gpaddmirrors -o ./addmirror
20190419:11:04:55:124622 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting gpaddmirrors with args: -o ./addmirror
20190419:11:04:55:124622 gpaddmirrors:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190419:11:04:55:124622 gpaddmirrors:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190419:11:04:55:124622 gpaddmirrors:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190419:11:04:56:124622 gpaddmirrors:ps1:gpadmin-[INFO]:-Heap checksum setting consistent across cluster
Enter mirror segment data directory location 1 of 5 >
/home/gpadmin/mirror
Enter mirror segment data directory location 2 of 5 >
/home/gpadmin/mirror
Enter mirror segment data directory location 3 of 5 >
/home/gpadmin/mirror
Enter mirror segment data directory location 4 of 5 >
/home/gpadmin/mirror
Enter mirror segment data directory location 5 of 5 >
/home/gpadmin/mirror
20190419:11:06:22:124622 gpaddmirrors:ps1:gpadmin-[INFO]:-Configuration file output to ./addmirror successfully.


[gpadmin@ps1 ~]$ cat addmirror
filespaceOrder=
mirror0=0:ps2:26432:27432:28432:/home/gpadmin/mirror/hgdw0
mirror1=1:ps2:26433:27433:28433:/home/gpadmin/mirror/hgdw1
mirror2=2:ps2:26434:27434:28434:/home/gpadmin/mirror/hgdw2
mirror3=3:ps2:26435:27435:28435:/home/gpadmin/mirror/hgdw3
mirror4=4:ps2:26436:27436:28436:/home/gpadmin/mirror/hgdw4
mirror5=5:ps1:26432:27432:28432:/home/gpadmin/mirror/hgdw5
mirror6=6:ps1:26433:27433:28433:/home/gpadmin/mirror/hgdw6
mirror7=7:ps1:26434:27434:28434:/home/gpadmin/mirror/hgdw7
mirror8=8:ps1:26435:27435:28435:/home/gpadmin/mirror/hgdw8
mirror9=9:ps1:26436:27436:28436:/home/gpadmin/mirror/hgdw9
[gpadmin@ps1 ~]$
 
 
gpaddmirrors -i addmirror
 
[gpadmin@ps1 ~]$ gpaddmirrors -i addmirror
20190419:11:08:50:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting gpaddmirrors with args: -i addmirror
20190419:11:08:50:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190419:11:08:50:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190419:11:08:50:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Heap checksum setting consistent across cluster
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Greenplum Add Mirrors Parameters
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Greenplum master data directory          = /home/gpadmin/hgdata/master/hgdw-1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Greenplum master port                    = 15432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Parallel batch limit                     = 16
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 1 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw0
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw0
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 2 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 3 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 4 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw3
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw3
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 5 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw4
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw4
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 6 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw5
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw5
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27432
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 7 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw6
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw6
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27433
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 8 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw7
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw7
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27434
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 9 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw8
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw8
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27435
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror 10 of 10
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance host               = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance address            = ps2
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance directory          = /home/gpadmin/hgdata/primary/hgdw9
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance port               = 25436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Primary instance replication port   = 28436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance host                = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance address             = ps1
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance directory           = /home/gpadmin/mirror/hgdw9
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance port                = 26436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-   Mirror instance replication port    = 27436
20190419:11:08:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:----------------------------------------------------------
 
Continue with add mirrors procedure Yy|Nn (default=N):
> y
20190419:11:09:33:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-10 segment(s) to add
20190419:11:09:33:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Building template directory
20190419:11:09:35:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Validating remote directories
.
20190419:11:09:36:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Copying template directory file
.
20190419:11:09:37:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Configuring new segments
.
20190419:11:09:39:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Cleaning files
.
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps2:/home/gpadmin/mirror/hgdw0:content=0:dbid=13:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps2:/home/gpadmin/mirror/hgdw1:content=1:dbid=14:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps2:/home/gpadmin/mirror/hgdw2:content=2:dbid=15:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps2:/home/gpadmin/mirror/hgdw3:content=3:dbid=16:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps2:/home/gpadmin/mirror/hgdw4:content=4:dbid=17:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps1:/home/gpadmin/mirror/hgdw5:content=5:dbid=18:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps1:/home/gpadmin/mirror/hgdw6:content=6:dbid=19:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps1:/home/gpadmin/mirror/hgdw7:content=7:dbid=20:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps1:/home/gpadmin/mirror/hgdw8:content=8:dbid=21:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting file move procedure for ps1:/home/gpadmin/mirror/hgdw9:content=9:dbid=22:mode=r:status=u
20190419:11:09:40:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Updating configuration with new mirrors
20190419:11:09:41:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Updating mirrors
.
20190419:11:09:42:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Starting mirrors
20190419:11:09:42:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-era is 78cdf816ba933af5_190418102427
20190419:11:09:42:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
..
20190419:11:09:44:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Process results...
20190419:11:09:44:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Updating configuration to mark mirrors up
20190419:11:09:44:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Updating primaries
20190419:11:09:44:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Commencing parallel primary conversion of 10 segments, please wait...
.......................................................................................................................................................................................................................................................
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Process results...
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[WARNING]:-Failed to inform primary segment of updated mirroring state.  Segment: ps2:/home/gpadmin/hgdata/primary/hgdw5:content=5:dbid=7:mode=r:status=u: REASON: cmd had rc=255 completed=True halted=False
  stdout='20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Starting gpsegtoprimaryormirror.py with args: -D /home/gpadmin/hgdata/primary/hgdw5:25432 -D /home/gpadmin/hgdata/primary/hgdw6:25433 -D /home/gpadmin/hgdata/primary/hgdw7:25434 -D /home/gpadmin/hgdata/primary/hgdw8:25435 -D /home/gpadmin/hgdata/primary/hgdw9:25436 -C en_US.utf8:en_US.utf8:en_US.utf8 -M primary -p KGRwMApTJ2Ric0J5UG9ydCcKcDEKKGRwMgpJMjU0MzIKKGRwMwpTJ3RhcmdldE1vZGUnCnA0ClMncHJpbWFyeScKcDUKc1MnZGJpZCcKcDYKSTcKc1MnaG9zdE5hbWUnCnA3ClMncHMyJwpwOApzUydwZWVyUG9ydCcKcDkKSTI3NDMyCnNTJ3BlZXJQTVBvcnQnCnAxMApJMjY0MzIKc1MncGVlck5hbWUnCnAxMQpTJ3BzMScKcDEyCnNTJ2Z1bGxSZXN5bmNGbGFnJwpwMTMKSTAxCnNTJ21vZGUnCnAxNApTJ3InCnAxNQpzUydob3N0UG9ydCcKcDE2CkkyODQzMgpzc0kyNTQzMwooZHAxNwpnNApnNQpzZzYKSTgKc2c3ClMncHMyJwpwMTgKc2c5CkkyNzQzMwpzZzEwCkkyNjQzMwpzZzExClMncHMxJwpwMTkKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzMKc3NJMjU0MzQKKGRwMjAKZzQKZzUKc2c2Ckk5CnNnNwpTJ3BzMicKcDIxCnNnOQpJMjc0MzQKc2cxMApJMjY0MzQKc2cxMQpTJ3BzMScKcDIyCnNnMTMKSTAxCnNnMTQKZzE1CnNnMTYKSTI4NDM0CnNzSTI1NDM1CihkcDIzCmc0Cmc1CnNnNgpJMTAKc2c3ClMncHMyJwpwMjQKc2c5CkkyNzQzNQpzZzEwCkkyNjQzNQpzZzExClMncHMxJwpwMjUKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzUKc3NJMjU0MzYKKGRwMjYKZzQKZzUKc2c2CkkxMQpzZzcKUydwczInCnAyNwpzZzkKSTI3NDM2CnNnMTAKSTI2NDM2CnNnMTEKUydwczEnCnAyOApzZzEzCkkwMQpzZzE0CmcxNQpzZzE2CkkyODQzNgpzc3Mu -V postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4
20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Changing segments...
20190419:11:10:14:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-
COMMAND RESULTS
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw7--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw6--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw5--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw9--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw8--MODIFIED:True--REASON:Conversion Succeeded
 
'
  stderr='Timeout, server ps2 not responding.
'
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[WARNING]:-Failed to inform primary segment of updated mirroring state.  Segment: ps2:/home/gpadmin/hgdata/primary/hgdw6:content=6:dbid=8:mode=r:status=u: REASON: cmd had rc=255 completed=True halted=False
  stdout='20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Starting gpsegtoprimaryormirror.py with args: -D /home/gpadmin/hgdata/primary/hgdw5:25432 -D /home/gpadmin/hgdata/primary/hgdw6:25433 -D /home/gpadmin/hgdata/primary/hgdw7:25434 -D /home/gpadmin/hgdata/primary/hgdw8:25435 -D /home/gpadmin/hgdata/primary/hgdw9:25436 -C en_US.utf8:en_US.utf8:en_US.utf8 -M primary -p KGRwMApTJ2Ric0J5UG9ydCcKcDEKKGRwMgpJMjU0MzIKKGRwMwpTJ3RhcmdldE1vZGUnCnA0ClMncHJpbWFyeScKcDUKc1MnZGJpZCcKcDYKSTcKc1MnaG9zdE5hbWUnCnA3ClMncHMyJwpwOApzUydwZWVyUG9ydCcKcDkKSTI3NDMyCnNTJ3BlZXJQTVBvcnQnCnAxMApJMjY0MzIKc1MncGVlck5hbWUnCnAxMQpTJ3BzMScKcDEyCnNTJ2Z1bGxSZXN5bmNGbGFnJwpwMTMKSTAxCnNTJ21vZGUnCnAxNApTJ3InCnAxNQpzUydob3N0UG9ydCcKcDE2CkkyODQzMgpzc0kyNTQzMwooZHAxNwpnNApnNQpzZzYKSTgKc2c3ClMncHMyJwpwMTgKc2c5CkkyNzQzMwpzZzEwCkkyNjQzMwpzZzExClMncHMxJwpwMTkKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzMKc3NJMjU0MzQKKGRwMjAKZzQKZzUKc2c2Ckk5CnNnNwpTJ3BzMicKcDIxCnNnOQpJMjc0MzQKc2cxMApJMjY0MzQKc2cxMQpTJ3BzMScKcDIyCnNnMTMKSTAxCnNnMTQKZzE1CnNnMTYKSTI4NDM0CnNzSTI1NDM1CihkcDIzCmc0Cmc1CnNnNgpJMTAKc2c3ClMncHMyJwpwMjQKc2c5CkkyNzQzNQpzZzEwCkkyNjQzNQpzZzExClMncHMxJwpwMjUKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzUKc3NJMjU0MzYKKGRwMjYKZzQKZzUKc2c2CkkxMQpzZzcKUydwczInCnAyNwpzZzkKSTI3NDM2CnNnMTAKSTI2NDM2CnNnMTEKUydwczEnCnAyOApzZzEzCkkwMQpzZzE0CmcxNQpzZzE2CkkyODQzNgpzc3Mu -V postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4
20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Changing segments...
20190419:11:10:14:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-
COMMAND RESULTS
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw7--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw6--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw5--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw9--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw8--MODIFIED:True--REASON:Conversion Succeeded
 
'
  stderr='Timeout, server ps2 not responding.
'
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[WARNING]:-Failed to inform primary segment of updated mirroring state.  Segment: ps2:/home/gpadmin/hgdata/primary/hgdw7:content=7:dbid=9:mode=r:status=u: REASON: cmd had rc=255 completed=True halted=False
  stdout='20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Starting gpsegtoprimaryormirror.py with args: -D /home/gpadmin/hgdata/primary/hgdw5:25432 -D /home/gpadmin/hgdata/primary/hgdw6:25433 -D /home/gpadmin/hgdata/primary/hgdw7:25434 -D /home/gpadmin/hgdata/primary/hgdw8:25435 -D /home/gpadmin/hgdata/primary/hgdw9:25436 -C en_US.utf8:en_US.utf8:en_US.utf8 -M primary -p KGRwMApTJ2Ric0J5UG9ydCcKcDEKKGRwMgpJMjU0MzIKKGRwMwpTJ3RhcmdldE1vZGUnCnA0ClMncHJpbWFyeScKcDUKc1MnZGJpZCcKcDYKSTcKc1MnaG9zdE5hbWUnCnA3ClMncHMyJwpwOApzUydwZWVyUG9ydCcKcDkKSTI3NDMyCnNTJ3BlZXJQTVBvcnQnCnAxMApJMjY0MzIKc1MncGVlck5hbWUnCnAxMQpTJ3BzMScKcDEyCnNTJ2Z1bGxSZXN5bmNGbGFnJwpwMTMKSTAxCnNTJ21vZGUnCnAxNApTJ3InCnAxNQpzUydob3N0UG9ydCcKcDE2CkkyODQzMgpzc0kyNTQzMwooZHAxNwpnNApnNQpzZzYKSTgKc2c3ClMncHMyJwpwMTgKc2c5CkkyNzQzMwpzZzEwCkkyNjQzMwpzZzExClMncHMxJwpwMTkKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzMKc3NJMjU0MzQKKGRwMjAKZzQKZzUKc2c2Ckk5CnNnNwpTJ3BzMicKcDIxCnNnOQpJMjc0MzQKc2cxMApJMjY0MzQKc2cxMQpTJ3BzMScKcDIyCnNnMTMKSTAxCnNnMTQKZzE1CnNnMTYKSTI4NDM0CnNzSTI1NDM1CihkcDIzCmc0Cmc1CnNnNgpJMTAKc2c3ClMncHMyJwpwMjQKc2c5CkkyNzQzNQpzZzEwCkkyNjQzNQpzZzExClMncHMxJwpwMjUKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzUKc3NJMjU0MzYKKGRwMjYKZzQKZzUKc2c2CkkxMQpzZzcKUydwczInCnAyNwpzZzkKSTI3NDM2CnNnMTAKSTI2NDM2CnNnMTEKUydwczEnCnAyOApzZzEzCkkwMQpzZzE0CmcxNQpzZzE2CkkyODQzNgpzc3Mu -V postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4
20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Changing segments...
20190419:11:10:14:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-
COMMAND RESULTS
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw7--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw6--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw5--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw9--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw8--MODIFIED:True--REASON:Conversion Succeeded
 
'
  stderr='Timeout, server ps2 not responding.
'
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[WARNING]:-Failed to inform primary segment of updated mirroring state.  Segment: ps2:/home/gpadmin/hgdata/primary/hgdw8:content=8:dbid=10:mode=r:status=u: REASON: cmd had rc=255 completed=True halted=False
  stdout='20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Starting gpsegtoprimaryormirror.py with args: -D /home/gpadmin/hgdata/primary/hgdw5:25432 -D /home/gpadmin/hgdata/primary/hgdw6:25433 -D /home/gpadmin/hgdata/primary/hgdw7:25434 -D /home/gpadmin/hgdata/primary/hgdw8:25435 -D /home/gpadmin/hgdata/primary/hgdw9:25436 -C en_US.utf8:en_US.utf8:en_US.utf8 -M primary -p KGRwMApTJ2Ric0J5UG9ydCcKcDEKKGRwMgpJMjU0MzIKKGRwMwpTJ3RhcmdldE1vZGUnCnA0ClMncHJpbWFyeScKcDUKc1MnZGJpZCcKcDYKSTcKc1MnaG9zdE5hbWUnCnA3ClMncHMyJwpwOApzUydwZWVyUG9ydCcKcDkKSTI3NDMyCnNTJ3BlZXJQTVBvcnQnCnAxMApJMjY0MzIKc1MncGVlck5hbWUnCnAxMQpTJ3BzMScKcDEyCnNTJ2Z1bGxSZXN5bmNGbGFnJwpwMTMKSTAxCnNTJ21vZGUnCnAxNApTJ3InCnAxNQpzUydob3N0UG9ydCcKcDE2CkkyODQzMgpzc0kyNTQzMwooZHAxNwpnNApnNQpzZzYKSTgKc2c3ClMncHMyJwpwMTgKc2c5CkkyNzQzMwpzZzEwCkkyNjQzMwpzZzExClMncHMxJwpwMTkKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzMKc3NJMjU0MzQKKGRwMjAKZzQKZzUKc2c2Ckk5CnNnNwpTJ3BzMicKcDIxCnNnOQpJMjc0MzQKc2cxMApJMjY0MzQKc2cxMQpTJ3BzMScKcDIyCnNnMTMKSTAxCnNnMTQKZzE1CnNnMTYKSTI4NDM0CnNzSTI1NDM1CihkcDIzCmc0Cmc1CnNnNgpJMTAKc2c3ClMncHMyJwpwMjQKc2c5CkkyNzQzNQpzZzEwCkkyNjQzNQpzZzExClMncHMxJwpwMjUKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzUKc3NJMjU0MzYKKGRwMjYKZzQKZzUKc2c2CkkxMQpzZzcKUydwczInCnAyNwpzZzkKSTI3NDM2CnNnMTAKSTI2NDM2CnNnMTEKUydwczEnCnAyOApzZzEzCkkwMQpzZzE0CmcxNQpzZzE2CkkyODQzNgpzc3Mu -V postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4
20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Changing segments...
20190419:11:10:14:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-
COMMAND RESULTS
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw7--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw6--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw5--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw9--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw8--MODIFIED:True--REASON:Conversion Succeeded
 
'
  stderr='Timeout, server ps2 not responding.
'
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[WARNING]:-Failed to inform primary segment of updated mirroring state.  Segment: ps2:/home/gpadmin/hgdata/primary/hgdw9:content=9:dbid=11:mode=r:status=u: REASON: cmd had rc=255 completed=True halted=False
  stdout='20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Starting gpsegtoprimaryormirror.py with args: -D /home/gpadmin/hgdata/primary/hgdw5:25432 -D /home/gpadmin/hgdata/primary/hgdw6:25433 -D /home/gpadmin/hgdata/primary/hgdw7:25434 -D /home/gpadmin/hgdata/primary/hgdw8:25435 -D /home/gpadmin/hgdata/primary/hgdw9:25436 -C en_US.utf8:en_US.utf8:en_US.utf8 -M primary -p KGRwMApTJ2Ric0J5UG9ydCcKcDEKKGRwMgpJMjU0MzIKKGRwMwpTJ3RhcmdldE1vZGUnCnA0ClMncHJpbWFyeScKcDUKc1MnZGJpZCcKcDYKSTcKc1MnaG9zdE5hbWUnCnA3ClMncHMyJwpwOApzUydwZWVyUG9ydCcKcDkKSTI3NDMyCnNTJ3BlZXJQTVBvcnQnCnAxMApJMjY0MzIKc1MncGVlck5hbWUnCnAxMQpTJ3BzMScKcDEyCnNTJ2Z1bGxSZXN5bmNGbGFnJwpwMTMKSTAxCnNTJ21vZGUnCnAxNApTJ3InCnAxNQpzUydob3N0UG9ydCcKcDE2CkkyODQzMgpzc0kyNTQzMwooZHAxNwpnNApnNQpzZzYKSTgKc2c3ClMncHMyJwpwMTgKc2c5CkkyNzQzMwpzZzEwCkkyNjQzMwpzZzExClMncHMxJwpwMTkKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzMKc3NJMjU0MzQKKGRwMjAKZzQKZzUKc2c2Ckk5CnNnNwpTJ3BzMicKcDIxCnNnOQpJMjc0MzQKc2cxMApJMjY0MzQKc2cxMQpTJ3BzMScKcDIyCnNnMTMKSTAxCnNnMTQKZzE1CnNnMTYKSTI4NDM0CnNzSTI1NDM1CihkcDIzCmc0Cmc1CnNnNgpJMTAKc2c3ClMncHMyJwpwMjQKc2c5CkkyNzQzNQpzZzEwCkkyNjQzNQpzZzExClMncHMxJwpwMjUKc2cxMwpJMDEKc2cxNApnMTUKc2cxNgpJMjg0MzUKc3NJMjU0MzYKKGRwMjYKZzQKZzUKc2c2CkkxMQpzZzcKUydwczInCnAyNwpzZzkKSTI3NDM2CnNnMTAKSTI2NDM2CnNnMTEKUydwczEnCnAyOApzZzEzCkkwMQpzZzE0CmcxNQpzZzE2CkkyODQzNgpzc3Mu -V postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4
20190419:11:10:08:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-Changing segments...
20190419:11:10:14:080241 gpsegtoprimaryormirror.py_ps2:gpadmin:ps2:gpadmin-[INFO]:-
COMMAND RESULTS
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw7--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw6--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw5--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw9--MODIFIED:True--REASON:Conversion Succeeded
STATUS--DIR:/home/gpadmin/hgdata/primary/hgdw8--MODIFIED:True--REASON:Conversion Succeeded
 
'
  stderr='Timeout, server ps2 not responding.
'
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Done updating primaries
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-******************************************************************
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Mirror segments have been added; data synchronization is in progress.
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Data synchronization will continue in the background.
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-Use  gpstate -s  to check the resynchronization progress.
20190419:11:13:51:125086 gpaddmirrors:ps1:gpadmin-[INFO]:-******************************************************************
[gpadmin@ps1 ~]$
 
[gpadmin@ps1 ~]$ gpstate -c
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-Starting gpstate with args: -c
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4'
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.3.23 (Greenplum Database 5.10.2 build commit:b3c02f3acd880e2d676dacea36be015e4a3826d4) on x86_64-pc-linux-gnu, compiled by GCC gcc (GCC) 6.2.0, 64-bit compiled on Aug 10 2018 07:30:09'
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-Obtaining Segment details from master...
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:--Current GPDB mirror list and status
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:--Type = Group
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Status                             Data State        Primary   Datadir                              Port    Mirror   Datadir                      Port
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps1       /home/gpadmin/hgdata/primary/hgdw0   25432   ps2      /home/gpadmin/mirror/hgdw0   26432
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps1       /home/gpadmin/hgdata/primary/hgdw1   25433   ps2      /home/gpadmin/mirror/hgdw1   26433
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps1       /home/gpadmin/hgdata/primary/hgdw2   25434   ps2      /home/gpadmin/mirror/hgdw2   26434
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps1       /home/gpadmin/hgdata/primary/hgdw3   25435   ps2      /home/gpadmin/mirror/hgdw3   26435
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps1       /home/gpadmin/hgdata/primary/hgdw4   25436   ps2      /home/gpadmin/mirror/hgdw4   26436
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps2       /home/gpadmin/hgdata/primary/hgdw5   25432   ps1      /home/gpadmin/mirror/hgdw5   26432
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps2       /home/gpadmin/hgdata/primary/hgdw6   25433   ps1      /home/gpadmin/mirror/hgdw6   26433
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps2       /home/gpadmin/hgdata/primary/hgdw7   25434   ps1      /home/gpadmin/mirror/hgdw7   26434
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps2       /home/gpadmin/hgdata/primary/hgdw8   25435   ps1      /home/gpadmin/mirror/hgdw8   26435
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:-   Primary Active, Mirror Available   Resynchronizing   ps2       /home/gpadmin/hgdata/primary/hgdw9   25436   ps1      /home/gpadmin/mirror/hgdw9   26436
20190419:11:16:16:126725 gpstate:ps1:gpadmin-[INFO]:--------------------------------------------------------------
[gpadmin@ps1 ~]$