How to disable NUMA in Red Hat Enterprise Linux system?
Solution Verified - Updated August 17 2017 at 11:06 AM -
English
Environment
	* 
Red Hat Enterprise Linux 4
	* 
Red Hat Enterprise Linux 5
	* 
Red Hat Enterprise Linux 6
	* 
Red Hat Enterprise Linux 7


Issue
	* 
How to disable NUMA in Red Hat Enterprise Linux system?


Resolution
Adding the "numa=off" to kernel command line in boot loader configuration and rebooting the system will disable NUMA.
Examples:
	* 
RHEL 4, RHEL 5, RHEL 6 (/boot/grub/grub.conf)


Raw
title Red Hat Enterprise Linux AS (2.6.9-55.EL)
root (hd0,0)
kernel /vmlinuz-2.6.9-55.EL ro root=/dev/VolGroup00/LogVol00 rhgb quiet numa=off
initrd /initrd-2.6.9-55.EL.img
	* 
RHEL 7 (/etc/default/grub)


Raw
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel_vm-210/root rd.lvm.lv=rhel_vm-210/swap vconsole.font=latarcyrheb-sun16 crashkernel=auto vconsole.keymap=us rhgb quiet numa=off"
Please note, on RHEL 7 grub config has to be rebuilt for changes to take effect:
Raw
~]# grub2-mkconfig -o /etc/grub2.cfg
	* 
Product(s)
	* 
Red Hat Enterprise Linux
	* 
Component
	* 
numactl
	* 
Tags
	* 
numa


This solution is part of Red Hat’s fast-track publication program, providing a huge library of solutions that Red Hat engineers have created while supporting our customers. To give you the knowledge you need the instant it becomes available, these articles may be presented in a raw and unedited form.
 
来自 <https://access.redhat.com/solutions/23216>