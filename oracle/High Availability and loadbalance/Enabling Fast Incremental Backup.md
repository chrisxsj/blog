Enabling Fast Incremental Backup

ALTER DATABASE
{ENABLE|DISABLE} BLOCK CHANGE TRACKING
[USING FILE '...']
alter database enable block change tracking using file '/u02/app/oracle/bt.trc'; 

You can use the following syntax to change the location of the block change tracking file:
ALTER DATABASE RENAME FILE '...' TO '...';

Monitoring Block Change Tracking
SQL> SELECT filename, status, bytes  FROM   v$block_change_tracking;
SQL> SELECT file#, avg(datafile_blocks),avg(blocks_read), avg(blocks_read/datafile_blocks) * 100 AS PCT_READ_FOR_BACKUP, avg(blocks) FROM   v$backup_datafile  WHERE  used_change_tracking = 'YES'  AND    incremental_level > 0 GROUP  BY file#;