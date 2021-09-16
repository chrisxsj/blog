overview of Creating and Configuring an Oracle Database



》methods for creating a database
》With Database Configuration Assistant (DBCA), a graphical tool.
    Creating a Database with Interactive DBCA
        Grid Infrastructure Installation Guide for Linux
        Database Installation Guide for Linux
    Creating a Database with Noninteractive/Silent DBCA
        dbca -silent -createDatabase -templateName General_Purpose.dbc
          -gdbname ora11g -sid ora11g -responseFile NO_VALUE -characterSet AL32UTF8
         -memoryPercentage 30 -emConfiguration LOCAL

     dbca -silent -responseFile /u01/app/software/database/dbca.rsp
    Note:
    If you copied the software to a hard disk, the response files are located in the                        database/response directory.
    dbca.rsp 文件内容如下：根据自己的场景进行修改。
    [GENERAL]
    RESPONSEFILE_VERSION = "11.2.0"
    OPERATION_TYPE = "createDatabase"
    [CREATEDATABASE]
    GDBNAME = "orcl"
    SID = "orcl"
    TEMPLATENAME = "New_Database.dbt"
    SYSPASSWORD = "xxxxxxx"
    SYSTEMPASSWORD = "xxxxxxx"
    SYSMANPASSWORD = "xxxxxxx"
    DBSNMPPASSWORD = "xxxxxxx"
    DATAFILEDESTINATION ="/u01/app/oracle/oradata"
    STORAGETYPE=FS
    CHARACTERSET = "AL32UTF8"
    DATABASETYPE = "MULTIPURPOSE"
    AUTOMATICMEMORYMANAGEMENT = "FALSE"
    TOTALMEMORY =8192
    #MEMORYPERCENTAGE = "30"
Home / Database / Oracle Database Online Documentation 11g Release 2 (11.2) / Installing and Upgrading
Database Installation Guide
A Installing and Configuring Oracle Database Using Response Files
https://docs.oracle.com/cd/E11882_01/install.112/e47689/app_nonint.htm#LADBI1341
》With the CREATE DATABASE SQL statement.
Complete the following steps to create a database with the CREATE DATABASE statement. The examples create a database named mynewdb.
Step 1: Specify an Instance Identifier (SID)
Step 2: Ensure That the Required Environment Variables Are Set
Step 3: Choose a Database Administrator Authentication Method
Step 4: Create the Initialization Parameter File
Step 5: (Windows Only) Create an Instance
Step 6: Connect to the Instance
Step 7: Create a Server Parameter File
Step 8: Start the Instance
Step 9: Issue the CREATE DATABASE Statement
Step 10: Create Additional Tablespaces
Step 11: Run Scripts to Build Data Dictionary Views
Step 12: (Optional) Run Scripts to Install Additional Options
Step 13: Back Up the Database.
Step 14: (Optional) Enable Automatic Instance Startup
db_name='test'
memory_target=200m
processes = 150
audit_file_dest='/u02/app/oracle/admin/test/adump'
audit_trail ='db'
db_block_size=8192
db_domain=''
db_recovery_file_dest='/u02/app/oracle/flash_recovery_area'
db_recovery_file_dest_size=2G
diagnostic_dest='/u02/app/oracle'
dispatchers='(PROTOCOL=TCP) (SERVICE=ORCLXDB)'
open_cursors=300
remote_login_passwordfile='EXCLUSIVE'
undo_tablespace='UNDOTBS1'
# You may want to ensure that control files are created on separate physical
# devices
control_files = '/u02/app/oracle/control01.ctl
compatible ='11.2.0'
mkdir -p /u02/app/oracle/admin/test/adump
mkdir -p /u02/app/oracle/flash_recovery_area

CREATE DATABASE test
   USER SYS IDENTIFIED BY oracle
   USER SYSTEM IDENTIFIED BY oracle
   LOGFILE GROUP 1 ('/u02/app/oracle/oradata/redo01a.log','/u02/app/oracle/oradata/redo01b.log') SIZE 50M BLOCKSIZE 512,
           GROUP 2 ('/u02/app/oracle/oradata/redo02a.log','/u02/app/oracle/oradata/redo02b.log') SIZE 50M BLOCKSIZE 512,
           GROUP 3 ('/u02/app/oracle/oradata/redo03a.log','/u02/app/oracle/oradata/redo03b.log') SIZE 50M BLOCKSIZE 512
   MAXLOGFILES 30
   MAXLOGMEMBERS 5
   MAXLOGHISTORY 200
   MAXDATAFILES 200
   CHARACTER SET ZHS16GBK
   NATIONAL CHARACTER SET AL16UTF16
   EXTENT MANAGEMENT LOCAL
   DATAFILE '/u02/app/oracle/oradata/system01.dbf' SIZE 325M REUSE
   SYSAUX DATAFILE '/u02/app/oracle/oradata/sysaux01.dbf' SIZE 325M REUSE
   DEFAULT TABLESPACE users
      DATAFILE '/u02/app/oracle/oradata/users01.dbf'
      SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TEMPORARY TABLESPACE tempts1
      TEMPFILE '/u02/app/oracle/oradata/temp01.dbf'
      SIZE 20M REUSE
    UNDO TABLESPACE undotbs1
      DATAFILE '/u02/app/oracle/oradata/undotbs01.dbf'
      SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
      
