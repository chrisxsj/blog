# repmgrd_log_rotation

**作者**

chrisx

**日期**

2021-05-17

**内容**

repmgr配置和使用

ref [repmgrd log rotation](https://repmgr.org/docs/5.1/repmgrd-log-rotation.html)

----

[toc]

## repmgrd log rotation

要确保当前的repmgrd日志文件（在repmgr.conf中使用参数log_file指定）不会无限增长，请配置系统的logrotate以定期对其进行循环。

瀚高repmgr集群配置

1. 启动repmgrd

```sh
$ repmgrd -d
```

2. hg_repmgr.conf中配置日志log_file

```sh
$ cat conf/hg_repmgr.conf |grep log_file |grep -v '#'   #查看repmgr日志配置
log_file='/opt/HighGo6.0.2-cluster/repmgr.log'
```

3. 在/etc/logrotate.d目录下创建文件

```sh

# vi /etc/logrotate.d/hgrepmgr  #循环配置

/opt/HighGo6.0.2-cluster/repmgr.log {
       missingok
       compress
       rotate 1
       maxsize 100M
       daily
       create 0600 highgo highgo
       postrotate
           /usr/bin/killall -HUP repmgrd
       endscript
   }


yum install logrotate -y    #logrotate命令
yum install psmisc -y   #killall命令


repmgr primary register -F  #重新读取配置文件
repmgr standby register -F  #重新读取配置文件

```

logrotate 是一个 linux 系统日志的管理工具。可以对单个日志文件或者某个目录下的文件按时间 / 大小进行切割，压缩操作；指定日志保存数量；还可以在切割之后运行自定义命令。

关于rotate规则的配置，从logrotate.conf文件里可以看到，配置方式有两种

一种是直接在logrotate.conf里配置，适用于系统日志文件。
另外一种是如果你要做rotate的日志文件是由第三方RPM包软件产生的，需要在/etc/logrotate.d这个文件夹下新建一个配置文件，配置相关rotate规则。（其实如果你安装了第三方的软件包之后，在/etc/logrotate.d这个文件夹下就会自动创建了对应软件的rotate配置文件。）

一般情况下呢，logrotate是基于每天的cron job来执行的，所以对某个log文件的rotae每天执行一次，除非rotate的执行标准是基于log文件大小，并且你logrotate这个命令每天被执行了多次，也就是你自定义了定时任务，让logrotate每x分钟或者每x小时执行一次，再或者你手动执行这个命令添加了-f/--force这个选项。

在/etc/cron.daily/这个文件夹下有一个logrotate可执行脚本，那每天就会跑一次

4. 如果需要每天运行多次，可加入计划任务，调用logrotate命令

```sh
#crontab -e
59 12,23 * * *  /usr/sbin/logrotate -f /etc/logrotate.d/hgrepmgr
```
