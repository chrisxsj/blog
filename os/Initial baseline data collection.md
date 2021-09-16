Initial baseline data collection for local/SAN streaming I/O performance
Updated 2016年六月30日11:34 - 
English 
The purpose of this article to provide a starting point when it is believed that filesystem or storage is slow or would like to be measured. The steps below provide useful baseline data from which to begin troubleshooting RHEL filesystem and storage speed, instead of spending time doing irrelevant tests like small cached dd or scp.
Data Collection
During each test, collect the following information:
	* 
cat /etc/fstab > /tmp/etc-fstab.out
	* 
cat /proc/mounts > /tmp/proc-mounts.out
	* 
Set up performance monitoring such as:

		* 
Performance Co Pilot:

			* 
Installation and enabling
			* 
You can either configure a smaller logging interval and gather logs after these tests
			* 
Or use PCP to collect one-off data
		* 
The watcher-cron script provided at:

			* 
Gathering system baseline resource usage for IO performance issues


I/O Tests
	* 
As these tests drop filesystem cache, they are not suitable for production usage.
	* 
Quiesce (make the system quiet) as much as possible by stopping running applications and preventing user activity before running the tests.


Test the streaming write performance of the storage
	* 
Drop cache before every test: echo 3 > /proc/sys/vm/drop_caches
	* 
dd if=/dev/zero of=/mnt/testfile.bin bs=1M count=10000 conv=fsync


Test the streaming read performance of the storage
	* 
Drop cache before every test: echo 3 > /proc/sys/vm/drop_caches
	* 
dd if=/mnt/testfile.bin of=/dev/null bs=1M conv=fsync


Theory Points
	* 
Pick one RHEL system, one storage location, one mountpoint. We need consistency in our tests and results.
	* 
A large file transfer will only go as fast as the slowest point in the system. If the disk performs at 10Mb/sec and the storage fabric performs at 100Gb/sec, the file transfer will go at 10Mb/sec.
	* 
There is no point doing tests to the filesystem cache, such as dd without conv=fsync. Cached I/O is more a test of memory bandwidth and page flush settings than of disk performance.
	* 
Use a large block size (eg: 1MiB) and large repeat count (eg: 10000) to get a big streaming IO (eg: 10GiB) to fully exercise the storage.


Things Not To Use
	* 
dd without conv=fsync or oflag=direct. This uses filesystem cache.
	* 
scp. This is bottlenecked by a single CPU core performing encryption, and eventually by OpenSSH's built-in 64KiB buffer size.
	* 
rsync. This uses filesystem cache, and cannot bypass the cache.


Further Performance Tuning
Further performance tuning is outside the scope of this solution, however, the following are good ideas:
	* 
Make a test matrix and recording results of each test. eg:
Raw
.--------------------------------- ------------ -----------.
| Client kernel                   | Write      | Read      |
+--------------------------------- ------------ -----------
| 2.6.32-220                      | 100Mb/sec  | 100Mb/sec |
| 2.6.32-279**                    | 110Mb/sec  | 110Mb/sec |
'--------------------------------- ------------ -----------'

changed parameter denoted with **
	* 
If you change any parameters, record how that parameter was set for all data points. eg:
Raw
.------------------ -------------- ------------ -----------.
| Client kernel    | io-scheduler | Write      | Read      |
+------------------ -------------- ------------ -----------+
| 2.6.32-220       | cfq          | 100Mb/sec  | 100Mb/sec |
| 2.6.32-279**     | cfq          | 110Mb/sec  | 110Mb/sec |
| 2.6.32-279       | noop**       | 120Mb/sec  | 120Mb/sec |
'--------------------------------- ------------ -----------'

changed parameter denoted with **
	* 
Only change one parameter at a time. Record results of all parameter changes.


 
From <https://access.redhat.com/articles/2420561>