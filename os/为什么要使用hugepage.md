为什么要使用hugepage？？！！
要深入了解linux内存运行机制，需要知道下面提到的几个方面：
内存页管理
linux操作系统对内存实行分页管理，把物理内存分为了固定统一大小的块，称为page，内存页面的默认大小被设置为 4096 字节（4KB），并且每个页都有一个编号 [page frame number]。这样一个512M大小的内存将包括128K个页。这种方式称为paging，使得操作系统对内存的管理更方便。
MMU
最终的内存页面并不直接和程序打交道，它通过MMU和程序打交道。由于有了MMU这个中间层，它负责将一个程序的虚拟内存地址映射到实际的物理地址，怎么做到的呢？
当然是通过一张表，即页表来查询的。page table的作用就是将进程操作的地址[虚拟地址]转换成物理地址，并记录记录页的状态、位置等信息。
由于采用了MMU这个中间层，物理内存不再和程序直接打交道，则物理内存的形式就变得不再重要，它可以是内存条，也可以是磁盘，甚至可以是设备，只要MMU能给出合理的解释，
并且按照应用程序访问内存的规则来访问这些实体并能给出正确的结果即可。这就使得文件映射，设备映射成了可能。如下图所示：

 

TLB
从内存管理的角度，所有的物理内存都被划分为一个个的frame，而虚拟内存则被划分为一个个的page。内存管理单元的一个任务就是维护这两者之间的一个映射关系。
这个映射关系通常是保存在一个“页表”中的，但是通常，该表的查询比较耗时间，因此为了提高查询过程，系统中引入了一个叫做（TLB）的cache。
引入TLB后，物理内存页和虚拟内存页的映射首先通过查询TLB来完成，如果TLB中没有相关的对应关系，我们称此时发生了一个 TLB miss，此时内存管理单元将通过进一步查询页表来完成映射请求，因此带来了比较打的开销。
一般的X86机器上，虚拟内存页的大小为4K，为了提高TLB的命中率，大页表的概念被提出来了。
通过使用大页表，TLB中的每一个entry覆盖了更多的内存范围，从而降低了TLB miss的发生。
 
内存交换
    1. Linux系统会不时的进行页面交换操作，以保持尽可能多的空闲物理内存，即使并没有什么事情需要内存，Linux也会交换出暂时不用的内存页面。这可以避免等待交换所需的时间。
    2. Linux 进行页面交换是有条件的，不是所有页面在不用时都交换到虚拟内存，linux内核根据”最近最经常使用“算法，仅仅将一些不经常使用的页面文件交换到虚拟 内存，有时我们会看到这么一个现象：linux物理内存还有很多，但是交换空间也使用了很多。其实，这并不奇怪，例如，一个占用很大内存的进程运行时，需 要耗费很多内存资源，此时就会有一些不常用页面文件被交换到虚拟内存中，但后来这个占用很多内存资源的进程结束并释放了很多内存时，刚才被交换出去的页面 文件并不会自动的交换进物理内存，除非有这个必要，那么此刻系统物理内存就会空闲很多，同时交换空间也在被使用，就出现了刚才所说的现象了。关于这点，不 用担心什么，只要知道是怎么一回事就可以了。
    3. 交换空间的页面在使用时会首先被交换到物理内存，如果此时没有足够的物理内存来容纳这些页 面，它们又会被马上交换出去，如此以来，虚拟内存中可能没有足够空间来存储这些交换页面，最终会导致linux出现假死机、服务异常等问题，linux虽 然可以在一段时间内自行恢复，但是恢复后的系统已经基本不可用了。
 
以下可以看到page size 和hugepage size
[oracle@db ~]$ getconf PAGESIZE
4096
[oracle@db ~]$ cat /proc/meminfo |grep Huge
AnonHugePages:         0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
假设内存大小为250G=268435456000
使用page size时有多少个page：268435456000/4096=65536000
使用hugepage size时有多少个page：268435456000/(2048*1024)=128000
这里： 每个page，都有一个page table（大概10byte）管理，记录页的状态、位置
管理64491个page需要page table大小：65536000*10/1024/1024=625M
管理125个page需要page table大小：128000 *10/1024/1024=1M
这里：linux中每个进程都分配一个独立的page table
如果有1000个进程，
使用page size时，共占内存 625M*1000=610G
使用hugepage size时共占1M*1000=1G
 
在 Linux 操作系统上运行内存需求量较大的应用程序时，由于其采用的默认页面大小为 4KB，因而将会产生较多 TLB Miss 和缺页中断，从而大大影响应用程序的性能。当操作系统以 2MB 甚至更大作为分页的单位时，将会大大减少 TLB Miss 和缺页中断的数量，显著提高应用程序的性能。这也正是 Linux 内核引入大页面支持的直接原因。好处是很明显的，假设应用程序需要 2MB 的内存，如果操作系统以 4KB 作为分页的单位，则需要 512 个页面，进而在 TLB 中需要 512 个表项，同时也需要 512 个页表项，操作系统需要经历至少 512 次 TLB Miss 和 512 次缺页中断才能将 2MB 应用程序空间全部映射到物理内存；然而，当操作系统采用 2MB 作为分页的基本单位时，只需要一次 TLB Miss 和一次缺页中断，就可以为 2MB 的应用程序空间建立虚实映射，并在运行过程中无需再经历 TLB Miss 和缺页中断（假设未发生 TLB 项替换和 Swap）。
所以通过以上可以看出，
sga会ping在内存里 ，且不会频繁的内存交换，  --memlock
减少内存的损耗，提高内存的使用率    --page减少
减少 TLB Miss 和缺页中断的数量，显著提高应用程序的性能  --page变大
注意：启用了hugepage后，linux上是内存管理是hugepage+page管理方式