Why am I seeing the error message "read only-file system" when the file system is mounted rw?
 SOLUTION 已验证 - 已更新 2016年三月24日00:58 - 
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
	* 
ext3 file system
	* 
ext4 file system


问题
	* 
Why am I seeing the error message "read only file system" when the file system is mounted rw?
Raw
Jul 20 05:05:00 Hostname kernel: Remounting filesystem read-only


决议
	* 
If the kernel finds corruption on the disk or if certain key IOs like journal writes start failing, the kernel may remount the file system as read-only. This is because the file system can no longer maintain write integrity under these conditions.
	* 
Any such behaviour will be thoroughly logged in /var/log/messages, unless the file system hosting /var/log is also the file system affected by the Read-Only event. If /var is affected by the read only event it may be beneficial to configure remote logging. The following links show how to do this for RHEL 3/4/5 and for RHEL 6:
How to configure remote logging on Red Hat Enterprise Linux 3/4/5
How to configure remote logging on Red Hat Enterprise Linux 6
	* 
Note that in some cases it may be possible to unmount the read-only file system but most likely it will require a reboot. Unmounting the file system requires cleaning up all internal data structures and if any of them are marked dirty and need to be written out then the read-only state will prevent that in order to stop any further writes from causing potentially more corruption to the state of the file system. This means the modified structures cannot be cleaned and remain in memory.
	* 
Many of the operations in the file system will error out early if the file system has been marked in error to also prevent further damage and this can prevent things like open files from being closed which then stops the unmount from working. The only way to be sure the file system is operating in a fully reliable state when it is next mounted is to reboot.
	* 
Should this happen, backup your recent data as this may be a symptom of an impending disk failure. Unmount the file system/device and Perform file system checks on the disk/device using e2fsck as soon as possible and use the -c option to enable badblock checking. The normal fsck may not detect all the errors and return clean. For example:
Raw
# e2fsck -c /dev/sda3

In this case, the device is /dev/sda3
	* 
Please note that fsck may not always resolve the issue and some cases will require a reboot with file system check on boot. In cases of severe corruption or disk damage, recovery may only be possible by restoration from backup.
	* 
In some cases, filesystem check must be run manually from rescue mode. In these instances the following documentation will prove helpful:
How to fsck in rescue mode for Red Hat Enterprise Linux
	* 
As per the man pages for fsck.ext4:
Raw
   -c     This option causes e2fsck to use badblocks(8) program to do a read-only scan of the device in order to find
           any bad blocks.  If any bad blocks are found, they are added to the bad block inode to prevent them from
           being allocated to a file or directory.  If  this  option  is  specified twice, then the bad block
           scan will be done using a non-destructive read-write test.


根源
	* 
The integrity of the file system can be threatened for a variety of reasons, the most notable causes for a read-only event are:

		* 
Connection failure(s) during write
		* 
Bad hardware(intermittent hardware failure)
		* 
Bad cables/fabric
		* 
Power loss
		* 
Multiple connection failures
		* 
Faulty network connections
		* 
Flapping on nic
		* 
Software Bug
		* 
Incorrect file system resize operations, such as logical volume resizing.


 
From <https://access.redhat.com/solutions/9494>
 