Rman debug

 Hi,
log
do the folloing and let me know.
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'
 
1. Start RMAN in debug mode:
rman target <un/pw@target_db> catalog <un/pw@catalog_db> debug all trace=rman.trc log=rman.log
rman> set echo on
rman> report obsolete redundancy 3;
2. Please upload:
* The files rman.trc and rman.
 