What is vm.overcommit_memory parameter?
Solution Unverified - 已更新 2014年十二月23日08:20 -
English
环境
	* 
Red Hat Enterprise Linux 6
	* 
Red Hat Enterprise Linux 5


问题
What is the vm.overcommit_memory parameter?
决议
	* 
When memory allocation routines are called in Linux, the system keeps track of the amount of memory that has been requested, but doesn't actually allocate memory for this request until the memory is used. The kernel may allow more memory to be requested than is in the system. This is called overcommitting memory. overcommit_memory and overcommit_ratio regulate this behavior.


overcommit_memory
overcommit_memory is a value which sets the general kernel policy toward granting memory allocations. If the value is 0, then the kernel grants allocations above the amount of physical RAM and swap in the system as defined by the overcommit_ratio value. If there is enough memory, then the request is granted. Otherwise, it is denied and an error code is returned to the application. If the value is set to 1, the kernel allows all memory allocations, regardless of the current memory allocation state. Enabling this feature can be somewhat helpful in environments which allocate large amounts of memory expecting worst case scenarios but do not use it all. If the setting in this file is 2, then the kernel checks to determine if there is enough memory free to grant a memory request to a malloc call from an application.
	* 
What is the formula to calculate "CommitLimit" value on Red Hat Enterprise Linux 5 and 6 ?


overcommit_ratio
The overcommit_ratio tunable defines the amount by which the kernel overextends its memory resources in the event that overcommit_memory is set to the value of 2. The value in this file represents a percentage added to the amount of actual RAM in a system when considering whether to grant a particular memory request. For instance, if this value is set to 50, then the kernel would treat a system with 1 GB of RAM and 1 GB of swap as a system with 1.5 GB of allocatable memory when considering whether to grant a malloc request from an application. The general formula for this tunable is:
Raw
allocatable memory=(swap size + (RAM size * overcommit ratio))
Use these previous two parameters with caution. Enabling overcommit_memory can create significant performance gains at little cost but only if your applications are suited to its use. If your applications use all of the memory they allocate, memory overcommit can lead to short performance gains followed by long latencies as your applications are swapped out to disk frequently when they must compete for oversubscribed RAM. Also, ensure that you have at least enough swap space to cover the overallocation of RAM (meaning that your swap space should be at least big enough to handle the percentage if overcommit in addition to the regular 50 percent of RAM that is normally recommended).
	* 
How to disable the Out of memory or oom-killer?


根源
	* 
Reference : Understanding Virtual Memory, 2004, Red Hat Magazine

