Rman 什么时候需要设置set dbid？
rman中恢复参数文件和控制文件时，在restore前可能需要设置set dbid=xxxxx。其目的是用于唯一确定恢复所需的备份文件集。
1. 如果使用了catalog资料库，而该资料库中存放着多个target库的备份信息，如果需要恢复控制文件和参数文件，通过设置的DBID，rman可以确定所需的备份文件信息。如果资料库只记录了一个target库的备份信息，则无需设置dbid
2. 没有使用catalog资料库，即nocatalog的情况下，很多资料说此时需要设置DBID，其实不然。如果使用restore spfile from autobackup语句，则需要设置dbid,RMAN通过dbid来寻找自动 备份的文件。如果你在恢复语句中，给出了备份文件：restore spfile from '/path/xxx.bak' 则无需提前设置dbid。
总而言之，set dbid的唯一目的是使RMAN找到恢复参数文件和控制文件唯一确定的的备份文件。