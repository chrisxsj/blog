How to configure chrony ?
 SOLUTION 已验证 - 已更新 2019年七月23日02:33 - 
English 
环境
	* 
Chronyd
	* 
Red Hat Enterprise Linux 7


问题
	* 
Sample configuration for chronyd.
	* 
What are important configuration parameters required to make chronyd work ?


决议
We need to set up a configuration for chrony in configuration file /etc/chrony.conf.
Following are few sample configurations possible for chrony :
I. If you have 3 NTP servers 'foo.example.net', 'bar.example.net' and 'baz.example.net', your chrony.conf file could contain as a minimum
Raw

            server foo.example.net
            server bar.example.net
            server baz.example.net
            server bat.example.net
II. For including few more useful directives : driftfile' ,makestep', `rtcsync' , 'iburst'. Then smallest useful configuration file would look something like
Raw

            server foo.example.net iburst
            server bar.example.net iburst
            server baz.example.net iburst
            server bat.example.net iburst
            driftfile /var/lib/chrony/drift
            makestep 10 3
            rtcsync
III. If using a pool of NTP servers (one name is used for multiple servers which may change over time), it's better to specify them with the pool' directive instead of multipleserver' directives. The configuration file could in this case look like
Raw

            pool pool.ntp.org iburst
            driftfile /var/lib/chrony/drift
            makestep 10 3
            rtcsync
To know more about each of this parameters in chrony please refer :
Configuring NTP Using the chrony Suite
根源
	* 
Default chrony.conf can not be used as it is. It must be altered accordingly to include new NTP servers list and other directives as needed.


诊断步骤
A) Install chrony
Raw
 yum install chrony*
B) Edit the configuration file as suggested in resolution tab
Raw
#vim /etc/chrony.conf
C) Restart chronyd service to load the changes
Raw
# systemctl restart chronyd.service
D) Check if time has been synchronized
Raw
# timedatectl
E) Display system time information
Raw
# chronyc tracking
	* 
Chrony has been configured successfully.


 
From <https://access.redhat.com/solutions/3073261>
 
 
===========================
 
A typical configuration file for the master (called master) might be (assuming the clients are in the 192.168.165.x subnet and that the master’s address is 192.168.169.170)

driftfile /var/lib/chrony/drift
generatecommandkey
keyfile /etc/chrony.keys
initstepslew 10 client1 client3 client6
local stratum 8
manual
allow 192.168.165
For the clients that have to resynchronise the master when it restarts, the configuration file might be

server master
driftfile /var/lib/chrony/drift
logdir /var/log/chrony
log measurements statistics tracking
keyfile /etc/chrony.keys
generatecommandkey
local stratum 10
initstepslew 20 master
allow 192.168.169.170
 
From <https://chrony.tuxfamily.org/doc/2.1/manual.html#Isolated-networks>
 
 
 
 
 
 
Chrony是NTP（Network Time Protocol，网络时间协议，服务器时间同步的一种协议）的另一种实现，与ntpd不同，它可以更快且更准确地同步系统时钟，最大程度的减少时间和频率误差。
 
Chrony包括两个核心组件：
1、chronyd：一个后台运行的守护进程，用于调整内核中运行的系统时钟与NTP服务器同步。它确定服务器增减时间的比率，并对此进行调整补偿；
2、chronyc：提供用户界面，用于监控性能并进行多样化的配置。它可以在chronyd实例控制的服务器上工作，也可以在一台不同的远程服务器上工作。
 
https://www.cnblogs.com/struggle-1216/p/12056199.html
 
1.2.2添加防火墙规则
firewall-cmd --add-service=ntp --permanent
firewall-cmd --reload
(因NTP使用123/UDP端口协议，所以允许NTP服务即可)
 
makestep 手动同步
 
 
注意：
[root@hgdb ~]# chronyc -v
chronyc (chrony) version 3.2 (+READLINE +IPV6 +DEBUG)
[root@hgdb ~]#
 
[root@postgres ~]# chronyc -v
chronyc (chrony) version 3.4 (+READLINE +SECHASH +IPV6 +DEBUG)
[root@postgres ~]#
 
版本需一致
 
 
4、chrony也支持ntpdate，我们现在来卸载客户端上的chrony，然后使用ntpdate尝试同步。
 
[root@JDK-Tomcat ~]# yum -y remove chronyd
[root@JDK-Tomcat ~]# yum -y install ntpdate
[root@JDK-Tomcat ~]# ntpdate 10.1.1.21
12 Jan 19:41:49 ntpdate[3407]: step time server 10.1.1.21 offset 4702.851108 se
————————————————
 
状态查看之-timedatectl
 
client：
[root@hgdbt ~]# timedatectl
      Local time: Wed 2020-01-22 11:20:31 CST
  Universal time: Wed 2020-01-22 03:20:31 UTC
        RTC time: Wed 2020-01-22 03:20:52
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: no
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
[root@hgdbt ~]#
 
server：
[root@postgres ~]# timedatectl
      Local time: Wed 2020-01-22 11:22:22 CST
  Universal time: Wed 2020-01-22 03:22:22 UTC
        RTC time: Wed 2020-01-22 03:22:43
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: yes
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a
[root@postgres ~]#
 
 
开始调整日志
Jan 22 11:23:16 hgdbt chronyd[4434]: Backward time jump detected!
Jan 22 11:23:16 hgdbt chronyd[4434]: Can't synchronise: no selectable sources
Jan 22 11:25:26 hgdbt chronyd[4434]: Selected source 192.168.6.13
Jan 22 11:25:26 hgdbt chronyd[4434]: System clock wrong by 1288.963734 seconds, adjustment started
 