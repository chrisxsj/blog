#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
######################################
# introduction,通过变量给字体加颜色,这里定义一个函数，后面如果想改变字体颜色直接调用即可
# 传2个参数给函数，第一个参数指定内容，第二个参数指定颜色
# COLOR '我是红色' red
######################################
 
function COLOR () {
RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
YELLOW_COLOR='\E[1;33m'
BLUE_COLOR='\E[1;34m'
PINK_COLOR='\E[1;35m'
RES='\E[0m'

#这里判断传入的参数是否不等于2个，如果不等于2个就提示并退出
 
if [ $# -ne 2 ];then
    echo "Please provide two parameters,the first to specify the content,the second to specify the color {red|yellow|blue|green|pink}" 
    return
fi

case "$2" in 
   red|RED) 
        echo -e "${RED_COLOR}$1${RES}" 
        ;; 
   yellow|YELLOW) 
        echo -e "${YELLOW_COLOR}$1${RES}" 
        ;; 
   green|GREEN) 
        echo -e "${GREEN_COLOR}$1${RES}"
        ;;
   blue|BLUE)
        echo -e "${BLUE_COLOR}$1${RES}"
        ;;
   pink|PINK)
        echo -e "${PINK_COLOR}$1${RES}"
        ;;
         *) 
        echo -e "Please enter the specified color：{red|yellow|blue|green|pink}"
esac
}

#COLOR