top 5
Gc cr multi block request 等待严重，且 有gc cr block lost 事件。


3 号实例Netstat –s 含有大量 fragments dropped after timeout
 在其他两个服务器上没有

 处理：
 1 官方文档处理 修改参数
 https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=525579225582978&id=563566.1&_adf.ctrl-state=l230su207_65

 2 两节点测速 scp

客户检查心跳网络发现 3号实例的心跳网络灯变黄，推测是进行了降速。
网络问题修复后检查 3号实例AWR
