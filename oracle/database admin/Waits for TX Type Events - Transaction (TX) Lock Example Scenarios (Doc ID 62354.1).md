Applies to: 
Oracle Database - Personal Edition - Version 7.3.4.0 and later
Oracle Database - Enterprise Edition - Version 7.3.4.0 and later
Oracle Database - Standard Edition - Version 7.3.4.0 and later
Oracle Database Cloud Schema Service - Version N/A and later
Oracle Database Exadata Express Cloud Service - Version N/A and later
Information in this document applies to any platform.
Purpose
This document provides examples of TX locks and the waits which can occur in various circumstances. Often such waits will go unnoticed unless they are of a long duration or when they trigger a deadlock scenario (which raises an ORA-60 error).

The examples here demonstrate fundamental locking scenarios which should be understood by application developers and DBA's alike. 

The examples require select privilege on the V$ views.
Troubleshooting Steps
What is a TX lock?
A TX lock is acquired when a transaction initiates its first change and is held until the transaction does a COMMIT or ROLLBACK. It is used mainly as a queuing mechanism so that other sessions can wait for the transaction to complete. The lock name (ID1 and ID2) of the TX lock reflect the transaction ID of the active transaction.
NOTE: TX lock is an application coding, design and usage problem and can ONLY be fixed by changing application code with more frequent and explicit COMMIT statements and any other minor code changes. Oracle Support cannot fix TX lock wait issues other than helping to identify the objects and commands causing the waits. Please work with Developers to fix the code and to alleviate TX lock waits.
When TX lock contention occurs, typically you will start to encounter waits for various 'enq: TX - ...' wait events. You can find information relating to how to resolve such contention issues in the following articles:
Document 1476298.1 Resolving Issues Where 'enq: TX - row lock contention' Waits are Occurring 
Document 873243.1 Troubleshooting 'enq: TX - index contention' Waits in a RAC Environment. 
Document 1472175.1 Troubleshooting waits for 'enq: TX - allocate ITL entry' 
Document 1946502.1 Resolving Issues Where 'enq: TX - contention' Waits are Occurring
 
Useful SQL Statements
If you encounter a lock related hang scenario the following SQL statements can be used to help isolate the waiters and blockers:
	• Show all sessions waiting for any lock:
SELECT event,  p1,  p2,  p3
FROM v$session_wait
WHERE wait_time= 0
AND event like 'enq%';
	• From 10g a different more descriptive event name exists for the more frequent enqueues and you can query the TX wait event as follows:
SELECT sid,  p1raw,  p2,  p3
FROM v$session_wait
WHERE wait_time     = 0
AND event        like 'enq: TX%';
	• Show sessions waiting for a TX lock:
SELECT * FROM v$lock WHERE type='TX' AND request>0;
	• Show sessions holding a TX lock:
SELECT * FROM v$lock WHERE type='TX' AND lmode > 0;
	• Show which segments have undergone the most row lock waits: 
SELECT owner, object_name, subobject_name, value
FROM v$segment_statistics
WHERE statistic_name='row lock waits'
AND value > 0
ORDER BY 4 DESC;
Wait about ten minutes or so, and then run the script again.  You may compare the differences of corresponding entries in the VALUE column to see which object(s) has undergone the most row lock contention.
Example Tables
The lock waits which can occur are demonstrated using the following tables.
Connect as <username>/<xxxx> or some dummy user to set up the test environment using the following SQL:
DROP TABLE tx_eg;
CREATE TABLE tx_eg ( num number, txt varchar2(10), sex varchar2(10) ) INITRANS 1 MAXTRANS 1;
INSERT into tx_eg VALUES ( 1, 'First','FEMALE' );
INSERT into tx_eg VALUES ( 2, 'Second','MALE' );
INSERT into tx_eg VALUES ( 3, 'Third','MALE' );
INSERT into tx_eg VALUES ( 4, 'Fourth','MALE' );
INSERT into tx_eg VALUES ( 5, 'Fifth','MALE' );
COMMIT;

In the examples below three sessions are required:
	• Ses#1 indicates the TX_EG table owners first session
	• Ses#2 indicates the TX_EG table owners second session
	• DBA indicates a SYSDBA user with access to View:V$LOCK
