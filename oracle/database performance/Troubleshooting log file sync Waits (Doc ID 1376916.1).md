星期五        [Update from Customer]
您好，
在1节点出现大量log file sync时，往往2节点会出现很多gc buffer busy等待事件，请问这两个等待事件有联系吗？
 
Oracle 技术支持    - 星期五        [ODM Action Plan]
亲爱的客户，您好：
这两个是有关系的，一般gc buffer busy等待事件是由于远程节点的Log file sync 引起。
 
Oracle 技术支持    - 星期五        [ODM Action Plan]
亲爱的客户，您好：
关于您的问题，简单回答如下：
在RAC中为了保证Instance Recovery实例恢复机制，而要求每一个current block在本地节点local instance被修改后， 必须要将该current block相关的redo 写入到logfile 后，才能由LMS进程传输给其他节点使用。
如果本节点的redo log写入很慢，那么其他节点的进程就会显示gc buffer busy等待。
如果我们没有解释明白，请您更新SR我们再继续讨论。
 
谢谢您
王恩普（Peter Wang）
全球软件支持-中国数据库组
