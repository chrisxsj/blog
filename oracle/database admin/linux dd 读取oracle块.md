linux dd 读取oracle log file 0号块

 由于 dd 命令允许二进制方式读写，所以特别适合在原始物理设备上进行输入/输出。
dd if=/oracle/APP/ORACLE/ORADATA/TEST/REDO01.LOG bs=512 count=1 |od -x
 
if=file 输入文件名，缺省为标准输入。 
of=file 输出文件名，缺省为标准输出
bs：block size  块大小
count: block size 总数
od -x  : 转换成16进制