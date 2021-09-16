Using the Deadline IO Scheduler
Solution 已验证 - 已更新 2019年一月22日23:04 -
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


问题
	* 
How do I turn on the deadline scheduler for a device?
	* 
What are the tunables for the deadline scheduler and what do they do?
	* 
How does the logic within the scheduler work in choosing which IO to dispatch next?


决议
To configure a disk to use the deadline scheduler:
	* 
RHEL 5, RHEL 6, RHEL 7: via the /sys filesystem


Raw

$ echo 'deadline' > /sys/block/sda/queue/scheduler
$ cat               /sys/block/sda/queue/scheduler
noop anticipatory [deadline] cfq
To configure all disks to use the deadline scheduler (at boot time):
	* 
RHEL 4, RHEL 5, RHEL 6: add elevator=deadline to the end of the kernel line in /etc/grub.conf file:


Raw

title Red Hat Enterprise Linux Server (2.6.9-67.EL)
root (hd0,0)
kernel /vmlinuz-2.6.9-67.EL ro root=/dev/vg0/lv0 elevator=deadline
initrd /initrd-2.6.9-67.EL.img
	* 
RHEL 7: add `elevator=deadline` to `GRUB_CMDLINE_LINUX` in `/etc/default/grub`
Raw
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="vconsole.font=latarcyrheb-sun16 vconsole.keymap=us rd.lvm.lv=vgroot/root elevator=deadline crashkernel=auto rhgb quiet"
GRUB_DISABLE_RECOVERY="true"

		* 
and then rebuild the `/boot/grub2/grub.cfg` file to reflect the above changes:

			* 
On BIOS-based machines: ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
			* 
On UEFI-based machines: ~]# grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg


 
NOTE: In RHEL 4 the IO scheduler selection is not per-disk, but global only.
NOTE: In RHEL 7, the deadline IO scheduler is the default IO scheduler for all block devices except SATA disks. For SATA disk, the default IO scheduler is cfq.
 
Deadline tunables:
 
Raw

$ grep -vH "zzz" /sys/block/sda/queue/iosched/*
/sys/block/sda/queue/iosched/fifo_batch:16        {number of contiguous io to treat as one}
/sys/block/sda/queue/iosched/front_merges:1       {1=enabled}
/sys/block/sda/queue/iosched/read_expire:500      {time in milliseconds}
/sys/block/sda/queue/iosched/write_expire:5000    {time in milliseconds}
/sys/block/sda/queue/iosched/writes_starved:2     {minimum number of reads to perform,
                                                  if available, before any writes}
 
See "Understanding the Deadline IO Scheduler" for additional and more in-depth information on the deadline scheduler, its tunables and how those tunables change IO selection and flow through the deadline scheduler. The discussion includes how the logic within the deadline scheduler works in choosing which IO to dispatch next.
 
来自 <https://access.redhat.com/solutions/32376>