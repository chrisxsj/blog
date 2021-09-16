cat /etc/rc.local
su - oracle "-c /home/oracle/scripts/start_db.sh"

cat start_db.sh
source ~/.bash_profile

lsnrctl start
sqlplus /nolog << EOF
connect / as sysdba
startup mount;
ALTER DATABASE OPEN READ ONLY;
RECOVER MANAGED STANDBY DATABASE DISCONNECT USING CURRENT LOGFILE;
exit
EOF