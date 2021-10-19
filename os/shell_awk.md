# awk

awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在其对数据分析并生成报告时，显得尤为强大。简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。

awk工作流程是这样的：读入有'\n'换行符分割的一条记录，然后将记录按指定的域分隔符划分域，填充域，
$0则表示所有域,
$1表示第一个域,
$n表示第n个域。
$NF指最后一个域

## 用法

-F指定域分隔符为':'
awk -F "," '{print $NF}'--$NF指最后一个域

默认域分隔符是"空白键" 或 "[tab]键",所以$1表示登录用户，$3表示登录用户ip,以此类推。

## 示例

[oracle@rhel63single ~]$ rm `ls -l --time-style=full-iso | awk '/2012/{print $9}' `
删除 
截取 完全日期显示格式 文件命令符合2012 以空格为截断点显示第九列
的文件
ls -atlr | awk '/root/{print $9}

[oracle@rhel63single ~]$ ls -l --time-style=full-iso 
total 664
-rw-r--r--. 1 oracle oinstall  48583 2013-02-21 11:14:22.834404645 +0800 ashrpt_1_0221_1114.html
-rw-r--r--. 1 oracle oinstall 429882 2013-02-20 10:06:08.815839174 +0800 awrrpt_1_1_3.html
drwxr-xr-x. 8 oracle oinstall   4096 2011-09-22 16:57:44.000000000 +0800 database
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Desktop
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Documents
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Downloads
-rw-r--r--. 1 oracle oinstall    919 2013-02-20 13:47:41.736856696 +0800 imp_tts_tentbs_10g_to_linux.log
-rw-r--r--. 1 oracle oinstall 137316 2013-02-21 12:41:24.978557370 +0800 monitor_sql.html
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Music
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Pictures
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Public
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Templates
-rw-r--r--. 1 root   root          0 2012-02-24 00:00:19.169470455 +0800 test_lei
-rw-r--r--. 1 oracle oinstall   4096 2013-02-20 15:44:15.000000000 +0800 tts_tentbs_to_linux.dmp
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Videos
-rw-r--r--. 1 oracle oinstall  16384 2013-02-21 17:12:25.771401759 +0800 vtest.dmp
[oracle@rhel63single ~]$ ls -l --time-style=full-iso | awk '/2012/{print $9}'
test_lei
[oracle@rhel63single ~]$ rm `ls -l --time-style=full-iso | awk '/2012/{print $9}' `
rm: remove write-protected regular empty file `test_lei'? y
[oracle@rhel63single ~]$ ls -l --time-style=full-iso 
total 664
-rw-r--r--. 1 oracle oinstall  48583 2013-02-21 11:14:22.834404645 +0800 ashrpt_1_0221_1114.html
-rw-r--r--. 1 oracle oinstall 429882 2013-02-20 10:06:08.815839174 +0800 awrrpt_1_1_3.html
drwxr-xr-x. 8 oracle oinstall   4096 2011-09-22 16:57:44.000000000 +0800 database
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Desktop
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Documents
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Downloads
-rw-r--r--. 1 oracle oinstall    919 2013-02-20 13:47:41.736856696 +0800 imp_tts_tentbs_10g_to_linux.log
-rw-r--r--. 1 oracle oinstall 137316 2013-02-21 12:41:24.978557370 +0800 monitor_sql.html
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Music
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Pictures
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Public
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.257394994 +0800 Templates
-rw-r--r--. 1 oracle oinstall   4096 2013-02-20 15:44:15.000000000 +0800 tts_tentbs_to_linux.dmp
drwxr-xr-x. 2 oracle oinstall   4096 2013-02-21 09:26:40.258328517 +0800 Videos
-rw-r--r--. 1 oracle oinstall  16384 2013-02-21 17:12:25.771401759 +0800 vtest.dmp