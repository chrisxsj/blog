#! /bin/bash
#######################################
# author，Chrisx
# date，2022-01-17
# Copyright 2022 All rights reserved"
# description,显示目录下子目录占用空间大小
#######################################
dir=/opt
cd $dir
for k in $(ls $dir)
do
   [ -d $k] && du -sh $k
done