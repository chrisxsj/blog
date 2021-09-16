How to test network bandwidth? (iperf qperf netcat nc ttcp)
 SOLUTION 已验证 - 已更新 2019年十月9日12:52 - 
English 
环境
	* 
Red Hat Enterprise Linux
	* 
Network


问题
	* 
How to test network bandwidth?
	* 
How to use tools such as iperf qperf netcat nc ttcp to see maximum available networking speed?
	* 
Need to measure a system's maximum TCP and UDP bandwidth performance throughput. How this can be achieved?
	* 
Where can I download the iperf utility package?
	* 
How to test network throughput without special tools such as iperf?
	* 
What is iperf and can I use it on a RHEL machine?


决议
Several solutions are available for testing network bandwidth:
	* 
iperf (current version)
	* 
qperf
	* 
netcat (nc) and dd
	* 
iperf 2 (old version)
	* 
ttcp


Downloading and installing iperf
Add the EPEL Repository
If using RHEL 7, this step can be skipped as iperf is included in the supported channel.
If using RHEL 6 or RHEL 5, add the EPEL repository to get a ready-made RPM package:
	* 
How to use Extra Packages for Enterprise Linux (EPEL)?


Install iperf Package
Raw
# yum install iperf3
Compile from source code
If you are unable to add EPEL, you may compile iperf from the upstream source.
The latest version of the iperf source code is at https://github.com/esnet/iperf
Other OSes such as BSD or UNIX can likely compile this source code if required.
Instructions for building are provided on GitHub, and in the README.md file in the source.
Windows, Mac, iOS, Android, etc
Builds of iperf3 for other environments are available at https://iperf.fr/iperf-download.php
 
Bandwidth Test
iperf has the notion of a "client" and "server" for testing network throughput between two systems.
The following example sets a large send and receive buffer size to maximise throughput, and performs a test for 60 seconds which should be long enough to fully exercise a network.
Server
On the server system, iperf is told to listen for a client connection:
Raw
server # iperf3 -i 10 -s

-i  the interval to provide periodic bandwidth updates
-s  listen as a server
See man iperf3 for more information on specific command line switches.
Client
On the client system, iperf is told to connect to the listening server via hostname or IP address:
Raw
client # iperf3 -i 1 -t 60 -c <server hostname or ip address>

-i  the interval to provide periodic bandwidth updates
-t  the time to run the test in seconds
-c  connect to a listening server at...
See man iperf3 for more information on specific command line switches.
 
Test Results
Both the client and server report their results once the test is complete:
Server
Raw

server # iperf3 -i 10 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.0.0.2, port 22216
[  5] local 10.0.0.1 port 5201 connected to 10.0.0.2 port 22218
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-10.00  sec  17.5 GBytes  15.0 Gbits/sec                 
[  5]  10.00-20.00  sec  17.6 GBytes  15.2 Gbits/sec                 
[  5]  20.00-30.00  sec  18.4 GBytes  15.8 Gbits/sec                 
[  5]  30.00-40.00  sec  18.0 GBytes  15.5 Gbits/sec                 
[  5]  40.00-50.00  sec  17.5 GBytes  15.1 Gbits/sec                 
[  5]  50.00-60.00  sec  18.1 GBytes  15.5 Gbits/sec                 
[  5]  60.00-60.04  sec  82.2 MBytes  17.3 Gbits/sec                 
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-60.04  sec  0.00 Bytes    0.00 bits/sec                  sender
[  5]   0.00-60.04  sec   107 GBytes  15.3 Gbits/sec                  receiver
Client
Raw

