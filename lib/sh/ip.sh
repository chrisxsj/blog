#! /bin/bash
#######################################
# author，Chrisx
# date，2022-02-21
# Copyright 2022 All rights reserved"
# description,ping test
#######################################

function fip {
cd /etc/sysconfig/network-scripts
cp ifcfg-eth0 ifcfg-eth1

sed -i 's/eth0/eth1' ifcfg-eth1
sed -i '/UUID/d' ifcfg-eth1
sed -i '/IPADDR/s/192.168.0.11/192.168.0.12/' ifcfg-eth1

systemctl restart NetworkManager
}

#fip