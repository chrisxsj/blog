# WAL

**作者**

Chrisx

**日期**

2021-05-26

**内容**

WAL Internals Of PostgreSQ，

---

[toc]

## redo在pg中的实现

pg中使用wal

## wal算法

* 对buffer中更改的数据页加Exclusive-lock
* 启动关键部分？
* <!--Start the critical section which ensures that any error occur till End of critical section should be a PANIC as buffers might ontain unlogged changes.-->
* 在buffer中应用更改
* 将缓冲区标记为脏，这确保BGWriter（检查点）将刷新此页面并在写入日志记录之前将缓冲区标记为脏，可确保缓冲区的内容锁存较少争议。
* 构建要插入事务日志缓冲区的记录。
* 使用LSN更新页面，LSN将由BGWriter或页面的刷新操作使用，以确保从缓冲区中刷新相应的日志
* End Critical section.
* 解锁并解锁缓冲区。

## WAL中使用的重要锁

WALInsertLock

此锁用于将事务日志记录内容插入事务日志内存缓冲区。 首先获取此锁，然后将包括完整缓冲区（如果FULL_PAGE_WRITES打开）在内的整个内容复制到日志缓冲区中。

使用此锁的其他地方

* During flush of log buffers to check if there are any more additions to log buffer since last it is decided till log buffer flush point.
* To determine the Checkpoint redo location
* During Online backup to enforce Full page writes till the backup is finished.
* to get the current WAL insert location from built in function.

WALWriteLock

此锁用于将事务日志缓冲区数据写入WAL文件。 执行此锁定后，所有事务日志缓冲区数据将被刷新到预定点

使用它的地方

* Flush of transaction log which can be due to Commit, Flush of data buffers, truncate of commit log etc.
* During Switch of Xlog.
* During get of new Xlog buffer, if all buffers are already occupied and not flushed.
* Get the time of the last xlog segment switch

## Write Ahead Log Files

The transaction log files are stored in $PGDATA/pg_xlog
directory. They are named as 000000020000070A0000008E

* The first 8 digits identifies the timeline,
* The following 8 digits identifies the (logical) xlog file and
* The last ones represents the (physical) xlog file (Segement)

The physical files in pg_xlog directory are not actually the xlog 
files; PostgreSQL calls it segments.

Each Segment contains Bocks of 8K and Segment size is 16M

Block 0
1. Seg Hdr 
2. Block Header
3. WAL Records
Each WAL record
has header.
WAL 1, 2 ,3
Block 1
1. Block Header
2. WAL Records
3. Each WAL record
has header.
WAL 4,5
Block 2
1. Block Header
2. WAL Records
3. Each WAL record
has header.
…
Block 255
1. Block Header
2. WAL Records
3. Each WAL record
has header.
WAL m,n,

## Switch Transaction Log Segment

What is XLOG SWITCH?
It means to change the current xlog segment file to next
segment file

What all needs XLOG SWITCH?

At Archive timeout, so that current files can be archived
At Shutdown, so that current files can be archived.
At start of online backup
By built-in function pg_switch_xlog

## Async Commit

* In this mode, the WAL data gets flushed to disk after predefined  time by a background WAL writer process.
* Commit only updates the WAL record pointer upto which background process needs to flush.
*  In worst-case three walwriter cycles will be required to flush the WAL buffered data.
*  We must not set a transaction-committed hint bit on a relation page and have that record make it to disk prior to the WAL record of the commit. This can maintain transaction status consistency across crash recovery.

## Protection against partial writes in disk

Data Page Partial Write Protection

To protect the data page partial write, the first WAL record affecting a given page after a checkpoint is made to contain a copy 
of the entire page, and we implement replay by restoring that page copy instead of redoing the update.

WAL Page Partial Write Protection

Each WAL record contains CRC and checking the validity of the WAL record's CRC will detect partial write.
Each WAL page contains a magic number, the validity of which is checked after reading each page

## XLogRecord

