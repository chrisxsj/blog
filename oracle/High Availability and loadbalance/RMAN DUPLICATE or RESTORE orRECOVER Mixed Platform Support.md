RMAN DUPLICATE/RESTORE/RECOVER Mixed Platform Support (文档 ID 1079563.1)

In this Document


Abstract



History



Details



Summary



References

APPLIES TO:
Oracle Database - Enterprise Edition - Version 10.2.0.1 and later
Oracle Database - Standard Edition - Version 11.2.0.4 to 11.2.0.4 [Release 11.2]
Information in this document applies to any platform.
ABSTRACT
This note covers RMAN DUPLICATE, RESTORE, and RECOVER mixed platform support.
HISTORY
 Author: Tim Chien
 Create Date 31-MAR-2010 
 Update Date 09-JUN-2010
DETAILS
Mixed platforms are supported for:
+ Active Database DUPLICATE
+ Backup-based DUPLICATE using image copies or backup sets
+ RESTORE and RECOVER using image copies or backup sets
Note that the following platform combinations assume that the source database is created at the same version as the destination database (i.e. was not upgraded from a version prior to that listed in the heading for that combination).
An upgraded database can still have blocks which are dependent on old formats and can elicit compatibility issues. Thus, the database is required to be created at the same version as the destination database and not upgraded from a prior version.
 
These RMAN commands are ONLY supported for the platform combinations listed in this note and are ONLY relevant for same endian combinations.
If a particular combination is not listed below, you must use other supported migration procedures, such as transportable tablespace/database or Data Pump import/export.
  
For Oracle Database 10g Release 2 and above releases:
Solaris x86-64 <-> Linux x86-64
HP-PA <-> HP-IA
Windows IA (64-bit) / Windows (64-bit Itanium) <-> Windows 64-bit for AMD / Windows (x86-64)
For Oracle Database 11g Release 1 and above releases (requires minimum 11.1 compatible setting):
Linux <-> Windows
Note:  Backup must be cold/consistent backup.  I.e. cannot apply redo between Windows and Linux, see:
Restore From Windows To Linux using RMAN Fails (Note 2003327.1)
 
NOTE: If you need to rollback a PSU already installed, you may need the rollback files from the source system if the source and target are of different platforms.
For Oracle Database 12g Release 2 and above releases: 
New functionality with RMAN backup "for transport" allows transport with backupsets.  See the following for details:
Steps to Transport a Database to a Different Platform Using Backup Sets in Chapter 28 of the Database Backup and Recovery User's Guide:
http://docs.oracle.com/database/121/BRADV/rcmxplat.htm#BRADV724
12c How Perform Cross-Platform Database Transport to different Endian Platform with RMAN Backup Sets (Note 2013271.1)
REFERENCES
NOTE:2003327.1 - Restore From Windows To Linux using RMAN Fails
NOTE:1508375.1 - Duplicate from Windows to Linux ORA-600 [KTBRCL:CDLC NOT IN CR] 
NOTE:13335722.8 - Bug 13335722 - Enhancement to allow RMAN conversion of backups cross-endian cross-platform
NOTE:2013271.1 - 12c How Perform Cross-Platform Database Transport to different Endian Platform with RMAN Backup Sets