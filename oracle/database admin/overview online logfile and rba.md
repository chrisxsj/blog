
## dump日志文件
如果通过控制文件转储，我们可以在控制文件中找到关于日志文件的信息 :
LOG FILE #1: 
  (name #1) /opt/oracle/oradata/conner/redo01.log
Thread 1 redo log links: forward: 2 backward: 0
siz: 0x5000 seq: 0x00000011 hws: 0x2 bsz: 512 nab: 0x2 flg: 0x1 dup: 1
Archive links: fwrd: 0 back: 0 Prev scn: 0x0000.0023ac36
  Low scn: 0x0000.0023afee 11/22/2004  17:10:06 
Next scn: 0x0000.0023aff1 11/22/2004 17:10:11 
同样我们可以通过直接 dump 日志文件的方式来进行转储 :
SQL> alter system dump logfile '/opt/oracle/oradata/conner/redo01.log'; 
System altered.

以下是对RBA的理解！！！！！！！！！！！！！
RBA: redo byte address ==》redo block大小是512bytes
RBA组成==》 thread# 和 sequence#.block#.offset
thread#： 实例通道
sequence#日志序列号：日志重复使用，但每次使用都会有一个唯一序列号
block#：块号
offset： 偏移量 byte number
实验
select * from v$log;   ==》current
alter system switch logfile;
update jason.test_bbwait set name='kkk' where id=1;   --dml操作
update jason.test_bbwait set name='jason' where id=1 and name='kkk';
重新登陆  产生新的会话trace！！=v$diag_info
alter system dump logfile '+DATA/orcl/onlinelog/group_1.261.867775175';   --dump转储日志文件！！！！
select * from v$diag_info where lower(name) like '%default%';
截取dump 文件 /u02/app/oracle/diag/rdbms/orcl/orcl/trace/orcl_ora_9443.trc
那么我们查找一下dml操作的哪条记录
SQL> select dump('kkk',16) from dual;
DUMP('KKK',16)
----------------------
Typ=96 Len=3: 6b,6b,6b
在trace log中搜索 6b 6b 6b
REDO RECORD - Thread:1 RBA: 0x000029.00000002.0010 LEN: 0x0210 VLD: 0x0d
SCN: 0x0000.001b6100 SUBSCN:  1 10/18/2015 23:32:56
(LWN RBA: 0x000029.00000002.0010 LEN: 0002 NST: 0001 SCN: 0x0000.001b60fe)
CHANGE #1 TYP:2 CLS:1 AFN:8 DBA:0x020000cf OBJ:81525 SCN:0x0000.001b4355 SEQ:2 OP:11.5 ENC:0 RBL:0
......
compat bit: 4 (post-11) padding: 1
op: Z
KDO Op code: URP row dependencies Disabled
  xtype: XA flags: 0x00000000  bdba: 0x020000cf  hdba: 0x020000ca
itli: 3  ispac: 0  maxfr: 4858
tabn: 0 slot: 8(0x8) flag: 0x2c lock: 0 ckix: 0
ncol: 2 nnew: 1 size: -2
col  1: [ 3]  6b 6b 6b
SQL> select owner,object_name from dba_objects where data_object_id=81525;
OWNER                      OBJECT_NAME
------------------------------ ------------------------------
JASON                      TEST_BBWAIT
RBA: 0x000029.00000002.0010 ==>转换成10进制   41.2.16==》存放在41号日志第2个块上第16个字节
我们也可以把16进制转化成ascii码
SQL> select chr(to_number('6b','xxxxxxx')) from dual;
CH
--
k
################
rba = redo byte address 。
讲到rba，这里涉及到了几点需要大家提前预知，即controlfile header，ckpt process 与 dbwn process ， dirty buffer 。
先来看一下RBA的构成：
它由3部分组成，4byte+4byte+2byte分别为 logfile sequence number ，logfile block number，byte offsetinto the block ，即redo 序列号，redo block 号，以及偏移量（第几个字节）。
并且全部使用16进制。
例如：rba= 0x000024.000011bd.0010
seq#=0x000024=36
blk#=0x000011bd=4541
ofs#=0x0010=16
接下来说一下instance recovery
这里的Checkpoint position 其实就是cache low rba， End of redo thread就是最后一个on-disk rba。
大家都知道实例恢复的时候需要从cache low rba 到 on-disk rba  ， lowrba  与 on-disk 全部存储在控制文件里面，on-diskrba 可以简单的理解为是 lgwr 最后写日志文件的地址。那么cache low rba是如何而来呢？
cache low rba 其实就是ckpt进程每3秒写入到controlfileheader 上面的rba 。
########################


文档原创，转载请注明出处-------------------
