不完全恢复的几种类型

  Type of Recovery Function
  ------------------- ----------------------------
  Time-based recovery Recovers the data up to a specified point in time.
  Cancel-based recovery Recovers until you issue the CANCEL statement (not available when using Recovery Manager).
  Change-based recovery Recovers until the specified SCN.
  Log sequence recovery Recovers until the specified log sequence number (only available when using Recovery Manager). 
基于sql plus的不完全恢复
1 SQL> recover database until time '2013-09-04:12:52:22';
2 SQL> recover database using backup controlfile until  cancel;
 
基于rman的不完全恢复
run {
      shutdown immediate;
      startup mount;
      set until time "to_date('20130705 10:09:53','yyyymmdd hh24:mi:ss')";
      restore database;
      recover database;
      alter database open resetlogs;
} 
 
run {
      shutdown immediate;
      startup mount;
      set until scn 3400;
      restore database;
      recover database;
      alter database open resetlogs;
}  
 
run {
      shutdown immediate;
      startup mount;
      set until sequence 12903;
      restore database;
      recover database;
      alter database open resetlogs;
}  
基于取消的恢复，使用sqlplus
SQL>  recover database until cancel;
rmna> sql 'recover database until cancel';
 