mkdir -p /u02/app/oracle/oradata/
Home / Database / Oracle Database Online Documentation 11g Release 2 (11.2) / Database Administration
Database Administrator's Guide
2 Creating and Configuring an Oracle Database
https://docs.oracle.com/cd/E11882_01/server.112/e25494/create.htm#ADMIN002


》Manually Installing Sample Schemas
If you decide not to install the sample schemas at the time of your initial database installation using DBCA, then you can also create the sample schemas manually by running SQL scripts. Install Oracle Database Examples (Companion CD, part of the media kit) to include these scripts in the demo directory under $ORACLE_HOME.
See Also:
Oracle Database Examples Installation Guide for download and installation information


About the Scripts
Sample Schemas script directories are located in $ORACLE_HOME/demo/schema. You must install the Oracle Database Examples media to populate the directories with the Sample Schema scripts. Each schema has two primary scripts:
The xx_main.sql script, where xx is the schema abbreviation, resets and creates all objects and data for a particular schema. This main script calls all other scripts necessary to build and load the schema.
The script xx_drop.sql, where xx is the schema abbreviation, removes all objects from a particular schema.
Sample Schemas script directories are located in the $ORACLE_HOME/demo/schema directory after completing the Oracle Database Examples installation.
Note:
This chapter contains only the master script for the entire sample schemas environment. It does not include the scripts for the individual schemas because these scripts are very lengthy.
Master Script
The master script, mksample.sql, sets up the overall Sample Schema environment and creates all the schemas.
5 Download Oracle Database Examples
This section describes how to download Oracle Database Examples on your computer to a location other than Oracle Database 11g Release 2 (11.2) Oracle home.
Go to the Oracle Database 11g download page on Oracle Technology Network:
http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html
Select the See All link, and then select the Oracle Database Examples zip file under the heading Oracle Database 11g Examples (formerly Companion).
For example, for Linux x86, select linux_11gR2_examples.zip.

Installing the HR Schema
All scripts necessary to create the Human Resource (HR) schema reside in $ORACLE_HOME /demo/schema/human_resources .
You need to call only one script, hr_main.sql , to create all the objects and load the data. The following steps provide a summary of the installation process:
	1. 
Log on to SQL*Plus as SYS and connect using the AS SYSDBA privilege.


	1. 
sqlplus connect sys as sysdba
	2. 
Enter password: password


	1. 
To run the hr_main.sql script, use the following command:


	1. 
SQL> @?/demo/schema/human_resources/hr_main.sql


	1. 
Enter a secure password for HR


	1. 
specify password for HR as parameter 1:
	2. 
Enter value for 1:


See Also:
Oracle Database Security Guide for the minimum password requirements
	1. 
Enter an appropriate tablespace, for example, users as the default tablespace for HR


	1. 
specify default tablespace for HR as parameter 2:
	2. 
Enter value for 2:


	1. 
Enter temp as the temporary tablespace for HR


	1. 
specify temporary tablespace for HR as parameter 3:
	2. 
Enter value for 3:


	1. 
Enter your SYS password


	1. 
specify password for SYS as parameter 4:
	2. 
Enter value for 4:


	1. 
Enter the directory path, for example, $ORACLE_HOME /demo/schema/log/ , for your log directory


	1. 
specify log path as parameter 5:
	2. 
Enter value for 5:


After the hr_main.sql script runs successfully and the HR schema is installed, you are connected as the user HR. To verify that the schema was created, use the following command:
SQL> SELECT       table_name FROM user_tables;
Running hr_main.sql accomplishes the following tasks:
	1. 
Removes any previously installed HR schema
	2. 
Creates the user HR and grants the necessary privileges
	3. 
Connects as HR
	4. 
Calls the scripts that create and populate the schema objects

For a complete listing of the scripts and their functions, refer to Table 5-1 .
A pair of optional scripts, hr_dn_c.sql and hr_dn_d.sql , is provided as a schema extension. To prepare the HR schema for use with the directory capabilities of Oracle Internet Directory, run the hr_dn_c.sql script. If you want to return to the initial setup of the HR schema, then use the hr_dn_d.sql script to undo the effects of the hr_dn_c.sql script.
Use the hr_drop.sql script to drop the HR schema.


https://docs.oracle.com/cd/E11882_01/server.112/e10831/scripts.htm#COMSC00017
Home / Database / Oracle Database Online Documentation 11g Release 2 (11.2) / Application Development/Database Sample Schemas
2 Installation
5 Sample Schema Scripts and Object Descriptions



 [hr.zip](script\hr.zip) 