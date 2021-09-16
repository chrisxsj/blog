架构：
Client--lang--master host--interconnect--segment host（primary，mirror）
---------------standby
------------------------------interconnect--segment host（primary，mirror）
------------------------------interconnect--segment host（primary，mirror）
------------------------------interconnect--segment host（primary，mirror）
Master host负责
+ 建立与客户端会话连接与管理
+ sql解析，形成分布式执行计划
+ 将生成好的执行计划分发到每个segment上执行
+ 收集segment的执行结果
+ master不存储业务数据，只存储数据字典
+ master主机可以一主一备
+ 为了提高性能，master最好独占一台机器
 
Segment host负责
+ 业务数据存储和存取
+ 执行master分发的sql
+ 对于master来说，每个segment都是对等的，负责对应数据的存储和计算
+ 每台机器可以配置一到多个segment
+ 由于每个segment对等，建议采用相同机器配置
+ segment分primary，mirror两种，交错的存放在子节点上
 
master和segment其实都是一个单独的postgresql
master和segment之间通过内部连接interconnect通信（千兆/万兆）
client一般只能与master节点进行交互
 
# 安装
Greenplum没有windows版本，只能安装在类unix系统上
Greenplum对IO消耗大，要求高
下载地址！
https://greenplum.org/
 
1 安装软件
2 配置hostlist
3 使用gpssh-exkeys打通所有节点（ssh互信）
4 将软件分发到每一台机器上
5 配置~/.bash_profile环境变量
6 初始化greenplum配置文件
7 初始化数据库
 
创建新的数据库
数据库启动与关闭
 
greenplum常用命令
1 psql
2 pgAdmin
 
greenplum开发相关
常用函数等