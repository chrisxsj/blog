# cpu

**作者**

Chrisx

**日期**

2021-05-12

**内容**

cpu介绍

---

[toc]

## cpu介绍

形象的理解

* socket就是主板上插cpu的槽的数目，也即管理员说的”路“
* core就是我们平时说的”核“，即双核，4核等
* thread就是每个core的硬件线程数，即超线程

举个例子，服务器是：2路4核超线程（一般默认为2个线程），那么，通过cat /proc/cpuinfo看到的是2*4*2=16个processor，很多人也习惯成为16核了！

## cpu信息查看

/proc/cpuinfo会产生cpu信息，输出项的含义如下：

| 名称             | 说明                                                              |
| ---------------- | ----------------------------------------------------------------- |
| processor        | 系统中逻辑处理核的编号。                                          |
| vendor_id        | CPU制造商                                                         |
| model name       | CPU属于的名字及其编号、标称主频                                   |
| cpu MHz          | CPU的实际使用主频                                                 |
| cache size       | CPU二级缓存大小                                                   |
| physical id      | 物理cpu标号                                                       |
| siblings         | 单个物理CPU拥有的逻辑核个数                                      |
| core id          | 物理核标号                                                        |
| cpu cores        | 物理核的数量                                                      |
| fpu              | 是否具有浮点运算单元（Floating Point Unit）                       |
| fpu_exception    | 是否支持浮点计算异常                                              |
| wp               | 表明当前CPU是否在内核态支持对用户空间的写保护（Write Protection） |
| flags            | 当前CPU支持的功能                                                 |
| power management | 对能源管理的支持                                                  |

基于以上信息可以知道CPU、CPU的核数、CPU是否启用超线程等信息。

```sh
echo "物理CPU的个数：$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)"
echo "单个CPU的物理核数：$(cat /proc/cpuinfo | grep "cpu cores" | uniq )"
echo "单个cpu的逻辑核数：$(cat /proc/cpuinfo | grep "processor" | wc -l)"
echo "CPU是否启用超线程：$(cat /proc/cpuinfo | grep -e "cpu cores"  -e "siblings" | sort | uniq)"   #如果cpu cores数量和siblings数量一致，则没有启用超线程，否则超线程被启用。

# 总核数 = 物理CPU个数 X 每颗物理CPU的核数 
# 总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数
```

## cpu示例

飞腾200（ft2000）

```bash
#cat /proc/cpuinfo:
processor	: 0
BogoMIPS	: 100.00
Features	: fp asimd evtstrm crc32 cpuid
CPU implementer	: 0x70
CPU architecture: 8
CPU variant	: 0x1
CPU part	: 0x662
CPU revision	: 2
```

<!--
除了socket，core，thread三个概念，感觉经常对一些概念一知半解，比如说SMP（Symmetric Multi-Processing），CMP（Chip multiprocessors），SMT（Simultaneous multithreading），大家经常说，但是真正能理解的人估计不多。
（1）SMT，同时多线程Simultaneous multithreading，简称SMT。
SMT可通过复制处理器上的结构状态，让同一个处理器上的多个线程同步执行并共享处理器的执行资源，可最大限度地实现宽发射、乱序的超标量处理，提高处理 器运算部件的利用率，缓和由于数据相关或Cache未命中带来的访问内存延时。当没有多个线程可用时，SMT处理器几乎和传统的宽发射超标量处理器一样。 SMT最具吸引力的是只需小规模改变处理器核心的设计，几乎不用增加额外的成本就可以显著地提升效能。多线程技术则可以为高速的运算核心准备更多的待处理 数据，减少运算核心的闲置时间。这对于桌面低端系统来说无疑十分具有吸引力。Intel从3.06GHz Pentium 4开始，所有处理器都将支持SMT技术。 Intel的hyper-threading其实就是 two-thread SMT.
（2）CMP, 片上多处理器（Chip multiprocessors，简称CMP）
CMP是由美国斯坦福大学提出的，其思想是将大规模并行处理器中的SMP（对称多处理器）集成到同一芯片内，各个处理器并行执行不同的进程。与CMP比 较， SMT处理器结构的灵活性比较突出。但是，当半导体工艺进入0.18微米以后，线延时已经超过了门延迟，要求微处理器的设计通过划分许多规模更小、局部性 更好的基本单元结构来进行。相比之下，由于CMP结构已经被划分成多个处理器核来设计，每个核都比较简单，有利于优化设计，因此更有发展前途。目 前，IBM 的Power 4芯片和Sun的 MAJC5200芯片都采用了CMP结构。多核处理器可以在处理器内部共享缓存，提高缓存利用率，同时简化多处理器系统设计的复杂度。
（3）SMP，对称多处理器（Symmetric Multi-Processors，简称SMP）
是指在一个计算机上汇集了一组处理器(多CPU),各CPU之间共享内存子系统以及总线结构。在这种技术的支持下，一个服务器系统可以同时运行多个处理 器，并共享内存和其他的主机资源。像双至强，也就是我们所说的二路，这是在对称处理器系统中最常见的一种（至强MP可以支持到四路，AMD Opteron可以支持1-8路）。也有少数是16路的。但是一般来讲，SMP结构的机器可扩展性较差，很难做到100个以上多处理器，常规的一般是8个 到16个，不过这对于多数的用户来说已经够用了。在高性能服务器和工作站级主板架构中最为常见，像UNIX服务器可支持最多256个CPU的系统，其实 qemu从代码设计上也是最大支持256个virtual cpu。
-->

