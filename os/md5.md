# md5

md5 验证

windows：
C:\Users\oracle>certutil  -hashfile p13390677_112040_Linux-x86-64_1of7.zip md5

linux：
md5sum p13390677_112040_Linux-x86-64_1of7.zip

solaris：
MD5:
$ digest -v -a md5 /home/myuser/test_file1  

AIX：
$ csum p8202632_10205_AIX64-5L_1of2.zip

HPUX：
MD5:
$ openssl dgst -md5 oracle.aurora.javadoc.zip

得出的值和如下官方提供的md5值进行对比，如果md5值不同，则表示文件有可能被篡改过。不可以使用。 
文件的名字发生变化并不影响md5值的校验结果。

参考：
How to Verify the Integrity of a Patch/Software Download? [Video] (文档 ID 549617.1)