Space issue in Fast / Flash Recovery Area - FRA Full (Doc ID 829755.1)
E) How to Monitor Flash Recovery Area Space Usage ?
V$RECOVERY_FILE_DEST :  To find out the current location, disk quota, space in use, space reclaimable by deleting files, and total number of files in the flash recovery area.
V$FLASH_RECOVERY_AREA_USAGE : To find out the percentage of the total disk quota used by different types of files. Also, you can determine how much space for each type of file can be reclaimed by deleting files that are obsolete, redundant, or already backed up to tape.
For example
SQL>Select file_type, percent_space_used as used,percent_space_reclaimable as reclaimable,
    number_of_files as "number" from v$flash_recovery_area_usage;
    
    FILE_TYPE          USED RECLAIMABLE     number
    ------------ ---------- ----------- ----------
    CONTROLFILE           0           0          0
    ONLINELOG             0           0          0
    ARCHIVELOG         4.77           0          2 
    BACKUPPIECE       56.80           0         10 
    IMAGECOPY             0           0          0
    FLASHBACKLOG      11.68       11.49         63
SQL>select name, space_limit as Total_size ,space_used as Used,SPACE_RECLAIMABLE as reclaimable,NUMBER_OF_FILES as "number" from  V$RECOVERY_FILE_DEST;
NAME                          TOTAL_SIZE   USED      RECLAIMABLE    Number
------------------------      ----------  ---------- -----------  --------
E:\oracle\flash_recovery_area 2147483648  353280000   246841344       75

Note VIEW names:
From >= 10gR2 and <= 11gR1: V$FLASH_RECOVERY_AREA_USAGE
From              >= 11gR2: V$RECOVERY_AREA_USAGE        
.
(For Oracle >=11gR2 (11.2), V$FLASH_RECOVERY_AREA_USAGE was deprecated)

来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=441761282899687&id=829755.1&_adf.ctrl-state=4mien8lus_21> 
