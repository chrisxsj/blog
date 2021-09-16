vmount: Operation not permitted.

# mount 192.168.1.69:/opt/vfs_home /mhapp/vfs_home

mount: 1831-008 giving up on:
192.168.1.6:/opt/vfs_home
vmount: Operation not permitted. 
 网上有这样解决的，你试试看：
#vi /etc/exports
**         (rw,insecure,no_root_squash) 
insecure选项允许NFS客户端不使用NFS保留的端口，呵呵，问题解决!!
首先使用命令查看出错日志文件
[root@lzgonline init.d]# cat /var/log/messages | grep mount
Jun 29 00:49:04 lzgonline mountd[1644]: refused mount request from 192.168.3.12 for /home/lzgonline/rootfs (/home/lzgonline/rootfs): illegal port 1689
Jun 29 00:51:02 lzgonline mountd[1644]: refused mount request from 192.168.3.12 for /home/lzgonline/rootfs (/home/lzgonline/rootfs): illegal port 1710
Jun 29 01:02:17 lzgonline mountd[1644]: refused mount request from 192.168.3.12 for /home/lzgonline/rootfs (/home/lzgonline/rootfs): illegal port 1916
Jun 29 01:09:51 lzgonline mountd[1644]: refused mount request from 192.168.3.12 for /home/lzgonline/rootfs (/home/lzgonline/rootfs): illegal port 2157
Jun 29 01:17:02 lzgonline mountd[1644]: refused mount request from 192.168.3.12 for /home/lzgonline/rootfs (/home/lzgonline/rootfs): illegal port 2318
 
从出错日志可以看出，mount.nfs: access denied by server while mounting 192.168.3.12:/home/lzgonline/rootfs 被拒绝的原因是因为使用了非法端口，功夫总没白费，终于在一个linux技术论坛上找到了答案：
I googled and found that since the port is over 1024 I needed to add the "insecure" option to the relevant line in /etc/exports on the server. Once I did that (and ran exportfs -r), the mount -a on the client worked.
//如果端口号大于1024，则需要将 insecure 选项加入到配置文件（/etc/exports）相关选项中mount客户端才能正常工作:
查看 exports 手册中关于 secure 选项说明也发现确实如此
[root@lzgonline init.d]# man exports
secure,This  option requires that requests originate on an Internet port less than IPPORT_RESERVED (1024). This option is on by default. To turn it off, specify insecure.
//secure 选项要求mount客户端请求源端口小于1024（然而在使用 NAT 网络地址转换时端口一般总是大于1024的），默认情况下是开启这个选项的，如果要禁止这个选项，则使用 insecure 标识
修改配置文件/etc/exports，加入 insecure 选项
/home/lzgonline/rootfs  *(insecure,rw,async,no_root_squash)
保存退出
然后重启nfs服务：service nfs restart
然后问题就解决了
 
来自 <http://www.cnblogs.com/mchina/archive/2013/01/03/2840040.html>