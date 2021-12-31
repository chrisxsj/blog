# find

**作者**

chrisx

**日期**

2021-12-28

**内容**

find 常见用法介绍

---

[toc]

## 按时间查找文件

linux 文件的几种时间

* atime 最后一次访问时间, 如 ls, more 等, 但 chmod, chown, ls, stat 等不会修改些时间, 使用 ls -utl 可以按此时间顺序查看;
* ctime 最后一次状态修改时间, 如 chmod, chown 等状态时间改变但修改时间不会改变, 使用 stat file 可以查看;
* mtime 最后一次内容修改时间, 如 vi 保存后等, 修改时间发生改变的话, atime 和 ctime 也相应跟着发生改变.

```sh
find -name "*.trc" -ctime +10 |wc -l  #10天前的文件
find -name "*.trc" -ctime +30 -exec rm -rf {} \;   #删除30天之前的文件
find -name "*.trw" -ctime +10 |wc -l
find -name "*.trw" -ctime +30 -exec rm -rf {} \;
find . -ctime +72 |xargs du -cm
find -name "*.trw" -mmin +1440  |wc -l

```

eg

```sh
#!/bin/bash
source ~/.bash_profile
DATE=`date +%Y%m%d%H`
echo `date`'  begin......' >>/home/highgo/scripts/log/del_find_audit$DATE
find /data/highgo/4.3.4/data/audit_log -type f -name "*.csv" -mmin +60  |wc -l >>/home/highgo/scripts/log/del_find_audit$DATE
find /data/highgo/4.3.4/data/audit_log -type f -name "*.csv" -mmin +60 -exec ls -atlh {} \; >>/home/highgo/scripts/del_find_audit$DATE
find /data/highgo/4.3.4/data/audit_log -type f -name "*.csv" -mmin +60 -exec rm  -f {} \; >>/home/highgo/scripts/log/del_find_audit$DATE
echo `date`' end......' >>/home/highgo/scripts/log/del_find_audit$DATE
echo `date`' -------------------------' >>/home/highgo/scripts/log/del_find_audit$DATE

```

## 按照大小查找文件

```sh
find . -size +3000k -exec ls -ld {}  \;     #比如要查找磁盘中大于3M的文件
find . -size -3000k -exec ls -ld {}  \;     #比如要查找磁盘中小于3M的文件

```

## 查找文件内容

```sh
find log_2021-12-24*|xargs grep -ri "update"    #查找前缀log_2021-12-24的所有文件，带有update的内容

```
