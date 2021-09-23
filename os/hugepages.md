# hugepages

**作者**

chrisx

**日期**

2021-05-12

**内容**

PostgreSQL大页内存配置

ref [Linux Huge Pages](https://www.postgresql.org/docs/13/kernel-resources.html)

----

[toc]

## pg使用大页介绍

Linux, by default, uses 4K memory pages, BSD has Super Pages, whereas Windows has Large Pages. A page is a chunk of RAM that is allocated to a process. A process may own more than one page depending on its memory requirements. The more memory a process needs the more pages that are allocated to it. The OS maintains a table of page allocation to processes. The smaller the page size, the bigger the table, the more time required to look up a page in that page table. Therefore, huge pages make it possible to use a large amount of memory with reduced overheads; fewer page lookups, fewer page faults, faster read/write operations through larger buffers. This results in improved performance.
PostgreSQL has support for bigger pages on Linux only. By default, Linux uses 4K of memory pages, so in cases where there are too many memory operations, there is a need to set bigger pages. Performance gains have been observed by using huge pages with sizes 2 MB and up to 1 GB. The size of Huge Page can be set boot time. You can easily check the huge page settings and utilization on your Linux box using cat /proc/meminfo | grep -i huge command.

cat /proc/meminfo | grep -i huge

Script to quantify Huge Pages
This is a simple script which returns the number of Huge Pages required. Execute the script on your Linux box while your PostgreSQL is running. Ensure that $PGDATA environment variable is set to PostgreSQL’s data directory.

查看操作系统页面大小

```sh
getconf -a |grep PAGE_SIZE
```

:warning: 通常，内存超过64G，建议使用大页内存

<!--
以下是关于HugePage的说明和解释：

When a process uses some memory, the CPU is marking the RAM as used by that process. For efficiency, the CPU allocate RAM by chunks of 4K bytes (it's the default value on many platforms). Those chunks are named pages. Those pages can be swapped to disk, etc.
Since the process address space are virtual, the CPU and the operating system have to remember which page belong to which process, and where it is stored. Obviously, the more pages you have, the more time it takes to find where the memory is mapped. When a process uses 1GB of memory, that's 262144 entries to look up (1GB / 4K). If one Page Table Entry consume 8bytes, that's 2MB (262144 * 8) to look-up.
Most current CPU architectures support bigger pages (so the CPU/OS have less entries to look-up), those are named Huge pages (on Linux), Super Pages (on BSD) or Large Pages (on Windows), but it all the same thing.

From <https://www.eygle.com/archives/2011/12/hugepageshugetl.html>
-->

## pg配置大页

1. 计算需要的大页数量

ref [gethugepage.sh](../bin/gethugepage.sh)

2. 设置大页

```bash
sysctl -w vm.nr_hugepages=67537

```

3. Pg开启大页功能

默认huge_pages = try，建议使用try，必要时使用on

<!--Now set the parameter huge_pages “on” in $PGDATA/postgresql.conf and restart the server.-->

4. 查看大页使用

```bash
cat /proc/meminfo | grep -i huge

AnonHugePages: 6144 kB
HugePages_Total: 67537 ## 设置的HUGE PAGE
HugePages_Free: 66117 ## 这个是当前剩余的，但是实际上真正可用的并没有这么多，因为被PG锁定了65708个大页
HugePages_Rsvd: 65708 ## 启动PG时申请的HUGE PAGE
HugePages_Surp: 0
Hugepagesize: 2048 kB ## 当前大页2M

执行一些查询，可以看到Free会变小。被PG使用掉了。
cat /proc/meminfo |grep -i huge
AnonHugePages: 6144 kB
HugePages_Total: 67537
HugePages_Free: 57482
HugePages_Rsvd: 57073
HugePages_Surp: 0
Hugepagesize: 2048 kB
```

Now you can see that a very few of the huge pages are used. Let’s now try to add some data into the database.
Let’s see if we are now using more huge pages than before.
