How to identify if the system is installed with UEFI or with Legacy only Boot?
Solution 已验证 - 已更新 2016年十一月9日09:48 -
English
环境
	* 
Red Hat Enterprise Linux 6
	* 
Red Hat Enterprise Linux 7


问题
	* 
How to identify if the system is installed with UEFI or with Legacy only Boot?


决议
	* 
Run the command below to find out if the system is BIOS boot or UEFI boot.


Raw
# [ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
	* 
For BIOS Boot, it will show as follows.


Raw

# [ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
BIOS
	* 
For UEFI boot, it will show


Raw

# [ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
UEFI
 
来自 <https://access.redhat.com/solutions/2147971>