Adjust vm.swappiness to Avoid Unneeded Disk I/O

This is post #11 in my December 2013 series about Linux Virtual Machine Performance Tuning. For more, please see the tag “Linux VM Performance Tuning.”
The Linux kernel has quite a number of tunable options in it. One of those is vm.swappiness, a parameter that helps guide the kernel in making decisions about memory. “vm” in this case means “virtual memory,” which doesn’t mean memory allocated by a hypervisor but refers to the addressing scheme the Linux kernel uses to handle memory. Even on a physical host you have “virtual memory” within the OS.
Memory on a Linux box is used for a number of different things. One way it is used is internally for buffers for things like network stacks, SCSI queues, etc. Another way is the obvious use for applications. The third big way is as disk cache, where RAM not used for buffers or applications is used to make disk read accesses faster. All of these uses are important, so when RAM is scarce how does the kernel decide what’s more important and what should be sent to the swap file?
The kernel buffers always stay in main memory, because they have to. Applications and cache don’t need to stay in RAM, though. The cache can be dropped, and the applications can be paged out to the swap file. Dropping cache means a potential performance hit. Likewise with paging applications out. The vm.swappiness parameter helps the kernel decide what to do. By setting it to the maximum of 100 the kernel will swap very aggressively. By setting it to 0 the kernel will only swap to protect against an out-of-memory condition. The default is 60 which means that some swapping will occur.
In this context we’re talking about swapping inside the guest OS, not at the hypervisor level. Swapping is bad in a virtual environment, at any level. When the guest OS starts swapping on a physical server it only affects that server, but in a virtual environment it causes problems for all the workloads.

So how do I stop that from happening?
Simple: set vm.swappiness to 0:
$ sudo sysctl -w vm.swappiness=0
For more permanence, set it in /etc/sysctl.conf by appending “vm.swappiness = 0” and running “sudo sysctl –p” to reload the values.
There is also a great sysctl::conf class example in the Puppet Augeas information. If you aren’t using Puppet this simple example would be a great way to start!
 