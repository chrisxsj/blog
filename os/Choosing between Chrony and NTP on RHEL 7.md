Choosing between Chrony and NTP on RHEL 7
 SOLUTION 已验证 - 已更新 2017年十一月8日01:48 - 
English 
环境
	* 
Red Hat Enterprise Linux 7
	* 
Chrony
	* 
NTP


问题
What recommendations can Red Hat provide to customers when selecting between Chrony or NTP time protocols for Red Hat Enterprise Linux (RHEL) 7?
决议
The following section of the RHEL 7 System Administrators Guide provides guidance on this topic:
	* 
Red Hat Enterprise Linux 7 System Administrators Guide - 16.1.2. Choosing Between NTP Daemons.


Raw
Chrony should be preferred for all systems except for the systems that are managed or monitored by tools that do not support chrony, or the systems that have a hardware reference clock which cannot be used with chrony.

**NOTE**
Systems which are required to perform authentication of packets with the Autokey protocol, can only be used with ntpd, because chronyd does not support this protocol. The Autokey protocol has serious security issues, and thus using this protocol should be avoided. Instead of Autokey, use authentication with symmetric keys, which is supported by both chronyd and ntpd. Chrony supports stronger hash functions like SHA256 and SHA512, while ntpd can use only MD5 and SHA1.
 
From <https://access.redhat.com/solutions/2070363>