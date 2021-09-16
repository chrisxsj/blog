Installing 11.2.0.3 Or 11.2.0.4 (32-bit (x86) or 64-bit (x86-64) ) On RHEL6 Reports That Packages "elfutils-libelf-devel-0.97" And "pdksh-5.2.14" Are Missing (PRVF-7532) (Doc ID 1454982.1)



In this Document


Symptoms



Cause



Solution



References

APPLIES TO:
Oracle Database - Enterprise Edition - Version 11.2.0.3 to 11.2.0.4 [Release 11.2]
Oracle Universal Installer - Version 11.2.0.3 to 11.2.0.4 [Release 11.2]
Oracle Database - Standard Edition - Version 11.2.0.3 to 11.2.0.4 [Release 11.2]
Linux x86-64
Linux x86
SYMPTOMS
While installing the 11.2.0.3 or 11.2.0.4 (32-bit (x86) or 64-bit (x86-64) database software on a Red Hat Enterprise Linux 6 (RHEL6) server  (x86 or x86-64),
the Oracle Universal Installer (OUI) reports that packages "elfultils-libelf-devel-0.97" and "pdksh-5.2.14" are missing.
In the installActions.log the following output can be observed:
:
INFO: INFO: *********************************************
INFO: INFO: Package: elfutils-libelf-devel-0.97: This is a prerequisite condition to test whether the package "elfutils-libelf-devel-0.97" is available on the system.
INFO: INFO: Severity:IGNORABLE
INFO: INFO: OverallStatus:VERIFICATION_FAILED
INFO: INFO: -----------------------------------------------
INFO: INFO: Verification Result for Node:nodename
INFO: INFO: Expected Value:elfutils-libelf-devel-0.97
INFO: INFO: Actual Value:missing
INFO: INFO: Error Message:PRVF-7532 : Package "elfutils-libelf-devel" is missing on node "nodename"
INFO: INFO: Cause: A required package is either not installed or, if the package is a kernel module, is not loaded on the specified node.
INFO: INFO: Action: Ensure that the required package is installed and available.
INFO: INFO: -----------------------------------------------
:
INFO: INFO: *********************************************
INFO: INFO: Package: pdksh-5.2.14: This is a prerequisite condition to test whether the package "pdksh-5.2.14" is available on the system.
INFO: INFO: Severity:IGNORABLE
INFO: INFO: OverallStatus:VERIFICATION_FAILED
INFO: INFO: -----------------------------------------------
INFO: INFO: Verification Result for Node:nodename
INFO: INFO: Expected Value:pdksh-5.2.14
INFO: INFO: Actual Value:missing
INFO: INFO: Error Message:PRVF-7532 : Package "pdksh" is missing on node "nodename"
INFO: INFO: Cause: A required package is either not installed or, if the package is a kernel module, is not loaded on the specified node.
INFO: INFO: Action: Ensure that the required package is installed and available.
INFO: INFO: -----------------------------------------------
:
CAUSE
OUI executes the following command:
/bin/rpm -q --qf %{version} redhat-release
and no output is returned (because in RHEL6 the package redhat-release has been replaced by redhat-release-server-6Server).
This causes OUI to believe that the server is not a RHEL server.
As OUI can not identify what type of server it is, OUI performs the default (OEL4) prerequisite checks.
This problem has been logged as unpublished bug 13981169 with Oracle Development.
In addition to this, no RHEL6 prerequisite checks are defined in <path>/database/stage/cvu/cvu_prereq.xml in the 11.2.0.3 media.
SOLUTION
If you have received the 11.2.0.3 or 11.2.0.4 media on DVD,
it will be necessary to copy the media from the DVD to a disk on the RHEL6 server.
If you have downloaded the 11.2.0.3 or 11.2.0.4 media from My Oracle Support (MOS) then you extract first the software.
Once the software is copied/extracted under  <path>/database, do the following:
1. Change directory to <path>/database/stage/cvu/cv/admin
2. Backup cvu_config
% cp cvu_config backup_cvu_config
3. Edit cvu_config and change the following line:
CV_ASSUME_DISTID=OEL4
to:
CV_ASSUME_DISTID=OEL6
4. Save the updated cvu_config file
5. Install the 11.2.0.3 or 11.2.0.4 software using <path>/database/runInstaller
% cd <path>/database
% ./runInstaller
OUI should now perform the OEL6 prerequisite checks (which are identical to the RHEL6 prerequisite checks) and
no longer report that packages "elfutils-libelf-devel-0.97" and "pdksh-5.2.14" are missing.
 
ATTENTION :
About the 32 bit version of soft (x86), in case the problem remains then :
- restore the original cvu_config file 
- after manually verifying that all of the requirements have been met,
choose the 'Ignore all' option in the installer and continue with the installation.
 
 
REFERENCES
NOTE:1441282.1 - Requirements for Installing Oracle 11gR2 RDBMS on RHEL6 or OL6 64-bit (x86-64)
