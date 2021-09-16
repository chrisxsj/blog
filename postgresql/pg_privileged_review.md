# pg_privileged_review

all priveleged access sessions should be recorded and kept for investigation and audit purpose.

## pg 访问权限策略配置

配置文件$PGDATA/pg_hba.conf

## pg 会话连接记录配置

alter system set log_connections=on;
alter system set log_disconnections=on;
数据库访问会话记录会被写入到数据库日志中。

## 查看访问会话记录

CREATE TABLE postgres_log
(
log_time timestamp(3) with time zone,
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
COPY postgres_log FROM '/full/path/to/logfile.csv' WITH csv;
postgres=# select log_time,user_name,database_name,process_id,connection_from,message from postgres_log where message like '%connection%'limit 2;
        log_time          | user_name | database_name | process_id |   connection_from   |                      message
----------------------------+-----------+---------------+------------+--------------------+----------------------------------------------------
2020-12-07 00:00:01.793+08 |           |               |      70446 | 10.247.40.133:52084 | connection received: host=10.247.40.133port=52084
2020-12-07 00:00:01.807+08 | sgib2b    | tpsgdb        |      70446 | 10.247.40.133:52084 | connection authorized: user=sgib2bdatabase=tpsgdb
(2 rows)
