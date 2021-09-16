How to sync to local clock using chrony
 SOLUTION IN PROGRESS - 已更新 2017年六月7日09:00 - 
English 
环境
	* 
Red Hat Enterprise Server 7
	* 
chrony


问题
chrony does not sync to local clock.
The local server "127.127.1.0" is added to /etc/chrony.conf.
Raw

server 127.127.1.0
allow 127.0.0.0/8
local stratum 10
It synchronized with the local server after the daemon started. 'chronyc sources' command gives the following result.
Raw

210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* 127.127.1.0                  15   6   377    42  -4471ns[  -13us] +/-  204us
However, the error "Can't synchronise: no selectable sources" appears in /var/log/messages and the local sever is no longer selected as a selectable NTP server.
Raw

210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^? 127.127.1.0                  15   4     0   150  -6275ns[  -11us] +/-   80us
决议
Remove "server 127.127.1.0" line from /etc/chrony.conf. Adding "local stratum " to the configuration file (/etc/chrony.conf) is enough. The "local" directive allows chronyd to appear synchronised to real time.
See System Administrator's Guid and chrony Manual for more detailed information.
根源
"server 127.127.1.0" is an ntpd-specific way to enable the local refclock driver, which is not supported in chrony.
诊断步骤
'chronyc tracking' command shows "Reference ID : 127.127.1.1 ()" if the chronyd is referring local.
Raw

Reference ID    : 127.127.1.1 ()
Stratum         : 10
Ref time (UTC)  : Wed Jun  7 04:46:35 2017
System time     : 0.000000010 seconds slow of NTP time
Last offset     : +0.000000000 seconds
RMS offset      : 0.000000000 seconds
Frequency       : 0.895 ppm slow
Residual freq   : +0.000 ppm
Skew            : 0.000 ppm
Root delay      : 0.000000 seconds
Root dispersion : 0.000001 seconds
Update interval : 0.0 seconds
Leap status     : Not synchronised
Additionally, 'chronyc sources' shows no selectable time source.
Raw

210 Number of sources = 0
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
 
From <https://access.redhat.com/solutions/3071471>