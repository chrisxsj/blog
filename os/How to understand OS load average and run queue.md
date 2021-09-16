How to understand OS load average and run queue / blocked queue in terms of CPU utilization (Doc ID 2221159.1)
In this Document
 
Goal
Solution
References
 
Applies to:
Oracle Cloud Infrastructure - Version N/A and later
Linux OS - Version Oracle Linux 5.2 to Oracle Linux 7.3 [Release OL5U2 to OL7U3]
Linux x86
Linux x86-64
Goal
How to understand OS load average and run queue
Solution
First lets understand what is Load Average:
Load average is the number of jobs in the run queue (state R) or waiting for disk I/O (state D) averaged over 1, 5, and 15 minutes.
Example output from uptime/top command:
# uptime
11:49:14 up 25 days, 5:56, 68 users, load average: 0.03, 0.13, 0.47     <-----
# top -b -n 1
top - 11:49:34 up 25 days, 5:56, 68 users, load average: 0.09, 0.14, 0.46   <-----
Tasks: 456 total, 1 running, 445 sleeping, 10 stopped, 0 zombie
Cpu(s): 0.8%us, 0.4%sy, 0.0%ni, 98.6%id, 0.2%wa, 0.0%hi, 0.0%si, 0.0%st
Mem: 141823788k total, 140483388k used, 1340400k free, 313452k buffers
Swap: 16772092k total, 0k used, 16772092k free, 134695384k cached
The rule of thumb is:
	* 
Single Core system - if load average is 1.00 it means that system is fully utilized and if there will be more tasks incoming they will be queue-up and wait for execution
	* 
Single Core system - if load average is 2.00 it means that System is already utilized and some tasks are already queued-up and waiting for execution
	* 
Multi core system ( 4 cores ) - if load average is 1.00 it means that system uses 1/4 of his CPU capabilities, one task is actively running and there are still 3 cores at 'idle' stage
	* 
Multi core system ( 4 cores ) - if load average is 4.00 it means that system uses all 4 cores and it indicate that system is fully utilized


Is there some head room still left in above cases? - normally no - if load average is close to number of cores on system - OS should be reviewed to look for actual bottleneck and missing tuning or maybe OS not scaled properly to serve any APP/DB tasks.
 How Load average value is being calculated on Active OS? - for this we need to find run queue which is available via vmstat command:
Idle system ( 8 core system )
vmstat 1 6
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
r b swpd free buff cache si so bi bo in cs us sy id wa st
0 0 0 1674516 316588 134364752 0 0 0 1 0 0 1 0 99 0 0
0 0 0 1674624 316588 134364752 0 0 0 0 195 307 0 0 100 0 0
0 0 0 1674624 316596 134364752 0 0 0 12 168 302 0 0 100 0 0
0 0 0 1674624 316596 134364752 0 0 0 0 198 331 0 0 100 0 0
0 0 0 1674624 316596 134364752 0 0 0 0 206 356 0 0 100 0 0
0 0 0 1674624 316600 134364736 0 0 0 12 197 333 0 0 100 0 0
Active System ( 8 core system )
vmstat 1 6
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
r b swpd free buff cache si so bi bo in cs us sy id wa st
5 0 0 1674516 316588 134364752 0 0 0 1 0 0 1 0 99 0 0
7 0 0 1674624 316588 134364752 0 0 0 0 195 307 0 0 100 0 0
2 0 0 1674624 316596 134364752 0 0 0 12 168 302 0 0 100 0 0
6 0 0 1674624 316596 134364752 0 0 0 0 198 331 0 0 100 0 0
1 0 0 1674624 316596 134364752 0 0 0 0 206 356 0 0 100 0 0
8 0 0 1674624 316600 134364736 0 0 0 12 197 333 0 0 100 0 0
Above outputs are example - first one shows that current run queue ( r ) is 0 where on active system run queue jumps from 1 to 8 in 6 probes.
What exactly is run queue?
run-queue: Number of active ( running ) and queued processes.
In second example when system is active we see run queue of 8 - this is already maximum upper limit system with 8 cores should run.
Of course run queue might show values like 36 or even 101 - they will be perfectly fine if on first 36 we have 36 cores and on second one 101 we have more than 101 cores.
Run queue column should be always lower/same as number of cores installed on system - of course run queue of 100 can be visible on system with only 8 cores - it will mean that 8 processes are actively being served by CPU and rest 92 are queued and waiting for execution.
If run queue is above installed CPU cores investigation should be done in terms of checking APP/DB performance and missing tuning or can indicate that system is not scaled-up properly to serve such run queue / load.
Just like load average run queue should stay below the number of installed cores - not keeping this value below maximum threshold will cause slowdown/hung or eviction case ( if system is HA enabled ) as OS can simply queue-up heartbeat monitoring on disk/network layer as its busy serving other tasks.
High load average and run queue will cause sudden crash/hung case - its worth to monitor both values actively via 3rd party monitoring tools and alert when run queue / load average are taking more than 70% of actual CPU resources.
 
