# performance_turning_os

**作者**

chrisx

**日期**

2021-05-12

**内容**

性能调优-操作系统

----

[toc]

## os

1. 配置操作系统防火墙
ref [firwall](./../os/firewall.md)
2. 禁用selinux
ref [selinux](./../os/selinux.md)
3. 调整操作系统内核参数
ref [kernel_parameters](../os/Kernel_Parameters.md)
4. 配置操作系统资源限制
ref [limits](../os/limits.md)
5. 设置磁盘的IO调度算法
ref [scheduler](../os/scheduler.md)
6. 磁盘预读参数
ref [read_ahead](../os/read_ahead.md)
7. 配置大页内存
ref [hugepages](../os/hugepages.md)
8. 关闭numa
ref [how to disable numa](../os/How%20to%20disable%20NUMA.md)
ref [How to determine if NUMA configuration is enabled or disabled](../os/How%20to%20determine%20if%20NUMA%20configuration%20is%20enabled%20or%20disabled.md)
9. SHMMAX、SHMALL、SHMMNI配置
ref [shmmax_shmall_shmmni](../os/shmmax_shmall_shmmni.md)
10. 关闭透明大页（transparent_hugepage）
ref [Transparent_HugePages](../os/Transparent_HugePages.md)
11. 设置SWAP
ref [Transparent_HugePages](../os/swap.md)

## 调优方法

1  top、free、vmstat、iostat、mpstat、sar

```sh
top
free -m
iostat -dx 2 2
mpstat 2 2
cat /etc/cron.d/sysstat
cat /etc/sysconfig/sysstat
cd /var/log/sa

sar -u -f /var/log/sa/sa29 -s 10:00:00 -e 11:00:00
```