client # iperf3 -i 1 -t 60 -c 10.0.0.1
Connecting to host 10.0.0.1, port 5201
[  4] local 10.0.0.2 port 22218 connected to 10.0.0.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-10.00  sec  17.6 GBytes  15.1 Gbits/sec    0   6.01 MBytes      
[  4]  10.00-20.00  sec  17.6 GBytes  15.1 Gbits/sec    0   6.01 MBytes      
[  4]  20.00-30.00  sec  18.4 GBytes  15.8 Gbits/sec    0   6.01 MBytes      
[  4]  30.00-40.00  sec  18.0 GBytes  15.5 Gbits/sec    0   6.01 MBytes      
[  4]  40.00-50.00  sec  17.5 GBytes  15.1 Gbits/sec    0   6.01 MBytes      
[  4]  50.00-60.00  sec  18.1 GBytes  15.5 Gbits/sec    0   6.01 MBytes      
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-60.00  sec   107 GBytes  15.4 Gbits/sec    0             sender
[  4]   0.00-60.00  sec   107 GBytes  15.4 Gbits/sec                  receiver
Reading the Result
Between these two systems, we could achieve a bandwidth of 15.4 gigabit per second or approximately 1835 MiB (mebibyte) per second.
Notes
	* 
The server listens on TCP port 5201 by default. This port will need to be allowed through any firewalls present.
	* 
The port used can be changed with the -p commandline option.
	* 
There is a bug with iperf3 in UDP mode where the server reports a bandwidth of zero. This is expected, use the client reading for bandwidth count: https://github.com/esnet/iperf/issues/314
	* 
When using the -w option to set the buffer size, it cannot be larger than either of net.core.rmem_max or net.core.wmem_max of both the sender and receiver. In other words, both the sender and receiver system must have their rmem_max and wmem_max be at least as large as the -w option size.
	* 
Per the iperf FAQ, it is expected that iperf2 may outperform iperf3 when testing with parallel streams (the -P option).
	* 
Extremely high bandwidth such as 40 Gbps or 100 Gbps may require a different testing method altogether: iperf does not reach full speed on fast network connection


根源
Be aware that the theoretical maximum transfer rate will not be what is achieved in practice. For additional details, read the Factors limiting actual performance, criteria for real decisions section on Wikipedia's List of device bit rates page.
Any given transfer is only as fast as the slowest link.
A Request For Enhancement (RFE) has been filed to have iperf included in RHEL 7. This is tracked under Red Hat Private Bug 913329 - [RFE] include iperf in RHEL.
Alternative Options
qperf
qperf is a network bandwidth and latency measurement tool which works over many transports including TCP/IP, RDMA, UDP, and SCTP.
It is available in the RHEL Server channel, so no third-party packages are required.
More details are available at: How to use qperf to measure network bandwidth and latency performance?
 
nc (netcat) and dd
If iperf is not an option for the enviroment, a simple throughput test can be performed with nc (netcat) and dd.
dd is in the coreutils package, and nc is in the nc package, both provided by Red Hat.
On the target, start a netcat listener. In the following example, netcat is listening on TCP port 12345:
Raw
server # nc -l -n 12345 > /dev/null
Have the client connect to the listener. The dd command will report throughput/second:
Raw

# dd if=/dev/zero bs=1M count=10240 | nc -n <server hostname or ip address> 12345
10240+0 records in
10240+0 records out
10737418240 bytes (11 GB) copied, 42.1336 s, 255 MB/s
Note that netcat uses a smaller buffer than other tools and this buffer size cannot be changed, this introduces a bottleneck in netcat, so throughput will be significantly lower with netcat than with purpose-built tools like iperf or TTCP.
 
iperf v2
The Resolution section above provides instructions for the later iperf3, but the older iperf v2 can still be used if desired.
iperf v2 can be installed using EPEL (yum install iperf). Source code for Linux and BSD is available at https://sourceforge.net/projects/iperf/. Binaries for Windows, Mac, iOS, Android, and other platforms are provided at https://iperf.fr/iperf-download.php.
iperf v2 requires several more settings than iperf3, and has a bug where multi-threaded UDP traffic is not accounted properly at all which makes a multi-thread UDP test useless on this version.
Start a server with:
Raw
server # iperf -l 128K -w 4M -i 10 -s

