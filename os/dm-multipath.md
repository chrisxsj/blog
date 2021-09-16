dm-multipath

各位，附件中是rhel5下使用dm-multipath配置 多路径的文档说明，该说明来自如下的链接。
 
另外，其他rhel版本的使用dm-multipath配置 多路径的文档说明，请自行从下面的链接中下载。
 
dm-multipath 使用的虚拟名：/dev/mapper/mpathN
 
 
对multipath -ll命令的输出的解释:
mpathv (360014054fc671cae13a43aaa558e6905) dm-4 LIO-ORG ,dg_sata_ssd2_d1 
size=700G features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 11:0:0:3 sde  8:64   active ready running
  `- 13:0:0:3 sdu  65:64  active ready running
 
 
1.mpathv是multipath软件聚合之后生成的磁盘盘符.
2.mpathv的WWID是360014054fc671cae13a43aaa558e6905
3.mpathv对应着底层的两个盘符sde和sdu,并且sde和sdu的状态都是active ready running
4.dm-4此类的名字禁止外界应用程序使用---切记!!!
5.wp=rw ,我猜测wp是写策略的意思.
6.LIO-ORG是??
7.dg_sata_ssd2_d1是使用udev规则之后(/etc/udev/rules.d/96-asmmultipath.rules)生成的盘符,该盘符会供给外界应用程序(比如Oracle database)
附:
[root@rac1 rules.d]# cat /etc/udev/rules.d/96-asmmultipath.rules
ACTION=="add|change", ENV{DM_UUID}=="mpath-36001405606bd41c53e74877993614b6a", SYMLINK+="highgo/dg_sata_ssd2_d3", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-3600140529532299d56a46dcb5b9e7d9f", SYMLINK+="highgo/dg_sata_ssd1_d3", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-36001405db23f61b99324f21b51be3445", SYMLINK+="highgo/dg_sata_ssd2_d2", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-36001405f0bcaacbfd0c4b42aa46c8302", SYMLINK+="highgo/ocrvote_sata_d3", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-3600140587c66a6637204e8f9055df09e", SYMLINK+="highgo/dg_pcie_ssd_d2", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-360014054b754a19e6804cacaacb1a81b", SYMLINK+="highgo/fla_sata_d3", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-360014058939cdbdc68148e098748902d", SYMLINK+="highgo/ocrvote_sata_d1", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-36001405dcd17d99262c48089d938f34b", SYMLINK+="highgo/dg_pcie_ssd_d3", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-36001405984077912332492bb0f5239ee", SYMLINK+="highgo/fla_sata_d1", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-3600140571a31cd92eb6429db03cf53a4", SYMLINK+="highgo/ocrvote_sata_d2", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-360014054fc671cae13a43aaa558e6905", SYMLINK+="highgo/dg_sata_ssd2_d1", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-3600140582e300b662294ebab2be1d2d6", SYMLINK+="highgo/fla_sata_d2", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-3600140509db8f21d0d648c8968fef0d5", SYMLINK+="highgo/dg_sata_ssd1_d1", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-360014058906b9a85fbd4553a6977508e", SYMLINK+="highgo/dg_sata_ssd1_d2", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-36001405fb344d0dd49f47259c66085b7", SYMLINK+="highgo/dg_pcie_ssd_d1", OWNER="grid", GROUP="asmadmin", MODE="0660"
ACTION=="add|change", ENV{DM_UUID}=="mpath-360014054164f58a55e84226ad2e5c4c1", SYMLINK+="highgo/ocrvote_tmp_d1", OWNER="grid", GROUP="asmadmin", MODE="0660"
[root@rac1 rules.d]# 
 
注:两个节点的lsscsi -g的结果很可能不一致,不一致的原因是在于linux os 认到的/dev/sd*的顺序,由于外界应用程序(比如Oracle database)不是用的/dev/sd*,因此这不是问题.
[root@rac2 rules.d]# lsscsi -g   
[0:2:0:0]    disk    AVAGO    SMC3108          4.62  /dev/sda   -        
[11:0:0:0]   disk    LIO-ORG  ocrvote_sata_d1  4.0   /dev/sdb   -        
[11:0:0:1]   disk    LIO-ORG  fla_sata_d1      4.0   /dev/sdc   -        
[11:0:0:2]   disk    LIO-ORG  dg_sata_ssd1_d1  4.0   /dev/sdd   -        
[11:0:0:3]   disk    LIO-ORG  dg_sata_ssd2_d1  4.0   /dev/sde   -        
[11:0:0:4]   disk    LIO-ORG  dg_pcie_ssd_d1   4.0   /dev/sdf   -        
[12:0:0:0]   disk    LIO-ORG  ocrvote_sata_d3  4.0   /dev/sdg   -        
[12:0:0:1]   disk    LIO-ORG  fla_sata_d3      4.0   /dev/sdh   -        
[12:0:0:2]   disk    LIO-ORG  dg_sata_ssd1_d3  4.0   /dev/sdi   -        
[12:0:0:3]   disk    LIO-ORG  dg_sata_ssd2_d3  4.0   /dev/sdj   -        
[12:0:0:4]   disk    LIO-ORG  dg_pcie_ssd_d3   4.0   /dev/sdk   -        
[13:0:0:0]   disk    LIO-ORG  ocrvote_sata_d2  4.0   /dev/sdl   -        
[13:0:0:1]   disk    LIO-ORG  fla_sata_d2      4.0   /dev/sdm   -        
[13:0:0:2]   disk    LIO-ORG  dg_sata_ssd1_d2  4.0   /dev/sdo   -        
[13:0:0:3]   disk    LIO-ORG  dg_sata_ssd2_d2  4.0   /dev/sdq   -        
[13:0:0:4]   disk    LIO-ORG  dg_pcie_ssd_d2   4.0   /dev/sdv   -        
[14:0:0:0]   disk    LIO-ORG  ocrvote_sata_d1  4.0   /dev/sdn   -        
[14:0:0:1]   disk    LIO-ORG  fla_sata_d1      4.0   /dev/sdp   -        
[14:0:0:2]   disk    LIO-ORG  dg_sata_ssd1_d1  4.0   /dev/sdu   -        
[14:0:0:3]   disk    LIO-ORG  dg_sata_ssd2_d1  4.0   /dev/sdy   -        
[14:0:0:4]   disk    LIO-ORG  dg_pcie_ssd_d1   4.0   /dev/sdab  -        
[15:0:0:0]   disk    LIO-ORG  ocrvote_sata_d3  4.0   /dev/sdr   -        
[15:0:0:1]   disk    LIO-ORG  fla_sata_d3      4.0   /dev/sdt   -        
[15:0:0:2]   disk    LIO-ORG  dg_sata_ssd1_d3  4.0   /dev/sdw   -        
[15:0:0:3]   disk    LIO-ORG  dg_sata_ssd2_d3  4.0   /dev/sdx   -        
[15:0:0:4]   disk    LIO-ORG  dg_pcie_ssd_d3   4.0   /dev/sdaa  -        
[16:0:0:0]   disk    LIO-ORG  ocrvote_sata_d2  4.0   /dev/sds   -        
[16:0:0:1]   disk    LIO-ORG  fla_sata_d2      4.0   /dev/sdz   -        
[16:0:0:2]   disk    LIO-ORG  dg_sata_ssd1_d2  4.0   /dev/sdac  -        
[16:0:0:3]   disk    LIO-ORG  dg_sata_ssd2_d2  4.0   /dev/sdad  -        
[16:0:0:4]   disk    LIO-ORG  dg_pcie_ssd_d2   4.0   /dev/sdae  

=======================

 * 不重启操作系统情况下，识别新划分存储

echo '- - -' > /sys/class/scsi_host/host*/scan    --存储识别
multipath -V3     --多路径识别
multipath -ll