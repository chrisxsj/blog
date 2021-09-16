# Replication_Feature_Matrix

**作者**

Chrisx

**日期**

2021-09-03

**内容**

High Availablility（高可用）和Load Balanceing（负载）方案介绍

----

[toc]

目前针对PostgreSQL数据库社区内高可用集群的方案大部分都是基于PostgreSQL的流复制进行的。基于流复制，主库连续归档模式运行，备库连续恢复模式运行，保证主备全库数据一致。

pg支持的高可用矩阵

ref [High Availability, Load Balancing, and Replication Feature Matrix](https://www.postgresql.org/docs/13/different-replication-solutions.html)
ref [高可用、负载均衡和复制特性矩阵](http://www.postgres.cn/docs/13/different-replication-solutions.html)

> PostgreSQL不提供 同步多主 复制类型

## 集群的作用

为什么使用高可用集群

* 高可用，减少中断服务时间。保护业务连续性。对比备份恢复，故障时间最短。
* 负载均衡，将负载（工作任务）进行平衡、分摊到多个操作单元上。需要vip
* 健壮性，软件稳定不易出错。解决脑裂
* 可扩展性，可对节点随时添加删除，甚至是在线操作。
* 自动化程度，自动管理

## 方案对比

| 高可用集群方案        | 原理                                         | 功能                                                                                 | 不足                                                                                                             |
| --------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| repmgr                | built-in streaming repl                      | 高可用（switchover，autofailover）；可扩展； 可解决脑裂                              | 没有负载均衡；备库只读；不支持win                                                                                |
| built-in logical repl | built-in logical repl                        | 高可用（手动切换ip）；备库读写                                                       | 需要解决逻辑冲突；只支持表对象；自动化程度较低                                                                   |
| patroni+etcd          | built-in streaming repl+etcd                 | 高可用（switchover，autofailover，autofollow）；健壮性较高，可解决脑裂               | 需要借助第三方软件，配置复杂；至少位3节点？？                    ；备库只读；                                    |
| jdbc+hg_repmgr        | built-in streaming repl                      | 高可用（switchover，autofailover）；负载均衡（sql转发）                              | 脑裂（repmgr的witness解决）；备库提升为主库缺失数据（repmgr的priority？failover_validation_command？）；备库只读 |
| pgpool-2              | built-in streaming repl+pgpool               | 高可用（autofailover）；负载均衡（select）；限制用户连接数 ；执行并行查询；支持vip； | 需要借助第三方软件，配置复杂；不支持win；备库只读；自动化程度较低， 不支持autofollow switchover；不能解决脑裂 ？ |
| keepalived            | built-in streaming repl+keepalived（脚本）   | 高可用（autofailover）；支持vip                                                      | 不支持win；备库只读； 自动化程度较低， 不支持autofollow，switchover；不能解决脑裂 ？                             |
| pacemaker+Corosync    | pacemaker+Corosync                           | 高可用，支持vip                                                                      | 需要借助第三方软件，配置复杂；动化程度较低， 支持follow操作；不能解决脑裂                          |
| Shared Disk           | rose；infoscale（vcs）  ；pacemaker+Corosync | 高可用，可解决脑裂                                                                   | 大部分商业软件收费                                                                                               |

