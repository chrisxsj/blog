Rman validate



RMAN>  restore database preview;
1，完全还原确定需应用哪个备份集
2，可以看到0级备份和1级备份和将应用的归档日志。
RMAN> restore database validate;
1，检查用于恢复数据库的最新备份集，以确认这个备份是否完整
2，检查恢复所需要的数据文件副本和归档日志备份集，并确认他的完整
确定需要备份集后，利用备份BS Key 值，通过validate backupset检查验证这个备份集
RMAN> validate backupset 23;
1，validate对备份集进行全面验证，确定完整性