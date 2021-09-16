# greenplum 高可用

4.1启用master镜像
1. 新增主机加入集群作为master的standy（新增主机需要这步，原有主机不需要这步）

环境配置，例如OS kernel 参数;
创建DW管理用户；
ssh key的交换（使用gpssh-exkeys -e exist_hosts -x new_hosts）；
DW安装目录 bin软件的拷贝；
规划standy 数据目录；
使用gpcheck检查 (gpcheck -f new_hosts )；
使用gpcheckperf检查性能 (gpcheckperf -f new_hosts_file -d /data1 -d /data2 -v)
、、、、、、参见前面安装软件过程

2.运行gpinitstandby 工具在当前活动的primarymaster主机上向Greenplum数据库系统增加一个standby master主机:
   gpinitstandby -s host2       （这里-s指定后备Master主机的名称）
    中间输入一次Y
3.检查Master镜像进程状态
   gpstate -f
    说明：standby master的状态应该是passive，WAL sender状态应该是streaming

4.2启用segment镜像
要增加Segment镜像到一个现有系统（和主Segment相同的主机阵列）
    mirror就是镜像，也叫数据备份。mirror对于数据存储来说很重要，因为我们的服务器指不定什么时候出毛病，有mirror就好很多了，因为两台存储节点同时宕掉的几率还是很小的。如果前面在GP初始化文件里没有配置mirror，请按照下面的方法添加
[gpadmin@host3 ~]$ gpaddmirrors -p 10000
运行过程中每个节点的segment的primary有多少个就需要输入多次mirror路径：/ssd_dir/pgdata6/mirror

============

恢复一个已经不同步的Standby：
$ gpinitstandby -n

*****************************************************
EXAMPLES
*****************************************************



Start an existing standby master host and synchronize the data with the 
current primary master host: 

gpinitstandby -n 

NOTE: Do not specify the -n and -s options in the same command. 

不行就remove再add

Remove the existing standby master from your Greenplum system 
configuration: 

gpinitstandby -r 


Add a standby master host to your Greenplum Database system and start 
the synchronization process: 

gpinitstandby -s host09 