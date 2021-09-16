# 起源发展
2003：Greenplum由scott yala和luke lonergan成立
2005：Greenplum数据库第一个版本发布
2014：Greenplum4.3发布
 
OLTP：on-line transaction processing
OLAP：on-line analytical processing
 
Oracle RAC：shared-everything
Greenplum：shared-nothing
 
Greenplum基于postgresql开发，与postgresql兼容性非常好
 
# 特性及应用场景
## 特性
	1. 
海量数据处理能力，TB到PB
	2. 
高性价比，各种硬件选型的自由行、license相比RAC,teradata，价格低廉；易维护，维护成本低
	3. 
支持Just in time BI，实现动态数据仓库（ADW），业务用户能对当前业务数据进行BI实时分析
	4. 
易用性，基于postgresql，语法，工具与postgresql兼容，一致。
	5. 
支持线性扩展
	6. 
并发支持和高可用。Greenplum提供数据曾mirror机制保护，将每个节点的数据在另外的节点中同步镜像。对于主节点，提供master/standby机制容错
	7. 
支持mapreduce
	8. 
数据库内部压缩。greenplum支持数据库表进行压缩处理，提升数据库性能


## 场景
最大特点是不需要高端硬件支持仍然可以支撑大规模高性能 数据仓库和商业只能查询