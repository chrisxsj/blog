How to monitor and configure shared memory usage in Red Hat Enterprise Linux
SOLUTION 已验证 - 已更新2017年七月31日17:42 -
English
环境
	* 
Red Hat Enterprise Linux 5
	* 
Red Hat Enterprise Linux 6
	* 
Red Hat Enterprise Linux 7


问题
	* 
How do I monitor/configure shared memory usage in RHEL?


决议
Shared memory statistics can be obtained from the output of the command ipcs -m. A sample output is shown here:
Raw
[root@host]# ipcs -m
------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 0          root       644        80         2
0x00000000 32769      root       644        16384      2
0x00000000 65538      root       644        280        2
0x00000000 294916     user       600        393216     2          dest
0x00000000 327685     user       600        393216     2          dest
0x00000000 360454     user       600        393216     2          dest
0x00000000 393223     user       600        393216     2          dest
0x00000000 425992     user       600        393216     2          dest
0x00000000 458761     user       600        393216     2          dest
To get the current usage, sum all the values on the 5th column. For example:
Raw
[root@host]# ipcs -m | awk '{ SUM += $5} END { print SUM }'
This command will print the current usage (in bytes) of shared memory.
In /etc/sysctl.conf we have four directives for shared memory. Note that this example is from a default installation of RHEL6.
Raw
[root@host]# sysctl -a | grep shm
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096
vm.hugetlb_shm_group = 0
The values are described here:
	* 
SHMMNI - This parameter sets the system wide maximum number of shared memory segments.
	* 
SHMALL - This parameter sets the total amount of shared memory pages that can be used system wide. Hence, SHMALL should always be at least ceiling(shmmax/PAGE_SIZE).
	* 
SHMMAX - This parameter defines the maximum size in bytes of a single shared memory segment that a Linux
process can allocate in its virtual address space.


Here, a key point to note is that SHMALL is calculated in pages. In x86_64 architecture, a page of memory is 4 KiB in size. So, the total amount of shared memory that the system can allocate here is:
Raw
[root@host]# echo "4294967296*4" | bc
17179869184
[root@host]# echo "17179869184/1024/1024" | bc
16384
By default, on RHEL6, there is 16384 GiB of shared memory allowable (maximum). To double check that, use the command ipcs -lm.
Raw
[root@host]# ipcs -lm
------ Shared Memory Limits --------
max number of segments = 4096
max seg size (kbytes) = 67108864
max total shared memory (kbytes) = 17179869184
min seg size (bytes) = 1
The same is visible from proc filesystem.
Raw
[root@host]# cat /proc/sys/kernel/shmall
4294967296
[root@host]# cat /proc/sys/kernel/shmmax
68719476736
[root@host]# cat /proc/sys/kernel/shmmni
4096
	* 
To change the shared memory values, edit /etc/sysctl.conf and apply:


Raw
[root@host]# sysctl -p
	* 
Shared memory is chunk of memory that can be shared by multiple processes. An application acquires shared memory by making a system call similar to what it would make to acquire conventional memory. The only difference is that each chunk of shared memory has key and it's possible for another application to map the same shared memory, by referencing the key.
	* 
The OS doesn't know how much of a shared-memory segment has been "used". Application makes a call, say, asking for a shared-memory segment of 'X' bytes. Once it done, it takes the memory back. But the OS has no idea how much is used, 1 byte, 5000, or 10,000 into the memory.
	* 
If attempted to write outside of an allocated memory segment, then a segment fault occurs. It can be very difficult to interpret Linux memory statistics.


诊断步骤
	* 
To monitor shared memory, refer to this knowledge solution: How to find process using the ipcs shared memory segment?
	* 
Note: The above output of "ipcs -m" command shows the status as "dest" for some of the shmid's, which means that some of the shared memory segments are in the process of being destroyed or deleted. This can be confirmed by the greping for the shmid's in "/proc/*/maps" to confirm the process ids. Refer to the knowledge solution: How to monitor shared memory usage in Red Hat Enterprise Linux?

