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

巨型页面的使用会导致更小的页面表以及花费在内存管理上的 CPU 时间更少，从而提高性能。

当PostgreSQL使用大量连续的内存块时，使用大页面会减少开销， 特别是在使用大shared_buffers时。 要在PostgreSQL中使用此特性，您需要一个包含 CONFIG_HUGETLBFS=y和CONFIG_HUGETLB_PAGE=y的内核。 您还必须调整内核设置vm.nr_hugepages。要估计所需的巨大页面的数量， 请启动PostgreSQL，而不启用巨大页面，并使用 /proc文件系统来检查postmaster的匿名共享内存段大小以及系统的巨大页面大小。
Linux、FreeBSD以及Illumos之类的操作系统也能为普通内存分配自动使用巨型页（也被称为“超级”页或者“大”页面），而不需要来自PostgreSQL的显式请求。在Linux上，这被称为“transparent huge pages”（THP，透明巨型页）。已知这种特性对某些Linux版本上的某些用户会导致PostgreSQL的性能退化，因此当前并不鼓励使用它（与huge_pages的显式使用不同）。

<!--
Linux默认使用大小为4K的内存页。
页面是分配给一个进程的一块内存，一个进程可能拥有多个页面，这取决于它对内存的要求。进程需要的内存越多，分配给它的页面就越多。
操作系统持有一个分配给进程的页面的表。CPU和操作系统必须记住哪个页面属于哪个进程，以及它存储在哪里。显然，页面越多，查找内存映射位置所需的时间就越长。
因此，大页面使得使用大量内存的同时减少开销成为可能。

使用大页面之后，页面查找次数更少，页面错误更少，通过更大的缓冲区读取/写入操作更快，这样就提升了数据库的性能。

-->

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

ref [gethugepage.sh](../lib/sh/gethugepage.sh)

2. 设置大页

```bash
sysctl -w vm.nr_hugepages=67537 #临时设置

echo 'vm.nr_hugepages=67537' >> /etc/sysctl.conf    #永久设置
```

3. Pg开启大页功能

默认huge_pages = try，建议使用try，必要时使用on

```sql
show huge_pages;

```

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
