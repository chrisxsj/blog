Linux ps



内存增序
ps aux --sort rss |head -n 10
内存减序
ps aux --sort -rss |head -n 10
cpu增序
ps auxw --sort=%cpu |head -n 10
cpu减序
ps auxw --sort=-%cpu |head -n 10
 
 
# ps aux |more
USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
root 1 0.0 0.0 4772 564 ? S Sep22 0:03 init [3]
root 2 0.0 0.0 0 0 ? S Sep22 0:03 [migration/0]
root 3 0.0 0.0 0 0 ? SN Sep22 0:00 [ksoftirqd/0]
root 4 0.0 0.0 0 0 ? S Sep22 0:02 [migration/1]
root 5 0.0 0.0 0 0 ? SN Sep22 0:00 [ksoftirqd/1]
root 6 0.0 0.0 0 0 ? Ss+ Sep22 0:02 [migration/2]
root 7 0.0 0.0 0 0 ? SN Sep22 0:00 [ksoftirqd/2]
root 8 0.0 0.0 0 0 ? S Sep22 0:00 [migration/3]
root 9 0.0 0.0 0 0 ? SN Sep22 0:00 [ksoftirqd/3]
root 10 0.0 0.0 0 0 ? S< Sep22 0:00 [migration/4]
上述欄位解釋：
USER 进程的属主；
PID 进程的ID；
PPID 父进程；
%CPU 进程占用的CPU百分比；
%MEM 占用内存的百分比；
NI 进程的NICE值，数值大，表示较少占用CPU时间；
VSZ 該进程使用的虚拟內存量（KB）；
RSS 該進程占用的固定內存量（KB）（驻留中页的数量）；
TTY 該進程在那個終端上運行（登陸者的終端位置），若與終端無關，則顯示（？）。若為pts/0等，則表示由網絡連接主機進程
WCHAN 當前進程是否正在進行，若為-表示正在進行；
START 該進程被觸發启动时间；
TIME 該进程實際使用CPU運行的时间；
COMMAND 命令的名称和参数；
STAT狀態位常見的狀態字符
D 无法中断的休眠状态（通常 IO 的进程）；
R 正在运行可中在队列中可过行的；
S 处于休眠状态；
T 停止或被追踪；
W 进入内存交换 （从内核2.6开始无效）；
X 死掉的进程 （基本很少見）；
Z 僵尸进程；
< 优先级高的进程
N 优先级较低的进程
L 有些页被锁进内存；
s 进程的领导者（在它之下有子进程）；
l 多进程的（使用 CLONE_THREAD, 类似 NPTL pthreads）；
+ 位于后台的进程组；