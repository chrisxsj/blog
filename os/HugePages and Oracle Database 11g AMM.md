HugePages and Oracle Database 11g Automatic Memory Management (AMM) on Linux (Doc ID 749851.1)
 

In this Document
 
Purpose
Scope
Details
References
 
Applies to:
Oracle Database Backup Service - Version N/A and later
Oracle Database Cloud Exadata Service - Version N/A and later
Oracle Database Cloud Service - Version N/A and later
Oracle Cloud Infrastructure - Version N/A and later
Linux OS - Version 2.6 to Oracle Linux 7.4 with Unbreakable Enterprise Kernel [4.1.12]
Linux x86
Linux x86-64
IBM: Linux on System z
IBM: Linux on POWER Big Endian Systems
IBM S/390 Based Linux (31-bit)
Linux Itanium
Purpose
This document discusses the interoperability of the Automatic Memory Management (AMM) feature introduced by Oracle Database 11g and the HugePages (HugeTLB) feature of the Linux OS kernel.
Scope
This document is to be used by Linux system administrators and Oracle database administrators that work with Oracle Database Server 11g on Linux Operating System.
Details
The 11g AMM feature is enabled by the MEMORY_TARGET / MEMORY_MAX_TARGET instance initialization parameters.
That is also the case with a default database instance created using Database Configuration Assistant (DBCA).
With AMM, all SGA memory is allocated by creating files under /dev/shm. When Oracle DB does SGA allocations that way HugePages are not reserved/used.
The use of AMM is absolutely incompatible with HugePages. (Please see references at the end of the document for further information on HugePages)
On systems with HugePages in use, attempting to set the MEMORY_TARGET / MEMORY_MAX_TARGET instance initialization parameters may result in the following error message:
ORA-00845: MEMORY_TARGET not supported on this system
AMM should not be confused with Automatic Shared Memory Management (ASMM) where ASMM has no problem with HugePages (See also 1134002.1)
Please also note that ramfs (instead of tmpfs mount over /dev/shm) is not supported for AMM at all. With AMM the Oracle database needs to grow and reduce the size of SGA dynamically. This is not possible with ramfs where it possible and supported with tmpfs (which is the default for the OS installation).
Note that, AMM is setup for ASM instances by default. On the other hand, since the ASM instances do not have a large SGA, using HugePages for ASM instances is not crucial.
If you want to use HugePages make sure that both MEMORY_TARGET / MEMORY_MAX_TARGET initialization parameters are unset (i.e. using "ALTER SYSTEM RESET") for the database instance.(See also Oracle Database Administrator's Guide 11g)
References
 
NOTE:361323.1 - HugePages on Linux: What It Is... and What It Is Not...
NOTE:465048.1 - ORA-00845 Raised When Starting Instance
 
来自 <https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=359190525965150&id=749851.1&_adf.ctrl-state=4wjl154pq_240>