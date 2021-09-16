# 流复制

## 流复制启动

主：walsender
备：walreceiver

步骤

6. wal接收器接受连接请求，启动wal发送器进程。并建立连接
7. 如果备库最新LSN小于主库最新LSN，那么wal发送器将前一个LSN到后一个LSN之间的WAL数据发送到WAL接收器。这些wal数据来自主库的PG_WAL子目录的wal段。这一阶段称为追赶阶段。
8. 流复制开始工作

## 如何实施流复制

主从通信
主：walsender
备：walreceiver

参数配置
synchronous_standby_names='s1'
host_standby=on
wal_level=archive

5. wal接收器调用函数（如fsync（））将wal数据刷新到wal段中，向wal发送器返回另一个ACK响应，并通知启动进程相关wal数据已更新
6. 启动进程重放已写入wal段的wal数据


## 管理多个备库

使用参数synchronous_standby_names='s1,s2'

s1优先级为1
s2优先级为2
未在此参数中的备库处于异步模式，优先级为0

