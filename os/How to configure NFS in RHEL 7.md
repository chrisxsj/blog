How to configure NFS in RHEL 7 SOLUTION 已验证 - 已更新 2018年十二月7日22:43 - English 环境
	* Red Hat Enterprise Linux 7

问题
	* How do I configure NFS in RHEL 7?
	* How do I enable the NFS service in RHEL 7?

决议
	1. Install NFS packages on the system using the following command:Raw# yum install nfs-utils rpcbind
	2. Enable the services at boot time:Raw#  systemctl enable nfs-server#  systemctl enable rpcbind#  systemctl enable nfs-lock         <-- In  RHEL7.1 (nfs-utils-1.3.0-8.el7)   this does not work (No such file or directory).   it does not need to be enabled since rpc-statd.service  is static.#  systemctl enable nfs-idmap     <-- In  RHEL7.1 (nfs-utils-1.3.0-8.el7)   this does not work (No such file or directory).  it does not need to be enabled since nfs-idmapd.service is static.
	3. Start the NFS services:Raw#  systemctl start rpcbind#  systemctl start nfs-server#  systemctl start nfs-lock#  systemctl start nfs-idmap
	4. Check the status of NFS service:Raw# systemctl status nfs
	5. Create a shared directory:Raw# mkdir /test
	6. Export the directory:Raw# vi /etc/exports/test *(rw)
	7. Exporting the share:Raw# exportfs -r
	8. Restart the NFS service:Raw# systemctl restart nfs-server
	9. If the firewall is enabled, ports for NFS will need to be opened.

 From <https://access.redhat.com/solutions/1355233> 

What firewalld services should be active on an NFS server in RHEL 7?
 SOLUTION UNVERIFIED - 已更新 2014年十一月4日11:21 - 
English 
环境
	* 
Red Hat Enterprise Linux (RHEL) 7

		* 
Host acting as an NFS server
	* 
firewalld


问题
	* 
I'm trying to export file systems via NFS, and need to know which firewalld services will allow access


决议
NOTE: All firewall configurations should tailored to the individual environment based on its specific requirements. The recommendations here are only given in a general sense, and should only be followed if the implications of opening these ports is fully understood.
To allow access to NFS, enable the nfs, mountd, and rpc-bind services in the relevant zone in the firewall-config application or using firewall-cmd:
Raw

# firewall-cmd --add-service=nfs --zone=internal --permanent
# firewall-cmd --add-service=mountd --zone=internal --permanent
# firewall-cmd --add-service=rpc-bind --zone=internal --permanent
 
From <https://access.redhat.com/solutions/974543>

 
 
服务器
# yum install nfs-utils rpcbind
 
#  systemctl enable nfs-server
#  systemctl enable rpcbind
#  systemctl enable nfs-lock
 
 
#  systemctl start rpcbind
#  systemctl start nfs-server
#  systemctl start nfs-lock
#  systemctl start nfs-idmap
 
# systemctl status nfs
 
mkdir /tmp
mount /dev/sdb1 /mnt
 
[root@postgres yum.repos.d]# cat /etc/exports
/test        192.168.6.11(rw,no_root_squash,sync)
 
 
 
exportfs -r
 
 
# firewall-cmd --add-service=nfs  --permanent
# firewall-cmd --add-service=mountd --permanent
# firewall-cmd --add-service=rpc-bind --permanent
firewall-cmd --reload
 
 
客户端
[root@hgdbt yum.repos.d]# showmount -e 192.168.6.13
Export list for 192.168.6.13:
/test 192.168.6.11
 
如出现如下报错，说明firewalld没有放开端口。执行以上的firewall-cmd命令，将服务器加入防火墙即可
clnt_create: RPC: Port mapper failure - Unable to receive: errno 113 (No route to host)
 
mount -t nfs 192.168.6.13:/test /test
vi /test/aa
 
配置开机自动挂载
vi /etc/fstab
添加
192.168.6.13:/test /test nfs  nodev,ro,rsize=32768,wsize=32768    0 0