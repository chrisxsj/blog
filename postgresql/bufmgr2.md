# bufmgr2

**作者**

chrisx

**日期**

2021-04-28

**内容**

PostgreSQL shared_buffers

参考[对比探讨——PostgreSQL和InnoDB的BufferPool](http://liuyangming.tech/10-2019/INNODB-vs-PgSQL-buffer.html)

----

[toc]

## 介绍

PostgreSQL推荐设置是25%~40%的内存；MySQL推荐设置是80%；那么是什么造成这两个的不同呢？

在PostgreSQL的文档中，关于这个问题有如下的描述：

    “PostgreSQL also relies on the operating system cache”
    “Larger settings for shared_buffers usually require a corresponding increase in max_wal_size, in order to spread out the process of writing large quantities of new or changed data over a longer period of time. “

可以这么理解：

    Kernel cache（page cache）可以看做是多进程架构的应用系统的一种数据共享的方式
    由于PostgreSQL对shared_buffers采用的是buffer IO，那么更大的shared_buffer需要在checkpoint时writeback更多脏页，以及需要更多对应这也脏页的日志空间。

## 文件读写API

在Linux下编程，我们可以有很多种方式操作文件，下面对各个接口进行了梳理：

    System call

Operation	Function(s)
Open	open(), creat()
Write	write(), aio_write(), pwrite(), pwritev()
Sync	fsync(), sync(),fdatasync()
Close	close()

这部分是VFS的system call，会陷入内核态；其中write：只保证数据从应用地址空间拷贝到内核地址空间，即page cache，只有fsync才保证将数据和元数据都实实在在地落盘了（fdatasync只同步数据部分，这里涉及到file integrity和data integrity，可以参考Linux的手册）。

:warning: 注意

    当open的时候如果加上了O_SYNC参数，那么write调用就等价于write+fsync；

    当open加上O_DIRECT参数时，write的时候只会绕过kernel buffer，不会sync，但是需要要求写的时候要对齐写，比如对齐512或者4k；

## PostgreSQL的double buffer

在了解PostgreSQL的double buffer问题之前，先了解一下我们常用的服务器操作系统——Linux的文件读写缓存。

IO就是内存和外存之间的数据传输。

在内存中，就是用户态和内核态；PostgreSQL位于用户态，在进行读写的时候，通过system call，将数据拷贝到内核态；另外，也有可能是通过Library间接进行system call。

在内核态中，这里只考虑两层结构：VFS和BLOCKIO层。当我们调用write将数据写出时，首先会写入到page cache中（前提是没有打开O_DIRECT，后面会详细讨论）。最后，操作系统会周期性的清理Page cache就是将Kernel Buffer中的数据写到磁盘中，或者我们对文件调用fsync，那么才最终落盘。

通过DMA的机制写盘，不占用系统CPU资源。

## PostgreSQL的文件读写

讨论数据的文件读写，主要针对两类数据：数据页和日志记录。作为对比，这里罗列了一下MySQL的相关机制；从图中可以看出，PostgreSQL的wal根据配置的不同，可能是direct io也可能是bufferio；但是shared_buffers中只有一种方式，就是buffer io。
而在mysql中，数据页和redo日志都是可以通过不同的配置，选择direct io和buffer io；但是一般配置为使用direct io；因为direct io相对buffer io来说高效些。

那么为什么PostgreSQL采用buffer io呢？这里是我自己的观点。

软件系统和艺术作品类似，诞生都是有一定的历史原因的。PostgreSQL是诞生在实验室中，主要为了研究数据库内核原理，那么使用buffer io能够减少IO栈的代码开发，进而能够减少额外的debug。这样，研究人员能够更加专注在数据库内核原理的研究中，因此PostgreSQL才会有相当丰富的SQL语法、丰富的执行算法、以及优秀的基于代价的执行优化器等等功能。可以称其为一个全栈的数据库，基于其优秀的扩展性，几乎可以解决中小型公司的大部分业务场景。

**在流复制中，通过buffer io，那么wal sender可以从page cache读取wal，减少了物理读的次数。**

## double buffer

由于PostgreSQL采用的是buffer io，那么我们可以换一个角度看PostgreSQL的内存。可以看做是整个内存空间的一个两级缓存，但是PostgreSQL对第一级有完全的控制权。
由于内存中的两级缓存存在，那么shared_buffers中的数据页会在内存中存在两份，因此，当我们将shared_buffer配置为推荐配置的最大值40%时，其实我们已经用了80%的内存空间。这就可以理解为什么PostgreSQL推荐最大是40%。

为什么PostgreSQL和MySQL设置的不同呢？

数据库要保证数据的写入，不管是写入的时间还是写入的位置，完全在自己的掌控之中。BufferPool在DB中，可以作为读cache和写buffer，减少物理读的次数，也减少物理写的次数。但是，最终BufferPool中的数据还是要落盘的，那么落盘时的操作就是调用上述的API。

因此，造成配置的差异原因可能就是两者使用API的方式不同，其区别在于是否要留一大部分Kernel Buffer；在MySQL/InnoDB中，我们可以通过参数innodb_flush_method，决定data和log是否使用O_DIRECT（绕过Kernel Buffer）和O_SYNC；而在PostgreSQL中，我们只有通过wal_sync_method和fsync选择是否O_SYNC，没有对O_DIRECT进行选择的入口。

## 清空buffer

在sql优化时,如果shared_buffers中包含有需要的数据,数据会从shared_buffers中读取,导致测试结果不是很准确.一般来说,优化sql应该做最坏的打算(也就是应该从磁盘读取数据)才能保证在优化后实际使用过程中的性能,所以应该在优化sql前把shared_buffers清空,以保证执行计划的准确性.

每次都重启操作系统工作效率比较低,可以采用以下方式清空shared_buffers

1. 停止数据库
2. 切换到root用户,如果直接是root用户省略此步
3. 清空高速缓存前尝试将数据刷新至磁盘

```sh
sync
```

4. 释放linux内存

```sh
echo 3 > /proc/sys/vm/drop_caches
```

5. 退出root用户,如果直接是root用户省略此步
6. 启动数据库

以上步骤操作完成后,shared_buffers保证被清空了, 此时就能保证执行计划的准确性了.