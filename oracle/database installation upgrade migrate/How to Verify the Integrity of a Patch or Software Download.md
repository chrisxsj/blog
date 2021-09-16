How to Verify the Integrity of a Patch/Software Download? [Video] (Doc ID 549617.1)



In this Document
 
Goal
Solution
Calculating MD5 and SHA-1 checksum in Solaris 10 and 11:
Calculating MD5 and SHA-1 checksum in Linux:
Calculating MD5 and SHA-1 checksum in AIX:
Calculating MD5 and SHA-1 checksum in HPUX (PA-RISC and Itanium):
Calculating MD5 and SHA-1 checksum in Windows:
References
 
Applies to:
Oracle Database - Enterprise Edition - Version 8.1.7.4 and later
Oracle Database - Standard Edition - Version 8.1.7.4 and later
Information in this document applies to any platform.
 
 
 
 
Goal
What is MD5 checksum?
What is SHA-1 checksum?
How to check the MD5 and SHA-1 checksum of a download of a Patch / Software Download?
 
Note:  this document may be used for all patches downloaded from MyOracleSupport
Solution
 
MD5 stands for Message-Digest algorithm 5. The MD5 algorithm takes as input a message of random length and produces as output a 128-bit "fingerprint" or "message digest". By comparing the MD5sum of the input (the file to be downloaded) and the output (the downloaded file), the integrity of the download can be verified.
SHA stands for Secure Hash Algorithm. There are five algorithms in SHA, denoted by SHA-1, SHA-224, SHA-256, SHA-384, and SHA-512. SHA-1, like MD5,  is another algorithm that is used to verify data integrity. The main difference between the two algorithms is that while MD5 uses 128bits to produce a message digest, SHA-1 uses 160 bits.
When downloading Oracle software from OTN or any patchset from Metalink, it is important to ensure that the file did not get corrupt during the download. This can be achieved by comparing the MD5 and/or SHA-1 checksum as shown below:
 
Video - Verifying a good download from MOS (02:14)
---------------------------------------------------------------------------------------------------
After download, the SHA-1 and MD5 should match that of the source, as above. If they do not match, it is required to download the file again.
It is also possible to check the calculate the checksum provided in OTN using the 'cksum' command.
For instance, in Linux, the following command is used:
/usr/bin/cksum <file_name>
Note:
Solaris does not ship with md5sum installed.
For Solaris 8 and 9:
md5sum, sha1sum utilities are included in the GNU 'coreutils' package available at www.sunfreeware.com
For Solaris 10:
'digest' utility must be installed.
Calculating MD5 and SHA-1 checksum in Solaris 10 and 11:
The digest utility calculates the message digest of the given file(s) or stdin using the algorithm specified.
 
MD5:
$ digest -v -a md5 <complete_path_of_file_name>
SHA-1:
$/usr/bin/digest -v -a sha1<complete_path_of_file_name>
 
Here, file_name is the complete location of the downloaded file.
Example of calculating MD5 and SHA-1 checksum in Solaris :
MD5:
$ digest -v -a md5 /home/myuser/test_file1
 
md5 /home/myuser/test_file = d41d8cd98f00b204e9800998ecf8427e
 
SHA-1:
$/usr/bin/digest -v -a sha1 /home/myuser/test_file3
 
sha1 (/home/myuser/test_file3) = da39a3ee5e6b4b0d3255bfef95601890afd80709
Calculating MD5 and SHA-1 checksum in Linux:
The command is
MD5:
$md5sum <complete_path_of_file_name>
SHA-1:
$ sha1sum <complete_path_of_file_name>
Here, file_name is the complete location of the downloaded file.
Example of calculating MD5 and SHA-1 checksum in Linux:
MD5:
$md5sum /home/myuser/test_file2
d41d8cd98f00b204e9800998ecf8427e /home/myuser/test_file2
 
SHA-1:
$ sha1sum /home/myuser/test_file4
 
da39a3ee5e6b4b0d3255bfef95601890afd80709 /home/myuser/test_file4
Calculating MD5 and SHA-1 checksum in AIX:
The command is
MD5:
$ csum <filename>
SHA-1:
$ csum -h SHA1 <filename>
Here, file_name is the complete location of the downloaded file.
Example of MD5 and SHA-1 checksum utility on AIX:
MD5:
$ csum p8202632_10205_AIX64-5L_1of2.zip
1b58a3f5478fbdf9c660fcce5f9558cb  p8202632_10205_AIX64-5L_1of2.zip
SHA-1:
$ csum -h SHA1 p8202632_10205_AIX64-5L_1of2.zip
be78759fe031cd3a59b8490ee1d27b1ca321dd8f  p8202632_10205_AIX64-5L_1of2.zip
Calculating MD5 and SHA-1 checksum in HPUX (PA-RISC and Itanium):
The command is
MD5:
$ openssl dgst -md5 <filename>
SHA-1:
$ openssl dgst -sha1 <filename>
Here, file_name is the complete location of the downloaded file.
Example of MD5 and SHA-1 checksum utility on HPUX (PA-RISC or Itanium):
MD5:
$ openssl dgst -md5 oracle.aurora.javadoc.zip
 
MD5(oracle.aurora.javadoc.zip)= fc75f35af0d389cc0a7a1dd959ccb706
SHA-1:
$ openssl dgst -sha1 oracle.aurora.javadoc.zip
 
SHA1(oracle.aurora.javadoc.zip)= c8cbb951fc3905a545f139fd7f59bb07ebab136b
Calculating MD5 and SHA-1 checksum in Windows:
Microsoft offers a tool called the File Checksum Integrity Verifier utility, available for download from Microsoft Technet within Knowledge Base article number 841290. 
This utility can be used on Windows to verify the integrity of the downloaded file.
The syntax is:
        fciv.exe  -both  <downloaded_filename>
For example, these are the results for a patch download from My Oracle Support (MOS):
fciv  -both    p2617419_10102_GENERIC.zip
//
// File Checksum Integrity Verifier version 2.05.
//
MD5                                                     SHA-1
-------------------------------------------------------------------------
64f18de4aa1a41894cf08cddc1cd1dbc 276c2c529324744021f279d84cbb46c189896390
p2617419_10102_generic.zip
 or
 
CertUtil -hashfile <fulll path of downloaded_filename>  MD5
 
References
NOTE:1351051.1 - Information Center: Install and Configure Database Server/Client Installations
NOTE:1351428.1 - Information Center: Patching and Maintaining Oracle Database Server/Client Installations
NOTE:1194734.1 - Where do I find Database content on My Oracle Support (MOS) [Video]
NOTE:778.1 - Troubleshooting Video Issues in MOS
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=420421393016271&id=549617.1&_adf.ctrl-state=re0xaolxe_57>

case：
下载的安装包，有md5值的，直接比对，没有md5值的，生成一个md5值比对。
1、生成md5值
Notepad++ or other tools
工具>md5>从文件生成
351b7f86136e4813c9aff1a08084c765  hgdb4.7.6-standard-rhel7.x-x86-64-20181025.tar.gz
 
2、上传linux服务器
 
3、验证md5值
[pg@pg software]$ md5sum hgdb4.7.6-standard-rhel7.x-x86-64-20181025.tar.gz
351b7f86136e4813c9aff1a08084c765  hgdb4.7.6-standard-rhel7.x-x86-64-20181025.tar.gz