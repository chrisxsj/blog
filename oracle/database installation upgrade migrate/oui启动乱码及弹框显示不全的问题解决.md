# oui启动乱码及弹框显示不全的问题解决

中文环境会造成乱码，解决方案如下

export LANG=C

弹框显示不全，可能是java版本过低。解决方案如下

下载新版Java，使用新版jdk

tar -xvf jdk1.8.0_301
./runInstaller -jreLoc /opt/jdk1.8.0_301