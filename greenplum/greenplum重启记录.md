gp重启


gp关闭
[dgadmin@hgdb-master-26 pg_log]$ gpstop -M fast
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Starting gpstop with args: -M fast
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Gathering information and validating the environment...
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Obtaining Greenplum Master catalog information
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 5.17.0+3fab7bf build ga'
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:---------------------------------------------
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Master instance parameters
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:---------------------------------------------
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Master Greenplum instance process active PID   = 12794
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Database                                       = template1
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Master port                                    = 5432
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Master directory                               = /data/db/dgdata/master/hgseg-1
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Shutdown mode                                  = fast
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Timeout                                        = 120
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Shutdown Master standby host                   = On
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:---------------------------------------------
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Segment instances that will be shutdown:
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:---------------------------------------------
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Host           Datadir                          Port    Status
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-22   /data/db/dgdata/primary/hgseg0   40000   u
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-23   /data/db/dgdata/mirror/hgseg0    50000   u
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-23   /data/db/dgdata/primary/hgseg1   40000   u
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-24   /data/db/dgdata/mirror/hgseg1    50000   u
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-24   /data/db/dgdata/primary/hgseg2   40000   u
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-25   /data/db/dgdata/mirror/hgseg2    50000   u
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-25   /data/db/dgdata/primary/hgseg3   40000   u
20200203:12:53:13:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-22   /data/db/dgdata/mirror/hgseg3    50000   u
 
Continue with Greenplum instance shutdown Yy|Nn (default=N):
> y
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-There are 256 connections to the database
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Commencing Master instance shutdown with mode='fast'
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Master host=hgdb-master-26
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Detected 256 connections to database
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Switching to WAIT mode
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Will wait for shutdown to complete, this may take some time if
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-there are a large number of active complex transactions, please wait...
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Commencing Master instance shutdown with mode=fast
20200203:12:53:26:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Master segment instance directory=/data/db/dgdata/master/hgseg-1
20200203:12:53:29:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Attempting forceful termination of any leftover master process
20200203:12:53:29:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Terminating processes for segment /data/db/dgdata/master/hgseg-1
20200203:12:53:29:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Stopping master standby host hgdb-secondary-27 mode=fast
20200203:12:53:30:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Successfully shutdown standby process on hgdb-secondary-27
20200203:12:53:30:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Targeting dbid [2, 6, 3, 7, 4, 8, 5, 9] for shutdown
20200203:12:53:31:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Commencing parallel primary segment instance shutdown, please wait...
20200203:12:53:31:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-0.00% of jobs completed
20200203:12:53:39:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-100.00% of jobs completed
20200203:12:53:39:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Commencing parallel mirror segment instance shutdown, please wait...
20200203:12:53:39:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-0.00% of jobs completed
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-100.00% of jobs completed
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Segments stopped successfully      = 8
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-   Segments with errors during stop   = 0
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Successfully shutdown 8 of 8 segment instances
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Database successfully shutdown with no errors reported
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Cleaning up leftover gpmmon process
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-No leftover gpmmon process found
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Cleaning up leftover gpsmon processes
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-No leftover gpsmon processes on some hosts. not attempting forceful termination on these hosts
20200203:12:53:41:006536 gpstop:hgdb-master-26:dgadmin-[INFO]:-Cleaning up leftover shared memory
 
 
gp启动
[dgadmin@hgdb-master-26 pg_log]$ gpstart
20200203:12:53:50:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Starting gpstart with args:
20200203:12:53:50:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Gathering information and validating the environment...
20200203:12:53:50:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Greenplum Binary Version: 'postgres (Greenplum Database) 5.17.0+3fab7bf build ga'
20200203:12:53:50:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Greenplum Catalog Version: '301705051'
20200203:12:53:50:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Starting Master instance in admin mode
20200203:12:53:52:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Obtaining Greenplum Master catalog information
20200203:12:53:52:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Obtaining Segment details from master...
20200203:12:53:53:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Setting new master era
20200203:12:53:53:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Master Started...
20200203:12:53:53:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Shutting down master
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:---------------------------
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Master instance parameters
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:---------------------------
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Database                 = template1
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Master Port              = 5432
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Master directory         = /data/db/dgdata/master/hgseg-1
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Timeout                  = 600 seconds
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Master standby start     = On
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:---------------------------------------
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Segment instances that will be started
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:---------------------------------------
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   Host           Datadir                          Port    Role
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-22   /data/db/dgdata/primary/hgseg0   40000   Primary
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-23   /data/db/dgdata/mirror/hgseg0    50000   Mirror
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-23   /data/db/dgdata/primary/hgseg1   40000   Primary
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-24   /data/db/dgdata/mirror/hgseg1    50000   Mirror
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-24   /data/db/dgdata/primary/hgseg2   40000   Primary
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-25   /data/db/dgdata/mirror/hgseg2    50000   Mirror
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-25   /data/db/dgdata/primary/hgseg3   40000   Primary
20200203:12:53:54:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   hgdb-data-22   /data/db/dgdata/mirror/hgseg3    50000   Mirror
 
Continue with Greenplum instance startup Yy|Nn (default=N):
> y
20200203:12:54:00:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
....................................................................................................................
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Process results...
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   Successful segment starts                                            = 8
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   Failed segment starts                                                = 0
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-   Skipped segment starts (segments are marked down in configuration)   = 0
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Successfully started 8 of 8 segment instances
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-----------------------------------------------------
20200203:12:55:56:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Starting Master instance hgdb-master-26 directory /data/db/dgdata/master/hgseg-1
20200203:12:55:58:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Command pg_ctl reports Master hgdb-master-26 instance active
20200203:12:55:58:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Starting standby master
20200203:12:55:58:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Checking if standby master is running on host: hgdb-secondary-27  in directory: /data/db/dgdata/master/hgseg-1
20200203:12:56:00:006799 gpstart:hgdb-master-26:dgadmin-[INFO]:-Database successfully started
[dgadmin@hgdb-master-26 pg_log]$