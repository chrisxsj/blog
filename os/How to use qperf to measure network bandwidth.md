How to use qperf to measure network bandwidth and latency performance?
 SOLUTION VERIFIED - Updated May 20 2019 at 3:15 PM - 
English 
Environment
	* 
Red Hat Enterprise Linux
	* 
Networking


Issue
	* 
How to use qperf to measure network bandwidth and latency performance?
	* 
Is there a supported alternative to iperf to measure network throughput?
	* 
How do I test performance of RDMA?


Resolution
Installation
Install qperf from the RHEL server channel on both the qperf Server and qperf Client:
Raw

[root@yourQperfServer ~]# yum install qperf
[root@yourQperfClient ~]# yum install qperf
Checking for Bandwidth
Server (Receiving Data)
Have one system listen as a qperf server:
Raw
[root@yourQperfServer ~]# qperf
The server listens on TCP Port 19765 by default. This can be changed with the --listen_port option.
This port will need to be allowed in any firewall present. On iptables:
Raw
[root@yourQperfServer ~]# iptables -I INPUT -m tcp -p tcp --dport 19765 -j ACCEPT && iptables -I INPUT -m tcp -p tcp --dport 19766 -j ACCEPT
Or on firewalld, once qperf makes a connection, it will create a control port and data port , the default data port is 19765 but we also need to enable a data port.
Raw
 

[root@yourQperfServer ~]# firewall-cmd --permanent --add-port=19765/tcp --add-port=19766/tcp
success

[root@yourQperfServer ~]# firewall-cmd --reload
success

[root@yourQperfServer ~]#firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s25
  sources:
  services: ssh dhcpv6-client http https
  ports: 19765/tcp  19766/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
Client
Have the other system connect to qperf server as a client:
Raw
[root@yourQperfClient ~]# qperf -ip 19766 -t 60 --use_bits_per_sec  <server hostname or ip address> tcp_bw
Results
Results are printed on the client only, the following result shows throughput between these two systems is 16.1 gigabit per second:
Raw

tcp_bw:
    bw  =  16.1 Gb/sec
If the --use_bits_per_sec option is not used, the throughput is supplied in GiB per second (or other applicable IEC binary unit):
Raw

tcp_bw:
    bw  =  1.94 GB/sec
Checking for latency
Client
Raw
[root@yourQperfClient ~]# qperf -vvs  <server hostname or ip address> tcp_lat
Results
Results are printed on the client only, the following result shows latency value is 311 Microseconds and then there are few other details as well. loc_xx shows details from local system perspective and rem_xx shows the same from remote system perspective. Refer man qperf for more options / verbosity.
Raw

tcp_lat:
    latency         =    311 us
    msg_rate        =   3.22 K/sec
    loc_send_bytes  =   3.22 KB
    loc_recv_bytes  =   3.22 KB
    loc_send_msgs   =  3,218
    loc_recv_msgs   =  3,217
    rem_send_bytes  =   3.22 KB
    rem_recv_bytes  =   3.22 KB
    rem_send_msgs   =  3,217
    rem_recv_msgs   =  3,217
Other Tests
Other tests are available, including UDP bandwidth and latency, SCTP bandwidth and latency, and other protocols which run on RDMA.
See the TESTS section of man qperf for more details.
Root Cause
	* 
qperf is a network bandwidth and latency measurement tool which works over many transports including TCP/IP, RDMA, UDP, and SCTP.


 