http://aix.chinaunix.net/doc/2008/04/13/1108472.shtml
关于aix上的filesystemcache，有如下的书籍讨论过：
白鳝的 Oracle优化日记：一个金牌DBA的故事 .pdf


注意右上角的显示：
FileSystemCache（numperm ）  66.8%
Process                     28.3%
System                      4.8%
Free                        0.2%  
以上三者的合计约等于100%，也就是说，此处显示全部物理内存的占用情况。

特别注意：
FileSystemCache（numperm ） 实际占用了 66.8%的物理内存。
但是， FileSystemCache最大能占用多少比例的物理内存呢？答案是： 90%，来自于：

FileSystemCache对应的操作系统参数，可以用操作系统命令 vmo  -a  -F（针对aix6.1 ）进行查看，主要是这几个参数：
maxclient%=20
maxperm%=20
maxpin%=80
minperm%=5
strict_maxperm=0
strict_maxclient=1
以上参数值来自工程实践。
值得注意的是，在 oracle的所有官方文档中，maxclient%和 maxperm%都要求是保持默认值（即： 90%），从工程实践来说，保持默认值是存在很大问题的

修改此参数的风险评估：
按照此前在生产机上 nmon敲m 后的显示结果：目前 FileSystemCache占用了16.6% 的物理内存，不到 20%,而20% 是对应maxclient%=20。所以，使修改了以上参数，对目前的 rman备份（备份文件系统上）、 expdp等涉及到文件系统的操作，不产生影响（不会有备份速度变慢等之类的现象）。
说白了，设置以上参数，对生产机来说，就是为了设置一个 FileSystemCache的最大值20% ，防止FileSystemCache使用过多的内存。
但是对于FileSystemCache （numperm） 使用率达到66.8% 的机器（上面的例子）来说，设置以上参数，除了 “设置一个FileSystemCache 的最值 20%，防止FileSystemCache 使用过多的内存 ”之外，还有一个作用是：立即回收 FileSystemCache所占用的多于20%部分的内存，即：回收了66.8%-20%=46.8%的内存大小。


在缺省情况下，maxclient 限制是严格的限制。这意味着，AIX 内核不允许非计算性的客户端文件缓存超出 maxclient 限制的范围（也就是说，AIX 内核不允许 numclient 超出 maxclient ）。当 numclient 达到 maxclient 限制时，AIX 内核将采用特殊的、仅客户端的模式开始分页替换。在这种仅客户端的模式中，AIX 分页替换守护进程将严格地选择客户端分页进行操作。
在缺省情况下，maxperm 是一个"非严格的"限制，这意味着在某些情况下可以超出这个限制。将 maxperm 设定为非严格的限制，这允许在具有可用空闲内存的时候，可以在内存中缓存更多的非计算性文件。通过将 strict_maxperm 可调参数设置为 1，就可以使 maxperm 限制成为"严格"的限制。当 maxperm 是严格限制的时候，即使有可供使用的空闲内存，内核也不允许非计算性分页的数目超出 maxperm 的限制。因此，将 maxperm 作为严格限制的缺点是，非计算性分页的数目不能超出 maxperm 的限制，并且在系统中具有空闲内存的时候，也不能使用更多的内存。
在大多数的客户环境中，最理想的方式是始终让内核只选择非计算性的分页进行操作，因为与对非计算性的分页（即数据文件缓存）进行分页相比，对计算性的分页（例如，进程的堆栈、数据等等）进行分页通常会对进程产生更大的性能开销。因此，可以将 lru_file_repage 可调参数设置为 0。在这种情况下，当 numperm 在 minperm 和 maxperm 之间的时候，AIX 内核始终选择非计算性的分页进行操作。
http://www.ibm.com/developerworks/cn/aix/library/au-vmm/