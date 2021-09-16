How to take consistent backups at standby site (Doc ID 1292126.1)

 

In this Document
 
Goal
Solution
References
 
 
Applies to:
Oracle Database - Enterprise Edition - Version 10.2.0.4 and later
Oracle Database Cloud Schema Service - Version N/A and later
Oracle Database Exadata Cloud Machine - Version N/A and later
Oracle Cloud Infrastructure - Database Service - Version N/A and later
Oracle Database Backup Service - Version N/A and later
Information in this document applies to any platform.
***Checked for relevance on 08-Jan-2013***
Goal
How to take an offline, consistent, self-contained backup at the standby site. The aim of this exercise is to have a self-contained backup that can be restored on its own without needing recovery.  I.e., since recovery of standby is stopped, the backup is a cold backup.  
 
This process will work for both RAC and non-RAC systems.
Solution
1) stop managed recovery:
 
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
 
2) backup the database and controlfile
 
RMAN> backup database plus archivelog ;
 
RMAN> backup current controlfile; 
Note: In 10g, you will need to backup the controlfile from the primary site.
The above will result in a consistent, self-contained backup.
 
3) restart managed recovery:
 
To restore from this backup:
 
RMAN> startup nomount;
RMAN> restore controlfile from 'controlfile backuppiece name and location';
RMAN> alter database mount;
RMAN> restore database;
RMAN> recover database noredo;
 
 
 
For taking consistent RMAN Backups in Standby in Active DataGuard mode
Please see:
 
 (Doc ID 1419923.1) Howto make a consistent RMAN backup in an Standby database in Active DataGuard mode
 
 
References
NOTE:1419923.1 - Howto make a consistent RMAN backup in an Standby database in Active DataGuard mode
 
NOTE:735106.1 - How to Recreate a Controlfile
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=335509987040120&parent=DOCUMENT&sourceId=1419923.1&id=1292126.1&_afrWindowMode=0&_adf.ctrl-state=10y544x71x_390>