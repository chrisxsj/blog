# gpfdist

gpfdist用于批量加载数据，相较于copy，copy只能通过master节点。gpfdist可实现所有节点并行高效加载，并行速度取决于你的分片数。

工作作原理

1. 启动gpfdist，并在Master上建表。表建好后并没有任何数据流动，只是定义好了外部表的原始数据信息。
2. 将外部表插入到一张Greenplum的物理表中，开始导入数据。
3. Segment根据建表时定义的gpfdist url个数，启动相同的并发到gpfdist获取数据，其中每个Segment节点都会连接到gpfdist上获取数据。
4. gpfdist收到Segment的连接并要接收数据时，开始读取文件，顺序读取文件，然后将文件拆分成多个块，随机抛给Segment。
5. 由于gpfdist并不知道数据库中有多少个Segment，数据是按照哪个分布键拆分的，因此数据是随机发送到每个Segment上的，数据到达Segment的时间基本上是随机的，所以外部表可以看成是一张随机分布的表，将数据插入到物理表的时候，需要进行一次重新分布。
6. 为了提高性能，数据读取于与重分布是同时进行的，当数据重分布完毕后，整个数据导入流程结束。

gpfdist最主要的功能

* 负载均衡：每个Segment分配到的数据都是随机的，所以每个节点的负载都非常均衡。
* 并发读取，性能高：每台Segment都同时通过网卡到文件服务器获取数据，并发读取，从而获取了比较高的性能。`相对于copy命令，数据要通过Master流入，使用外部表就消除了Master这个单点问题。`

如何提高gpfdist性能
Greenplum数据导入，容易出瓶颈的2个地方。

1. 文件服务器
因为所有Segment都连接到文件服务器上获取数据，所以如果文件服务器是单机的，那么文件服务器很容易在磁盘IO和网卡上出现性能瓶颈。
2. Segment节点
Segment节点比文件系统要多不少，Segment一般不会出现磁盘IO和网卡性能问题。当Segment出现瓶颈时，数据导入引起的瓶颈可能性极小，更多的是整个数据库的性能都出现了瓶颈。

