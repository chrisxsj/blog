Linux find

Linux中find常见用法示例
find   path   -option   [   -print ]   [ -exec   -ok   command ]   {} \;
find命令的参数；
pathname: find命令所查找的目录路径。例如用.来表示当前目录，用/来表示系统根目录。
-print： find命令将匹配的文件输出到标准输出。
-exec： find命令对匹配的文件执行该参数所给出的shell命令。相应命令的形式为'command' { } \;，注意{ }和\；之间的空格。
-ok： 和-exec的作用相同，只不过以一种更为安全的模式来执行该参数所给出的shell命令，在执行每一个命令之前，都会给出提示，让用户来确定是否执行。
#-print 将查找到的文件输出到标准输出
#-exec   command   {} \;      —–将查到的文件执行command操作,{} 和 \;之间有空格
#-ok 和-exec相同，只不过在操作前要询用户s
 
-ctime -n    查找距现在 n*24H 内修改过的文件
-ctime n    查找距现在 n*24H 前, (n+1)*24H 内修改过的文件
-ctime +n    查找距现在 (n+1)*24H 前修改过的文件
[a|c|m]min    [最后访问|最后状态修改|最后内容修改]min
[a|c|m]time    [最后访问|最后状态修改|最后内容修改]time
linux 文件的几种时间 (以 find 为例):
atime 最后一次访问时间, 如 ls, more 等, 但 chmod, chown, ls, stat 等不会修改些时间, 使用 ls -utl 可以按此时间顺序查看;
ctime 最后一次状态修改时间, 如 chmod, chown 等状态时间改变但修改时间不会改变, 使用 stat file 可以查看;
mtime 最后一次内容修改时间, 如 vi 保存后等, 修改时间发生改变的话, atime 和 ctime 也相应跟着发生改变.
例：
find . -size +3000k -exec ls -ld {}  \;     --比如要查找磁盘中大于3M的文件
find . -size -3000k -exec ls -ld {}  \;     --比如要查找磁盘中小于3M的文件
find -name "*.trc" -ctime +10 |wc -l  --10天前的文件
find -name "*.trc" -ctime +30 -exec rm -rf {} \;   --删除30天之前的文件
find -name "*.trw" -ctime +10 |wc -l
find -name "*.trw" -ctime +30 -exec rm -rf {} \;
find . -ctime +72 |xargs du -cm
find -name "*.trw" -mmin +1440  |wc -l
==========================
查当前目录下的所有普通文件
# find . -type f -exec ls -l {} \; 
-rw-r–r–    1 root      root         34928 2003-02-25   ./conf/httpd.conf 
-rw-r–r–    1 root      root         12959 2003-02-25   ./conf/magic 
-rw-r–r–    1 root      root          180 2003-02-25   ./conf.d/README 
查当前目录下的所有普通文件，并在- e x e c选项中使用ls -l命令将它们列出
 
在/ l o g s目录中查找更改时间在5日以前的文件并删除它们：
$ find logs -type f -mtime +5 -exec   -ok   rm {} \;
 
查询当天修改过的文件
[root@book class]# find   ./   -mtime   -1   -type f   -exec   ls -l   {} \;
 
查询文件并询问是否要显示
[root@book class]# find   ./   -mtime   -1   -type f   -ok   ls -l   {} \;  
< ls … ./classDB.inc.php > ? y
-rw-r–r–    1 cnscn    cnscn       13709   1月 12 12:22 ./classDB.inc.php
[root@book class]# find   ./   -mtime   -1   -type f   -ok   ls -l   {} \;  
< ls … ./classDB.inc.php > ? n
[root@book class]#
 
查询并交给awk去处理
[root@book class]# who   |   awk   ’{print $1"\t"$2}’
cnscn    pts/0
 
来自 <http://shawonline.blog.51cto.com/304978/199674>
 
Eg
 
delete trace
 
/home/highgo/scripts/del_find_audit.sh
 
#!/bin/bash
source ~/.bash_profile
DATE=`date +%Y%m%d%H`
echo `date`'  begin......' >>/home/highgo/scripts/log/del_find_audit$DATE
find /data/highgo/4.3.4/data/audit_log -type f -name "*.csv" -mmin +60  |wc -l >>/home/highgo/scripts/log/del_find_audit$DATE
find /data/highgo/4.3.4/data/audit_log -type f -name "*.csv" -mmin +60 -exec ls -atlh {} \; >>/home/highgo/scripts/del_find_audit$DATE
find /data/highgo/4.3.4/data/audit_log -type f -name "*.csv" -mmin +60 -exec rm  -f {} \; >>/home/highgo/scripts/log/del_find_audit$DATE
echo `date`' end......' >>/home/highgo/scripts/log/del_find_audit$DATE
echo `date`' -------------------------' >>/home/highgo/scripts/log/del_find_audit$DATE