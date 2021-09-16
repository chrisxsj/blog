HP MCSG cluster

 ioscan -fnCdisk   --扫描磁盘（pv）
启动cluster
# cmruncl        
cmruncl: Validating network configuration...
cmruncl: Network validation complete
cmruncl: Validating cluster lock disk .... Done
cmruncl: Cluster is already running on "jddb1".
cmruncl: Cluster is already running on "jddb2".
#
查看cluster
# cmviewcl
CLUSTER        STATUS
cluster        up
  NODE           STATUS       STATE
  jddb1          up           running
  jddb2          up           running
UNOWNED_PACKAGES
    PACKAGE        STATUS           STATE            AUTO_RUN    NODE
    pkg1           down             failed           disabled    unowned
    pkg2           down             failed           disabled    unowned
#
 
查看vg
# vgdisplay
启动cluster package
# cmrunpkg -v pkg2
查看cluster（注意每个包只能跑在单独的服务器上）
# cmviewcl
CLUSTER        STATUS
cluster        up
  NODE           STATUS       STATE
  jddb1          up           running
    PACKAGE        STATUS           STATE            AUTO_RUN    NODE
    pkg1           up               running          disabled    jddb1
  NODE           STATUS       STATE
  jddb2          up           running
    PACKAGE        STATUS           STATE            AUTO_RUN    NODE
    pkg2           up               running          disabled    jddb2
#
 
来自 <http://www.loveunix.net/archiver/tid-128535.html>