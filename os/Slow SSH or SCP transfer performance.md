Slow SSH or SCP transfer performance
 SOLUTION 已验证 - 已更新 2017年八月3日10:20 - 
English 
环境
	* 
Red Hat Enterprise Linux
	* 
File transfers over SSH or SCP


问题
	* 
I have a 10Gbps ethernet connection but SCP only transfers at 50-250Mb/s instead of 1Gb/s.
	* 
SSH transfer performance is not near 1G or 10G line speed.


决议
Don't use SSH or SCP or SFTP to test network bandwidth.
Instead use an unencrypted file transfer protocol such as FTP or NFS, or a bandwith measurement tool such as iperf:
	* 
How to test network bandwidth? (iperf qperf netcat nc ttcp)


Using a less complex SSH cipher such as arcfour can partially work around the performance issue. This may come at the cost of security, as RC4 encryption is easily broken if traffic is intercepted.
If your CPU has the AES-NI extension make sure that your OpenSSH package is at revision 5.3p1-70.el6_2.2 or newer for best performance.
根源
	* 
SSH/SCP use single-threaded encryption which is taxing on the CPU. Assuming the network and storage are fast enough, the CPU will become the bottleneck in this transfer.
	* 
The performance of any network transfer can be limited to the speed of the disks involved.
	* 
SSH/SCP performance is also limited by the hard-coded 64k buffer inside OpenSSH.
	* 
The default aes128-ctr cipher likely will transfer somewhere in the 50-200MB/s range.
	* 
The fastest and least secure cipher arcfour will likely only transfer in the 100-250MB/s range.
	* 
In other cases, the hardware could be the cause


诊断步骤
	* 
Test performance of scp to localhost, bypassing external network connection.
	* 
Watch top output while running scp to see if the cpu is idle less than 10%.
	* 
The processes involved with the transfer are scp, ssh, and sshd.
	* 
Test procedure:


Raw

dd if=/dev/zero of=testfile.bin bs=1M count=1000 conv=fsync
scp -c aes128-ctr testfile.bin (user)@localhost:~/
scp -c blowfish testfile.bin (user)@localhost:~/
scp -c arcfour testfile.bin (user)@localhost:~/
 
From <https://access.redhat.com/solutions/393343>