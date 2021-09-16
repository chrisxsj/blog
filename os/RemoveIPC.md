Setting RemoveIPC=yes on Redhat 7.2 Crashes ASM and Database Instances



设置了RemoveIPC=yes 的RHEL7.2  会crash掉Oracle asm 实例和Oracle database实例，该问题也会在使用Shared Memory Segment (SHM) or Semaphores (SEM)的应用程序中发生。
来源于：
ALERT: Setting RemoveIPC=yes on Redhat 7.2 Crashes ASM and Database Instances as Well as Any Application That Uses a Shared Memory Segment (SHM) or Semaphores (SEM) (文档 ID 2081410.1)
 
适用于：
Oracle Database - Standard Edition
Oracle Database - Enterprise Edition
Linux x86-64
Linux x86
 
 
描述：
在RHEL7.2中，systemd-logind 服务引入了一个新特性，该新特性是：当一个user 完全退出os之后，remove掉所有的IPC objects。
该特性由/etc/systemd/logind.conf参数文件中RemoveIPC选项来控制。详细请看man logind.conf(5)
 
在RHEL7.2中，RemoveIPC的默认值为yes
 
因此，当最后一个oracle 或者Grid用户退出时，操作系统会remove 掉这个user的shared memory segments and semaphores
 
由于Oracle ASM 和database 使用 shared memory segments ，remove shared memory segments将会crash掉Oracle ASM and database  instances.
 
请参考Redhat bug 1264533  - https://bugzilla.redhat.com/show_bug.cgi?id=1264533
 
 
 
OCCURRENCE（不知道翻译成什么比较合适）
该问题影响使用the shared memory segments 和semaphores 的所有应用程序,因此，Oracle ASM 实例和Oracle Database 实例均受到影响。
 
Oracle Linux 7.2 通过在/etc/systemd/logind.conf配置文件中明确设置RemoveIPC为no，Oracle Linux7.2 避免了该问题，
但是若是/etc/systemd/logind.conf文件是在os upgrade之前修改的，那么yum/update将会写一个正确的配置文件（RemoveIPC=no），该配置文件名是logind.conf.rpmnew，如果用户使用原来的配置文件，那么本文描述的failures将会发生。
为了避免本问题，当os升级之后，务必编辑logind.conf 文件并设置RemoveIPC=no。这在Oracle Linux 7.2 release notes中有记录。
 
 
 
症状：
 
1) Installing 11.2 and 12c GI/CRS fails, because ASM crashes towards the end of the installation.
2) Upgrading to 11.2 and 12c GI/CRS fails.
3) After Redhat Linux is upgraded to 7.2, 11.2 and 12c ASM and database instances crash.
systemd-logind remove掉IPC objects可能在任何时候发生，故障的表现可以有很大的不同，下面是故障的几个例子
 
Most common error that occurs is that the following is found in the asm or database alert.log:
ORA-27157: OS post/wait facility removed
ORA-27300: OS system dependent operation:semop failed with status: 43
ORA-27301: OS failure message: Identifier removed
ORA-27302: failure occurred at: sskgpwwait1
The second observed error occurs during installation and upgrade when asmca fails with the following error:
KFOD-00313: No ASM instances available. CSS group services were successfully initilized by kgxgncin
KFOD-00105: Could not open pfile 'init@.ora'
The third observed error occurred during installation and upgrade:
Creation of ASM password file failed. Following error occurred: Error in Process: /u01/app/12.1.0/grid/bin/orapwd
 
 Enter password for SYS:
 
OPW-00009: Could not establish connection to Automatic Storage Management instance
 
2015/11/20 21:38:45 CLSRSC-184: Configuration of ASM failed
2015/11/20 21:38:46 CLSRSC-258: Failed to configure and start ASM
The fourth observed error is the following message is found in the /var/log/messages file around the time that asm or database instance crashed:
Nov 20 21:38:43 testc201 kernel: traps: oracle[24861] trap divide error
ip:3896db8 sp:7ffef1de3c40 error:0 in oracle[400000+ef57000]
 
 
变通的解决方法：
1) Set RemoveIPC=no in /etc/systemd/logind.conf
 
2) Reboot the server or restart systemd-logind as follows:
    # systemctl daemon-reload
    # systemctl restart systemd-logind
 
 
补丁：
从RHEL7.2迁移到Oracle Linux7.2可以解决本问题。
若是迁移到Oracle Linux7.2不可能，请使用上述变通的解决方法