ps -ef |grep 'LOCAL=NO' |awk '{print "kill -9 " $2}'



alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 172.17.200.4)(PORT = 1521))' sid='orcl2';
alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 172.17.200.3)(PORT = 1521))' sid='orcl1';

8.1.1 Preparing for a Role Transition
Before starting any role transition, perform the following preparations:

•Verify that each database is properly configured for the role that it is about to assume. See Chapter 3, "Creating a Physical Standby Database" and Chapter 4, "Creating a Logical Standby Database" for information about how to configure database initialization parameters, ARCHIVELOG mode, standby redo logs, and online redo logs on primary and standby databases.

Note:

You must define the LOG_ARCHIVE_DEST_n and LOG_ARCHIVE_DEST_STATE_n parameters on each standby database so that when a switchover or failover occurs, all standby sites continue to receive redo data from the new primary database.
•Verify that there are no redo transport errors or redo gaps at the standby database by querying the V$ARCHIVE_DEST_STATUS view on the primary database.

For example, the following query would be used to check the status of the standby database associated with LOG_ARCHIVE_DEST_2:

SQL> SELECT STATUS, GAP_STATUS FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID = 2;
 
STATUS GAP_STATUS
--------- ------------------------
VALID NO GAP
Do not proceed until the value of the STATUS column is VALID and the value of the GAP_STATUS column is NOGAP, for the row that corresponds to the standby database.

•Ensure temporary files exist on the standby database that match the temporary files on the primary database.

•Remove any delay in applying redo that may be in effect on the standby database that will become the new primary database.

•Before performing a switchover from an Oracle RAC primary database to a physical standby database, shut down all but one primary database instance. Any primary database instances shut down at this time can be started after the switchover completes.

•Before performing a switchover to a physical standby database that is in real-time query mode, consider bringing all instances of that standby database to the mounted but not open state to achieve the fastest possible role transition and to cleanly terminate any user sessions connected to the physical standby database prior to the role transition.

shutdown all but one primary database instance!!!
standby database to mounted but not open state!!!!!!!! 


primary
select status,gap_status from v$archive_dest_status where dest_id=3;
standby
set linesize 200
col name format a24
col value format a20
col datum_time format a24
select name,value,datum_time from v$dataguard_stats;
select * from v$dataguard_stats;


step1 
select switchover_status,database_role from v$database;
step2
ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

step3
ommit
step4
select switchover_status,database_role from v$database;
step5
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
step6
alter database open;


switch over successfully,then 
============================

212.7.8.102-106


original primary db
SQL> show parameter listener

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
listener_networks		     string
local_listener			     string	 (ADDRESS = (PROTOCOL = TCP)(HO
						 ST = 212.7.8.31)(PORT = 1521))
remote_listener 		     string	 scan-ip:1521
SQL> 


212.7.8.3	rac1 =>212.7.8.102	rac1
212.7.8.4	rac2 =>212.7.8.103	rac2

212.7.8.31	rac1-vip =>212.7.8.104	rac1-vip
212.7.8.22	rac2-vip =>212.7.8.105	rac2-vip

212.7.8.21	scan-ip =>212.7.8.106	scan-ip

srvctl stop listener -n rac1 !!!!!!!
srvctl stop listener -n rac2 @!!!!!!

modify public ip!!!!!

no subset change!!!!
two node!!
1 # ./crsctl stop has
2 
modify /etc/hosts
modify ifcfg-eth0
/etc/init.d/network restart
3 # ./crsctl start has

modify vip!!!!!!!!!!!!!!
grid user
srvctl config nodeapps -a
crsctl stats res -t
ifconfig -a
[grid@rac1 ~]$ crsctl status res -t
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.CRS.dg
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.DATA.dg
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.LISTENER.lsnr
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.asm
               ONLINE  ONLINE       rac1                     Started             
               ONLINE  ONLINE       rac2                     Started             
ora.gsd
               OFFLINE OFFLINE      rac1                                         
               OFFLINE OFFLINE      rac2                                         
ora.net1.network
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.ons
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
ora.registry.acfs
               ONLINE  ONLINE       rac1                                         
               ONLINE  ONLINE       rac2                                         
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       rac2                                         
ora.cvu
      1        ONLINE  ONLINE       rac2                                         
ora.oc4j
      1        ONLINE  ONLINE       rac2                                         
ora.orcl.db
      1        OFFLINE OFFLINE                               Instance Shutdown   
      2        OFFLINE OFFLINE                                                   
ora.rac1.vip
      1        ONLINE  ONLINE       rac1                                         
ora.rac2.vip
      1        ONLINE  ONLINE       rac2                                         
ora.scan1.vip
      1        ONLINE  ONLINE       rac2                                         
[grid@rac1 ~]$ exit
logout
[root@rac1 ~]# ifconfig -a
eth0      Link encap:Ethernet  HWaddr 3C:4A:92:DC:58:E8  
          inet addr:212.7.8.3  Bcast:212.7.8.255  Mask:255.255.255.0
          inet6 addr: fe80::3e4a:92ff:fedc:58e8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:25867623457 errors:0 dropped:0 overruns:0 frame:0
          TX packets:26105723940 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:6781525632114 (6.1 TiB)  TX bytes:39590763583929 (36.0 TiB)
          Interrupt:186 