ref[使用Greenplum的并行文件服务器（gpfdist）](http://47.92.231.67:8080/6-0/admin_guide/external/g-using-the-greenplum-parallel-file-server--gpfdist-.html)
ref[定义外部表](http://47.92.231.67:8080/6-0/admin_guide/external/g-external-tables.html)

## 启动gpfdist服务

开启gpfdist服务，以用于并行导入数据

```bash
nohup gpfdist -d /home/hgadmin/gpfdist -p 8081 -t 600 -l /home/hgadmin/gpfdist/gpfdist.log 2>&1 &
```

参数解释：
-d 指定一个目录，gpfdist将从该目录中为可读外部表提供文件，或为可写外部表创建 输出文件。如果没有指定，默认为当前目录。
-p 设置Greenplum数据库建立与gpfdist进程的连接所允许的时间。默认值是5秒。 允许的值是2到7200秒（2小时）。在网络流量大的系统上可能要增加。
-l 设置日志文件所放的目录，这个参数也可以不用填写。

### 创建外部表

```sql
\timing on

CREATE external table ext_sb_payment_detail_00011 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00011.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';

```

参数解释
gpfdist://协议，gpfdist工具从一个文件主机上的目录中把外部数据文件并行提供给Greenplum数据库的所有Segment。所有的主Segment并行地访问外部文件。

Location中填写的gpfdist://服务器地址:端口/文件名称服
务器地址：就是安装linux系统的ip。
端口：就是上面自己配饰的访问gpfdist的端口。
文件名称：就是准备的数据文件名称。
format：设置加载数据文件的格式，delimiter as 定义数据之间的分隔符， null as 定义了null用空值替换。Encoding 设置数据的编码格式。

### 创建目标表

```sql
\timing on

CREATE TABLE sb_payment_detail (
  JFSBID bigint  NOT NULL,
  RYID int  NOT NULL,
  DWID int  NOT NULL,
  JFGZ decimal(10,0)  DEFAULT NULL,
  GRJFJS int  DEFAULT NULL,
  DWJFJS int  DEFAULT NULL,
  GRJFE decimal(10,0)  DEFAULT NULL,
  DWJFE decimal(10,0)  DEFAULT NULL,
  JFRQ timestamp DEFAULT NULL,
  JBR varchar(12) DEFAULT NULL,
  JBSJ timestamp DEFAULT NULL
) distributed by (JFSBID) partition by range (JFSBID)
(
  PARTITION p99 START (9999999901) INCLUSIVE END (10020000001) EXCLUSIVE,
  PARTITION p1002 START (10020000001) INCLUSIVE END (10999999901) EXCLUSIVE,
  PARTITION p100 START (10999999901) INCLUSIVE END (11999999901) EXCLUSIVE, 
  PARTITION p110 START (11999999901) INCLUSIVE END (12999999901) EXCLUSIVE, 
  PARTITION p120 START (12999999901) INCLUSIVE END (13999999901) EXCLUSIVE, 
  PARTITION p130 START (13999999901) INCLUSIVE END (14999999901) EXCLUSIVE, 
  PARTITION p140 START (14999999901) INCLUSIVE END (15999999901) EXCLUSIVE, 
  PARTITION p150 START (15999999901) INCLUSIVE END (16999999901) EXCLUSIVE, 
  PARTITION p160 START (16999999901) INCLUSIVE END (17999999901) EXCLUSIVE, 
  PARTITION p170 START (17999999901) INCLUSIVE END (18999999901) EXCLUSIVE, 
  PARTITION p180 START (18999999901) INCLUSIVE END (19999999900) EXCLUSIVE, 
  DEFAULT PARTITION pdefault
);


```

### 导入数据

```sql
\timing on
insert into mem_fat select * from ext_mee_fat;

\timing on
insert into test_lineitem (select * from ext_lineitem limit 20);
```

### 导出数据

创建可写外部表导出即可。

### 示例

```bash

nohup gpfdist -d /data/txt -p 8081 -t 600 >>/home/hgadmin/gpAdminLogs/gpfdist.log 2>&1 &



/home/hgadmin/sed_company.sh

echo `date` > /home/hgadmin/sed_company.log
echo '/data/txt/test.company.sql > /data/txt/test.company.csv' >> /home/hgadmin/sed_company.log
sed -e "/SET/d" -e "/INSERT INTO \`company\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.company.sql > /data/txt/test.company.csv
echo `date` >> /home/hgadmin/sed_company.log

nohup sh /home/hgadmin/sed_company.sh &



CREATE external table ext_company (
  DWID int,
  CBDWMC varchar(32),
  CBDJZT int,
  SBDJZFZRQ timestamp,
  FDDWZGYXM varchar(32),
  FDDWZGYDH varchar(32),
  FDDWZGYSFZHM varchar(32),
  QSNY timestamp
)
location('gpfdist://172.17.105.139:8081/test.company.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';



CREATE TABLE company (
  DWID int  NOT NULL,
  CBDWMC varchar(32) NOT NULL,
  CBDJZT int  DEFAULT NULL,
  SBDJZFZRQ timestamp DEFAULT NULL,
  FDDWZGYXM varchar(32) DEFAULT NULL,
  FDDWZGYDH varchar(32) DEFAULT NULL,
  FDDWZGYSFZHM varchar(32) DEFAULT NULL,
  QSNY timestamp DEFAULT NULL
) distributed by (DWID);

COMMENT on column company.DWID is '单位ID';
COMMENT on column company.CBDWMC is '单位名称';
COMMENT on column company.CBDJZT is '参保登记状态';
COMMENT on column company.SBDJZFZRQ is '社保登记日期';
COMMENT on column company.FDDWZGYXM is '法人代表姓名';
COMMENT on column company.FDDWZGYDH is '法人代表电话';
COMMENT on column company.FDDWZGYSFZHM is '法人代表证件号码';
COMMENT on column company.QSNY is '参保起始年月';
COMMENT on table company is '法人单位信息-10w条';


insert into company select * from ext_company;


alter table company add primary key (DWID);

```

<!--
=============================================


/home/hgadmin/sed_sb_account.sh

echo `date` > /home/hgadmin/sed_sb_account.log
echo '/data/txt/test.sb_account.sql > /data/txt/test.sb_account.csv' >> /home/hgadmin/sed_sb_account.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_account\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_account.sql > /data/txt/test.sb_account.csv
echo `date` >> /home/hgadmin/sed_sb_account.log

nohup sh /home/hgadmin/sed_sb_account.sh &




CREATE external table ext_sb_account (
  ryid int,
  sjjfnx int,
  zhzje decimal(10,0),
  zhjzny timestamp,
  zhstatus int
)
location('gpfdist://172.17.105.139:8081/test.sb_account.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';


CREATE TABLE sb_account (
  ryid int NOT NULL,
  sjjfnx int  DEFAULT NULL,
  zhzje decimal(10,0) DEFAULT NULL,
  zhjzny timestamp DEFAULT NULL,
  zhstatus int DEFAULT NULL
) distributed by (ryid);



COMMENT on column sb_account.ryid is '人员ID';
COMMENT on column sb_account.sjjfnx is '实际缴费年限';
COMMENT on column sb_account.zhzje is '账户总金额';
COMMENT on column sb_account.zhjzny is '账户截止年月';
COMMENT on column sb_account.zhstatus is '账户状态';

COMMENT on table sb_account is '人员社保账户信息1亿';


insert into sb_account select * from ext_sb_account;


alter table sb_account add PRIMARY KEY (ryid);


/home/hgadmin/sed_staff.sh

echo `date` > /home/hgadmin/sed_staff.log
echo '/data/txt/test.staff.sql > /data/txt/test.staff.csv' >> /home/hgadmin/sed_staff.log
sed -e "/SET/d" -e "/INSERT INTO \`staff\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.staff.sql > /data/txt/test.staff.csv
echo `date` >> /home/hgadmin/sed_staff.log

nohup sh /home/hgadmin/sed_staff.sh &



CREATE external table ext_staff (
  RYID int,
  RYXM varchar(32),
  DWDJID int,
  SHBZHM varchar(64),
  CJGZRQ timestamp,
  XB int,
  CSRQ timestamp,
  JFFS varchar(12),
  BLZYSJ timestamp,
  BLZYJBR varchar(12)
) location('gpfdist://172.17.105.139:8081/test.staff.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';

CREATE TABLE staff (
  RYID int NOT NULL,
  RYXM varchar(32) NOT NULL,
  DWDJID int  NOT NULL,
  SHBZHM varchar(64) NOT NULL,
  CJGZRQ timestamp DEFAULT NULL,
  XB int  DEFAULT NULL,
  CSRQ timestamp DEFAULT NULL,
  JFFS varchar(12) DEFAULT NULL,
  BLZYSJ timestamp DEFAULT NULL,
  BLZYJBR varchar(12) DEFAULT NULL
) distributed by (RYID);

COMMENT on column staff.RYID is '人员ID';
COMMENT on column staff.RYXM is '人员姓名';
COMMENT on column staff.DWDJID is '单位ID';
COMMENT on column staff.SHBZHM is '社会保障号';
COMMENT on column staff.CJGZRQ is '参加工作日期';
COMMENT on column staff.XB is '性别';
COMMENT on column staff.CSRQ is '出生日期';
COMMENT on column staff.JFFS is '缴费方式';
COMMENT on column staff.BLZYSJ is '办理增员时间';
COMMENT on column staff.BLZYJBR is '办理增员经办人';

COMMENT on table staff is '人员基本信息1亿';





insert into staff select * from ext_staff;

alter table staff add PRIMARY KEY (RYID);


==================================================
/home/hgadmin/sed00001.sh

echo `date` > /home/hgadmin/sed00001.log
echo '/data/txt/test.sb_payment_detail.00001.sql > /data/txt/test.sb_payment_detail.00001.csv' >> /home/hgadmin/sed00001.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00001.sql > /data/txt/test.sb_payment_detail.00001.csv
echo `date` >> /home/hgadmin/sed00001.log

nohup sh /home/hgadmin/sed00001.sh &



/home/hgadmin/sed00002.sh

echo `date` > /home/hgadmin/sed00002.log
echo '/data/txt/test.sb_payment_detail.00002.sql > /data/txt/test.sb_payment_detail.00002.csv' >> /home/hgadmin/sed00002.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00002.sql > /data/txt/test.sb_payment_detail.00002.csv
echo `date` >> /home/hgadmin/sed00002.log

nohup sh /home/hgadmin/sed00002.sh &



/home/hgadmin/sed00003.sh

echo `date` > /home/hgadmin/sed00003.log
echo '/data/txt/test.sb_payment_detail.00003.sql > /data/txt/test.sb_payment_detail.00003.csv' >> /home/hgadmin/sed00003.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00003.sql > /data/txt/test.sb_payment_detail.00003.csv
echo `date` >> /home/hgadmin/sed00003.log

nohup sh /home/hgadmin/sed00003.sh &



/home/hgadmin/sed00004.sh

echo `date` > /home/hgadmin/sed00004.log
echo '/data/txt/test.sb_payment_detail.00004.sql > /data/txt/test.sb_payment_detail.00004.csv' >> /home/hgadmin/sed00004.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00004.sql > /data/txt/test.sb_payment_detail.00004.csv
echo `date` >> /home/hgadmin/sed00004.log

nohup sh /home/hgadmin/sed00004.sh &




/home/hgadmin/sed00005.sh

echo `date` > /home/hgadmin/sed00005.log
echo '/data/txt/test.sb_payment_detail.00005.sql > /data/txt/test.sb_payment_detail.00005.csv' >> /home/hgadmin/sed00005.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00005.sql > /data/txt/test.sb_payment_detail.00005.csv
echo `date` >> /home/hgadmin/sed00005.log

nohup sh /home/hgadmin/sed00005.sh &



/home/hgadmin/sed00006.sh

echo `date` > /home/hgadmin/sed00006.log
echo '/data/txt/test.sb_payment_detail.00006.sql > /data/txt/test.sb_payment_detail.00006.csv' >> /home/hgadmin/sed00006.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00006.sql > /data/txt/test.sb_payment_detail.00006.csv
echo `date` >> /home/hgadmin/sed00006.log

nohup sh /home/hgadmin/sed00006.sh &


/home/hgadmin/sed00007.sh

echo `date` > /home/hgadmin/sed00007.log
echo '/data/txt/test.sb_payment_detail.00007.sql > /data/txt/test.sb_payment_detail.00007.csv' >> /home/hgadmin/sed00007.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00007.sql > /data/txt/test.sb_payment_detail.00007.csv
echo `date` >> /home/hgadmin/sed00007.log

nohup sh /home/hgadmin/sed00007.sh &

/home/hgadmin/sed00008.sh

echo `date` > /home/hgadmin/sed00008.log
echo '/data/txt/test.sb_payment_detail.00008.sql > /data/txt/test.sb_payment_detail.00008.csv' >> /home/hgadmin/sed00008.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00008.sql > /data/txt/test.sb_payment_detail.00008.csv
echo `date` >> /home/hgadmin/sed00008.log

nohup sh /home/hgadmin/sed00008.sh &

/home/hgadmin/sed00009.sh

echo `date` > /home/hgadmin/sed00009.log
echo '/data/txt/test.sb_payment_detail.00009.sql > /data/txt/test.sb_payment_detail.00009.csv' >> /home/hgadmin/sed00009.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00009.sql > /data/txt/test.sb_payment_detail.00009.csv
echo `date` >> /home/hgadmin/sed00009.log

nohup sh /home/hgadmin/sed00009.sh &

/home/hgadmin/sed00010.sh

echo `date` > /home/hgadmin/sed00010.log
echo '/data/txt/test.sb_payment_detail.00010.sql > /data/txt/test.sb_payment_detail.00010.csv' >> /home/hgadmin/sed00010.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00010.sql > /data/txt/test.sb_payment_detail.00010.csv
echo `date` >> /home/hgadmin/sed00010.log

nohup sh /home/hgadmin/sed00010.sh &

/home/hgadmin/sed00011.sh

echo `date` > /home/hgadmin/sed00011.log
echo '/data/txt/test.sb_payment_detail.00011.sql > /data/txt/test.sb_payment_detail.00011.csv' >> /home/hgadmin/sed00011.log
sed -e "/SET/d" -e "/INSERT INTO \`sb_payment_detail\` VALUES/d" -e "s/(//g" -e "s/"\),/"/g" -e "s/"\)\;/"/g" /data/txt/test.sb_payment_detail.00011.sql > /data/txt/test.sb_payment_detail.00011.csv
echo `date` >> /home/hgadmin/sed00011.log

nohup sh /home/hgadmin/sed00011.sh &

=========================================================

CREATE external table ext_sb_payment_detail_00001 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00001.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';



CREATE external table ext_sb_payment_detail_00002 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00002.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';



CREATE external table ext_sb_payment_detail_00003 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00003.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';


CREATE external table ext_sb_payment_detail_00004 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00004.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';



CREATE external table ext_sb_payment_detail_00005 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00005.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';


CREATE external table ext_sb_payment_detail_00006 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00006.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';




CREATE external table ext_sb_payment_detail_00007 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00007.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';


CREATE external table ext_sb_payment_detail_00008 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00008.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';



CREATE external table ext_sb_payment_detail_00009 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00009.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';




CREATE external table ext_sb_payment_detail_00010 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00010.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';


CREATE external table ext_sb_payment_detail_00011 (
  JFSBID bigint,
  RYID int,
  DWID int,
  JFGZ decimal(10,0),
  GRJFJS int,
  DWJFJS int,
  GRJFE decimal(10,0),
  DWJFE decimal(10,0),
  JFRQ timestamp,
  JBR varchar(12),
  JBSJ timestamp
) location('gpfdist://172.17.105.139:8081/test.sb_payment_detail.00011.csv') format 'CSV' (DELIMITER ',' NULL as '') encoding 'UTF8';


======================================================

CREATE TABLE sb_payment_detail (
  JFSBID bigint  NOT NULL,
  RYID int  NOT NULL,
  DWID int  NOT NULL,
  JFGZ decimal(10,0)  DEFAULT NULL,
  GRJFJS int  DEFAULT NULL,
  DWJFJS int  DEFAULT NULL,
  GRJFE decimal(10,0)  DEFAULT NULL,
  DWJFE decimal(10,0)  DEFAULT NULL,
  JFRQ timestamp DEFAULT NULL,
  JBR varchar(12) DEFAULT NULL,
  JBSJ timestamp DEFAULT NULL
) distributed by (JFSBID) partition by range (JFSBID)
(
  PARTITION p99 START (9999999901) INCLUSIVE END (10020000001) EXCLUSIVE,
  PARTITION p1002 START (10020000001) INCLUSIVE END (10999999901) EXCLUSIVE,
  PARTITION p100 START (10999999901) INCLUSIVE END (11999999901) EXCLUSIVE, 
  PARTITION p110 START (11999999901) INCLUSIVE END (12999999901) EXCLUSIVE, 
  PARTITION p120 START (12999999901) INCLUSIVE END (13999999901) EXCLUSIVE, 
  PARTITION p130 START (13999999901) INCLUSIVE END (14999999901) EXCLUSIVE, 
  PARTITION p140 START (14999999901) INCLUSIVE END (15999999901) EXCLUSIVE, 
  PARTITION p150 START (15999999901) INCLUSIVE END (16999999901) EXCLUSIVE, 
  PARTITION p160 START (16999999901) INCLUSIVE END (17999999901) EXCLUSIVE, 
  PARTITION p170 START (17999999901) INCLUSIVE END (18999999901) EXCLUSIVE, 
  PARTITION p180 START (18999999901) INCLUSIVE END (19999999900) EXCLUSIVE, 
  DEFAULT PARTITION pdefault
);

9999999901

10010000001

10999999901
11999999901
12999999901
13999999901
14999999901
15999999901
16999999901
17999999901
18999999901
19999999900

10010000000

COMMENT on column sb_payment_detail.JFSBID is '缴费申报ID';
COMMENT on column sb_payment_detail.RYID is '人员ID';
COMMENT on column sb_payment_detail.DWID is '单位ID';
COMMENT on column sb_payment_detail.JFGZ is '缴费工资';
COMMENT on column sb_payment_detail.GRJFJS is '个人缴费基数';
COMMENT on column sb_payment_detail.DWJFJS is '单位缴费基数';
COMMENT on column sb_payment_detail.GRJFE is '个人缴费额';
COMMENT on column sb_payment_detail.DWJFE is '单位缴费额';
COMMENT on column sb_payment_detail.JFRQ is '缴费日期';
COMMENT on column sb_payment_detail.JBR is '经办人';
COMMENT on column sb_payment_detail.JBSJ is '经办时间';

COMMENT on table sb_payment_detail is '人员社保缴费信息100亿';



==================================================

/home/hgadmin/insert00001.sh

echo `date` > /home/hgadmin/insert00001.log
echo 'psql' >> /home/hgadmin/insert00001.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00001;" -L /home/hgadmin/insert00001_psql.log
echo `date` >> /home/hgadmin/insert00001.log

nohup sh /home/hgadmin/insert00001.sh &



/home/hgadmin/insert00002.sh

echo `date` > /home/hgadmin/insert00002.log
echo 'psql' >> /home/hgadmin/insert00002.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00002;" -L /home/hgadmin/insert00002_psql.log
echo `date` >> /home/hgadmin/insert00002.log

nohup sh /home/hgadmin/insert00002.sh &


/home/hgadmin/insert00003.sh

echo `date` > /home/hgadmin/insert00003.log
echo 'psql' >> /home/hgadmin/insert00003.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00003;" -L /home/hgadmin/insert00003_psql.log
echo `date` >> /home/hgadmin/insert00003.log

nohup sh /home/hgadmin/insert00003.sh &



/home/hgadmin/insert00004.sh

echo `date` > /home/hgadmin/insert00004.log
echo 'psql' >> /home/hgadmin/insert00004.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00004;" -L /home/hgadmin/insert00004_psql.log
echo `date` >> /home/hgadmin/insert00004.log

nohup sh /home/hgadmin/insert00004.sh &



/home/hgadmin/insert00005.sh

echo `date` > /home/hgadmin/insert00005.log
echo 'psql' >> /home/hgadmin/insert00005.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00005;" -L /home/hgadmin/insert00005_psql.log
echo `date` >> /home/hgadmin/insert00005.log

nohup sh /home/hgadmin/insert00005.sh &


/home/hgadmin/insert00006.sh

echo `date` > /home/hgadmin/insert00006.log
echo 'psql' >> /home/hgadmin/insert00006.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00006;" -L /home/hgadmin/insert00006_psql.log
echo `date` >> /home/hgadmin/insert00006.log

nohup sh /home/hgadmin/insert00006.sh &



/home/hgadmin/insert00007.sh

echo `date` > /home/hgadmin/insert00007.log
echo 'psql' >> /home/hgadmin/insert00007.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00007;" -L /home/hgadmin/insert00007_psql.log
echo `date` >> /home/hgadmin/insert00007.log

nohup sh /home/hgadmin/insert00007.sh &


/home/hgadmin/insert00008.sh

echo `date` > /home/hgadmin/insert00008.log
echo 'psql' >> /home/hgadmin/insert00008.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00008;" -L /home/hgadmin/insert00008_psql.log
echo `date` >> /home/hgadmin/insert00008.log

nohup sh /home/hgadmin/insert00008.sh &

/home/hgadmin/insert00009.sh

echo `date` > /home/hgadmin/insert00009.log
echo 'psql' >> /home/hgadmin/insert00009.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00009;" -L /home/hgadmin/insert00009_psql.log
echo `date` >> /home/hgadmin/insert00009.log

nohup sh /home/hgadmin/insert00009.sh &



/home/hgadmin/insert00010.sh

echo `date` > /home/hgadmin/insert00010.log
echo 'psql' >> /home/hgadmin/insert00010.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00010;" -L /home/hgadmin/insert00010_psql.log
echo `date` >> /home/hgadmin/insert00010.log

nohup sh /home/hgadmin/insert00010.sh &


/home/hgadmin/insert00011.sh

echo `date` > /home/hgadmin/insert00011.log
echo 'psql' >> /home/hgadmin/insert00011.log
psql -c "insert into sb_payment_detail select * from ext_sb_payment_detail_00011;" -L /home/hgadmin/insert00011_psql.log
echo `date` >> /home/hgadmin/insert00011.log

nohup sh /home/hgadmin/insert00011.sh &



==========

/home/hgadmin/pk.sh

echo `date` > /home/hgadmin/pk.log
echo 'psql sb_payment_detail' >> /home/hgadmin/pk.log
psql -c "alter table sb_payment_detail add primary key(JFSBID);" -L /home/hgadmin/pk_psql.log
echo `date` >> /home/hgadmin/pk.log

nohup sh /home/hgadmin/pk.sh &


## 时间

100亿 分10个通道并行，每个通道10亿，用时5h

cat insert00011.log
Wed Apr 8 04:12:33 CST 2020
psql
Wed Apr 8 09:16:00 CST 2020

-->