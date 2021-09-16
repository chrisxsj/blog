How to disable transparent hugepages (THP) on Red Hat Enterprise Linux 7
Solution 已验证 - 已更新 2017年六月2日23:54 -
English
环境
	* 
Red Hat Enterprise Linux 7
	* 
transparent hugepages (THP)
	* 
tuned


问题
	* 
How to disable transparent hugepages (THP) on Red Hat Enterprise Linux 7
	* 
Disabling transparent hugepages (THP) on Red Hat Enterprise Linux 7 is not taking effect.


决议
Follow the steps below
	1. 
Add the "transparent_hugepage=never" kernel parameter option to the grub2 configuration file.

		* 
Append or change the "transparent_hugepage=never" kernel parameter on the GRUB_CMDLINE_LINUX option in /etc/default/grub file. Only include the parameter once.
Raw
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap ... transparent_hugepage=never"
	2. 
Rebuild the /boot/grub2/grub.cfg file by running the grub2-mkconfig -o command as follows:

		* 
Please ensure to take a backup of the existing /boot/grub2/grub.cfg before rebuilding.

			* 
On BIOS-based machines: ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
			* 
On UEFI-based machines: ~]# grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
	3. 
Reboot the system and verify option has been added

		* 
Reboot the system
Raw
# shutdown -r now
		* 
Verify the parameter is set correctly
Raw
# cat /proc/cmdline


 
 
If Transparent Huge Pages (THP) is still not disabled, continue and use one of the options below.
	* 
Option 1: (Recommended) create a customized tuned profile with disabled THP

		* 
With this resolution we will create a customized version of the currently running profile. The customized version will disable THP.
		* 
Find out which profile is active, create a copy. In the following example we currently use the throughput-performance profile:
Raw
# tuned-adm active
Current active profile: throughput-performance
		* 
To create customized profile, create a new directory in /etc/tuned directory with desired profile name.
Raw
# mkdir /etc/tuned/myprofile-nothp
		* 
Then create a new tuned.conf file for myprofile-nothp, and insert the new tuning info:
Raw
# cat /etc/tuned/myprofile-nothp/tuned.conf
[main]
include= throughput-performance
[vm]
transparent_hugepages=never
		* 
Make the script executable:
Raw
# chmod +x /etc/tuned/myprofile-nothp/tuned.conf
		* 
Enable myprofile like so:
Raw
# tuned-adm profile myprofile-nothp
		* 
This change will immediately take effect and persist reboots.
		* 
To verify if THP are disabled or not, run below command:
Raw
# cat /sys/kernel/mm/transparent_hugepage/enabled
	* 
Option 2: (Alternative) Disable tuned services

		* 
This resolution will disable the tuned services.
Raw
# systemctl stop tuned
# systemctl disable tuned
		* 
OR
Raw
# tuned-adm off
		* 
Now add "transparent_hugepage=never" kernel parameter in grub2 configuration file as explained in steps 1-3 above.
		* 
Reboot the server for changes to take effect.

