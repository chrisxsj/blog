How To Locate What Files Are Backed Up In What RMAN Backup Set (Doc ID 246189.1)

	* 
goal: How To Identify What Files Are In What RMAN Backup Set
	* 
fact: Recovery Manager (RMAN)


fix:
How To Locate An Archive Log In An RMAN Backup Set.

This note details how to tie up entries in the Data Dictionary RMAN views, with
the entries in the Control File.
This can be useful for identifying what Backup Piece Files correspond to watch
Archive Log.
This Note corresponds to Cataloged or Uncataloged RMAN, as the views correspond
to the entries in the Target Databases Control File.
From Target DB

Detail the archive log change you are looking for, note the SET_STAMP, as this
details the backup set the Log is located within.

The V$BACKUP_REDOLOG view queries the Control File so this can be done with or
without a Catalog.
Query the Backed Up Logs.

SQL> select recid,set_stamp,sequence#,first_change#,next_change#
             from  v$backup_redolog;

RECID  SET_STAMP  SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
---------- ---------- ---------- ------------- ------------
         1  464896378         63        157808       158491
         2  464896378         65        178497       178745
         3  464896378         66        178745       178777
         4  464896378         64        158491       178497
         5  464896390         63        157808       158491
         6  464896390         65        178497       178745
         7  464896390         66        178745       178777
         8  464896390         64        158491       178497
         9  464896390         67        178777       178781
->      10  464897514         63        157808       158491
        11  464897514         65        178497       178745
        12  464897514         66        178745       178777
        13  464897514         68        178781       178799
        14  464897514         64        158491       178497
        15  464897514         67        178777       178781

Now select from the backup piece themselves to locate the filename
for this backup.
 
Query against the V$BACKUP_PIECE view.

SQL>        select r.sequence#, p.handle
        from v$backup_piece p, v$backup_redolog r
        where r.set_stamp = p.set_stamp
          and r.set_count = p.set_count
          and r.sequence# = 63

SEQUENCE# HANDLE
---------- ------------------------------------------------------------
        63 /ots3/oradata/rzy/backup/RZY_0oetf7sl_1_1.bck
Look-a-like queries for datafiles are :

SQL>        select d.file#, p.handle
        from v$backup_piece p, v$backup_datafile d
        where d.set_stamp = p.set_stamp
          and d.set_count = p.set_count
          and d.file# = 3
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=337926893959898&id=246189.1&_adf.ctrl-state=10y544x71x_439>