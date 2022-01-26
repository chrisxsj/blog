# shell_task

**作者**

Chrisx

**日期**

2021-06-21

**内容**

shell前后台作业任务

----

[toc]

## 介绍

* 前台作业就是前台进程，用户可参与交互和控制
* 后台祖业就是后台进程，自动运行无法交互

## 作业命令

* command & 直接让作业后台运行
* ctrl+z 让前台作业切换到后台运行
* jobs 查看后台作业状态，带有作业id n（jobs -l 带有pid）
* fg %n 让后台作业n切换到前台
* bg %n 指定作业n后台运行
* kill %n 杀死作业n
  * n为jobs看到的作业编号
  * +标示最近一个job
  * —表示倒数第二个被执行的job
  * kill -9

:warning: jobs仅针对当前终端可见

## 作业脱机管理

* 作业切换到后台可避免误操作导致中断的情况。
* nohup可使得脱机后注销后，job依旧运行。nohup忽略所有挂断信号（sighub），指定&位于后台运行，不指定&位于前台运行。
  * nohup会缺省将日志输出到nohup.out日志文件
  
```sh
nohup ./x.sh |tee /tmp/out.log 2>&1 &

```

## screen

screen可以连接多个本地和远程命令行会话，并在其间自由切换。screen可以看做窗口管理器的命令行版本。

* 会话恢复
只要screen没有终止，其内部运行的会话都可也恢复。这一点对于远程用户特别有用。网络中断后用户重新登陆依然可以恢复回话。（screen -r）
* 多窗口
在screen环境下，所有会话独立运行，可在不同窗口间切换。

```sh
sudo apt install screen

screen --help

```

* -S 新建一个会话空间
* -ls 列出所有会话空间
* -r 重新连接（reattach）到分离的会话
* -d 分离（detach）当前会话

```sh
sudo screen -dmS s  #创建一个空会话
sudo screen -ls #查看已有的会话
ps -ef |grep 4839 
sudo screen -r s -X quit #指定会话退出

```