The second important column which is also being taken by Load Average is 'b' state in vmstat which explain blocked state processes - this can be easily interpreted as state-D processes ( awaiting for back-end IO to finish -- usually Storage Activity )
If Load average is high and no processes are being actively running and vmstat shows abnormal 'b' state value then its time to review SAN performance or verification of any OS component like ISCSI/NFS/NIC/HBA which might experience some issues and lead to serious blocked state under the Linux.
For example NFS Server might be busy on CPU level and all client ( Linux ) processes/tasks will be queue-up in state-d ( b ) leading to 'queueing' which might then release massive run-queue afterwards - as all processes were waiting for back-end IO to finish later they might again switch into Running leading to massive run-queue which can cause hung/panic state or lead to eviction case afterwards.
Network throughput and TCP/UDP traffic will get also impacted due to high Load Average - as system will be simply busy serving other tasks than confirming incoming/outgoing connections and prioritize incoming Network IO traffic via NFS/ISCSI etc.
 
In some cases TOP might show up %CPU value to be greater than 100 this is perfectly fine as TOP command by default in Linux shows single core operations hence in multi-core setups %CPU value can be greater than 100%. 
For example If PID utilize 4 cores fully then %CPU value will show 400
# top
top - 11:49:34 up 25 days, 5:56, 68 users, load average: 0.09, 0.14, 0.46
Tasks: 456 total, 1 running, 445 sleeping, 10 stopped, 0 zombie
Cpu(s): 0.8%us, 0.4%sy, 0.0%ni, 98.6%id, 0.2%wa, 0.0%hi, 0.0%si, 0.0%st
Mem: 141823788k total, 140483388k used, 1340400k free, 313452k buffers
Swap: 16772092k total, 0k used, 16772092k free, 134695384k cached
PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
1438 java 20 0 945m 4220 2528 S 400.5 0.0 56:31.95 java <---
Info about %CPU:
##
%CPU -- CPU Usage
The task's share of the elapsed CPU time since the last screen
update, expressed as a percentage of total CPU time.
In a true SMP environment, if a process is multi-threaded and top
is not operating in Threads mode, amounts greater than 100% may
be reported. You toggle Threads mode with the 'H' interactive
command.
##
To quickly list running/blocked processes use below ps command:
# ps r -Af
To list processes threads to verify if some threads spawned by parent PID are not causing CPU spike issue execute:
ps -e -To pid,ppid,state,pcpu,command
Also to verify if OS CPUs is serving actively User ( US ) space use below command examples:
# sar -P ALL 1
Linux 3.8.13-118.13.3.el6uek.x86_64 (lnx-ovm-san2076.uk.oracle.com) 01/08/2017 _x86_64_ (8 CPU)
02:40:38 PM CPU %user %nice %system %iowait %steal %idle
02:40:39 PM all 12.62 0.00 0.12 6.88 0.00 80.38
02:40:39 PM 0 0.00 0.00 0.00 54.55 0.00 45.45
02:40:39 PM 1 0.00 0.00 0.00 0.00 0.00 100.00
02:40:39 PM 2 0.99 0.00 0.00 0.00 0.00 99.01
02:40:39 PM 3 0.00 0.00 0.00 0.00 0.00 100.00
02:40:39 PM 4 100.00 0.00 0.00 0.00 0.00 0.00
02:40:39 PM 5 0.98 0.00 0.98 0.00 0.00 98.04
02:40:39 PM 6 0.00 0.00 0.00 0.00 0.00 100.00
02:40:39 PM 7 0.00 0.00 0.00 0.00 0.00 100.00
Average: CPU %user %nice %system %iowait %steal %idle
Average: all 12.63 0.00 0.13 6.00 0.00 81.24
Average: 0 0.00 0.00 0.00 45.23 0.00 54.77
Average: 1 0.50 0.00 0.00 3.00 0.00 96.50
Average: 2 0.50 0.00 0.00 0.00 0.00 99.50
Average: 3 0.00 0.00 0.00 0.50 0.00 99.50
Average: 4 100.00 0.00 0.00 0.00 0.00 0.00
Average: 5 0.50 0.00 0.50 0.00 0.00 99.00
Average: 6 0.00 0.00 0.00 0.00 0.00 100.00
Average: 7 0.00 0.00 0.00 0.00 0.00 100.00
# mpstat -P ALL
Linux 3.8.13-118.13.3.el6uek.x86_64 (lnx-ovm-san2076.uk.oracle.com) 01/08/2017 _x86_64_ (8 CPU)
02:41:26 PM CPU %usr %nice %sys %iowait %irq %soft %steal %guest %idle
02:41:26 PM all 0.79 0.00 0.10 1.18 0.00 0.02 0.00 0.00 97.92
02:41:26 PM 0 0.94 0.00 0.14 2.84 0.00 0.02 0.00 0.00 96.06
02:41:26 PM 1 0.94 0.00 0.14 2.70 0.00 0.02 0.00 0.00 96.20
02:41:26 PM 2 0.93 0.00 0.14 1.13 0.00 0.03 0.00 0.00 97.77
02:41:26 PM 3 0.94 0.00 0.13 2.71 0.00 0.02 0.00 0.00 96.20
02:41:26 PM 4 0.65 0.00 0.06 0.01 0.00 0.01 0.00 0.00 99.28
02:41:26 PM 5 0.65 0.00 0.06 0.01 0.00 0.01 0.00 0.00 99.27
02:41:26 PM 6 0.65 0.00 0.06 0.01 0.00 0.01 0.00 0.00 99.27
02:41:26 PM 7 0.64 0.00 0.05 0.01 0.00 0.01 0.00 0.00 99.29
In addition below TOP command switches can be used to obtain PID thread info and as well which core served PID last time:
To show threads in TOP:
# top -H
To show which core served PID last time execute:
# top
Then press 'F' and press 'J' and hit enter to obtain below output where 'P' row will be last used CPU
Tasks: 1045 total, 2 running, 1043 sleeping, 0 stopped, 0 zombie
Cpu(s): 0.2%us, 0.2%sy, 0.0%ni, 93.6%id, 5.9%wa, 0.0%hi, 0.0%si, 0.0%st
Mem: 16159656k total, 15349888k used, 809768k free, 597960k buffers
Swap: 8232956k total, 218784k used, 8014172k free, 9840192k cached
PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ P COMMAND
10428 root 20 0 15228 2228 1724 S 0.7 0.0 0:26.86 2 top
10838 oracle 20 0 4921m 585m 5708 S 0.7 3.7 137:11.13 3 mysqld
15360 root 20 0 15888 2792 1724 R 0.7 0.0 0:00.55 6 top
528 root 20 0 0 0 0 S 0.3 0.0 76:39.23 0 jbd2/dm-0-8
9003 root 20 0 0 0 0 S 0.3 0.0 8:49.33 2 jbd2/dm-3-8
10815 oracle 20 0 4921m 585m 5708 S 0.3 3.7 13:35.18 1 mysqld
14902 oracle 20 0 9431m 2.4g 28m S 0.3 15.5 19:54.77 3 java
15021 oracle 20 0 9431m 2.4g 28m S 0.3 15.5 20:09.19 1 java
15094 oracle 20 0 9431m 2.4g 28m S 0.3 15.5 6:54.88 3 java
32045 enduser 20 0 15228 2220 1724 S 0.3 0.0 9:32.73 5 top
32278 root 20 0 15228 2212 1724 S 0.3 0.0 9:32.96 1 top
 
