# vacuum-autovacuum

**作者**

Chrisx

**日期**

2021-04-27

**内容**

autovacuum

---

[TOC]

# autovacuum

什么情况下应该关注vacuum？
表中大量的delete，update，rollback insert。需要vacuum
如何优化调整？
autovacuum有7个默认值调整
不优化会发生什么？
table bloat
何时做优化？
本文介绍
优化是否生效？
手动vacuum后，table bloat不会再现

## 示例

1. 小表大量变动
对一个小表进行上千行的添加删除改动。然后用这个表join一个大表。查看结果集。

effect，查询变慢，如从10ms增加到5s，重启应用后自己解决
caused，autoanalyze没有更新统计信息。重启应用后，给了autovacuum和autoanalyze时间。

2. 大表大量变动
大表包括千万行，每小时添加删除百万行。

effect，查询变慢，查看autovacuum似乎一天24h在此表上工作。如果停止app几天或者dump or restore数据库会自动解决。
caused，没有足够的时间去完成autovacuum。或者长事务阻止。

3. 大表表索引大量变动
大表包括千万行，在一个事务中对索引值的列，进行每小时添加删除百万行。

effect，查询变慢，如果停止app几天或者dump or restore数据库会自动解决
caused，索引膨胀，由于删除的记录需要与新记录同时出现在索引中。 这意味着所有索引页都需要拆分，导致索引的大小（或更大）加倍。autovacuum只会删除100%空的page，因此不会回收索引空间。

4. 删除数据库变慢
删除一个数据库，需要5min的时间

effect，删除数据库可能需要5min
caused，autovacuum配置具有侵略性，服务器有高磁盘I/O与很多等待写。
Solution，在数据库响应和表膨胀间做choice，balance（性能或空间）

### autovacuum log

• Pages Removed / Removed Size – The AutoVacuum was able to reduce the table size.
• Tuples Removed – The AutoVaccum was able to remove records.
• Tupled Dead – The AutoVacuum was not able to remove these records due to they were created after the 
Oldest XMIN aka Oldest Transaction ID.

• ((Buffer Hits * vacuum_cost_page_hit) + (Buffer Misses * vacuum_cost_page_miss) + (Buffer Dirtied * vacuum_cost_page_dirty)) = Total Cost
• (((Buffer Hits * vacuum_cost_page_hit) + (Buffer Misses * vacuum_cost_page_miss) + (Buffer Dirtied * vacuum_cost_page_dirty)) / autovacuum/ 
vacuum_cost_limit) = Number of Delay Cycles
• (((Buffer Hits * vacuum_cost_page_hit) + (Buffer Misses * vacuum_cost_page_miss) + (Buffer Dirtied * vacuum_cost_page_dirty)) / 
autovacuum/vacuum_cost_limit) * autovacuum/vacuum_cost_delay = Total Delay’s for Disk IO to Catch up.

You will notice that once the blocking transactions completed that the table went from 228,199,485 records to 36,323,774 records but did not decrease in size.
• AutoVacuum: • Removes empty pages at the end of the table.
• Mark’s old records as reusable space.
• DOES NOT condense pages
• DOES NOT remove empty pages in the middle of the table

This means that once your table is bloated like this, there are only several solutions.
• Vacuum Full
• Cluster
• Truncate and re-insert the data – Truncate cleans up the pages immediately.
This type of bloat will cause sequential table scans to run slowly, because they have to read every page, even the empty ones.

To be able to run this query you need to load my toolset from https://github.com/LloydAlbin/SCHARP-PGDBA-Debugging-Tools which uses the pageinspect extension.
