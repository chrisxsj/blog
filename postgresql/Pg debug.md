客户端debug信息
client_min_messages (enum)：控制发送到客户端的消息级别。有效值是DEBUG5、 DEBUG4、DEBUG3、DEBUG2、 DEBUG1、LOG、NOTICE、 WARNING、ERROR、FATAL和PANIC。每个级别都包括其后的所有级别。级别越靠后，发送的消息越少。默认值是NOTICE。该参数可以设置为用户级别，alter role username set client_min_messages=log;修改后，重新登录用户即可。查询当前用户的日志级别select usename,a.useconfig,c.setconfig from pg_user a, pg_db_role_setting c where a.usesysid=c.setrole and a.usename='username’;
 
HGDB服务端debug信息会打印到数据库日志文件中，记录debug信息的前提是设置logging_collector 、 log_destination 、 log_directory 、 log_filename 等参数。
 
log_min_messages (enum)：控制写入哪些级别消息到服务器日志。有效值是DEBUG5、DEBUG4、 DEBUG3、DEBUG2、DEBUG1、 INFO、NOTICE、WARNING、 ERROR、LOG、FATAL和 PANIC。每个级别都包括以后的所有级别。级别越靠后，被发送的消息越少。默认值是WARNING。
 
log_min_error_statement (enum)：控制哪些导致一个错误情况的 SQL 语句被记录在服务器日志中。任何指定严重级别或更高级别的消息的当前 SQL 语句将被包括在日志项中。有效值是DEBUG5、 DEBUG4、DEBUG3、 DEBUG2、DEBUG1、 INFO、NOTICE、 WARNING、ERROR、 LOG、 FATAL和PANIC。默认值是ERROR，表示导致错误、日志消息、致命错误或恐慌错误的语句将被记录在日志中。要关闭记录失败语句，将这个参数设置为PANIC。