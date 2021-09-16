Relation between RMAN retention period and control_file_record_keep_time (Doc ID 397269.1)




In this Document
 
Purpose
Scope
Details
 
Applies to:
Oracle Database - Enterprise Edition - Version 8.1.7.0 and later
Information in this document applies to any platform.
Purpose
Guideline to set CONTROL_FILE_RECORD_KEEP_TIME in relation to the RETENTION POLICY
Scope
All DBA's using RMAN as Backup & Recovery tool
Details
 
RMAN backup keeps the backup metadata information in the reusable section of the controlfile. It depends on the parameter CONTROL_FILE_RECORD_KEEP_TIME. CONTROL_FILE_RECORD_KEEP_TIME specifies the minimum number of days before a reusable record in the control file can be reused. In the event a new record needs to be added to a reusable section and there is not enough space then it will delete the oldest record, which are aged enough.
 
Backup retention policy is the rule to set regarding which backups must be retained (whether on disk or other backup media) to meet the recovery and other requirements.
 
If the CONTROL_FILE_RECORD_KEEP_TIME is less than the retention policy then it may overwrite reusable records prior to obsoleting them in the RMAN metadata. Therefor it is recommended that the CONTROL_FILE_RECORD_KEEP_TIME should set to a higher value than the retention policy.   
NOTE:  Best practice is to NOT set control_file_record_keep_time to a value greater than 10.    If you need retention greater than this in the controlfile, you should use an RMAN catalog.   
Formula
 
CONTROL_FILE_RECORD_KEEP_TIME = retention period + level 0 backup interval + 1
 
For e.g.
 
e.q. level 0 backup once a week with retention policy of a recovery windows of 14 days then in this case the CONTROL_FILE_RECORD_KEEP_TIME should be 14+7+1=22
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=334944423458458&id=397269.1&_adf.ctrl-state=10y544x71x_171>