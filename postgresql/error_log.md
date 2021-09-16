
# error_log

**作者**

Chrisx

**日期**

2021-09-06

**内容**

错误报告和日志配置使用

----

[toc]

## 抓取慢sql设置

通过设置数据库参数获取慢SQL

```sql
alter system set logging_collector = on;
alter system set log_destination = 'csvlog';
alter system set log_directory = 'hgdb_log';
alter system set log_truncate_on_rotation = on;
alter system set log_filename = 'highgodb_%d.log';
alter system set log_rotation_age='1d';
alter system set log_rotation_size=0;
alter system set log_min_duration_statement = 5000;
```

> 注：
log_filename = 'postgresql-%I.log'      #最多保存12小时的日志,每小时一个文件
log_filename = 'postgresql-%H.log'    #最多保存24小时的日志,每小时一个文件
log_filename = 'postgresql-%w.log'    #最多保存一周的日志,每天一个文件
log_filename = 'postgresql-%d.log'    #最多保存一个月的日志,每天一个文件
log_filename = 'postgresql-%j.log'      #最多保存一年的日志,每天一个文件

> 注，
log_statement = none
(当把log_min_duration_statement 选项和log_statement一起使用时，已经被log_statement记录的语句文本不会在持续时间日志消息中重复。)

## 自定义日志信息log_line_prefix

log_line_prefix (string)
这是一个printf风格的字符串，它在每个日志行的开头输出。%字符开始“转义序列”，它将被按照下文描述的替换成状态信息。未识别的转义被忽略。其他字符被直接复制到日志行。某些转义只被会话进程识别并且被主服务器进程等后台进程当作空。通过指定一个在%之后和该选项之前的数字可以让状态信息左对齐或右对齐。 负值将导致在右边用空格填充状态信息已达到最小宽度，而正值则在左边填充。填充对于日志文 件的人类可读性大有帮助。这个参数只能在postgresql.conf文件中或在服务器命令行上设置。默认值是'%m [%p] '，它记录时间戳和进程ID。

ref[log_line_prefix](http://www.postgres.cn/docs/11/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-CSVLOG)

## csv日志

将csv日志导入数据库

创建表

```sql
CREATE TABLE postgres_log
(  log_time timestamp(3) with time zone,
  user_name text,
  database_name text,
  process_id integer,
  connection_from text,
  session_id text,
  session_line_num bigint,
  command_tag text,
  session_start_time timestamp with time zone,
  virtual_transaction_id text,
  transaction_id bigint,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos integer,
  context text,
  query text,
  query_pos integer,
  location text,
  application_name text,
  PRIMARY KEY (session_id, session_line_num)
);

导入数据
COPY postgres_log FROM '/path/to/logfile.csv' WITH csv;

示例
按执行时间由长到短排序
select log_time,database_name,user_name,application_name,substr(message, 11,4),message from postgres_log where message like '%duration%' order by substr(message, 11,4)desc;
```

在log_destination列表中包括csvlog提供了一种便捷方式将日志文件导入到一个数据库表。这个选项发出逗号分隔值（CSV）格式的日志行，包括这些列： 带毫秒的时间戳、 用户名、 数据库名、 进程 ID、 客户端主机:端口号、 会话 ID、 每个会话的行号、 命令标签、 会话开始时间、 虚拟事务 ID、 普通事务 ID、 错误严重性、 SQLSTATE 代码、 错误消息、 错误消息详情、 提示、 导致错误的内部查询（如果有）、 错误位置所在的字符计数、 错误上下文、 导致错误的用户查询（如果有且被log_min_error_statement启用）、 错误位置所在的字符计数、 在 PostgreSQL 源代码中错误的位置（如果log_error_verbosity被设置为verbose）以及应用名。
