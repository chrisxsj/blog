SYSDBA OS Authentication
The OS authentication is the process of verifying the identity of the user connecting to the database with the information managed by the OS. An OS user is able to use this authentication method if the following conditions are met:

 1. the  user is a member of a special group.
 2. the OS authentication is allowed by the server settings(sqlnet.authentication_services is set correctly)

 The OS user should belong to the OSDBA group in order to login as sysdba. On Unix the default name of these group is dba. On Windows the name of the group is ORA_DBA.  


 On Unix Parameter sqlnet.authentication_services must be set to (ALL) or to (BEQ, <other values>) for this to work. On Windows this parameter must be set to (NTS).
 
SYSDBA Password File Authentication

The credentials provided when connecting remotely as sysdba are compared to the contents of the passwordfile. 
 Password file authentication is enabled by setting the database parameter remote_login_password file to "shared" or "exclusive".
SQL> alter system set remote_login_passwordfile=exclusive scope=spfile;
 
 
Note: When both OS authentication and password file authentication are enabled then the OS Authentication will be used. This means that you can connect with any username/password combination.  See Note 242258.1 for details.
