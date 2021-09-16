# shell ansi

Shell 使用 ANSI 转义码 (ANSI escape codes) 进行颜色输出。

## 格式

```shell
echo -e "\e[4;31m 下划线红字 \e[0m"
```

1. 前部分：\e[4;31m
* `-e`,启用反斜杠转义的解释
* `\e[`,ANSI控制码开始的标志都为ESC[，ESC对应ASCII码表的033(八进制)，\e或\033来输入ESC，\e[即为ESC[。
* `4`,字体属性,含下划线的文本
* `;`,多个属性用冒号隔开
* `31`,前景色为红色
* `m`,终止转义序列

2. 中间部分：下划线红字
* 以上转义后,会使得其后面的文本输出都被转义，要使其恢复常规文本状态，再次进行转义。

3. 后部分：\e[0m
* `\e[`,ANSI控制码开始的标志都为ESC[
* `0`，字体属性，常规文本
* `m`,终止转义序列

## 创建字体颜色函数

```shell

#!/bin/bash
# ~/bin/color.sh
#通过变量给字体加颜色
#这里定义一个函数，后面如果想改变字体颜色直接调用即可
#传2个参数给函数，第一个参数指定内容，第二个参数指定颜色
 
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

```

加载函数
source color.sh

调用函数
COLOR "error" red
COLOR "warning" yellow
COLOR "this is chris" green

## 参考

转义序列颜色输出表

| 颜色             | 前景色 | 背景色 |
| ---------------- | ------ | ------ |
| 黑色 (Black)     | 30     | 40     |
| 红色 (Red)       | 31     | 41     |
| 绿色 (Green)     | 32     | 42     |
| ××× (Yellow)     | 33     | 43     |
| 蓝色 (Blue)      | 34     | 44     |
| 紫红色 (Magenta) | 35     | 45     |
| 青色 (Cyan)      | 36     | 46     |
| 白色 (White)     | 37     | 47     |

字体属性

| ANSI 码 | 含义     |
| ------- | -------- |
| 0       | 常规文本 |
| 1       | 粗体     |
| 4       | 下划线   |
| 5       | 闪烁     |
| 7       | 反色     |
