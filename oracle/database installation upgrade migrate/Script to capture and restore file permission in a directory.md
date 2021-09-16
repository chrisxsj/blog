Script to capture and restore file permission in a directory (for eg. ORACLE_HOME) (Doc ID 1515018.1)

 In this Document


Main Content



Purpose



Requirements



Configuring



Instructions



Caution



Script

APPLIES TO:
Oracle Database - Enterprise Edition
Generic UNIX
Generic Linux
MAIN CONTENT
PURPOSE
This script is intended to capture and restore the file permission of a given directory example - ORACLE_HOME. The script will create a output file called permission_<timestamp> and permission_<timestamp>.cmd

REQUIREMENTS
The script needs to be run on command prompt of Unix platform .
Perl is required to execute this script
Shell is required to run the shell script .
CONFIGURING
Download and save the script on your server as permission.pl
Provide the execute permission on the script
INSTRUCTIONS
 Run the script from the location where you have downloaded and saved it
./permission.pl <Path name to capture permission>
CAUTION
This sample code is provided for educational purposes only and not supported by Oracle Support Services. It has been tested internally, however, and works as documented. We do not guarantee that it will work for you, so be sure to test it in your environment before relying on it.
Proofread this sample code before using it! Due to the differences in the way text editors, e-mail packages and operating systems handle text formatting (spaces, tabs and carriage returns), this sample code may not be in an executable state when you first receive it. Check over the sample code to ensure that errors of this type are corrected.
Note : This script can restore permission back to the point at which it was captured. It is not intended to reset the permission.

SCRIPT
Execute the script from the dollar ($) prompt
Steps to capture permission of a directory
 1. Download the script from here
 2. Log in as "oracle" user
 3. copy the file to a location say /home/oracle/scripts
 4. Give execute permission
    $ chmod 755 permission.pl
 5. Execute the script to capture permission
    $ cd /home/oracle/scripts
    $ ./permission.pl <Path name to capture permission>

Script generates two files
a. permission-<time stamp> - This contains file permission in octal value, owner and group information of the files captured
b. restore-perm-<time stamp>.cmd - This contains command to change the permission, owner, and group of the captured files
Steps to restore captured permission of the directory
1. Give execute permission to file generated during capture
    chmod 755 restore-perm-<timestamp>.cmd
2. execute .cmd file to restore the permission and the ownership
    $ ./restore-perm-<timestamp>.cmd
Note: In case of RAC setup, you can execute restore-perm-<timestamp>.cmd as root user.
Sample output of the script
permission-<time stamp>
755 oracle oinstall /u03/app/oracle/OraHome_11202g
750 oracle oinstall /u03/app/oracle/OraHome_11202g/root.sh
644 oracle oinstall /u03/app/oracle/OraHome_11202g/install.platform
640 oracle oinstall /u03/app/oracle/OraHome_11202g/oraInst.loc
644 oracle oinstall /u03/app/oracle/OraHome_11202g/afiedt.buf
644 oracle oinstall /u03/app/oracle/OraHome_11202g/a.out
6755 root root /u03/app/oracle/OraHome_11202g/tsh.sh
644 oracle oinstall /u03/app/oracle/OraHome_11202g/Readme.txt
640 oracle oinstall /u03/app/oracle/OraHome_11202g/oraorcl1122
644 oracle oinstall /u03/app/oracle/OraHome_11202g/SQLtraining_day1.lst
751 oracle oinstall /u03/app/oracle/OraHome_11202g/bin/hsots
751 oracle oinstall /u03/app/oracle/OraHome_11202g/bin/nid
6751 oracle oinstall /u03/app/oracle/OraHome_11202g/bin/oracle
751 oracle oinstall /u03/app/oracle/OraHome_11202g/bin/orapwd
751 oracle oinstall /u03/app/oracle/OraHome_11202g/bin/wrap
750 oracle oinstall /u03/app/oracle/OraHome_11202g/bin/grdcscan

  restore-perm-<time stamp>.cmd
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g
chmod  755 /u03/app/oracle/OraHome_11202g
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/root.sh
chmod  750 /u03/app/oracle/OraHome_11202g/root.sh
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/install.platform
chmod  644 /u03/app/oracle/OraHome_11202g/install.platform
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/oraInst.loc
chmod  640 /u03/app/oracle/OraHome_11202g/oraInst.loc
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/afiedt.buf
chmod  644 /u03/app/oracle/OraHome_11202g/afiedt.buf
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/a.out
chmod  644 /u03/app/oracle/OraHome_11202g/a.out
chown  root:root /u03/app/oracle/OraHome_11202g/tsh.sh
chmod  6755 /u03/app/oracle/OraHome_11202g/tsh.sh
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/Readme.txt
chmod  644 /u03/app/oracle/OraHome_11202g/Readme.txt
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/oraorcl1122
chmod  640 /u03/app/oracle/OraHome_11202g/oraorcl1122
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/SQLtraining_day1.lst
chmod  644 /u03/app/oracle/OraHome_11202g/SQLtraining_day1.lst
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/bin/nid
chmod  751 /u03/app/oracle/OraHome_11202g/bin/nid
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/bin/oracle
chmod  6751 /u03/app/oracle/OraHome_11202g/bin/oracle
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/bin/orapwd
chmod  751 /u03/app/oracle/OraHome_11202g/bin/orapwd
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/bin/wrap
chmod  751 /u03/app/oracle/OraHome_11202g/bin/wrap
chown  oracle:oinstall /u03/app/oracle/OraHome_11202g/bin/grdcscan
chmod  750 /u03/app/oracle/OraHome_11202g/bin/grdcscan



 [permission.pl](script\permission.pl) 