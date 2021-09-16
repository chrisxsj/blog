[highgo@rsbdb ~]$ pg_controldata
pg_control 版本:                      1100
Catalog 版本:                         201809051
数据库系统标识符:                     6766416339649351617
数据库簇状态:                         在运行中
pg_control 最后修改:                  2019年12月10日 星期二 14时24分37秒
最新检查点位置:                       1/83834C10
最新检查点的 REDO 位置:               1/837FF598
最新检查点的重做日志文件: 000000010000000100000083
最新检查点的 TimeLineID:              1
最新检查点的PrevTimeLineID: 1
最新检查点的full_page_writes: 开启
最新检查点的NextXID:          0:3636
最新检查点的 NextOID:                 24583
最新检查点的NextMultiXactId: 2
最新检查点的NextMultiOffsetD: 3
最新检查点的oldestXID:            565
最新检查点的oldestXID所在的数据库：1
最新检查点的oldestActiveXID:  3636
最新检查点的oldestMultiXid:  1
最新检查点的oldestMulti所在的数据库：1
最新检查点的oldestCommitTsXid:0
最新检查点的newestCommitTsXid:0
最新检查点的时间:                     2019年12月10日 星期二 14时20分07秒
不带日志的关系: 0/1使用虚假的LSN计数器
最小恢复结束位置: 0/0
最小恢复结束位置时间表: 0
开始进行备份的点位置:                       0/0
备份的最终位置:                  0/0
需要终止备份的记录:        否
wal_level设置：                    logical
wal_log_hints设置：        关闭
max_connections设置：   300
max_worker_processes设置：   8
max_prepared_xacts设置：   0
max_locks_per_xact设置：   64
track_commit_timestamp设置:        关闭
最大数据校准:     8
数据库块大小:                         8192
大关系的每段块数:                     131072
WAL的块大小:    8192
每一个 WAL 段字节数:                  16777216
标识符的最大长度:                     64
在索引中可允许使用最大的列数:    32
TOAST区块的最大长度:                1996
大对象区块的大小:         2048
日期/时间 类型存储:                   64位整数
正在传递Flloat4类型的参数:           由值
正在传递Flloat8类型的参数:                   由值
数据页校验和版本:  0
Mock authentication nonce:            a80d4b06b64302851f9cb78ecaad306280ea3e31372fb55a048cc395619af255
[highgo@rsbdb ~]$
 
 
 
highgo=# SELECT to_timestamp(((6763533731320344722>>32) &(2^32 -1)::bigint));
      to_timestamp     
------------------------
 2019-11-26 16:45:12+08
(1 行记录)
 
highgo=#