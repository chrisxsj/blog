# hgdw gpexpand

gpexpand

集群扩容

## 1. 将主机加入集群

新增主机需要这步，在原有主机扩展不需要这一步

1. 环境配置，例如OS kernel 参数
参考[最佳实践](./hgdw_best_practices.md)
2. 创建DW管理用户
参考[安装文档](./hgdw_install.md)
3. ssh key免密配置

**root和hgadmin用户都需要执行**

```bash
gp4生成rsa key

ssh-keygen -t rsa

gp1将公钥复制到gp4机器的authorized_keys文件中
ssh-copy-id -i ~/.ssh/id_rsa.pub hgadmin@gp4

在master节点打通免密登陆
gpssh-exkeys -e exist_hosts -x expand_hosts

[hgadmin@gp1 ~]$ cat hostfile_exist
gp1
gp2
gp3
[hgadmin@gp1 ~]$ cat hostfile_expand
gp4

hgssh-exkeys -e /home/hgadmin/hostfile_exist -x /home/hgadmin/hostfile_expand

```

1. DW安装目录 软件的拷贝（bin）

规划segment数据目录；

```bash
root
source /usr/local/hgdw/hgdw_path.sh
hgssh -f  /home/hgadmin/hostfile_expand -e 'mkdir -p /opt/software'
hgssh -f  /home/hgadmin/hostfile_expand -e 'chmod 777 /opt/software'

gpscp -f  /home/hgadmin/hostfile_expand /opt/software/hgdw_3.0.zip  root@=:/opt/software
hgssh -f  /home/hgadmin/hostfile_expand -e 'unzip -d /usr/local /opt/software/hgdw_3.0.zip'
hgssh -f  /home/hgadmin/hostfile_expand -e 'chown hgadmin:hgadmin /usr/local/hgdw -R'

```

5. 同步环境变量

```bash
su - hgadmin
gpscp -f  /home/hgadmin/hostfile_expand /home/hgadmin/.bash_profile  hgadmin@=:/home/hgadmin/.bash_profile

```

6. 使用gpcheckperf检查性能 
gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfnet_expand -r N -d /tmp
gpcheckperf -f /home/hgadmin/hostfile_gpcheckperfio_expand -r ds -d /pgdata/test1 -d /pgdata/test2  -v

## 2 初始化segment并加入集群

这一步主要做的是
产生配置文件,也可以自己写配置文件

```bash
gpexpand -f /home/hgadmin/hostfile_expand

[hgadmin@gp1 ~]$ gpexpand -f /home/hgadmin/hostfile_expand
20200804:16:24:25:018378 gpexpand:gp1:hgadmin-[INFO]:-local HGDW Version: 'postgres (HGDW Database) 3.0'
20200804:16:24:25:018378 gpexpand:gp1:hgadmin-[INFO]:-master HGDW Version: 'PostgreSQL 9.4.24 (HGDW Database 3.0 build dev) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-39), 64-bit compiled on Mar 26 2020 17:28:51'
20200804:16:24:25:018378 gpexpand:gp1:hgadmin-[INFO]:-Querying gpexpand schema for current expansion state

System Expansion is used to add segments to an existing GPDB array.
gpexpand did not detect a System Expansion that is in progress.

Before initiating a System Expansion, you need to provision and burn-in
the new hardware.  Please be sure to run gpcheckperf to make sure the
new hardware is working properly.

Please refer to the Admin Guide for more information.

Would you like to initiate a new System Expansion Yy|Nn (default=N):
> y
20200804:16:24:39:018378 gpexpand:gp1:hgadmin-[ERROR]:-gpexpand failed: You must be adding two or more hosts when expanding a system with mirroring enabled.

Exiting...
20200804:16:24:39:018378 gpexpand:gp1:hgadmin-[INFO]:-Shutting down gpexpand...
[hgadmin@gp1 ~]$ gpexpand -f /home/hgadmin/hostfile_expand

```

在指定目录初始化segment数据库(gpexpand -i cnf -D dbname )；


将新增的segment信息添加到master元表；
操作如下：
gpexpand  -f  host_file(对应要扩展的host列表，如果是新增host也是这个操作)
输入1命令后会提示增加segment个数
    >增加host个数
    >依次写入对应的segment的路径
   输入完成后会生成文件:gpexpand_inputfile_yyyymmdd_XXXX
 gpexpand -i gpexpand_inputfile_yyyymmdd_XXXX(开始生成新增segment)

## 3 重分布表
 执行gpexpand -d 1:00:00  进行重分布（这个命令的意思是扩展所有表，直到扩展完成或者持续一个小时后）
 备注:完成后如果要重新扩展，需要gpexpand -c删除后再次运行gpexpand -f 