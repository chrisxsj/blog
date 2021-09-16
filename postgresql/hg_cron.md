# hg_cron

参考手册

## 配置管理 hg_cron

参数

```bash
#shared_preload_libraries = ''          # (change requires restart)
#hg_cron.date = ''  #24-hour format  ,example  13:10
#hg_cron.script = '' #script absolute path


```

启用

```sql
alter system set shared_preload_libraries=level_check,pgaudit,worker_hg_cron;

pg_ctl restart

alter system set hg_cron.date = '13:10';
alter system set hg_cron.script = '/opt/backup/script_name';

pg_ctl reload

```

## 参数说明

参数名 设置内容 说明
shared_preload_libraries ’worker_hg_cron’ 此参数指定插件需要依赖的
预加载库名，没有此参数则
worker_hg_cron 无法工作。
此参数修改，需重启数据
库。
hg_cron.date ‘13:10’ 此参数指定执行时间。格式
为“HH24:MI”。
此 参 数 修 改 可 通 过 pg_ctl 
reload 直接生效。
hg_cron.script ‘/opt/backup/script
_name’
此参数指定执行脚本相关的
绝对路径。
此 参 数 修 改 可 通 过 pg_ctl 
reload 直接生效