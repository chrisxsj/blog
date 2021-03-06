# top

**作者**

Chrisx

**日期**

2022-01-24

**内容**

top命令查看资源使用情况

----

[toc]

## top交互命令

* c： 显示完整的命令
* d： 更改刷新频率
* f： 增加或减少要显示的列(选中的会变成大写并加*号)
* F： 选择排序的列
* h： 显示帮助画面
* H： 显示线程
* i： 忽略闲置和僵死进程
* k： 通过给予一个PID和一个signal来终止一个进程。（默认signal为15。在安全模式中此命令被屏蔽）
* l:  显示平均负载以及启动时间（即显示影藏第一行）
* m： 显示内存信息
* M： 根据内存资源使用大小进行排序
* N： 按PID由高到低排列
* o： 改变列显示的顺序
* O： 选择排序的列，与F完全相同
* P： 根据CPU资源使用大小进行排序
* q： 退出top命令
* r： 修改进程的nice值(优先级)。优先级默认为10，正值使优先级降低，反之则提高的优先级
* s： 设置刷新频率（默认单位为秒，如有小数则换算成ms）。默认值是5s，输入0值则系统将不断刷新
* S： 累计模式（把已完成或退出的子进程占用的CPU时间累计到父进程的MITE+ ）
* T： 根据进程使用CPU的累积时间排序
* t： 显示进程和CPU状态信息（即显示影藏CPU行）
* u： 指定用户进程
* W： 将当前设置写入~/.toprc文件，下次启动自动调用toprc文件的设置
* <： 向前翻页
* \>： 向后翻页
* ?： 显示帮助画面
* 1(数字1)： 显示每个CPU的详细情况

主要用得到的是 1、M、P、c

## top批处理

```sh
top -b1 -n 2 -o +%MEM |tee /tmp/mem    #查看进程使用内存情况，以降序排列，执行2s，输出到文件
top -b1 -n 2 -o +%CPU |tee /tmp/cpu    #查看进程使用cpu情况，以降序排列，执行2s，输出到文件

```

* -b 以批处理模式启动top，这对于将输出从top发送到其他程序或文件非常有用。
* -c 命令行显示程序名称
* -1 1(数字1)： 显示每个CPU的详细情况
* -n 指定top在结束前应产生的最大迭代次数或帧数。
* -o 指定将对任务进行排序的字段的名称。你可以提前准备将“+”或“-”添加到字段名，以覆盖排序方向。前导“+”将强制排序从高到低，而“-”将确保从低到高的顺序。

## Mem

内存显示

* total: 内存总数
* used: 已经使用的内存数
* free: 空闲的内存数
* buff/cache: 缓存内存数

* buffer 与cache 的区别
　　A buffer is something that has yet to be “written” to disk. A cache is something that has been “read” from the disk and stored for later use.

* 真正内存使用率
(used-(buffers+cached))/total

* 真正内容空闲率
(free+buffers+cached)/total

* swap用了很多
我们在观察Linux的内存使用情况时，只要没发现用swap的交换空间，就不必担心自己的内存太少。如果常常看到swap用了很多，那么你就要考虑加物理内存了。这也是在Linux服务器上看内存是否够用的标准。

## load average

load average是cpu的load。分别代表最近1分钟、最近5分钟、最近15分钟的负载。这个负载是指这段时间内cpu正在处理以及等待cpu处理进程之和的统计信息。也就是cpu使用队列长度统计信息。

在多处理器系统上，负载相对于可用的处理器内核的数量是相对的。
在一个单核处理器环境，负载1就表示100%利用率
在多核处理器环境，如64核，负载15相对于64核，远远没有达到高负载。

负载是判断服务器压力重要指标。Linux/Unix系统是非常稳健的，虽然内存占用显示90%以上，但其最近5分钟的负载指数较低，说明服务器压力不大。