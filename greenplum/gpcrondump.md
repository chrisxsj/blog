gpcrondump -a -C --dump-stats -g -G -h -r -v --use-set-session-authorization -x postgresql -u /home/dgadmin/backup --prefix postgresql -l /home/dgadmin/backup
 
 
 
-a                                                                        不需要确认
--dump-stats                                                 从pg_statistic转储优化器统计信息。统计数据被保存在主数据目录为db_dumps/YYYYMMDD/gp_statistics_1_1_<timestamp>。
-g                                                                        复制配置文件
-G                                                                        转储全局对象，使用pg_dumpall转储角色和表空间等全局对象。全局对象被转储到主数据目录中db_dumps/YYYYMMDD /gp_global_1_1_ <时间戳>。
-h                                                                        记录转储详细信息，记录数据库表中数据库转储的详细信息。通过-x选项提供的数据库中的public.gpcrondump_history。如果当前不存在，将创建表。
-r                                                                        失败时回滚。如果失败，则回滚转储文件（删除部分转储）检测。默认是不回滚。
 
-u backupdir                                                指定备份文件将放置在每个主机上的绝对路径。如果路径不存在，则会创建该路径（如果可能）。如果未指定，则默认为要备份的每个实例的数据目录。
如果每个段主机具有多个段实例，则可能需要使用此选项，因为它将在集中位置而不是段数据目录中创建转储文件。
--use-set-session-authorization                使用SET SESSION AUTHORIZATION命令而不是ALTER OWNER命令来设置对象所有权。
 
-x dbname                                                        需要。要转储的Greenplum数据库的名称。为多个数据库指定多次。
--prefix <prefix_string>                         将<prefix_string>后跟下划线字符（_）添加到备份期间创建的所有备份文件的名称。
 
 
 
 
 
 
 
 
postgresql=# \l+
                                            List of databases
    Name    |  Owner  | Encoding |  Access privileges  |  Size  | Tablespace |        Description
------------+---------+----------+---------------------+--------+------------+---------------------------
 postgres   | dgadmin | UTF8     |                     | 52 MB  | pg_default |
 postgresql | dgadmin | UTF8     |                     | 755 MB | pg_default |
 template0  | dgadmin | UTF8     | =c/dgadmin          | 52 MB  | pg_default |
                                 : dgadmin=CTc/dgadmin
 template1  | dgadmin | UTF8     | =c/dgadmin          | 52 MB  | pg_default | default template database
                                 : dgadmin=CTc/dgadmin
(4 rows)
 
 
gpdbrestore -G -a -v --prefix postgresql -b 20190515 -u /home/dgadmin/backup -l /home/dgadmin/backup
 
 
-a                                                                         不需要确认
 
-b        <YYYYMMDD>                                                在db_dumps / <YYYYMMDD>中的Greenplum Database主机阵列上的段数据目录中查找转储文件。
如果指定了--ddboost，系统将在Data Domain Boost主机上查找转储文件。
 
-B <parallel_processes>                                要进行恢复前/后验证的并行检查段数。如果未指定，该实用程序将启动最多60个并行进程，具体取决于它需要还原的段实例数。
 
-d <master_data_directory>                        可选的。主机数据目录。如果未指定，将使用为$MASTER_DATA_DIRECTORY设置的值。
 
-e                                                                        在执行还原之前删除目标数据库，然后重新创建它。
 
-G [include|only]                                        如果在主数据目录中找到全局对象转储文件db_dumps / <date> / gp_global_1_1_ <timestamp>，则还原角色和表空间等全局对象。
指定“-G only”仅恢复全局对象转储文件
或者“-G include”来恢复全局对象以及正常恢复。
如果未提供任何参数，则默认为“include”。
 
-l <logfile_directory>                                写入日志文件的目录。 默认为〜/ gpAdminLogs。
 
--prefix <prefix_string>                        如果指定了gpcrondump选项--prefix <prefix_string>来创建备份，则必须在还原备份时使用<prefix_string>指定此选项。
如果使用gpcrondump创建了一组表的完整备份并指定了前缀，则可以将gpcrondump与选项--list-filter-tables和
--prefix <prefix_string>一起使用，以列出包含或排除的表备份。
 
-R <hostname>：<path_to_dumpset>        允许您提供一组转储文件的主机名和完整路径。主机不必位于Greenplum Database主机阵列中，但必须可以从Greenplum主站访问。
 
--redirect <database_name>                        还原数据的数据库的名称。指定此选项可将数据还原到与备份期间指定的数据库不同的数据库。如果<database_name>不存在，则创建它。
 
-s <database_name>                                        在Greenplum Database主机阵列上的段数据目录db_dumps目录中查找给定数据库名称的最新转储文件集。
 
-t <timestamp_key>                                        14位时间戳密钥，用于唯一标识要还原的备份数据集。它的形式为YYYYMMDDHHMMSS。
在Greenplum Database主机阵列上的段数据目录db_dumps目录中查找与此时间戳键匹配的转储文件。
 
-u <backup_directory>                                指定每个主机上包含db_dumps目录的目录的绝对路径。 如果未指定，则默认为要备份的每个实例的数据目录。
如果在创建备份集时使用gpcrondump选项-u指定了备份目录，请指定此选项。
如果<backup_directory>不可写，则备份操作报告状态文件将写入段数据目录。
您可以使用--report-status-dir选项指定写入报告状态文件的其他位置。
注意：如果指定了--ddboost，则不支持此选项。
-v |--verbose                                                指定详细模式。

 
备份脚本：（全备和增备）
 
#!/bin/bash
source /data/db/greenplum5.9.0/greenplum_path.sh
source /home/gpadmin/.bash_profile
DATE=`date "+%Y_%m_%d %H:%M:%S"`
log=/gpbakup/gpdbbak_all_log
gpcrondump -x dss_gp_db  -g -G -a  -u /gpbakup/dbbak >>/gpbakup/gpdump.log &>>$log
if [ $? -eq 0 ]; then
                echo -e $DATE: "\033[32m  All backup successful ! \033[m" | tee -a $log
                else
echo -e $DATE: "\033[31m All backup Failed！ \033[m" | tee -a $log
fi
 
 
 
 
#!/bin/bash
source /data/db/greenplum5.9.0/greenplum_path.sh
source /home/gpadmin/.bash_profile
DATE=`date "+%Y_%m_%d %H:%M:%S"`
log=/gpbakup/gpdbbak_add_log
gpcrondump -x dss_gp_db  -g -G -a  -u /gpbakup/add/ --incremental &>>$log
if [ $? -eq 0 ]; then
                echo -e $DATE: "\033[32m  Add backup successful ! \033[m" | tee -a $log
                else
echo -e $DATE: "\033[31m Add backup Failed！ \033[m" | tee -a $log
fi