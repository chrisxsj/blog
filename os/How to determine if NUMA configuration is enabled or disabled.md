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