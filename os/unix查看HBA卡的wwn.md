HBA，字面理解是主机总线适配卡，我觉得现在狭义的叫做FCHBA，在的HBA也就是Fibre Channel HostBus Adapter
和以太网卡的MAC地址一样，HBA上也有独一无二的标识，这就是WWN（World Wide Name）
rhel 6.4
你找对了，WWN就是 /sys/class/fc_host/hostX/port_name
状态是 /sys/class/fc_host/hostX/port_state
当前接口速率是 /sys/class/fc_host/hostX/speed
当前接口类型是 /sys/class/fc_host/hostX/port_type
 
UNIX系统下查看FC HBA卡的信息
在此介绍实际应用较为广泛的UNIX系统中如何查看FC HBA卡信息，包括IBM AIX、SUN SOLARIS、HP-UNIX。
1、 IBM AIX
    ① 查看AIX主机连接的光纤设备
       # lsdev -Cc adapter -S a | grep fcs
        fcs0      Available 09-08 FC Adapter
        fcs1      Available 09-09 FC Adapter
       上面的输出显示有2块光纤卡：fcs0和fcs1。
    ② 查看光纤卡fcs0的WWN号
       # lscfg -vpl fcs0
        fcs0             U787B.001.DNWG664-P1-C1-T1  FC Adapter
        Part Number.................10N8620
        Serial Number...............1B74404468
        Manufacturer................001B
        EC Level....................A
        Customer Card ID Number.....5759
        FRU Number.................. 10N8620
        Device Specific.(ZM)........3
        Network Address.............10000000C96E2898
        ROS Level and ID............02C82138
        Device Specific.(Z0)........1036406D
        Device Specific.(Z1)........00000000
        Device Specific.(Z2)........00000000
        Device Specific.(Z3)........03000909
        Device Specific.(Z4)........FFC01159
        Device Specific.(Z5)........02C82138
        Device Specific.(Z6)........06C12138
        Device Specific.(Z7)........07C12138
        Device Specific.(Z8)........20000000C96E2898
        Device Specific.(Z9)........BS2.10X8
        Device Specific.(ZA)........B1F2.10X8
        Device Specific.(ZB)........B2F2.10X8
        Device Specific.(ZC)........00000000
        Hardware Location Code......U787B.001.DNWG664-P1-C1-T1
上面命令的输出中，加粗红色的部分就是光纤卡的WWN号。
2、 SUN SOLARIS
    ① 查询现有存储设备和光纤设备，可以读到包括磁盘设备的WWN号
       # luxadm probe
    ② 查看HBA的prot，可以得到HBA卡的port值以及属性
      # luxadm -e port
      /devices/pci@0,0/pci1022,7450@2/pci1077,101@1/fp@0,0:devctl          NOT CONNECTED
      /devices/pci@0,0/pci1022,7450@2/pci1077,101@1,1/fp@0,0:devctl        CONNECTED
从中可以看到仅有一块光纤卡连接到存储设备。
③ 选择已经连接的HBA卡，查看其WWN号
       # luxadm -e dump_map /devices/pci@0,0/pci1022,7450@2/pci1077,101@1/fp@0,0:devctl
       Pos  Port_ID Hard_Addr Port WWN         Node WWN         Type
       0    0       0        210000e08b19827a 200000e08b19827a 0x1f (Unknown Type,Host Bus Adapter)
3、 HP-UNIX
    ① 列出HP机上连接的光纤卡设备
      # ioscan -fnC fc
Class  I  H/W Path  Driver S/W State   H/W Type   Description
=================================================================
fc  0  0/3/1/0  fcd  CLAIMED   INTERFACE  HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 1)
                      /dev/fcd0
fc  1  0/3/1/1  fcd  CLAIMED   INTERFACE  HP A6826-60001 2Gb Dual Port PCI/PCI-X Fibre Channel Adapter (FC Port 2)
                      /dev/fcd1
    从上面命令的输出可以看 ,/dev/fcd0 和 /dev/fcd1两块光纤卡。
    ② 查看光纤卡的WWN号
      # fcmsutil /dev/fcd0
      Vendor ID is = 0x001077
      Device ID is = 0x002312
      PCI Sub-system Vendor ID is = 0x00103c
      PCI Sub-system ID is = 0x0012ba
      PCI Mode = PCI-X 133 MHz
      ISP Code version = 3.3.18
      ISP Chip version = 3
      Topology = PTTOPT_FABRIC
      Link Speed = 2Gb
      Local N_Port_id is = 0xa10500
      Previous N_Port_id is = None
      N_Port Node World Wide Name = 0x50060b00001db241
      N_Port Port World Wide Name = 0x50060b00001db240
      Switch Port World Wide Name = 0x205e000dec0e2e00
      Switch Node World Wide Name = 0x2001000dec0e2e01
      Driver state = ONLINE
      Hardware Path is = 0/3/1/0
      Maximum Frame Size = 2048
      Driver-Firmware Dump Available = NO
      Driver-Firmware Dump Timestamp = N/A
      Driver Version = @(#) libfcd.a HP Fibre Channel ISP 23xx & 24xx Driver B.11.23.04 /ux/core/isu/FCD/kern/src/common/wsio/fcd_init.c:Oct 18 2005,08:21:11
其中红色加粗部分显示了HBA卡的WWNN和WWPN号，另外还能看到该HBA卡连接的光纤交换机端口的WWN号。 
 
来自 <http://bbs.51cto.com/thread-1116648-1.html>