* Fixed size log record header which sits in the beginning of each log record
* Stores the information of current transaction id
* Stores CRC to validate the log record
* Stores total length of record
* Info bits to indicate whether backup block information is present.
* Resource manager id to indicate type of resource of log record

## XLogRecData

* The resource manager data is defined by a chain of one or more XLogRecData structs.
* Multiple structs are used when backup pages needs to be written
* when the buffer is backed up, it does not insert the data pointed to by this XLogRecData struct into the XLOG record
* Flag to indicate whether free space of backup page can be omitted.
* Actual data of record
* Buffer associated with data

## BkpBlock

* Header information for backup block. This is appended to Xlog Record
* Stores information about hole inside backup page
* Stores information for relation containing block
* Follows it is the actual backup page data

## Advantages/Disadvantages Of PG Implementation

Advantages

1. One of the Advanced features of PostgreSQL is it its ability to perform transactional DDL’s via its Write Ahead Log design.
2. Removing holes of data page and then write to WAL will have less I/O if pages are not full.
3. WAL data written for Insert and Delete operation is lesser than systems having UNDO (Oracle).
4. During ASync Commit, writing data only in blocks ensures less usage of I/O bandwidth.
5. Keeping Log Sequence Number on each page ensures that during dirty page flush Buffer Manager doesnot need to wait for Flush of WAL until necessary.

Disadvantages 

1. Flushing data pages during Commit can be heavier.
2. Update operation writes whole row in WAL even if 1 or 2columns are modified. This can lead to increase in overall WAL traffic.
3. During Async Commit, each time to check tuple visibility it needs to refer CLOG Buffer/File which is costly.
4. Calculating CRC for each WAL can be costly especially in case during full data page writes.

## Redo Log Files（写的应该是oracle的。）

 Redo log uses operating system block size 
– usually 512 bytes
– format dependent on 
• operating system
• Oracle version

Each redo log consists of
– header
– redo records

 Redo log is written sequentially

 Block 0 Block 1 Block 2
Redo
Record
1
File
Header
Redo
Header
Block 3
Redo
Records
2 & 3
Block 4
Redo
Records
3 & 4
Block M
Redo
Record
N


A redo record consists of 
– redo record header
– one or more change vectors

Each redo record contains undo and redo for an atomic change

Some changes do not require undo

Redo
Record
Header
Change
#1
Change
#2
Change
#3
Change
#N


Redo Record Header

Every redo record has a header
REDO RECORD - Thread:1 RBA: 0x003666.000000cf.0010 LEN: 0x019c VLD: 0x01
SCN: 0x0000.00eb1279 SUBSCN: 1 05/08/2003 15:44:12

## Advantages/Disadvantages Of Oracle Implementation

Advantages

1. Update has less redo as it writes only changed data.
2. Group commits by LGWR can reduce the overall I/O and improve performance.
3. Writing in block sizes same as hardware/OS block size gives benefit.
4. Log writer flushes redo if redo log buffer is 1/3rd full which will make sure there can never be contention for Redo Log Buffer.

Disadvantages

1. There can be lot of space wastage in Redo log files during high activity in database.
2. Redo of Insert and Delete SQL statements will be more as compare to PostgreSQL because it has to write Redo for Undo data generated as well.
3. Headers size is more compare to PostgreSQL. It can have multiple headers for one Redo Record. 1st for each Redo Record then for each Change Vector.

## Improvements in PostgreSQL

1. For Update operation the amount of WAL required can be reduced by writing only changed column values and reconstruct full row during recovery.
2. Flushing Data page contents during Commit by main user process is costly, other databases does it in background process.
3. We can introduce a concept similar to Group Commits by WAL writer which can improve performance during high volume of transactions.
4. Improve the Tuple visibility logic for setting the transaction status in a tuple during Asynchronous Commits.
5. To improve the writing of same Redo Block again and again if the transaction data is small.

## Need for WAL reduction for Update

