# pacemaker and corosync installation

**作者**

chrisx

**日期**

2021-04-02

**内容**

* `Pacemaker`是一个集群资源管理软件（CRM）
ref [Pacemaker](https://wiki.clusterlabs.org/wiki/Pacemaker)
ref [Pacemaker Overview](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/high_availability_add-on_overview/s1-pacemakeroverview-haao)
ref [Pacemaker Architecture Components](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/high_availability_add-on_overview/s1-pacemakerarchitecture-haao)
ref [Clusters from Scratch Step-by-Step Instructions for Building Your First High-Availability Cluster](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/2.0/html/Clusters_from_Scratch/index.html)
* `Corosync`是高可用基础架构，用来支持集群中各节点间的通信。
ref [Corosync](http://corosync.github.io/corosync/)
* `pcs`和`pcsd Web UI`是pacemaker管理和控制工具
ref [Pacemaker Configuration and Management Tools](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/high_availability_add-on_overview/s1-pacemakertools-haao)
* `Fencing`

<!--
Redhat7及以上版本自带的集群软件为pacemaker&corosync，Redhat7及之前版本自带集群软件为RHCS

ref [High Availability Add-On Overview](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/high_availability_add-on_overview/ch-introduction-haao)

The High Availability Add-On is a clustered system,There are four major types of clusters: ,There are four major types of clusters:
Storage     --GFS2
High availability    --Pacemaker
Load balancing
High performance
-->

---

[toc]

## pacemaker

Pacemaker历史
Pacemaker来源于OpenAIS项目，从heartbeat2.1.3中分离出来的，单独用来进行集群资源管理的软件

* Pacemaker于2018/07/06发布了2.0版本，之前的版本为1.1系列，其最新发行版为1.1.19。
* Pacemaker由多种语言开发而成（C，python，shell script ，other），主要的开发语言是C，其占比75%以上

ref [Pacemaker Architecture](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/2.0/html/Clusters_from_Scratch/_pacemaker_architecture.html)

* 起搏器主进程（pacemakerd）生成所有其他守护进程，如果它们意外退出，则重新启动它们。

* 集群信息库（CIB）是集群配置以及所有节点和资源状态的XML表示。CIB管理器（基于起搏器）使CIB在集群中保持同步，并处理修改它的请求。

* 属性管理器（pacemakerattrd）维护所有节点的属性数据库，使其在集群中保持同步，并处理修改它们的请求。这些属性通常记录在CIB中。

* 给定CIB的快照作为输入，调度器（pacemaker schedulerd）确定实现集群所需状态所需的操作。

* 本地执行器（pacemaker execd）处理在本地集群节点上执行资源代理的请求，并返回结果。

* fencer（pacemaker fenced）处理对fence节点的请求。给定一个目标节点，fencer决定哪个集群节点应该执行哪个fencer设备，并调用必要的fencer代理（直接调用，或者通过请求其他节点上的fencer对等方），并返回结果。

* 控制器（pacemaker controld）是pacemaker的协调器，维护集群成员的一致视图并协调所有其他组件。

* Pacemaker通过选择一个控制器实例作为指定控制器（DC）来集中集群决策。如果选择的DC进程（或它所在的节点）失败，则快速建立一个新的DC进程。DC通过获取CIB的当前快照来响应集群事件，将其提供给调度器，然后请求执行者（直接在本地节点上，或者通过对其他节点上的控制器对等方的请求）和fencer执行任何必要的操作。

## corosync

corosync是一个组件，也是一个同名的守护进程，它服务于高可用性集群的核心成员身份和成员通信需求。它是高可用性附加组件功能所必需的。
除了这些成员资格和消息传递功能外，corosync还：

* 管理法定人数规则和决定。
* 为跨集群的多个成员协调或操作的应用程序提供消息传递功能，因此必须在实例之间传递有状态或其他信息。

## PCS

pcs可以控制起搏器和Corosync心跳守护进程的各个方面。作为一个基于命令行的程序，PCs可以执行以下群集管理任务：

* 创建和配置Pacemaker/Corosync群集
* 在群集运行时修改其配置
* 远程配置Pacemaker和Corosync，以及启动、停止和显示集群的状态信息

## install

ref [Installation](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/2.0/html/Clusters_from_Scratch/ch02.html)

### install OS(RedHat 7.5 86_64)

1. 禁用firewalld

ref [firewall](./firewall.md)

2. Configure Time Synchronization

It is highly recommended to enable NTP on your cluster nodes
ref [ntp](./ntp.md)

### Configure the OS

```sh
ping 192.168.6.142
ssh 192.168.6.142
```

### 第二个节点重复相关配置

### 配置两个节点间通信

hostname
ssh

ref [Configure Communication Between Nodes](./Configure_Communication_Between_Nodes.md)

### Set up a Cluster

各个发行版均提供pacemaker，可从iso镜像中获取

安装集群软件（两个节点）

```shell
yum install -y pacemaker pcs psmisc policycoreutils-python

```

:warning: 注意

* corosync软件会作为pacemaker的依赖包安装；
* pcs是pacemaker的命令行接口，用来管理pacemaker的资源。类似的工具还有crmsh，需要单独安装。
* 建议配置yum源，注意yum源的位置。 ref [yum_repository_local](./yum_repository_local.md)

## Enable pcs Daemon

启用pcs

```shell
pacemakerd --features   #pcs查看版本和支持
systemctl start pcsd.service
systemctl enable pcsd.service

```

安装的软件包将创建具有禁用密码的hacluster用户。虽然这对于在本地运行pcs命令很好，但是该帐户需要一个登录密码才能执行同步corosync配置或在其他节点上启动和停止集群等任务。

```shell
echo hacluster | passwd --stdin hacluster
ssh db2 'echo hacluster | passwd --stdin hacluster'

```

## Configure Corosync

在任一节点上，使用pcs cluster auth作为hacluster用户进行身份验证

```shell
corosync -v             #corosync查看版本和支持

pcs cluster auth NODE1 NODE2 -u hacluster -p POSSWORD --force
eg:
pcs cluster auth db db2 -u hacluster -p hacluster

-u 用户名
-p 密码
-force  强制
```

:warning: 注意：corosync认证的节点是心跳地址！

接下来，在同一节点上使用pcs cluster setup生成并同步corosync配置

```shell
pcs cluster setup --name mycluster db db2

```

The final corosync.conf configuration on each node should look something like the sample in [Sample Corosync Configuration](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/2.0/html/Clusters_from_Scratch/ap-corosync-conf.html)(/etc/corosync/corosync.conf)

<!--
注意：配置corosync使用的心跳地址，需要修改其配置文件/etc/corosync/corosync.conf
eg：修改心跳地址为 pgha1》192.168.192.101 pgha2》192.168.192.102。如果想使用hostname需要将其解析加入到hosts
[root@pgha1 ~]# cat /etc/corosync/corosync.conf
totem {
    version: 2
    cluster_name: my_cluster
    secauth: off
    transport: udpu
}
nodelist {
    node {
#        ring0_addr: pgha1
    ring0_addr: 192.168.192.101    //心跳地址
        nodeid: 1
    }
    node {
#        ring0_addr: pgha2
    ring0_addr: 192.168.192.102    //心跳地址
        nodeid: 2
    }
}
quorum {
    provider: corosync_votequorum
    two_node: 1    //仲裁策略
}
logging {
    to_logfile: yes
    logfile: /var/log/cluster/corosync.log
    to_syslog: yes
}
-->

## Start and Verify Cluster

启动集群

```shell
pcs cluster start --all
```

也可以单节点启动

```shell
pcs cluster start
or
systemctl start corosync.service
systemctl start pacemaker.service

```

验证corosync安装

```shell
[root@db ~]# corosync-cfgtool -s
Printing ring status.
Local node ID 1
RING ID 0
        id      = 192.168.6.141
        status  = ring 0 active with no faults
[root@db ~]#

ip，定义的ip
status，状态没有错误。

接下来，检查成员资格和仲裁API

[root@db ~]#  corosync-cmapctl | grep members
runtime.totem.pg.mrp.srp.members.1.config_version (u64) = 0
runtime.totem.pg.mrp.srp.members.1.ip (str) = r(0) ip(192.168.6.141)
runtime.totem.pg.mrp.srp.members.1.join_count (u32) = 1
runtime.totem.pg.mrp.srp.members.1.status (str) = joined
runtime.totem.pg.mrp.srp.members.2.config_version (u64) = 0
runtime.totem.pg.mrp.srp.members.2.ip (str) = r(0) ip(192.168.6.142)
runtime.totem.pg.mrp.srp.members.2.join_count (u32) = 1
runtime.totem.pg.mrp.srp.members.2.status (str) = joined
[root@db ~]# pcs status corosync

Membership information
----------------------
    Nodeid      Votes Name
         1          1 db (local)
         2          1 db2
[root@db ~]#

```

验证Pacemaker安装

查看后台进程

```shell
[root@db ~]# ps -ef |grep pacemaker
root      3635     1  0 16:45 ?        00:00:00 /usr/sbin/pacemakerd -f
haclust+  3636  3635  0 16:45 ?        00:00:00 /usr/libexec/pacemaker/cib
root      3637  3635  0 16:45 ?        00:00:00 /usr/libexec/pacemaker/stonithd
root      3638  3635  0 16:45 ?        00:00:00 /usr/libexec/pacemaker/lrmd
haclust+  3639  3635  0 16:45 ?        00:00:00 /usr/libexec/pacemaker/attrd
haclust+  3640  3635  0 16:45 ?        00:00:00 /usr/libexec/pacemaker/pengine
haclust+  3641  3635  0 16:45 ?        00:00:00 /usr/libexec/pacemaker/crmd
root      3827  2203  0 17:00 pts/0    00:00:00 grep --color=auto pacemaker
[root@db ~]#

```

以上必须的后台进程都在

查看集群状态

```shell
[root@db ~]# pcs status
Cluster name: mycluster
WARNINGS:
No stonith devices and stonith-enabled is not false

Stack: corosync
Current DC: db2 (version 1.1.21-4.el7-f14e36fd43) - partition with quorum
Last updated: Fri Apr  2 17:01:28 2021
Last change: Fri Apr  2 16:46:11 2021 by hacluster via crmd on db2

2 nodes configured
0 resources configured

Online: [ db db2 ]

No resources

Daemon Status:
  corosync: active/disabled
  pacemaker: active/disabled
  pcsd: active/enabled
[root@db ~]#

```

最后，确保corosync或pacemaker没有日志启动错误（除了与未配置STONITH相关的消息，目前还可以）

```shell
[root@db ~]# journalctl -b | grep -i error

```

浏览现有配置

```shell
查看xml配置文件
pcs cluster cib

在进行任何更改之前，最好检查配置的有效性。

[root@db ~]# crm_verify -L -V
   error: unpack_resources:     Resource start-up disabled since no STONITH resources have been defined
   error: unpack_resources:     Either configure some or disable STONITH with the stonith-enabled option
   error: unpack_resources:     NOTE: Clusters with shared data need STONITH to ensure data integrity
Errors found during check: config not valid
[root@db ~]#

As you can see, the tool has found some errors. The cluster will not start any resources until we configure STONITH. 

```

<!--
配置服务自启动
systemctl enable pacemaker.service
systemctl enable corosync.service
查看服务日志
journalctl | grep -i error
journalctl -u pacemaker.service

图形界面管理工具
https://192.168.80.101:2224/
-->

## Configure Fencing

Fencing使您的数据不被破坏，因为最流行的fencing形式是切断宿主的电源。为了保证数据的安全，默认情况下会启用fencing。

通过将stonith enabled cluster选项设置为false，可以告诉集群不要使用fencing

```shell
pcs property set stonith-enabled=false
crm_verify -L
```

可使用的fencing设备[Choose a Fence Device](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/2.0/html/Clusters_from_Scratch/_choose_a_fence_device.html)

如
支持SCSI-3的外部共享存储
IPMI设备

配置fencing

```shell
...
Find the name of the correct fence agent: pcs stonith list
Find the parameters associated with the device: pcs stonith describe agent_name
...
```

ref [Example](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/2.0/html/Clusters_from_Scratch/_example.html)

## Create an Active/Passive Cluster

1. 添加资源

我们的第一个资源将是一个唯一的IP地址，集群可以在任何一个节点上提供这个地址。无论在哪里运行任何群集服务，最终用户都需要一个一致的地址来联系他们。在这里，我将选择192.168.6.150 作为浮动地址，给它一个富有想象力的名称ClusterIP，并告诉集群每30秒检查一次它是否正在运行。

```shell
pcs resource create ClusterIP ocf:heartbeat:IPaddr2 \
    ip=192.168.6.150 cidr_netmask=24 op monitor interval=30s

#ocf:heartbeat:IPaddr2告诉Pacemaker有关您要添加的资源的三件事：
#第一个字段（本例中为ocf）是资源脚本所遵循的标准以及在何处找到它。
#第二个字段（本例中为heartbeat）是特定于标准的；对于OCF资源，它告诉集群资源脚本所在的OCF命名空间。
#第三个字段（本例中为IPaddr2）是资源脚本的名称。

#获取可用资源标准列表（的ocf部分）ocf:heartbeat:IPaddr2），运行：
pcs resource standards
#获取可用OCF资源提供者的列表（的heartbeat部分）ocf:heartbeat:IPaddr2），运行：
pcs resource providers
#最后，如果您想查看特定OCF提供程序（的IPaddr2部分）的所有可用资源代理ocf:heartbeat:IPaddr2），运行：
pcs resource agents ocf:heartbeat

```

现在，验证IP资源是否已添加，并显示群集的状态以查看它现在是否处于活动状态：

```shell
[root@db ~]# pcs status
Cluster name: mycluster
Stack: corosync
Current DC: db (version 1.1.21-4.el7-f14e36fd43) - partition with quorum
Last updated: Sun Apr  4 13:55:50 2021
Last change: Sun Apr  4 13:54:53 2021 by root via cibadmin on db

2 nodes configured
1 resource configured

Online: [ db ]
OFFLINE: [ db2 ]

Full list of resources:

 ClusterIP      (ocf::heartbeat:IPaddr2):       Started db

Daemon Status:
  corosync: active/enabled
  pacemaker: active/disabled
  pcsd: active/enabled

```

:warning: 如果ClusterIP没有启动，可能是没有配置fencing，建议禁用fencing。

## Perform a Failover

您可以看到ClusterIP资源的状态是在特定节点上启动的。关闭该机器上的起搏器和Corosync以触发故障转移。

节点1-db节点

```shell
[root@db ~]# ip addr
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:75:89:73 brd ff:ff:ff:ff:ff:ff
    inet 192.168.6.141/24 brd 192.168.6.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.6.150/24 brd 192.168.6.255 scope global secondary enp0s3
       valid_lft forever preferred_lft forever

```

failover

```shell
pcs cluster stop db

```

节点2-db2

```shell
[root@db2 ~]# pcs status
Cluster name: mycluster
Stack: corosync
Current DC: db2 (version 1.1.21-4.el7-f14e36fd43) - partition with quorum
Last updated: Sun Apr  4 14:09:19 2021
Last change: Sun Apr  4 14:08:59 2021 by hacluster via crmd on db

2 nodes configured
1 resource configured

Online: [ db2 ]
OFFLINE: [ db ]

Full list of resources:

 ClusterIP      (ocf::heartbeat:IPaddr2):       Started db2

Daemon Status:
  corosync: active/enabled
  pacemaker: active/disabled
  pcsd: active/enabled

[root@db2 ~]#

```

请注意，db出于集群目的处于脱机状态（它的pcsd仍然处于活动状态，允许它接收pcs命令，但它不参与集群）。

> Quorum
    If a cluster splits into two (or more) groups of nodes that can no longer communicate with each other (aka. partitions), quorum is used to prevent resources from starting on more nodes than desired, which would risk data corruption.
    A cluster has quorum when more than half of all known nodes are online in the same partition, or for the mathematically inclined, whenever the following equation is true:

    total_nodes < 2 * active_nodes

    For example, if a 5-node cluster split into 3- and 2-node paritions, the 3-node partition would have quorum and could continue serving resources. If a 6-node cluster split into two 3-node partitions, neither partition would have quorum; pacemaker’s default behavior in such cases is to stop all resources, in order to prevent data corruption.
    Two-node clusters are a special case. By the above definition, a two-node cluster would only have quorum when both nodes are running. This would make the creation of a two-node cluster pointless, but corosync has the ability to treat two-node clusters as if only one node is required for quorum.
    The pcs cluster setup command will automatically configure two_node: 1 in corosync.conf, so a two-node cluster will "just work".
    If you are using a different cluster shell, you will have to configure corosync.conf appropriately yourself.

## Prevent Resources from Moving after Recovery

在大多数情况下，非常需要防止健康资源在集群中移动。移动资源几乎总是需要一段时间的停机时间。对于像数据库这样的复杂服务，这个周期可能相当长。

为了解决这个问题，Pacemaker提出了资源粘性的概念，它控制了一个服务在其所在位置保持运行的强度。您可能会认为这是停机的“成本”。默认情况下，Pacemaker假设移动资源的成本为零，并将这样做以实现“最佳”[7]资源放置。我们可以为每个资源指定不同的粘性，但通常只需更改默认值即可。

## Configure the Cluster

```shell
[root@pcmk-1 ~]# pcs resource create WebSite ocf:heartbeat:apache  \
      configfile=/etc/httpd/conf/httpd.conf \
      statusurl="http://localhost/server-status" \
      op monitor interval=1min

也可以配置

pcs resource create WebSite ocf:heartbeat:pgsql
```

## Ensure Resources Run on the Same Host

`托管约束`

为了减少任何一台机器上的负载，Pacemaker通常会尝试将配置好的资源分散到集群节点上。但是，我们可以告诉集群两个资源是相关的，需要在同一个主机上运行（或者根本不运行）。在这里，我们指示集群网站只能在集群IP活动的主机上运行。

为了实现这一点，我们使用了一个colocation约束，该约束指示网站必须与ClusterIP在同一节点上运行。共位约束的“强制”部分用无穷大表示。无穷大的分数也意味着，如果ClusterIP在任何地方都不活跃，网站将不被允许运行。

If ClusterIP is not active anywhere, WebSite will not be permitted to run anywhere. 

托管约束是“定向的”，因为它们意味着关于两个资源的位置选择顺序的某些事情。在本例中，我们是说网站需要和ClusterIP放在同一台机器上，这意味着集群在为网站选择位置之前必须知道ClusterIP的位置。

```shell
pcs constraint colocation add WebSite with ClusterIP INFINITY
pcs constraint
```

## Ensure Resources Start and Stop in Order

`顺序约束`

与许多服务一样，Apache可以配置为绑定到主机上的特定IP地址或通配符IP地址。如果Apache绑定到通配符，那么在Apache启动之前还是之后添加一个IP地址并不重要；Apache将在该IP上做出相同的响应。但是，如果Apache只绑定到某个IP地址，那么顺序很重要：如果在Apache启动后添加了该地址，Apache将不会对该地址做出响应。

为了确保我们的网站不管Apache的地址配置如何都能响应，我们需要确保ClusterIP不仅在同一节点上运行，而且在网站启动之前启动。托管约束(colocation)只确保资源一起运行，而不确保它们的启动和停止顺序。

我们通过添加排序约束来实现这一点。默认情况下，所有订单约束都是强制的，这意味着ClusterIP的恢复也将触发网站的恢复。

## Prefer One Node Over Another

`位置约束`

pacemaker不依赖于节点之间的任何硬件对称性，因此很可能是一台机器比另一台机器更强大。

在这种情况下，您可能希望在功能更强大的节点可用时将资源托管在该节点上，以获得最佳性能 - 或者在功能较弱的节点可用时将资源托管在该节点上，因此您不必担心在故障转移后能否处理负载。

为此，我们创建一个`位置约束`。

在下面的位置约束中，我们说网站资源更喜欢节点pcmk-1，得分为50。在这里，分数表示我们希望资源在此位置运行的程度。

```shell
pcs constraint location WebSite prefers pcmk-1=50
pcs constraint
```

查看资源权重

```shell
[root@db2 ~]# crm_simulate -sL

Current cluster status:
Online: [ db2 ]
OFFLINE: [ db ]

 ClusterIP      (ocf::heartbeat:IPaddr2):       Started db2

Allocation scores:
native_color: ClusterIP allocation score on db: 0
native_color: ClusterIP allocation score on db2: 0

Transition Summary:
[root@db2 ~]#

```

## Move Resources Manually

有时管理员需要覆盖集群并强制资源移动到特定位置。在本例中，我们将强制网站移到pcmk-1。

我们将使用pcs resource move命令创建一个分数为无穷大的临时约束。虽然我们可以更新现有的约束，但是使用move可以很容易地在以后摆脱临时约束。如果需要的话，我们甚至可以给约束一个生存期，因此它将自动过期 - ，但在本例中我们没有这样做。

```shell
pcs resource move ClusterIP db2

[root@db ~]# pcs status
...
Full list of resources:

 ClusterIP      (ocf::heartbeat:IPaddr2):       Started db
...
```