eth0:1    Link encap:Ethernet  HWaddr 3C:4A:92:DC:58:E8  
          inet addr:212.7.8.31  Bcast:212.7.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:186 

eth1      Link encap:Ethernet  HWaddr 3C:4A:92:DC:58:E9  
          inet addr:10.10.10.11  Bcast:10.10.10.255  Mask:255.255.255.0
          inet6 addr: fe80::3e4a:92ff:fedc:58e9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4506419375 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3187125190 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:4019993435631 (3.6 TiB)  TX bytes:2290711734988 (2.0 TiB)
          Interrupt:218 

eth1:1    Link encap:Ethernet  HWaddr 3C:4A:92:DC:58:E9  
          inet addr:169.254.108.112  Bcast:169.254.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:218 

eth2      Link encap:Ethernet  HWaddr 3C:4A:92:DC:58:EA  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:59 

eth3      Link encap:Ethernet  HWaddr 3C:4A:92:DC:58:EB  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:91 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:483682056 errors:0 dropped:0 overruns:0 frame:0
          TX packets:483682056 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:367976059171 (342.7 GiB)  TX bytes:367976059171 (342.7 GiB)

sit0      Link encap:IPv6-in-IPv4  
          NOARP  MTU:1480  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

srvctl stop vip -n rac1 -f
srvctl stop vip -n rac2 -f
[grid@rac1 ~]$ srvctl stop vip -n rac1 -f
[grid@rac1 ~]$ srvctl stop vip -n rac2 -f

crsctl stats res -t
ifconfig -a
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       rac1                                         
ora.cvu
      1        ONLINE  ONLINE       rac1                                         
ora.oc4j
      1        ONLINE  ONLINE       rac1                                         
ora.orcl.db
      1        ONLINE  INTERMEDIATE rac1                     Mounted (Closed)    
      2        OFFLINE OFFLINE                               Instance Shutdown   
ora.rac1.vip
      1        OFFLINE OFFLINE                                                   
ora.rac2.vip
      1        OFFLINE OFFLINE                                                   
ora.scan1.vip
      1        ONLINE  ONLINE       rac1                       

$ ifconfig -a
eth0      Link encap:Ethernet  HWaddr 3C:4A:92:DC:58:E8  
          inet addr:212.7.8.3  Bcast:212.7.8.255  Mask:255.255.255.0
          inet6 addr: fe80::3e4a:92ff:fedc:58e8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:25867642342 errors:0 dropped:0 overruns:0 frame:0
          TX packets:26105735390 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:6781528007483 (6.1 TiB)  TX bytes:39590765132866 (36.0 TiB)
          Interrupt:186


modify /etc/hosts
# vi /etc/hosts

[root@rac1 bin]# ./srvctl modify nodeapps -n rac1 -A rac1-vip/255.255.255.0/eth0
[root@rac1 bin]# ./srvctl modify nodeapps -n rac2 -A rac2-vip/255.255.255.0/eth0

$ srvctl config nodeapps -a
$ 
$ srvctl start vip -n rac1
$ srvctl srart vip -n rac2
$ srvctl start listener -n rac1
$ srvctl start listener -n rac2

crsctl status res -t
ifconfig -a
srvctl config nodeapps -a 

alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 212.7.8.104)(PORT = 1521))' sid='orcl1';
alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 212.7.8.105)(PORT = 1521))' sid='orcl2';



modify scan vip!!!!!!!!!!
srvctl config scan

srvctl stop scan_listener
srvctl stop scan

srvctl ...
...

SQL> show parameter listener   

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
listener_networks		     string
local_listener			     string	 (ADDRESS = (PROTOCOL = TCP)(HO
						 ST = 212.7.8.104)(PORT = 1521)
						 )
remote_listener 		     string	 scan-ip:1521
SQL> 
alter system set remote_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 212.7.8.106)(PORT = 1521))';
select status,gap_status from v$archive_dest_status where dest_id=2;
==========================================
dataguard!
==========================================
then new primary db
172.17.200.1 =>212.7.8.3
172.17.200.2 =>212.7.8.4

172.17.200.3 =>212.7.8.31
172.17.200.4 =>212.7.8.22

172.17.200.5 =>212.7.8.21






SQL> show parameter listener

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
listener_networks		     string
local_listener			     string	 (ADDRESS = (PROTOCOL = TCP)(HO
						 ST = 172.17.200.3)(PORT = 1521
						 ))
remote_listener 		     string	 scan:1521
SQL> 

modify public ip with subset！！！！！！！！！！！！！！

[grid@his1 ~]$ oifcfg getif
eth0  172.17.200.0  global  public
eth1  10.10.0.0  global  cluster_interconnect
[grid@his1 ~]$ oifcfg delif -global eth0/172.17.200.0
PRIF-33: Failed to set or delete interface because hosts could not be discovered
  CRS-02307: No GPnP services on requested remote hosts.
PRIF-32: Error in checking for profile availability for host his2
  CRS-02306: GPnP service on host "his2" not found.