• In most telecom scenario’s, the Update operation updates few columns out of all used in schema
• For example

CREATE TABLE callinfo ( logtime date not null, updatetime date, 
callerno varchar2(20), agentid varchar2(10), status int, i0 
int, c0 varchar2(20), i1 int, c1 varchar2(20), i2 int, 
c2 varchar2(20), i3 int,c3 varchar2(20),i4 int,c4 varchar2(20),
i5 int,c5 varchar2(20),i6 int,c6 varchar2(20),i7 int,
c7 varchar2(20), i8 int,c8 varchar2(20),i9 int,
c9 varchar2(20),content varchar2(512));
update callinfo set status = status + 1, i0 = i0 + 1 where callerno = :callerno

## Method-1 to reduce WAL for Update op

• Only send the changed data to WAL and reconstruct tuple during recovery.
• Reconstruction would need the old tuple data and the new tuple changed data to reconstruct the row at time of recovery.
• After the row is generated it will be inserted in data page.
• It is better to do apply this method when old and new tuple are on same page, otherwise it need to do I/O during recovery.
• The changed columns are logged in a byte-by-byte instruction set format using tuple descriptor.

## Method-1 Contd..

• Byte-byByte format is used instead of attributes and number of attribute as we don’t tuple descriptor during recovery.
• The diff instructions allow us to express operations very simply. For Example,
CREATE TABLE foo (col1 integer, col2 integer, col3 varchar(50), col4 varchar(50));
INSERT INTO foo values (1, 1, repeat('abc',15), repeat(‘def’,15));

## Method-1 Contd..

UPDATE foo SET col2 = 100 WHERE col1 = 1;
will generate diff instructions (assuming 4 byte alignment for now) 
COPY 4 (bytes from old to new tuple) 
IGNORE 4 (bytes on old tuple) 
ADD 4 (bytes from new tuple) 
COPY 90 (bytes from old to new tuple)

## Method-1 Contd..

• With a terse instruction set the diff format can encode the diff instructions in a small number of bytes, considerably reducing the WAL volume.
• The simplicity of the diff algorithm is important because this introduces 
- additional CPU and 
- potentially contention also, since the diff is calculated while the block is locked.
• As a result, it is proposed that the diff would only be calculated when the new tuple length is in excess of a hard-coded limit

## Method-2 to reduce WAL for Update op

• This method of reducing WAL will be applied only if table has fixed length columns(int,char,float).
• Keep only changed data and offset of it in WAL.
• Reconstruction would need the old tuple data and the new tuple changed data to reconstruct the row at time of recovery.
• After the row is generated it will be inserted in data page.
• It is better to do apply this method when old and new tuple are on same page, otherwise it need to do I/O during recovery.

## Method-2 Contd..

• log the offset, length, value format for changed data to reconstruct the row during recovery.
• During recovery with this information the new row can be constructed without even tuple descriptor.
• As the log format is only for fixed length columns, so during recovery
it can be directly applied at mentioned locations to generate a new tuple.
• This method can also be optimized such that it will log in described format if all changed columns are before any variable data type column.

## Method-2 Contd..

• For Example
CREATE TABLE foo (col1 integer, col2 integer, col3 varchar(50), col4 varchar(50)); 
INSERT INTO foo values (1, 1, repeat('abc',15), repeat(‘def’,15)); 
UPDATE foo SET col2 = 100 WHERE col1 = 1;
• will generate log without considering tuple header
old tuple location
Offset: 5, length: 4 value: 100
• offset and length can be stored in 2-3 bytes considering this will be 
applied tuples of length less than 2000 bytes.

## Comparison for method-1 & method-2

• Method-1 is valid irrespective of data type of columns, whereas Method-2 is applied only in certain cases depending on datatype.
• In case of Method-2, contention chances will be less as the information required for logging should be available during tuple formation.
• Generation of new tuple during recovery can be faster in Method-2 as it needs to make a copy of original tuple and then replace new values at specified location.