Note
Oswatcher is capturing mpstat/vmstat/top by default, for further details on it please check: 1531223.1, in addition OS also capture standard SAR data by default in /var/log/sa
Should system be running with upper limit like 8 running processes with load average at same value on 8 core system? - No
System should be scaled up properly and not exceeding 70% of his possibilities -so there is some head-room for any new tasks to be executed -- this is specially important for HA enabled Servers and for systems where there are any High-End IO/Network components which might be accidently queued by active OS. For this in-depth check should be done by APP/DB team to verify what exactly is running actively under OS.
 
Does only APP/DB tasks are causing high run queue / load average - No
Some OS tasks might cause high run queue or load average - but these are really rare cases.
In this case top command will be useful to monitor US /SY / NI / ID / WA / HI / SI / ST values and focus on SY ( System ) section which tells how much processor time spend in kernel level. Make sure its always lower than actual US ( User ) utilization  and SY is not for example using 20-30% of CPU ( depends on CPU setup and actual case ). 
For example high %SY might be visible during High IO/Network operations or during memory shortage cases - example process is: kjorunald
High %SY might be also visible during heavy system loads - for example high run queue or blocked queue which is caused by APP/DB tasks - mostly then its observed that %SY will be at around 20-30% where %US will be much more higher.
Higher %SY does not always mean there is kernel or OS issue - for example there might be Application/Database code which is causing many sys-calls to be made around specific kernel function - to debug this further strace or perf should be used to verify specific PID interaction.
 
Does it mean that single core can only serve single process task at the time? - Yes/No
CPUs are designed for multitasking - even with single core system users can still execute multiple tasks and start multiple application - in single core setup 'time-slicing' is used which allows tasks to be executed for certain amount of time while other tasks will wait to be executed ( this can happen couple of times per second )
Modern systems will utilize multicore/multithreading features to make this switching impact less visible - hence on Enterprise Systems users have multi-core setup where applications can create smaller threads which will achieve actual multitask operations ( each core can serve different task ) leading to much more less load average on system and lower task queue - For example dual core system can split applications/threads/tasks into two separate cores allowing core to switch only half of tasks as compared to single core system causing far more less impact on system performance.
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=361628982289762&id=2221159.1&_adf.ctrl-state=4wjl154pq_354>