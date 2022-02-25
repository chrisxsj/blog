#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
##############################################
# Declare environment variables
source ~/.bash_profile
#################################################
# variable
filesize=50M                      #设置文件大小，单位k,M,G
filepath=/opt                 #设置检查路径
###############################################
# function
# Find files smaller or larger than filesize

function find_file_size() {
find $filepath -size -$filesize -exec ls -lrth {} \;
#+$filesize 大于，-$filesize 小于
}

#find_file_size
