AIX:
查看AIX操作系统 每个block size 大小：
# lsfs -q /u01
Name            Nodename   Mount Pt               VFS   Size    Options    Auto Accounting
/dev/fslv00     --         /u01                   jfs2  50331648 rw         yes  no
  (lv size: 50331648, fs size: 50331648, block size: 4096, sparse files: yes, inline log: no, inline log size: 0, EAformat: v1, Quota: no, DMAPI: no, VIX: no)
Windows:
C:\Documents and Settings\Administrator>fsutil fsinfo ntfsinfo c:
NTFS Volume Serial Number :       0xfae82044e81ffe0f
Version :                         3.1
Number Sectors :                  0x0000000004ffffff
Total Clusters :                  0x00000000009fffff
Free Clusters  :                  0x00000000003ff408
Total Reserved :                  0x0000000000000000
Bytes Per Sector  :               512
Bytes Per Cluster :               4096
Bytes Per FileRecord Segment    : 1024
Clusters Per FileRecord Segment : 0
Mft Valid Data Length :           0x000000000fac8000
Mft Start Lcn  :                  0x00000000000c0000
Mft2 Start Lcn :                  0x0000000000000010
Mft Zone Start :                  0x00000000000cfac0
Mft Zone End   :                  0x0000000000200000
Linux:
[root@www.linuxidc.com ~]# tune2fs -l /dev/sda1
tune2fs 1.39 (29-May-2006)
Filesystem volume name:   /
Last mounted on:          <not available>
Filesystem UUID:          05b4b85c-eb01-4d22-b011-4307b910010b
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery sparse_super large_file
Default mount options:    user_xattr acl
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              5124480
Block count:              5120710
Reserved block count:     256035
Free blocks:              4312881
Free inodes:              5006108
First block:              0
Block size:               4096
Fragment size:            4096
Reserved GDT blocks:      1022
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         32640
Inode blocks per group:   1020
Filesystem created:       Mon Dec 13 22:20:57 2010
Last mount time:          Thu Feb 10 08:39:51 2011
Last write time:          Thu Feb 10 08:39:51 2011
Mount count:              18
Maximum mount count:      -1
Last checked:             Mon Dec 13 22:20:57 2010
Check interval:           0 (<none>)
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               128
Journal inode:            8
First orphan inode:       2872327
Default directory hash:   tea
Directory Hash Seed:      3f80d852-e54e-4a21-8142-b3e30299fdd2
Journal backup:           inode blocks