Waits due to Row being locked by an active Transaction
When a session updates a row in a table the row is locked by the sessions transaction. Other users may SELECT that row and will see the row as it was BEFORE the UPDATE occurred. If another session wishes to UPDATE the same row it has to wait for the first session to commit or rollback. The second session waits for the first sessions TX lock in EXCLUSIVE mode.
--Ses#1:
UPDATE tx_eg SET txt='Garbage' WHERE num=1;
--Ses#2:
UPDATE tx_eg SET txt='Garbage' WHERE num=1;
--DBA:
SELECT sid,type,id1,id2,lmode,request FROM v$lock WHERE type='TX';
SID        TY ID1        ID2        LMODE      REQUEST 
	---------- -- ---------- ---------- ---------- ---------- 
	         8 TX     131075        597          6          0 
	        10 TX     131075        597          0          6 
This shows SID 10 is waiting for the TX lock held by SID 8 and it wants the lock in exclusive mode (as REQUEST=6).
--DBA:
SELECT sid,  p1raw,  p2,  p3
FROM v$session_wait
WHERE wait_time = 0
AND event       = 'enqueue';
SID        P1RAW    P2         P3                
	---------- -------- ---------- ----------        
	        10 54580006     131075        597      
Interpretation:
     >             ~~~~  ~~     ~~~~~~        ~~~
     >             type|mode       id1        id2        
     >               TX    6    131075        597             

The next select shows the object_id and the exact row that the session is waiting for. This  information is only valid in V$SESSION when a session is waiting due to a row level lock. It can be helpful for determining which object and row a TX lock request is blocked on due to the row being locked by some other transaction.
As SID 10 is the waiter above then this is the session to look at in V$SESSION:
--DBA:
SELECT row_wait_obj#,
  row_wait_file#,
  row_wait_block#,
  row_wait_row#
FROM v$session
WHERE sid=10;
ROW_WAIT_O ROW_WAIT_F ROW_WAIT_B ROW_WAIT_R 
 ---------- ---------- ---------- ---------- 
       3058          4       2683          0 
The waiter is waiting for the TX lock in order to lock row 0 in file 4, block 2683 of object 3058.
-- Ses#1: 
rollback; 
--Ses#2: 
rollback;
 
Waits due to Unique or Primary Key Constraint Enforcement
If a table has a primary key constraint, a unique constraint or a unique index then the uniqueness of the column/s referenced by the constraint is enforced by a unique index. If two sessions try to insert the same key value the second session has to wait to see if an ORA-0001 should be raised or not.
--Ses#1:  
ALTER TABLE tx_eg ADD CONSTRAINT tx_eg_pk PRIMARY KEY( num ); 
--Ses#1: 
INSERT INTO tx_eg VALUES (10,'New','MALE'); 
--Ses#2: 
INSERT INTO tx_eg VALUES (10,'OtherNew',null); 
--DBA: 
SELECT sid,type,id1,id2,lmode,request FROM v$lock WHERE type='TX';
SID        TY ID1        ID2        LMODE      REQUEST
 ---------- -- ---------- ---------- ---------- ----------
          8 TX     196625         39          6          0
         10 TX     262155         65          6          0
         10 TX     196625         39          0          4 
This shows SID 10 is waiting for the TX lock held by SID 8 and it wants the lock in share mode (as REQUEST=4). SID 10 holds a TX lock for its own transaction.
--Ses#1:  
commit; 
--Ses#2:  
ORA-00001: unique constraint (xxxx.TX_EG_PK) violated 
--Ses#2: 
rollback;
 
Waits due to Insufficient 'ITL' slots in a Block
Oracle keeps note of which rows are locked by which transaction in an area at the top of each data block known as the 'interested transaction list'. The number of ITL slots in any block in an object is controlled by the INITRANS and MAXTRANS attributes. INITRANS is the number of slots initially created in a block when it is first used, while MAXTRANS places an upper bound on the number of entries allowed. Each transaction which wants to modify a block requires a slot in this 'ITL' list in the block.

MAXTRANS places an upper bound on the number of concurrent transactions which can be active at any single point in time within a block.

INITRANS provides a minimum guaranteed 'per-block' concurrency.

If more than INITRANS but less than MAXTRANS transactions want to be active concurrently within the same block then the ITL list will be extended BUT ONLY IF THERE IS SPACE AVAILABLE TO DO SO WITHIN THE BLOCK.

