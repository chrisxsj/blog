# nmon

## nmon下载

nmon下载地址：http://nmon.sourceforge.net/pmwiki.php
包括nmon和nmon analyze

[nmon文件](./nmon/nmon16j.tar.gz)

## nmon使用

1 nmon命令

 nmon -s 10 -c 2 -f &
      -f 参数:生成文件,文件名=主机名+当前时间.nmon
     -T 参数:显示资源占有率较高的进程
     -s 参数:-s 10表示每隔10秒采集一次数据
     -c 参数:-s 10表示总共采集十次数据
     -m 参数:指定文件保存目录

timeout 400 nmon -s 5  -c 80 -f -m /tmp/nmondata &

2.使用nmon analyser

打开[nmon_analyser_v65.xlsm](./nmon/nmon_analyser_v66.xlsm)
点击Analyze nmon data按钮，选择nmon文件



> 注意：Office Excel是自带宏插件。免费版wps，没有包含宏。

 
下载VBA for WPS
地址：链接：https://pan.baidu.com/s/159ViPS6SMCz68o60ycYsEw 
提取码：zrez

下载VBA7.0.1590_For WPS(中文).exe后，先退出WPS，再直接安装就行，再次打开nmon analyser，启用宏