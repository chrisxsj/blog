# greenplum 集群扩容
1. 将主机加入集群（新增主机需要这步，在原有主机扩展不需要这一步）
环境配置，例如OS kernel 参数；
创建DW管理用户；
ssh key的交换（使用gpssh-exkeys -e exist_hosts -x new_hosts）；
DW安装目录 bin软件的拷贝；
规划segment 数据目录；
使用gpcheck检查 (gpcheck -f new_hosts )；
使用gpcheckperf检查性能 (gpcheckperf -f new_hosts_file -d /data1 -d /data2 -v)
    、、、、、、参见前面安装软件过程
2. 初始化segment并加入集群
这一步主要做的是
产生配置文件（gpexpand -f new_hosts_file），也可以自己写配置文件；
在指定目录初始化segment数据库(gpexpand -i cnf -D dbname )；
将新增的segment信息添加到master元表；
操作如下：
 Gpexpand  -f  host_file(对应要扩展的host列表，如果是新增host也是这个操作)
输入1命令后会提示增加segment个数
    >增加host个数
    >依次写入对应的segment的路径
   输入完成后会生成文件:gpexpand_inputfile_yyyymmdd_XXXX
 gpexpand -i gpexpand_inputfile_yyyymmdd_XXXX(开始生成新增segment)

3. 重分布表
 执行gpexpand -d 1:00:00  进行重分布（这个命令的意思是扩展所有表，直到扩展完成或者持续一个小时后）
 备注:完成后如果要重新扩展，需要gpexpand -c删除后再次运行gpexpand -f 