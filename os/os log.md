Windows: Save Application Log and System Log as txt files Using Event Viewer
Linux: /var/log/messages
Sun: /var/adm/messages
HP-UX: /var/adm/syslog/syslog.log
Tru64: /var/adm/messages
IBM: /bin/errpt - a (redirect this to a file called messages.out or something similar)
 
Common UNIX Commands Available on Most UNIX Platforms (文档 ID 69083.1)  和 Unix Commands on Different OS's [ID 293561.1]
默认操作系统日志保留4周，建议保留更长时间方便问题追溯。
修改方法：
#修改操作系统日志保留策略配置文件
vi /etc/logrotate.conf
#将其中# keep 4 weeks worth of backlogs
rotate 4
#改为 rotate 50
#设置立即生效
root用户执行：logrotate -f /etc/logrotate.conf