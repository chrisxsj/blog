#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
######################################
 
function random_password()
{
    cat /dev/urandom | head -100 |tr -dc a-z0-9#@ | head -c 8
    return 0
}
A=`main`
B=`main`
C=`main`
D=`main`
E=`main`
echo "return:$?"
printf "\033[40;37m num    password           \033[0m\n"
printf "%-5s %-10s\n" 1 $A
printf "%-5s %-10s\n" 2 $B
printf "%-5s %-10s\n" 3 $C
printf "%-5s %-10s\n" 4 $D
printf "%-5s %-10s\n" 5 $E
```