If there is no free 'ITL' then the requesting session will wait on one of the active transaction locks in mode 4.
--Ses#1: 
UPDATE tx_eg SET txt='Garbage' WHERE num=1; 
--Ses#2:  
UPDATE tx_eg SET txt='Different' WHERE num=2; 
--DBA:
SELECT sid,type,id1,id2,lmode,request FROM v$lock WHERE type='TX';
 SID        TY        ID1        ID2      LMODE    REQUEST
 ---------- -- ---------- ---------- ---------- ----------
          8 TX     327688         48          6          0
         10 TX     327688         48          0          4 
This shows SID 10 is waiting for the TX lock held by SID 8 and it wants the lock in share mode (as REQUEST=4).
--Ses#1: 
COMMIT; 
--Ses#2: 
COMMIT; 
--Ses#1: 
ALTER TABLE tx_eg MAXTRANS 2; 
--Ses#1: 
UPDATE tx_eg SET txt='First' WHERE num=1; 
--Ses#2: 
UPDATE tx_eg SET txt='Second' WHERE num=2;
Both rows update as there is space to grow the ITL list to accommodate both transactions.
--Ses#1: 
COMMIT; 
--Ses#2: 
COMMIT; 
You can check the ITL Waits in v$segment_statistics with a query like:
SELECT t.owner,
  t.object_name,
  t.object_type,
  t.statistic_name,
  t.value
FROM v$segment_statistics t
WHERE t.statistic_name = 'ITL waits'
AND t.value > 0;

In earlier releases of Oracle Database, the MAXTRANS parameter limited the number of transaction entries that could concurrently use data in a data block. This parameter has been deprecated in 10g and higher. Oracle Database now automatically allows up to 255 concurrent update transactions for any data block, depending on the available space in the block.
ITL contention is likely to generate waits for the 'enq: TX - allocate ITL entry'  wait event.  If need be, increase INITTRANS and MAXTRANS to resolve this. There is more on how to troubleshoot these waits in the following article:
Document 1472175.1 Troubleshooting waits for 'enq: TX - allocate ITL entry'
 
Waits due to rows being covered by the same BITMAP index fragment
Bitmap indexes index key values and a range of ROWIDs. Each 'entry' in a bitmap index can cover many rows in the actual table. If 2 sessions wish to update rows covered by the same bitmap index fragment then the second session waits for the first transaction to either COMMIT or ROLLBACK by waiting for the TX lock in mode 4.
--Ses#1:  
CREATE BITMAP INDEX tx_eg_bitmap ON tx_eg ( sex ); 
--Ses#1: 
UPDATE tx_eg SET sex='FEMALE' WHERE num=3; 
--Ses#2: 
UPDATE tx_eg SET sex='FEMALE' WHERE num=4; 
--DBA: 
SELECT sid,type,id1,id2,lmode,request FROM v$lock WHERE type='TX';
SID TY        ID1        ID2      LMODE    REQUEST 
---------- -- ---------- ---------- ---------- ----------
         8 TX     262151         62          6          0
        10 TX     327680         60          6          0
        10 TX     262151         62          0          4
This shows SID 10 is waiting for the TX lock held by SID 8 and it wants the lock in share mode (as REQUEST=4).
--Ses#1: 
COMMIT;
--Ses#2: 
COMMIT;
 
How to find which segments have undergone the most row lock waits using given range of AWR snapshot ID's:
 
ALTER SESSION SET nls_timestamp_format='DD-MON-RR HH24:MI';
SELECT P.snap_id,
  P.begin_interval_time,
  O.owner,
  O.object_name,
  O.subobject_name,
  O.object_type,
  S.row_lock_waits_delta
FROM dba_hist_seg_stat S,
  dba_hist_seg_stat_obj O,
  dba_hist_snapshot P
WHERE S.dbid               =O.dbid
AND S.ts#                  =O.ts#
AND S.obj#                 =O.obj#
AND S.dataobj#             =O.dataobj#
AND S.snap_id              =P.snap_id
AND S.dbid                 =P.dbid
AND S.instance_number      =P.instance_number
AND S.row_lock_waits_delta > 0
AND P.snap_id BETWEEN      <begin_snap>  AND <end_snap> 
ORDER BY 1,3,4;
In order to run DBA_HIST_* views,  a license for the Diagnostics Pack must be purchased.
In order to run AWR, license is required:
Document 1490798.1 AWR Reporting - Licensing Requirements Clarification
 
Other Scenarios
There are other wait scenarios which can result in a SHARE mode wait for a TX lock but these are rare compared to the examples given above. 

来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=162208800121999&id=62354.1&_adf.ctrl-state=g4ucdzcu5_57> 
