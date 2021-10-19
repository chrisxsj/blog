
# wsl2_network

**作者**

Chrisx

**日期**

2021-05-12

**内容**

wsl2网络设置，设置固定iP

----

[toc]

## wsl2 ip

WSL2 因虚拟技术的差异，与宿主机不在同一网络下，且每次重启时宿主机 IP 均会变化，故只能通过命令获取宿主机 IP

```sh
cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }' 
```

## windows访问wsl2中的docker

windows中可以使用localhost、127.0.0.1直接访问wsl2中的docker服务

## wsl2设置固定ip

根据wsl在github上的issues中我们可以找到有人已经有办法解决了，原理是在启动系统的时候手动重新给win10 的vEthernet (WSL) 和 wsl2下的eth0 添加一个ipv4地址。
那应该怎么做呢？

给wsl 中的ubuntu 设置ipv4 的ip 192.168.86.16，要在windows中访问wsl就用此ip

wsl -d Ubuntu-20.04 -u root ip addr add 192.168.80.11/24 broadcast 192.168.80.255 dev eth0 label eth0:1

给windows 设置ipv4 的ip 192.168.86.88，要在wsl中访问宿主机就用此ip

netsh interface ip add address "vEthernet (WSL)" 192.168.80.11 255.255.255.0

由于每次电脑重启后上面的ip都会失效，所以可以将上面的脚本放在一个.bat文件中，并设置为开机启动执行即可。不行你们试试，效果很好。

写了个bat脚本在windows里面把wsl拉起来，同时用root权限给wsl实例分配了一个固定的IP，然后在windows宿主分配了一个同网段的IP，实现了固定IP访问wsl。 这个脚本我研究了一下，可以顺便把wsl拉起来的时候需要启动的服务，比如ssh，docker等拉起来，这样同时也解决了wsl不支持systemd服务自启动的麻烦，说干就干，上脚本。

wsl2.bat

```bat
@ECHO OFF
setlocal EnableDelayedExpansion
color 3e
title 添加服务配置

::自动以管理员身份运行批处理(bat)文件
PUSHD %~DP0 & cd /d "%~dp0"
%1 %2
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :runas","","runas",1)(window.close)&goto :eof
:runas
  
::填写自己的脚本

::不管三七二十一先停掉可能在跑的wsl实例
::wsl --shutdown ubuntu
::重新拉起来，并且用root的身份，启动ssh服务和docker服务
::wsl -u root service ssh start
::wsl -u root service docker start | findstr "Starting Docker" > nul
if !errorlevel! equ 0 (
    echo docker start success
    :: 看看我要的IP在不在
    wsl -u root ip addr | findstr "192.168.6.11" > nul
    if !errorlevel! equ 0 (
        echo wsl ip has set
    ) else (
        ::不在的话给安排上
        wsl -u root ip addr add 192.168.6.11/24 broadcast 192.168.6.0 dev eth0 label eth0:1
        echo set wsl ip success: 192.168.6.11
    )


    ::windows作为wsl的宿主，在wsl的固定IP的同一网段也给安排另外一个IP
    ipconfig | findstr "192.168.6.9" > nul
    if !errorlevel! equ 0 (
        echo windows ip has set
    ) else (
        netsh interface ip add address "vEthernet (WSL)" 192.168.6.9 255.255.255.0
        echo set windows ip success: 192.168.6.9
    )
)
  
echo 执行完毕,任意键退出
  
pause >nul
exit

```

:warning: 脚本需要用管理员运行

开机启动

将wsl2.bat放到开机启动目录中（shell:startup）

如果不行，就把wsl2.bat给它建个桌面快捷方式，然后，右键选中快捷方式，选属性-》快捷方式-》高级，弹出高级属性窗口里面，选择”用管理员身份运行“，再将快捷方式放到开机启动目录中（shell:startup）
