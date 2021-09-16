How to troubleshoot chrony issues
 SOLUTION 已验证 - 已更新 2018年三月3日04:54 - 
English 
环境
	* 
Red Hat Enterprise Linux (RHEL) 7.0
	* 
chrony


问题
	* 
How to troubleshoot chrony issues.
	* 
chrony NTP troubleshooting techniques for accurate and reliable time sync.
	* 
How to check if chrony clients are synchronizing correctly with NTP servers.


决议
Note: You should always have at least 4 working time servers to be able to keep accurate time. 3 to verify time and 1+ as a redundant backup.
	* 
chrony is a pair of programs which are used to maintain the accuracy of the system clock on a computer.
	* 
chrony consists of:
-- chronyd, a daemon that runs in user space, and
-- chronyc, a command line program for making adjustments to chronyd.
	* 
Some useful commands are:


Raw

# chronyc activity
# chronyc ntpdata
# chronyc -n sources -v
# chronyc -n sourcestats -v
# chronyc -n tracking 

# systemctl status chronyd
# timedatectl
	* 
Here are some output examples:


Raw

# chronyc activity
200 OK
4 sources online
0 sources offline
0 sources doing burst (return to online)
0 sources doing burst (return to offline)
0 sources with unknown address
Raw

# chronyc -n sources -v
210 Number of sources = 4

.-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current synced, '+' = combined , '-' = not combined,
| /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ 200.160.0.8                   2   6   377    60  -7418us[-6893us] +/-   21ms
^+ 201.73.152.122                2   6   377    58  -9712us[-9187us] +/-  169ms
^+ 200.189.40.8                  2   6   377    60    +36ms[  +37ms] +/-   83ms
^* 200.160.7.186                 1   6   377    56  -6725us[-6200us] +/-  176ms
Note 1: The second character on the server lines should always be a '-', '+', or '*' after running for a while, otherwise the server is having trouble.
Note 2: If Reach is not 377 and chrony has been running for a while then access to that server is having connection issues.
Note 3: If LastRx is higher than Poll time (2^X seconds) then the server is having connection issues and it should be reflected in Reach as well.
Raw

# chronyc -n sourcestats -v
210 Number of sources = 4
                             .- Number of sample points in measurement set.
                            /    .- Number of residual runs with same sign.
                           |    /    .- Length of measurement set (time).
                           |   |    /      .- Est. clock freq error (ppm).
                           |   |   |      /           .- Est. error in freq.
                           |   |   |     |           /         .- Est. offset.
                           |   |   |     |          |          |   On the -.
                           |   |   |     |          |          |   samples. \
                           |   |   |     |          |          |             |
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
200.160.0.8                15   7   718      2.197     10.669  -7221us  2248us
201.73.152.122             13   7   721     -0.203      2.476    -10ms   463us
200.189.40.8               15   8   718      0.729      9.211    +36ms  2088us
200.160.7.186               8   6   522     -1.902      7.489  -6332us   606us
Raw

# chronyc -n tracking
Reference ID    : 200.160.7.186 (200.160.7.186)
Stratum         : 2
Ref time (UTC)  : Wed Nov  5 18:45:23 2014
System time     : 0.000799330 seconds fast of NTP time
Last offset     : 0.000525316 seconds
RMS offset      : 0.015844775 seconds
Frequency       : 0.971 ppm fast
Residual freq   : -0.002 ppm
Skew            : 2.283 ppm
Root delay      : 0.349031 seconds
Root dispersion : 0.000644 seconds
Update interval : 65.6 seconds
Leap status     : Normal
Raw

# systemctl status -l chronyd
chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled)
   Active: active (running) since Wed 2014-11-05 13:34:24 EST; 12min ago
  Process: 1921 ExecStartPost=/usr/libexec/chrony-helper add-dhclient-servers (code=exited, status=0/SUCCESS)
  Process: 1918 ExecStart=/usr/sbin/chronyd -u chrony $OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 1920 (chronyd)
   CGroup: /system.slice/chronyd.service
           └─1920 /usr/sbin/chronyd -u chrony

Nov 05 13:34:24 chrony-cli.example.lab chronyd[1920]: chronyd version 1.29.1 starting
Nov 05 13:34:24 chrony-cli.example.lab chronyd[1920]: Linux kernel major=3 minor=10 patch=0
Nov 05 13:34:24 chrony-cli.example.lab chronyd[1920]: hz=100 shift_hz=7 freq_scale=1.00000000 nominal_tick=10000 slew_delta_tick=833 max_tick_bias=1000 shift_pll=2
Nov 05 13:34:24 chrony-cli.example.lab chronyd[1920]: Frequency 0.266 +/- 0.248 ppm read from /var/lib/chrony/drift
Nov 05 13:34:24 chrony-cli.example.lab systemd[1]: Started NTP client/server.
Nov 05 13:34:30 chrony-cli.example.lab chronyd[1920]: Selected source 200.160.7.186
Raw

# timedatectl
      Local time: Wed 2014-11-05 13:48:16 EST
  Universal time: Wed 2014-11-05 18:48:16 UTC
        RTC time: Wed 2014-11-05 18:48:15
        Timezone: America/New_York (EST, -0500)
     NTP enabled: yes
NTP synchronized: no
 RTC in local TZ: no
      DST active: no
 Last DST change: DST ended at
                  Sun 2014-11-02 01:59:59 EDT
                  Sun 2014-11-02 01:00:00 EST
 Next DST change: DST begins (the clock jumps one hour forward) at
                  Sun 2015-03-08 01:59:59 EST
                  Sun 2015-03-08 03:00:00 EDT
If chronyd is unable to see any servers the following may be helpful.
The resulting chronyd.output and chronyd.strace files may reveal the reason it can't communicate.
Raw

# systemctl stop chronyd
# strace -fttTvyys 4096 -o chronyd.strace chronyd -d -d -q > chronyd.output 2>&1
# systemctl start chronyd
	* 
Additional References:
-- RHEL 7 System Administrators Guide
-- /usr/share/doc/chrony*/


 
From <https://access.redhat.com/solutions/1259943>