[grid@his1 ~]$ exit
logout
[oracle@his1 ~]$ exit
logout
[root@his1 ~]# /u01/app/11.2.0/grid/bin/oifcfg delif -global eth0/172.17.200.0
[root@his1 ~]# /u01/app/11.2.0/grid/bin/oifcfg getif
eth1  10.10.0.0  global  cluster_interconnect
[root@his1 ~]# /u01/app/11.2.0/grid/bin/oifcfg iflist
eth0  172.17.200.0
eth1  10.10.0.0
eth1  169.254.0.0
[root@his1 ~]# 
[root@his1 ~]# /u01/app/11.2.0/grid/bin/oifcfg setif -global eth0/212.7.8.0:public
[root@his1 ~]# /u01/app/11.2.0/grid/bin/oifcfg getif
eth1  10.10.0.0  global  cluster_interconnect
eth0  212.7.8.0  global  public

then modify ifcfg-eth0
[root@his1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0

then restart network
[root@his1 ~]# /etc/init.d/network restart

modify vip!!!!!!!!!!!!!!

[grid@his1 ~]$ srvctl config nodeapps -a
Network exists: 1/172.17.200.0/255.255.255.0/eth0, type static
VIP exists: /his1-vip/172.17.200.3/172.17.200.0/255.255.255.0/eth0, hosting node his1
VIP exists: /his2-vip/172.17.200.4/172.17.200.0/255.255.255.0/eth0, hosting node his2
[grid@his1 ~]$ 

[grid@his2 ~]$ crsctl status res -t
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.FRA.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.LISTENER.lsnr
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.OCR.dg
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.asm
               ONLINE  ONLINE       his1                     Started             
               ONLINE  ONLINE       his2                     Started             
ora.gsd
               OFFLINE OFFLINE      his1                                         
               OFFLINE OFFLINE      his2                                         
ora.net1.network
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.ons
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
ora.registry.acfs
               ONLINE  ONLINE       his1                                         
               ONLINE  ONLINE       his2                                         
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       his2                                         
ora.cvu
      1        ONLINE  ONLINE       his2                                         
ora.his1.vip
      1        ONLINE  ONLINE       his1                                         
ora.his2.vip
      1        ONLINE  ONLINE       his2                                         
ora.oc4j
      1        ONLINE  ONLINE       his1                                         
ora.orclnew.db
      1        ONLINE  ONLINE       his2                     Open                
      2        ONLINE  ONLINE       his1                     Open                
ora.scan1.vip
      1        ONLINE  ONLINE       his2       

[grid@his1 ~]$ srvctl stop vip -n his1
PRCC-1017 : his1-vip was already stopped on his1
PRCR-1005 : Resource ora.his1.vip is already stopped
[grid@his1 ~]$ srvctl stop vip -n his2
[grid@his1 ~]$ 
[grid@his1 ~]$ 
[grid@his1 ~]$ srvctl stop listener -n his1
[grid@his1 ~]$ srvctl stop listener -n his2
[grid@his1 ~]$ 

root user
./srvctl modify nodeapps -n his1 -A his1-vip/255.255.255.0/eth0
./srvctl modify nodeapps -n his2 -A his2-vip/255.255.255.0/eth0


alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 212.7.8.31)(PORT = 1521))' sid='orcl1';
alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 212.7.8.22)(PORT = 1521))' sid='orcl2';


modify scan ip!!!!!!!!!
[grid@his1 ~]$ srvctl config scan
SCAN name: scan, Network: 1/212.7.8.0/255.255.255.0/eth0
SCAN VIP name: scan1, IP: /scan/172.17.200.5
[grid@his1 ~]$ 

[root@his1 bin]# ./srvctl config scan
SCAN name: scan, Network: 1/212.7.8.0/255.255.255.0/eth0
SCAN VIP name: scan1, IP: /scan/212.7.8.21
[root@his1 bin]# 
lsnrctl status listener_scan1
no service!!!!
[grid@rac2 ~]$ lsnrctl status LISTENER_SCAN1

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 30-JUL-2016 23:36:51

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN1
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                30-JUL-2016 23:20:58
Uptime                    0 days 0 hr. 15 min. 52 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/crs/oracle/product/11.2.0/crs_1/network/admin/listener.ora
Listener Log File         /u01/crs/oracle/product/11.2.0/crs_1/log/diag/tnslsnr/rac2/listener_scan1/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=212.7.8.106)(PORT=1521)))
The listener supports no services
The command completed successfully
alter system set remote_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = 212.7.8.21)(PORT = 1521))';


SQL> show parameter listener

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
listener_networks		     string
local_listener			     string	 (ADDRESS = (PROTOCOL = TCP)(HO
						 ST = 212.7.8.22)(PORT = 1521))
remote_listener 		     string	 (ADDRESS = (PROTOCOL = TCP)(HO
						 ST = 212.7.8.21)(PORT = 1521))


end modify!!!

ALTER SYSTEM SET service_names='ORCLNEW','ORCL' SCOPE=BOTH;

note:  delete archivelog script!!!!!!!!!!!!!!!!