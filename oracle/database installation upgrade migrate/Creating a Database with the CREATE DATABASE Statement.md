Home / Database / Oracle Database Online Documentation 11g Release 2 (11.2) / Database Administration

 Step 1: Specify an Instance Identifier (SID)
 export ORACLE_SID=prod

 Step 2: Ensure That the Required Environment Variables Are Set
 echo $ORACLE_BASE
 echo $ORACLE_HOME
 echo $ORACLE_SID

 Step 3: Choose a Database Administrator Authentication Method
 orapwd file=orapwprod entries=5 password=oracle

 Step 4: Create the Initialization Parameter File
 # Change '<ORACLE_BASE>' to point to the oracle base (the one you specify at
 # install time)

 db_name='prod'
 memory_target=280m
 processes = 150
 audit_file_dest='/u02/app/oracle/admin/prod/adump'
 audit_trail ='db'
 db_block_size=8192
 db_domain=''
 #db_recovery_file_dest='<ORACLE_BASE>/flash_recovery_area'
 #db_recovery_file_dest_size=2G
 diagnostic_dest='/u02/app/oracle'
 #dispatchers='(PROTOCOL=TCP) (SERVICE=ORCLXDB)'
 open_cursors=300
 remote_login_passwordfile='EXCLUSIVE'
 undo_tablespace='UNDOTBS1'
 # You may want to ensure that control files are created on separate physical
 # devices
 control_files = '/u02/app/oracle/oradata/prod/control01.ctl', '/u02/app/oracle/oradata/prod/control02.ctl'
 compatible ='11.2.0'

 mkdir -p $ORACLE_BASE/admin/prod/adump
 mkdir -p $ORACLE_BASE/oradata/prod/

 Step 5: (Windows Only) Create an Instance
 windows: oradim -NEW -SID sid -STARTMODE MANUAL -PFILE pfile
 linux: startup nomount

 Step 6: Connect to the Instance
 $ sqlplus /nolog
 SQL> CONNECT SYS/oracle AS SYSDBA
 startup nomount

 Step 7: Create a Server Parameter File
 create spfile from pfile；

 Step 8: Start the Instance
 shutdown immediate
 startup nomount

 Step 9: Issue the CREATE DATABASE Statement
 CREATE DATABASE prod
    USER SYS IDENTIFIED BY oracle
    USER SYSTEM IDENTIFIED BY oracle
    LOGFILE GROUP 1 ('/u02/app/oracle/oradata/prod/redo01a.log','/u02/app/oracle/oradata/prod/redo01b.log') SIZE 100M BLOCKSIZE 512,
            GROUP 2 ('/u02/app/oracle/oradata/prod/redo02a.log','/u02/app/oracle/oradata/prod/redo02b.log') SIZE 100M BLOCKSIZE 512,
            GROUP 3 ('/u02/app/oracle/oradata/prod/redo03a.log','/u02/app/oracle/oradata/prod/redo03b.log') SIZE 100M BLOCKSIZE 512
    MAXLOGFILES 5
    MAXLOGMEMBERS 5
    MAXLOGHISTORY 100
    MAXDATAFILES 100
    CHARACTER SET ZHS16GBK
    NATIONAL CHARACTER SET AL16UTF16
    EXTENT MANAGEMENT LOCAL
    DATAFILE '/u02/app/oracle/oradata/prod/system01.dbf' SIZE 425M REUSE
    SYSAUX DATAFILE '/u02/app/oracle/oradata/prod/sysaux01.dbf' SIZE 325M REUSE
    DEFAULT TABLESPACE users
       DATAFILE '/u02/app/oracle/oradata/prod/users01.dbf'
       SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
    DEFAULT TEMPORARY TABLESPACE tempts1
       TEMPFILE '/u02/app/oracle/oradata/prod/temp01.dbf'
       SIZE 20M REUSE
    UNDO TABLESPACE undotbs1
       DATAFILE '/u02/app/oracle/oradata/prod/undotbs01.dbf'
       SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

 # process  ?/rdbms/admin/sql.bsq
       
 Step 10: Create Additional Tablespaces
 CREATE TABLESPACE app LOGGING
      DATAFILE '/u02/app/oracle/oradata/prod/apps01.dbf'
      SIZE 500M REUSE AUTOEXTEND ON NEXT  1280K MAXSIZE UNLIMITED
      EXTENT MANAGEMENT LOCAL;

 # desc dba_data_files;

 Step 11: Run Scripts to Build Data Dictionary Views
 @?/rdbms/admin/catalog.sql
 @?/rdbms/admin/catproc.sql
 In SQL*Plus, connect to your Oracle Database instance as SYSTEM user:

 @?/sqlplus/admin/pupbld.sql


 # DBA_REGISTRY  
