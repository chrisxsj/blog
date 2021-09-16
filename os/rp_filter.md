rp_filter kernel parameter



下面说明all,ethX,default的含义以及all,ethX的取值关系
https://access.redhat.com/solutions/1282293
rp_filter参数值的含义
https://access.redhat.com/solutions/53031
rp_filter - INTEGER
0 - No source validation.
1 - Strict mode as defined in RFC3704 Strict Reverse Path Each incoming packet is tested against the FIB and if the interface is not the best reverse path the packet check will fail. By default failed packets are discarded.
2 - Loose mode as defined in RFC3704 Loose Reverse Path Each incoming packet's source address is also tested against the FIB and if the source address is not reachable via any interface the packet check will fail.
对应MOS文章
rp_filter for multiple private interconnects and Linux Kernel 2.6.32+ (文档 ID 1286796.1)
 
For Linux Kernels 2.6.31 (including, for example, Oracle Linux and RedHat) and above, a bug has been fixed in the Reverse Path Filtering. As a consequence of this bug fix, interconnect packets may be blocked/discarded on multi-interconnect systems.  To avoid this situation, set the rp_filter kernel parameter to a vale of 0 (disable) or 2 (loose) for the private interconnect NICs.  For more information see http://docs.oracle.com/database/121/CWLIN/networks.htm#CWLIN481 and Document 1286796.1.
 
1 The rp_filter parameter can be set globally on all NICs, or specific on each NIC. The maximum (between the "all" and the specific interface) value is taken.
17:20:59
2 To avoid this situation, set the rp_filter kernel parameter to a vale of 0 (disable) or 2 (loose) for the private interconnect NICs.
基于以上两点，取最大值1 则不符合要求
(Max value would be "1", this is NOT OK)
net.ipv4.conf.ib1.rp_filter = 0   --心跳网卡1 0
net.ipv4.conf.ib0.rp_filter = 0   --心跳网卡0 0
net.ipv4.conf.all.rp_filter = 1   --全局网卡  1