-l   the buffer size to read from the network socket
-w  the socket buffer size
-i  the interval to provide periodic bandwidth updates
-s  listen as a server
Start a client with:
Raw
client # iperf -l 128K -w 4M -i 10 -t 60 -c <server hostname or ip address>

-l   the buffer size to write to the network socket
-w  the socket buffer size
-i  the interval to provide periodic bandwidth updates
-t  the time to run the test in seconds
-c  connect to a listening server at...
Results are printed on both ends like:
Raw

[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  18.2 GBytes  15.6 Gbits/sec
[  3] 10.0-20.0 sec  18.2 GBytes  15.6 Gbits/sec
[  3] 20.0-30.0 sec  18.2 GBytes  15.6 Gbits/sec
[  3] 30.0-40.0 sec  18.3 GBytes  15.7 Gbits/sec
[  3] 40.0-50.0 sec  18.3 GBytes  15.7 Gbits/sec
[  3] 50.0-60.0 sec  18.2 GBytes  15.6 Gbits/sec
[  3]  0.0-60.0 sec   109 GBytes  15.6 Gbits/sec
iperf v2 listens on TCP Port 5001 by default. This can be changed with the -p command option.
 
ttcp
The ttcp (Test TCP) tool has RPMs available in other repositories:
	* 
https://www.rpmfind.net/linux/rpm2html/search.php?query=ttcp


TTCP works by creating a TCP pipe, it is up to the user to send data over the pipe.
Raw
server # ttcp -l 1048576 -b 4194304 -r -s

-l  the buffer size to read from the TCP socket
-b  the socket buffer size
-r  receive
-s  sink (discard) data after recieving
A client can use dd to generate data to send over the pipe:
Raw
client # dd if=/dev/zero bs=1M count=10240 | ttcp -l 1048576 -b 4194304 -t -n 10240 <server hostname or ip address>

-l  the buffer size to write to the TCP socket
-b  the socket buffer size
-t  transmit
-n  the number of buffers to send
The server shows only the TTCP result:
Raw

ttcp-r: 10737418240 bytes in 7.157 real seconds = 1465034.870 KB/sec +++
ttcp-r: 25074 I/O calls, msec/call = 0.292, calls/sec = 3503.254
ttcp-r: 0.009user 4.366sys 0:07real 60% 0i+0d 1804maxrss 0+256pf 19857+1csw
The client shows results from both dd and from TTCP:
Raw

10240+0 records in
10240+0 records out
10737418240 bytes (11 GB) copied, 7.1567 s, 1.5 GB/s

ttcp-t: 10737418240 bytes in 7.157 real seconds = 1465070.691 KB/sec +++
ttcp-t: 10240 I/O calls, msec/call = 0.716, calls/sec = 1430.733
ttcp-t: 0.022user 4.218sys 0:07real 59% 0i+0d 1064maxrss 0+256pf 163783+3csw
诊断步骤
	* 
Bandwidth on virtual machines can be influenced greatly by memory and load.
Physical machines can also be affected, but virtual machines are affected more.
If you were to have substantial load on the system, then the true bandwidth available will not get shown.
Example:


Raw

Running this command in the background before an iperf test on a vm with low Memory/cpu
dd if=/dev/zero of=/dev/null &

Will provide the following results
--------------------------------->
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec   173 MBytes   145 Mbits/sec
[  4] 10.0-20.0 sec   168 MBytes   141 Mbits/sec
[  4] 20.0-30.0 sec   178 MBytes   149 Mbits/sec

Running without any load will result in more bandwidth
---------------------------------->
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  9.87 GBytes  8.48 Gbits/sec
[  3] 10.0-20.0 sec  9.80 GBytes  8.42 Gbits/sec
^C[  3]  0.0-22.5 sec  22.1 GBytes  8.46 Gbits/sec
 
From <https://access.redhat.com/solutions/33103>