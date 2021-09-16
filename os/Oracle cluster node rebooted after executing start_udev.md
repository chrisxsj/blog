Oracle cluster node rebooted after executing start_udev
Solution 已验证 - 已更新2016年九月22日18:25 -
English
环境
	* 
Red Hat Enterprise Linux 5.9
	* 
Red Hat Enterprise Linux 6
	* 
Oracle RAC


问题
	* 
The Oracle RAC node was rebooted when new disk devices were added to the system and start_udev command was executed, need RCA.


决议
	* 
It is not recommended to execute start_udev command on the production systems. Please refer to the following articles for detailed information about the potential issues that could be observed if start_udev command is executed on live/production systems:


o Starting udev with the 'start_udev' command hangs the machine and disconnects NFS shares
o Under what conditions should start_udev be run?
	* 
If there is a requirement to trigger the udev event for specific disk device, then following command could be used for the same, this would help us to avoid the disruption to other devices present on the system:


Raw
$ echo change > /sys/block/<device>/uevent
	* 
If there is still a need to reload udev rules with start_udev command, then it would be recommended to please run this command during a scheduled maintenance window only.


根源
	* 
After adding the SAN devices to Oracle cluster nodes, the udev rules were reloaded with following command:


Raw
$ start_udev
	* 
When start_udev command was executed on live/production system, it tried to reload udev rules for all the devices present on the system. As the system was in production, and applications were performing heavy I/O operation on SAN devices, reload of the udev rules caused very high load. Also, the reload of all udev rules caused temporary fluctuation with the network interfaces. During this time other nodes in Oracle cluster assumed the node as unreachable and triggered a fence/eviction due to which the node was rebooted.
	* 
It would also be suggested to please check with Oracle support for detailed analysis of Oracle cluster logs to confirm that a node has got rebooted due to fence/eviction from other nodes in cluster.


诊断步骤
	* 
Prior to the node reboot, logs were filled with following error messages. The following messages from multipathd daemon could be observed if dm-multipath has already created multipath device maps using the sub path to the SAN devices, and then udev rules are manually reloaded on the system:


Raw
Sep  1 19:55:03 node1 multipathd: sdbci: add path (uevent)
Sep  1 19:55:03 node1 multipathd: sdbci: spurious uevent, path already in pathvec
Sep  1 19:55:03 node1 multipathd: sdbcf: add path (uevent)
Sep  1 19:55:03 node1 multipathd: sdbcf: spurious uevent, path already in pathvec
Sep  1 19:55:03 node1 multipathd: sdbcc: add path (uevent)
Sep  1 19:55:03 node1 multipathd: sdbcb: spurious uevent, path already in pathvec
[...]
	* 
During these timestamps the following error messages were also logged which indicates that there was some issues in the network link connecting to couple of interfaces:


Raw
Sep  1 19:55:15 node1 kernel: tg3 0000:16:04.1: eth7: Link is down
Sep  1 19:55:18 node1 kernel: tg3 0000:16:04.1: eth7: Link is up at 1000 Mbps, full duplex
Sep  1 19:55:18 node1 kernel: tg3 0000:16:04.1: eth7: Flow control is off for TX and off for RX
Sep  1 19:55:20 node1 kernel: bonding: bond2: Setting MII monitoring interval to 100.
Sep  1 19:55:20 node1 kernel: bonding: bond2: Note: Updating updelay (to 2000) since it is a multiple of the miimon value.
Sep  1 19:55:20 node1 kernel: unable to update mode of bond2 because it has slaves.
Sep  1 19:55:20 node1 kernel: bonding: bond2: Setting eth3 as primary slave.
Sep  1 19:55:20 node1 kernel: bonding: bond2: Setting up delay to 2000.
:
Sep  1 21:32:40 node1 multipathd: dm-539: add map (uevent)
Sep  1 21:32:40 node1 multipathd: dm-540: add map (uevent)
Sep  1 21:32:40 node1 multipathd: dm-517: add map (uevent)
Sep  1 21:32:40 node1 multipathd: dm-518: add map (uevent)
Sep  1 21:35:06 node1 Oracle GoldenGate Manager for Oracle[22348]: 2013-12-05 21:35:06  WARNING OGG-00947  Oracle GoldenGate Manager for Oracle, mgr.prm: Lag for EXTRACT LPASO1 is 01:35:27 (checkpoint updated 00:00:04 ago).
	* 
After above error messages the system "node1" was crashed at following timestamps:


Raw
Sep  1 21:44:18 node1 syslogd 1.4.1: restart.               <<---------- Reboot
Sep  1 21:44:18 node1 kernel: klogd 1.4.1, log source = /proc/kmsg started.
[...]
	* 
Check if the user has manually reloaded udev rules with start_udev command?

