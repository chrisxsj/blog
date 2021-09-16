# gp 测试用例2

## 数据库适配

### 数据库初始化测试

1）数据库集群安装；
安装成功

2）创建实例，数据库，用户并创建表Test1；

```sql
create role highgouser with superuser login password 'highgouser';
create database highgodb owner highgouser;
create table test_t(i_id integer not null,i_name varchar(24),id_price decimal(5,2),i_data varchar(50),i_im_id integer) distributed by (i_id);

```

3）数据库重启；
数据库能够重启成功，重启后的数据库功能正常。

```bash
hgstop -M fast
hgstart

```

4）将csv文件导入到数据库中，且数据量保持一致；
以下表格统计各个表：导入数据量、导入耗时、导出数据量、导出耗时、恢复数据量、恢复耗时：

导入导出csv数据

CREATE external table ext_dj_sj(
	ID varchar,
	DJSLSQ_ID varchar,
	YWH varchar,
	YSDM varchar,
	SJSJ timestamp,
	SJLX varchar,
	SJMC varchar,
	SJSL varchar,
	SFSJSY varchar,
	SFEWSJ varchar,
	SFBCSJ varchar,
	YS varchar,
	BZ varchar,
	SCRKSJ varchar,
	GXSJ varchar,
	QXDM varchar,
	RECORDS varchar,
	QLDJLX varchar
	) location('gpfdist://192.168.6.11:8081/home/hgadmin/gpfdist/dj_sj.csv') format 'CSV' ( header DELIMITER ',' NULL as '') encoding 'UTF8';


create
	external table
		ext_fw_zrz(
			"ID" varchar,
			"ZD_ID" varchar,
			"BSM" varchar,
			"YSDM" varchar,
			"BDCDYH" varchar,
			"ZDDM" varchar,
			"ZRZH" varchar,
			"XMMC" varchar,
			"JZWMC" varchar,
			"JGRQ" varchar,
			"JZWGD" varchar,
			"ZZDMJ" varchar,
			"ZYDMJ" varchar,
			"YCJZMJ" varchar,
			"SCJZMJ" varchar,
			"DXSD" varchar,
			"GHYT" varchar,
			"FWJG" varchar,
			"ZTS" varchar,
			"JZWJBYT" varchar,
			"DAH" varchar,
			"BZ" varchar,
			"ZT" varchar,
			"SCRKSJ" varchar,
			"GXSJ" varchar,
			"QXDM" varchar,
			"BDCDYH_OLD" varchar,
			"ZDDM_OLD" varchar,
			"RECORDS" varchar,
			"QLDJLX" varchar,
			"BDCDYH_NEW" varchar,
			"ZDDM_NEW" varchar,
			"BSM_BACKUP" varchar,
			"ZCS" varchar,
			"DSCS" varchar,
			"DXCS" varchar
		) location('gpfdist://192.168.6.11:8081/home/hgadmin/gpfdist/fw_zrz.csv') format 'CSV'(header delimiter ',' null as '') encoding 'UTF8';

drop dj_sj


CREATE table dj_sj(
	ID varchar,
	DJSLSQ_ID varchar,
	YWH varchar,
	YSDM varchar,
	SJSJ timestamp,
	SJLX varchar,
	SJMC varchar,
	SJSL varchar,
	SFSJSY varchar,
	SFEWSJ varchar,
	SFBCSJ varchar,
	YS varchar,
	BZ varchar,
	SCRKSJ varchar,
	GXSJ varchar,
	QXDM varchar,
	RECORDS varchar,
	QLDJLX varchar
	);


create table fw_zrz(
			"ID" varchar,
			"ZD_ID" varchar,
			"BSM" varchar,
			"YSDM" varchar,
			"BDCDYH" varchar,
			"ZDDM" varchar,
			"ZRZH" varchar,
			"XMMC" varchar,
			"JZWMC" varchar,
			"JGRQ" varchar,
			"JZWGD" varchar,
			"ZZDMJ" varchar,
			"ZYDMJ" varchar,
			"YCJZMJ" varchar,
			"SCJZMJ" varchar,
			"DXSD" varchar,
			"GHYT" varchar,
			"FWJG" varchar,
			"ZTS" varchar,
			"JZWJBYT" varchar,
			"DAH" varchar,
			"BZ" varchar,
			"ZT" varchar,
			"SCRKSJ" varchar,
			"GXSJ" varchar,
			"QXDM" varchar,
			"BDCDYH_OLD" varchar,
			"ZDDM_OLD" varchar,
			"RECORDS" varchar,
			"QLDJLX" varchar,
			"BDCDYH_NEW" varchar,
			"ZDDM_NEW" varchar,
			"BSM_BACKUP" varchar,
			"ZCS" varchar,
			"DSCS" varchar,
			"DXCS" varchar
		);

insert into dj_sj select * from ext_dj_sj;

select hg_segment_id,count(*) from dj_sj group by hg_segment_id;

5）单独查询每一个节点的总数据量，核心表的数据条数；
6）数据备份导出，导出后并将数据库Drop掉；
导入已备份的文件，使数据库恢复正常。
