# pg12新特性-迁移recovery.conf到postgresql.conf

## pg12新特性的更改

官方文档
Move recovery.conf settings into postgresql.conf (Masao Fujii, Simon Riggs, Abhijit Menon-Sen, Sergei Kornilov)

recovery.conf is no longer used, and the server will not start if that file exists. recovery.signal and standby.signal files are now used to switch into non-primary mode. The trigger_file setting has been renamed to promote_trigger_file. The standby_mode setting has been removed.

解释

* recovery.conf 配置文件的设置移动到postgresql.conf，recovery.conf文件不再使用
* 若 recovery.conf 存在，数据库无法启动
* recovery.signal 和 standby.signal 文件用来表示非主模式
* trigger_file 参数更名为promote_trigger_file
* standby_mode 参数被移除

## 恢复相关设置

1. To start the server in standby mode, create a file called standby.signal in the data directory. 

若要以standby模式启动创服务器，请在data目录中建standby.signal文件。

> 注,12版本pg_basebackup 使用 -R 参数创建standby.signal
-R
--write-recovery-conf
Create standby.signal and append connection settings to postgresql.auto.conf in the output directory (or into the base archive file when using tar format) to ease setting up a standby server. The postgresql.auto.conf file will record the connection settings and, if specified, the replication slot that pg_basebackup is using, so that the streaming replication will use the same settings later on.

2. To start the server in targeted recovery mode, create a file called recovery.signal in the data directory. If both standby.signal and recovery.signal files are created, standby mode takes precedence. 

若要在standby模式模式下启动服务器，将在data目录中创建名为 recovery.signal 的文件。如果standby.signal和recovery.signal同时存在。则优先使用备用模式。

## reference

[官方文档](https://www.postgresql.org/docs/12/runtime-config-wal.html#RUNTIME-CONFIG-WAL-ARCHIVE-RECOVERY)

