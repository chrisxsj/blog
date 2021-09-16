How to lock out a user to login a system after a set number of failed attempts in Red Hat Enterprise Linux using pam_tally/pam_tally2
Solution 已验证 - 已更新 2016年六月14日05:29 -
English
English日本語环境
	* 
Red Hat Enterprise Linux 3
	* 
Red Hat Enterprise Linux 4
	* 
Red Hat Enterprise Linux 5
	* 
Red Hat Enterprise Linux 6
	* 
Red Hat Enterprise Linux 7
	* 
pam_tally / pam_tally2 / pam_faillock


问题
	* 
How to lock out a user to login a system after a set number of failed attempts
	* 
How to limit/restrict user(s) from login after failed login attempts
	* 
How to lockout a user to login on server using pam_tally/pam_tally2 module
	* 
How do I configure PAM stack using pam_tally.so/pam_tally2.so for blocking user login using (via) ssh after failed login attempts ?
	* 
Is there any way to enable account lockout after 3 failed login attempts in RHEL ?
	* 
Configure system-auth-ac/system-auth and password-auth-ac/password-auth with pam_tally/pam_tally2
	* 
Configure pam_tally/pam_tally2 in RHEL system for user account lockout
	* 
Implementing account lockout using pam_tally



决议
Pluggable Authentication Module (PAM) comes with the pam_tally login counter module. pam_tally has the capability to maintain attempted access count, reset counters on successful logins and also lock out users with multiple failed login attempts.
In the authentication phase of /etc/pam.d/system-auth and /etc/pam.d/password-auth files the pam_tally deny parameter can be used to restrict the number of failed login attempts. The user account will be locked out once the login attempts exceed the deny tally value.
The examples shown below are configured to allow a maximum number of 3 failed login attempts before it locks the user's account.

Red Hat Enterprise Linux 6
For Red Hat Enterprise Linux 6, pam_tally has been replaced by pam_tally2 thus, following lines need to be added to /etc/pam.d/system-auth and /etc/pam.d/password-auth files:
Raw
auth required pam_tally2.so onerr=fail deny=3 
account required pam_tally2.so
The sample /etc/pam.d/system-auth will look as follows:
Raw
auth required pam_env.so auth required pam_tally2.so onerr=fail deny=3 auth sufficient pam_unix.so nullok try_first_pass auth requisite pam_succeed_if.so uid >= 500 quiet auth required pam_deny.so account required pam_unix.so account required pam_tally2.so account sufficient pam_localuser.so account sufficient pam_succeed_if.so uid < 500 quiet account required pam_permit.so
For more details, have a look at this article: How to configure pam_tally2 to lock user account after certain number of failed login attempts
The attempts will be logged in /var/log/faillog file.
faillog command reports the number of failed login attempts for a specific user:
Raw
# faillog -u <username>
If pam_tally2.so is being used, pam_tally2 command can be used to check number of failed login attempts for a specific user:
Raw
# pam_tally2 -u <username>
To manually unlock a locked user account, execute the following command:
Raw
# faillog -u <username> -r
Similarly, if pam_tally2.so is being used then use pam_tally2 command to unlock a locked user account manually:
Raw
# pam_tally2 -r -u <username>


Red Hat Enterprise Linux 7
For Red Hat Enterprise Linux 7, pam_tally2 has been replaced by pam_faillock Please see Chapter 4. Hardening Your System with Tools and Services in the Red Hat Enterprise Linux 7 Security Guide.
Failed login attempts are stored in a separate file for each user in the /var/run/faillock directory.
Advanced Usage:
	* 
To prevent denial-of-service of a particular service account, use the pam_tally module with per_user option, refer to the How to exclude service accounts from getting locked up using pam_tally module?
	* 
To automatically unlock a user after seconds, refer to the How to make pam_tally to automatically unlock a user with unlock_time option?

Important Notes:
	* 
In RHEL 5, the module pam_tally2 has been added with release/upgrade of version pam-0.99.3.0-1.
Refer following article in order to use pam_tally2.so instead of pam_tally2 in RHEL5: How to configure pam_tally2 to lock user account after certain number of failed login attempts
	* 
For RHEL 6, with release of pam-1.1.1-4.el6, pam_tally module and the faillog (/var/log/faillog) file has been dropped.
	* 
In RHEL 6, the module pam_tally has been replaced by the module pam_tally2. This happened because of the pam package upgrade from version pam-0.99 to pam-1.1. For more details, refer Technical Notes
	* 
With release of RHEL 6.1 and pam-1.1.1-8.el6 , a new pam_faillock module was added to support temporary locking of user accounts in the event of multiple failed authentication attempts. For more details refer Technical Notes
Also, refer What is pam_faillock and how to use it in Red Hat Enterprise Linux 6?
	* 
The faillog command has become obsolete since RHEL 6.1 and is no longer available with release of shadow-utils-4.1.4.2-9.el6.
For more details, refer Where is faillog command for Red Hat Enterprise Linux 6 ?

