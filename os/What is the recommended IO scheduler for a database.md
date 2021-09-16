What is the recommended I/O scheduler for a database workload in Red Hat Enterprise Linux?
Solution 已验证 - 已更新 2018年十一月13日04:00 -
English
环境
	* 
Red Hat Enterprise Linux 7
	* 
Red Hat Enterprise Linux 6
	* 
Red Hat Enterprise Linux 5
	* 
Red Hat Enterprise Linux 4
	* 
Database applications
	* 
Physical (non-virtualized) disks


问题
	* 
What is the recommended I/O scheduler for an Oracle database in Red Hat Enterprise Linux?
	* 
What is the recommended I/O scheduler for an DB2 database in Red Hat Enterprise Linux?
	* 
What is the recommended I/O scheduler for an mysql, postgress database in Red Hat Enterprise Linux?


决议
	* 
Nominally, the deadline IO scheduler is recommended for database environments using physical storage.
	* 
The deadline IO scheduler can be enabled for disk devices using one of the following steps.

		* 
Red Hat Enterprise Linux 7 uses deadline as the default I/O scheduler for all SCSI devices, except SATA drives, so there are no additional steps required to select deadline IO scheduler for SAN devices in RHEL 7. For additional information see tuned-adm on changing performance profiles.
		* 
Red Hat Enterprise Linux 6 can utilize either the runtime or boot time methods below in addition to using tuned-adm. For example, tuned-adm profile enterprise-storage is recommended for fibre channel based storage. Among the changes the profile sets is changing the scheduler to deadline for all devices. Custom profiles can also be created.
		* 
Red Hat Enterprise Linux 4 cannot set an io scheduler for individual devices. Changing the IO scheduler on the boot line for all devices is the only supported option.
		* 
Enabling the deadline io scheduler at runtime via the /sys filesystem (RHEL 5, 6, 7):
Raw
$ echo 'deadline' > /sys/block/sda/queue/scheduler
        $ cat               /sys/block/sda/queue/scheduler
        noop anticipatory [deadline] cfq
		* 
Enabling the deadline io scheduler at boot time. Add elevator=deadline to the end of the kernel line in /etc/grub.conf file (RHEL 4, 5, and 6):
Raw
title Red Hat Enterprise Linux Server (2.6.9-67.EL)
    root (hd0,0)
    kernel /vmlinuz-2.6.9-67.EL ro root=/dev/vg0/lv0 elevator=deadline
    initrd /initrd-2.6.9-67.EL.img


根源
The Completely Fair Queuing (CFQ) scheduler is the default algorithm in Red Hat Enterprise Linux 4, 5, 6 which is suitable for a wide variety of applications and provides a good compromise between throughput and latency. But for the database systems it is generally recommended to use the Deadline IO scheduler.
Changing an io scheduler is done to assist in matching the application io workload to a specific sort/scheduler type. The Deadline scheduler favors reads over writes via use of separate io queues for each, and dispatches N reads for every 1 write dispatched, where N = writes_starved. This tends to reduce the merging opportunity for reads as they are dispatched quicker, but enhances merge opportunity for writes since they hang around longer within the scheduler. Also this means read latency is enhanced while write latency often increases.
So the ideal workload for deadline is one that has non-merging reads and mergeable (sequential buffered) write loads. The application generating such an io load would be more read latency sensitive rather than write latency sensitive. Since database loads tend to be random small (often 4kb) reads that won't have much merge opportunity and mostly sequential buffered writes associated with journalling and logging, the deadline scheduler is a good fit for most database io loads.
You can easily confirm this by using something like iostat -tkx to watch and review the application io workload that is presented to storage. Typically the rrqm/s rate is near zero, while the wrqm/s, if there are significant write load, is much higher. The ratio of reads per second (r/s) vs writes per second (w/s) is 4:1 or more in favor of read commands per second. And finally, taking rkB/s divided by r/s shows the average read request is fairly small. The combination of all that indicates a likely random read io load that would benefit from improved dispatch latency along with a smaller amount of sequential/buffered writes being present. An ideal combination for deadline scheduler use.
See Understanding the Deadline IO Scheduler for more details on how the deadline scheduler is designed and works.
 
来自 <https://access.redhat.com/solutions/54164>