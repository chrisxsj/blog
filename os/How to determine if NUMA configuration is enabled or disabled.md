How to determine if NUMA configuration is enabled or disabled?
Solution 已验证 - 已更新 2017年二月20日19:10 -
English
环境
	* 
Red Hat Enterprise Linux 4
	* 
Red Hat Enterprise Linux 5
	* 
Red Hat Enterprise Linux 6
	* 
Red Hat Enterprise Linux 7


问题
	* 
How to determine if NUMA configuration is enabled or disabled?
	* 
numactl --show does not show multiple nodes


Raw
# numactl --show
policy: default
preferred node: current
physcpubind: 0 1 2 3 4 5 6 7 8 9 10 11
cpubind: 0
nodebind: 0
membind: 0
	* 
numactl --hardware does not list multiple nodes


Raw
available: 1 nodes (0)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11
node 0 size: 65525 MB
node 0 free: 17419 MB
node distances:
node 0
0: 10
	* 
grep -i numa /var/log/dmesg returns No NUMA configuration found


Raw
No NUMA configuration found
Faking a node at 0000000000000000-0000001027fff000
Bootmem setup node 0 0000000000000000-0000001027fff000
NODE_DATA [000000000000c000 - 000000000003ffff]
bootmap [0000000000100000 - 0000000000304fff] pages 205
	* 
Even with NUMA enabled, dmesg does not show any information of NUMA initialization.


决议
	* 
NUMA should be enabled in the BIOS
	* 
If NUMA is enabled on BIOS, then execute the command numactl --hardware to list inventory of available nodes on the system
Example output of numactl --hardware on a system which has NUMA


Raw
# numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 16 17 18 19 20 21 22 23
node 0 size: 8157 MB
node 0 free: 88 MB
node 1 cpus: 8 9 10 11 12 13 14 15 24 25 26 27 28 29 30 31
node 1 size: 8191 MB
node 1 free: 5176 MB
node distances:
node 0 1
0: 10 20
1: 20 10
	* 
If dmesg does not show any information about NUMA, then increase the Ring Buffer size:
Boot with 'log_buf_len=16M' (or some other big value). Refer the following kbase article How do I increase the kernel log ring buffer size? for steps on how to increase the ring buffer
	* 
If the server does not have NUMA support or if the BIOS option is not enabled, then the following messages will be seen in dmesg


Raw
No NUMA configuration found
Faking a node at 0000000000000000-0000001027fff000
	* 
If ACPI is disabled, that will also disable NUMA; verify that ACPI is not disabled by a grub.conf kernel parameter and remove it if found:


Raw
$ grep acpi=off /proc/cmdline
$
根源
NUMA has to enabled in the BIOS. If dmesg does not have records of numa initialization during bootup, then it is possible that NUMA related messages in the kernel ring buffer might have been overwritten. Increase the ring buffer so that more messages can be stored. The default kernel ring buffer size is 512 kilobytes.
诊断步骤
1. Check /var/log/dmesg for NUMA related messages
2. Use numactl --hardware to list the numa inventory of the system
 
来自 <https://access.redhat.com/solutions/48756>

<!--
[root@hgdb network-scripts]# numactl --hardware
available: 8 nodes (0-7)
node 0 cpus: 0 1 2 3 4 5 6 7 64 65 66 67 68 69 70 71
node 0 size: 0 MB
node 0 free: 0 MB
node 1 cpus: 8 9 10 11 12 13 14 15 72 73 74 75 76 77 78 79
node 1 size: 0 MB
node 1 free: 0 MB
node 2 cpus: 16 17 18 19 20 21 22 23 80 81 82 83 84 85 86 87
node 2 size: 64068 MB
node 2 free: 40 MB
node 3 cpus: 24 25 26 27 28 29 30 31 88 89 90 91 92 93 94 95
node 3 size: 64508 MB
node 3 free: 35 MB
node 4 cpus: 32 33 34 35 36 37 38 39 96 97 98 99 100 101 102 103
node 4 size: 0 MB
node 4 free: 0 MB
node 5 cpus: 40 41 42 43 44 45 46 47 104 105 106 107 108 109 110 111
node 5 size: 0 MB
node 5 free: 0 MB
node 6 cpus: 48 49 50 51 52 53 54 55 112 113 114 115 116 117 118 119
node 6 size: 64508 MB
node 6 free: 401 MB
node 7 cpus: 56 57 58 59 60 61 62 63 120 121 122 123 124 125 126 127
node 7 size: 63453 MB
node 7 free: 31 MB
node distances:
node   0   1   2   3   4   5   6   7 
  0:  10  16  16  16  28  28  22  28 
  1:  16  10  16  16  28  28  28  22 
  2:  16  16  10  16  22  28  28  28 
  3:  16  16  16  10  28  22  28  28 
  4:  28  28  22  28  10  16  16  16 
  5:  28  28  28  22  16  10  16  16 
  6:  22  28  28  28  16  16  10  16 
  7:  28  22  28  28  16  16  16  10 


[root@hgdb network-scripts]# numastat 
                           node0           node1           node2           node3
numa_hit                     385             385         7267535       406936515
numa_miss                      0               0       101410887         2432927
numa_foreign                   0               0         3364852       327004541
interleave_hit                 0               0           19565           19507
local_node                     0               0         1729586       406287882
other_node                   385             385       106948836         3081560

                           node4           node5           node6           node7
numa_hit                     385             385         3699328          215024
numa_miss                      0               0       113122358       114497121
numa_foreign                   0               0         1093836              64
interleave_hit                 0               0           19577           19524
local_node                     0               0          426603           81457
other_node                   385             385       116395083       114630688
[root@hgdb network-scripts]# 

-->