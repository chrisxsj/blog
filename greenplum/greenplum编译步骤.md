1.1.   编译前依赖包准备（需要联网安装）（master）
yum -y install rsync coreutils glib2 lrzsz sysstat e4fsprogs xfsprogs ntp readline-devel zlib zlib-devel openssl openssl-devel pam-devel libxml2-devel libxslt-devel python-devel tcl-devel gcc make smartmontools flex bison perl perl-devel perl-ExtUtils* OpenIPMI-tools openldap openldap-devel logrotate gcc-c++ python-py libyaml-devel
 
yum -y install bzip2-devel libevent-devel apr-devel curl-devel ed python-paramiko python-devel
（需要联网安装）
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install --upgrade setuptools
pip install lockfile paramiko setuptools epydoc psutil
1.2.   编译
（1）       解压
tar -zxvf 6.10.1-src-full.tar.gz
（2）       给解压出来的软件包授权
chown gpadmin:gpadmin  -R gpdb_src/
（3）       创建安装目录，并授权
mkdir -p /data/gpdb
chown  gpadmin:gpadmin -R /data
（4）       拷贝解压目录到/ data  
su – gpadmin
cp -R gpdb_src/ /data
 
（5）       gpadmin用户执行配置 –prefix后是安装目录，


   ./configure --prefix=/data/gpdb --enable-mapreduce --with-perl --with-python --with-libxml --with-gssapi --disable-orca --with-gssapi --with-pgport=5432 --with-libedit-preferred --with-perl --with-python --with-openssl --with-pam --with-krb5 --with-ldap --with-libxml --enable-cassert --enable-debug --enable-testutils --enable-debugbreak --enable-depend --without-zstd 
make 
make install -j 8