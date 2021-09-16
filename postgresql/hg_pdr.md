# hg_pdr

---

[toc]

## 架构介绍

`PDR`,瀚高企业版数据库提供了性能诊断报告，Performance Diagnosis Report，简称PDR。
瀚高数据库性能监控与诊断组件, 实现了周期性的收集、处理、持久化和维护性能统计数据，主要用于数据库性能问题的诊断与解决。另外，PDR可以生成简单明了、信息丰富和分类清晰的HTML格式性能诊断报告，以方便数据库管理者阅读。（类似Oracle数据库的AWR报告）

Postmaster负责fork出后台进程，该进程使用SPI接口，对数据库内核进行直接访问，实现信息采集和存储。

```bash
$ ps -ef |grep post
......
hgdb601   8186  8176  0 15:11 ?        00:00:00 postgres: pg_wait_sampling collector
hgdb601   8188  8176  2 15:11 ?        00:00:00 postgres: performance diagnosis collector
......

```

PDR启动后，首先初始化SPI接口，用于统计信息的采集和保存。所有信息保存在一个_pg_pdr_模式中，一共有四个表

```sql
_pg_pdr_.pdrdb      --Database基本信息
_pg_pdr_.pdrtable   --Table基本信息
_pg_pdr_.pdrsql     --SQL执行信息
_pg_pdr_.pdrwait    --等待事件信息
```

这四个数据表不可修改表结构，不可修改删除数据，否则将导致无法生成性能分析报告或者生成的性能分析报告不准确。如果因意外情况导致这四个数据表的数据被修改，无法生成准确的性能分析报告，可删除这四张数据表并重启数据库，由快照 id=0 开始生新生成快照。

<!--
默认情况下，每隔一个小时，pdr会采集一次信息，将这些信息存入_pg_pdr_模式的四个表里。每一条信息都带有一个快照id，用以识别采集的数据属于哪个时间段。这些数据，Database基本信息和Table基本信息，来自于postgres自带的PgStat进程，pdr直接从共享内存中将这部分数据读取出来，并存入_pg_pdr_的表中。SQL执行信息来自pg_stat_statements插件，这部分信息也是保存在共享内存中的，可以通过相关函数直接读出。等待事件目前使用了pg_wait_sampling插件，对pg_stat_activity视图进行高频采样，将等待事件进行保存。_pg_pdr_中保存的统计信息，默认保留7天，超过7天的信息会被清理，以节约存储空间。
-->

## 安装配置

1. 启用
数据库初始化完成后，已经完成了PDR的安装，但没有启用。通过配置postgresql.conf可以启用PDR功能

* shared_preload_libraries= worker_pg_pdr,pg_stat_statements,pg_wait_sampling

加载这三个库文件，重启数据库，即可启用PDR功能

2. 配置参数

* pg_pdr.naptime=60
PDR 快照的产生间隔，单位为分钟，默认为 60 分钟产生一次快照。Naptime=0时，代表不启用 PDR 功能。
* pg_pdr.naplife=7
PDR 快照的保存时间，单位为天，默认保存最近 7 天的快照。超过 naplife的快照，会自动删除。
* pg_pdr.napdb=highgo
用于保存 PDR 快照数据表的数据库，默认设置为 highgo 数据库。

3. 创建快照

初次安装和使用 PDR 功能时，采集的第一个快照 id 是 0，用户可以用于生成性能分析报告的快照 id 是从 1 开始的。每拍一次快照，id 加 1。生成快照的时
机有两种，一是计划时间到期（默认 1 小时），自动拍摄快照。二是用户使用pg_pdr_new_snap()函数手工拍快照。

* 自动快照
在数据库启动 1 分钟后自动产生一次快照，然后根据配置文件中的pg_pdr.naptime 自动产生后续快照，无需操作。

* 手动快照

```sql
highgo=# select pg_pdr_new_snap();  --sql命令，手动产生快照
 pg_pdr_new_snap
-----------------
 t      --返回 t，表示生成快照成功。返回 f，表示生成快照失败。
```

> 注意事项：
1手动生成快照不影响自动快照的生成时间间隔。
2若用户修改了系统时间，将时间改为了比已有快照时间更早的时间，此时会带来时间上的混乱，PDR 会停止快照的采集，直到系统时间因流逝或被人为调整到合理时间，PDR 才会继续工作。
3若用户修改了系统时间，将时间增大，使得生成快照时的时间距上次采集快照的时间大于 naptime+60 分钟，此时 PDR 会停止快照的采集，直到重启数据库或人为调整时间，PDR 才会继续工作。
4若用户修改了系统时间，将时间稍微减小但并不比已有快照时间更早，并且立即使用了手动生成快照，此时会出现一次自动快照的时间间隔略有差异，但并不影响后续的自动快照。

## 生成报告

使用 pdr_report 命令，可以生成 PDR 报告

PDR 生成的快照存储在 napdb 配置的数据库中，快照包含整个数据集簇中所有数据库的性能信息。

```bash
[hgdb565@db ~]$ pdr_report
================================================================================
-----------------------------welcome to pdr report------------------------------
================================================================================
please input system user name:
highgo      #输入数据库用户名
please input password for highgo:
            #数据库用户密码
please input the database where the snapshot is stored:
highgo      #快照存储数据库名
please input which database you want to be reported:
highgo      #报告目标数据库名
--------------------------------------------------------------------------------
......
snap_id = 292, snap_ts = 2021-01-13 17:56:48
snap_id = 293, snap_ts = 2021-01-13 18:56:48
snap_id = 294, snap_ts = 2021-01-18 11:01:22
snap_id = 295, snap_ts = 2021-01-18 12:01:22
snap_id = 296, snap_ts = 2021-01-18 13:01:23
snap_id = 297, snap_ts = 2021-01-18 14:01:23
snap_id = 298, snap_ts = 2021-01-18 15:01:23
you can make report from 286(2021-01-11 17:49:21) to 298(2021-01-18 15:01:23)
--------------------------------------------------------------------------------
please input begin snapid(from 286):
297         #开始快照 id
snap_begin=[297]
please input end snapid(up to 298):
298         #结束快照 id
snap_end=[298]
please input html file name for this report(***.html):
highgo_report.html      #性能分析报告为 html 网页格式，可在浏览器中打开。
report ./highgo_report.html has been successfully created.
[hgdb565@db ~]$

```

> 注意事项：
1若开始快照与结束快照期间发生过数据库重启，将无法生成性能分析报告。
2使用 pdr_report 命令时，会分屏列出当前快照存储数据库和报告目标数据库拥有的所有快照 id，此时可使用 Enter 键显示下一行快照 id，可使用空格键显示下一屏快照 id，可使用 q 键停止显示剩余的快照 id。
3当使用pdr_report工具时，用户需要指定生成的数据库名，快照id的起止范围，生成报告的文件名。Pdr_report工具会根据这些信息，从数据库中把用户指定的信息读取出来，填写到pdr_report.html模板中，最终生成pdr报告。
4模板文件pg_pdr.html存放在share目录下，模板文件的样式可以进行修改，不会影响到报告的生成。

设置一个基线PDR。对比。



<!--
有一定理论基础+实验操作+500份pdr
-->