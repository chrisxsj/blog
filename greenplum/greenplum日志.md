Gp 日志

管理 GPDB 日志文件 l
数据库服务日志文件 l
管理程序的日志文件          
 
数据库服务日志文件 GPDB的日志输出量很大(尤其在较高的调试级别)而且不需要无限期的保存这 些日志。管理员需要定期的滚动日志文件，从而可以保证新的日志文件被使用 而旧的日志文件可以被定期的删除。
 
GPDB在Master和所有的Segment实例上开启了日志文件滚动。每天的日志文件 放在每个Instance数据目录的pg_log目录下并使用约定命名方式： gpdb-YYYY-MM-DD.log 尽管日志是按天滚动的，但它们不会被自动清空或删除。管理员需要通过一些 脚本或程序来定期的清理各实例pg_log目录下的旧日志文件。        
 
  管理程序的日志文件 GP管理程序的日志文件缺省位于~/gpAdminLogs目录下。管理程序日志文件的 约定命名方式为： <script_name>_<date>.log 日志记录的格式为： <timestamp>:<utility>:<host>:<user>:[INFO|WARN|FATAL]:<message> 在程序运行时，其日志文件会追加到特定的日期文件。
 
 
=================
 
在Primary失效时，文件同步程序会停止，Mirror会自动唤醒替代Primary处于活 动状态。所有的数据库操作将继续使用Mirror。在Mirror活动期间，所有对数据 库的修改将被记录日志。此时的系统状态为修改跟踪(Change Tracking)模式。 当失效的Segment被唤醒为在线状态，管理员可以使用恢复程序将其恢复到活 动状态(或原始状态)。恢复程序只同步拷贝Primary失效期间Mirror发生变化的 部分。此时的系统状态为重新同步(Resynchronizing)状态。一旦所有的Mirror 与它们的Primary都处于同步(synchronized)状态，系统状态将变为同步 (synchronized)状态。
 
--GPDB 的高可用概述 /Segment Mirror 概述