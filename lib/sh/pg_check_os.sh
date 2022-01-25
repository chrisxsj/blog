#! /bin/bash
#########################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
#########################################
# variable
DATE=`date +"%Y%m%d%H%M"`
# 
function server()  {
  echo "###### 服务器信息"
  dmidecode -s system-manufacturer
  dmidecode -s system-product-name
  dmidecode -s system-serial-number
  echo "###### 平台（系统版本+内核）"
  cat /etc/os-release
  uname -a
  echo "###### 主机名"
  hostnamectl
  cat /etc/sysconfig/network
  #echo "######拓扑结构 "
  #lstopo-no-graphics
  echo "###### 操作系统内核参数（静态和动态配置）"
  cat /etc/sysctl.conf |grep "^[a-z]"
  sysctl -a
  echo "###### 操作系统资源限制"
  cat /etc/security/limits.conf|grep -v "^$" |grep -v "^#"
  for dir in `ls /etc/security/limits.d`; do echo "/etc/security/limits.d/$dir : "; grep -v "^#" /etc/security/limits.d/$dir|grep -v "^$"; done
  echo "###### 文件系统"
  cat /etc/fstab
  mount -l
  echo "###### grub配置"
  cat /etc/default/grub |grep -v "^$" |grep -v "^#"
  echo "###### crontab配置"
  for dir in `ls /var/spool/cron`; do echo "/var/spool/cron/$dir : "; cat /var/spool/cron/$dir; done 
  echo "######  服务配置"
  systemctl list-unit-files |grep hgdb
  echo "###### selinux配置"
  cat /etc/selinux/config |grep -v "^$" |grep -v "^#"
  echo "###### firewall配置"
  systemctl status firewalld
  firewall-cmd --list-ports

  echo -e "\n"
}

# 
function network()  {
  echo "###### ip地址信息"
  ip addr show
  echo "###### 路由信息"
  ip route show

  echo -e "\n"
}

# 
function cpu()  {
  echo "###### cpu"
  lscpu

  echo -e "\n"
}

# 
function mem()  {
  echo "###### mem和hugepage"
  free -m
  cat /proc/meminfo |grep Huge
  echo "###### Transparent Huge Pages (THP)配置，建议禁用never"
  cat /sys/kernel/mm/transparent_hugepage/enabled

  echo -e "\n"
}

# 
function process()  {
  echo "###### 进程树"
  pstree -a -p|grep post

  echo -e "\n"
}

# 
function storage()  {
  echo "###### 块设备"
  lsblk
  echo "###### 磁盘空间"
  df -h
  df -i
  echo "###### 多路径信息"
  cat /etc/multipath.conf |grep -v '^#'

  echo -e "\n"
}

# 
function performance()  {
  echo "###### top"
  top -b1 -n 2 -o +%MEM |tee /tmp/mem
  top -b1 -n 2 -o +%CPU |tee /tmp/cpu
  echo "###### cpu"
  vmstat 2 5
  echo "###### io"
  iostat -tkx 2 5
  echo "###### CPU占用率前十"
  #ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head -n 10
  echo "###### 内存占用率前十"
  #ps aux|head -1;ps aux|grep -v PID|sort -rn -k +4|head -n 10

  echo -e "\n"
}

# 
function log()  {
  echo "###### /var/log/boot.log"
  tail -n 200  /var/log/boot.log
  echo "###### /var/log/cron(需要root)"
  tail -n 200 /var/log/cron
  echo "###### /var/log/dmesg"
  tail -n 200  /var/log/dmesg
  echo "###### /var/log/secure(需要root)"
  tail -n 200 /var/log/secure
  echo "###### /var/log/wtmp"
  who -a /var/log/wtmp |tail -n 200
  echo "###### /var/log/messages(需要root)"
  tail -n 200 /var/log/messages

  echo -e "\n"
}

# 
function infoscale()  {
  echo "###### 状态(需要root)"
  hastatus -sum
  echo "###### 查看vx磁盘信息"
  vxdisk list
  echo "###### 查看IO fencing信息"
  vxfenadm -d
  echo "###### 查看权重"
  vxfenconfig -a
  echo "###### 日志"
  halog -info

  echo -e "\n"
}
###########################################
# main
function main() {
  server
  network
  cpu
  mem
  process
  storage
  performance
  log
  infoscale
}

main > /tmp/pg_check_os$DATE 2>&1