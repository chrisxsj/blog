1 启动和关闭
启动   HACMP 服务：
#smitty hacmp
选择“ System Management(C-spoc)   ”
选择“ Manage HACMP Services   ”
选择“ Start cluster Services   ”
 
Command: OK            stdout: yes           stderr: no
Before command completion, additional instructions may appear below.
Status of the RSCT subsystems used by HACMP:
Subsystem         Group            PID          Status
 topsvcs          topsvcs          225532       active
 grpsvcs          grpsvcs          188486       active
 grpglsm          grpsvcs                       inoperative
 emsvcs           emsvcs           69736        active
 emaixos          emsvcs           102488       active
 ctrmc            rsct             70016        active
Status of the HACMP subsystems:
Subsystem         Group            PID          Status
 clcomdES         clcomdES         155906       active
 clstrmgrES       cluster          119232       active
Status of the optional HACMP subsystems:
Subsystem         Group            PID          Status
 clinfoES         cluster                       inoperative
关闭 
#smitty hacmp
选择“System Management(C-spoc)”
选择“Manage HACMP Services”
选择“Stop cluster Services”， 
先择“Now...”
Command: OK            stdout: yes           stderr: no
Before command completion, additional instructions may appear below.
Status of the RSCT subsystems used by HACMP:
Subsystem         Group            PID          Status
 topsvcs          topsvcs                       inoperative
 grpsvcs          grpsvcs                       inoperative
 grpglsm          grpsvcs                       inoperative
 emsvcs           emsvcs                        inoperative
 emaixos          emsvcs                        inoperative
 ctrmc            rsct             70016        active
Status of the HACMP subsystems:
Subsystem         Group            PID          Status
 clcomdES         clcomdES         155906       active
 clstrmgrES       cluster          119232       active
Status of the optional HACMP subsystems:
Subsystem         Group            PID          Status
 clinfoES         cluster                       inoperative
Command: running       stdout: yes           stderr: no
 
 
!!!或者
smit clstart
smit clstop
 
 
2  查看cluster运行情况和HACMP状态
 /usr/es/sbin/cluster/clstat命令用来显示HACMP状态。
 /usr/sbin/cluster/clstat可以帮助你查看当前HACMP的节点状态
 
3  查看Cluster的日志及错误信息（HACMP环境下的排错）：
HACMP的LOG文件:以下文件都是文本文件,可以用VI来看.每个日志文件都含有每个信息的产生时间.
/usr/adm/cluster.log :记录了HACMP的状态,由HA的守护进程所产生.
/tmp/hacmp.out :记录了HA的详细脚本.
/usr/sbin/cluster/history/cluster.mmdd :记录了HA的各个事件的发生.
/tmp/cm.log :由clstrmgr进程产生,每次HA重起时会被覆盖.
注：可以在启动HACMP时使用 # tail –f /tmp/hacmp.out命令，以查看HACMP的启动是否正常或跟踪启动时的错误信息。
 
来自 < http://blog.csdn.net/lively1982/article/details/8278274 >