
How do I determine which disk devices connected to my machine do not contain any data?
SOLUTION 已验证 - 已更新2013年十一月29日06:57 -
English
环境
	* 
Red Hat Enterprise Linux


问题
	* 
How do I determine which disk devices connected to my machine do not contain any data?


决议
	* 
Use the provided script below to provide information on which disk devices contain data and which do not:


Raw
  # for DISK in $(awk '!/name/ {print $NF}' /proc/partitions); do echo -n "$DISK "; if [ $(hexdump -n10485760 /dev/$DISK | head | wc -l) -gt "3" ]; then echo "has data"; else echo "is empty"; fi; done;
 vda has data
 vdb is empty
根源
	* 
The script provided is based on the output of hexdump. It checks the first 10MB of each device listed in /proc/partitions and prints whether the device contains data or is empty.
	* 
If hexdump is ran against a device with no data it will show the following output:


Raw
 # hexdump -n10485760 /dev/vdb
 0000000 0000 0000 0000 0000 0000 0000 0000 0000
 *
 0a00000
	* 
If hexdump is ran against a device with data, it will show values other than the 0's seen above:


Raw
 # hexdump -n10485760 /dev/vda | head
 0000000 0000 0000 0000 0000 0000 0000 0000 0000
 *
 00001b0 0000 0000 0000 0000 5a46 dcb0 0000 0100
 00001c0 0001 fe8e ffff 003f 0000 5982 7470 0000
 00001d0 0000 0000 0000 0000 0000 0000 0000 0000
 *
 00001f0 0000 0000 0000 0000 0000 0000 0000 aa55
 0000200 0000 0000 0000 0000 0000 0000 0000 0000
 *
 0008000 414c 4542 4f4c 454e 0001 0000 0000 0000
	* 
产品（第）
	* 
Red Hat Enterprise Linux
	* 
类别
	* 
Learn more
	* 
标记
	* 
rhel
	* 
storage


This solution is part of Red Hat’s fast-track publication program, providing a huge library of solutions that Red Hat engineers have created while supporting our customers. To give you the knowledge you need the instant it becomes available, these articles may be presented in a raw and unedited form.
================================
查看磁盘有无数据的命令:
aix是lquerypv 、linux是hexdump