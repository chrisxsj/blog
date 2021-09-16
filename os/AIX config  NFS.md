AIX config  NFS



1 服务器端
启动nfs服务
启、停NFS服务
立即启动
#/usr/sbin/mknfs '-N'
立即启动，restart也自动运行
#/usr/sbin/mknfs '-B'
立即停止
#/usr/sbin/rmnfs '-N'
立即停止，系统停止也停止
#/usr/sbin/mknfs '-B'
smit nfs 》 Add a Directory to Exports List》
* Pathname of directory to export 输入导出目录路径和名称
smit mknfsexp》hosts access ，host root access
cat /etc/exports
 
 
2 客户端
#lssrc -s portmap
smit nfs>   Add a File System for Mounting
Pathname of mount point 填B机上mount点
Pathname of remote directory填A机上路径
Host where remote directory resides填A机主机名（在A机器上运行hostname获得）
 
注意： 要在A,B两端的/etc/hosts里互相都加上彼此的IP地址和hostname
 
来自 <http://blog.tianya.cn/blogger/post_read.asp?BlogID=124396&PostID=39269383>