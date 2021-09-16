# auto_explain

reference[Appendix F. Additional Supplied Modules/auto_explain](https://www.postgresql.org/docs/12/auto-explain.html)

auto_explain模块提供了一种方式来自动记录慢速语句及其执行计划，而不需 要手工运行EXPLAIN，对慢SQL的分析有用。在大型应用中追踪未被优化的查询时有用。

在普通用法中，这些参数都在postgresql.conf中设置，不过超级用户可以在他们自己的会话中随时修改这些参数。

## 配置

可以通过explain查看sql的执行计划，但pg不提供历史执行计划查看功能。auto_explain可实现此功能。auto_explain可以自动将sql的执行计划记录到日志文件。对于数据库出现sql性能问题时，可通过此模块输出sql的执行计划进行性能分析

设置参数，加载

shared_preload_libraries=pg_stat_statements,auto_explain--需重启
auto_explain.log_min_duration=on--单位毫秒，超过这个值的sql执行计划会被记录到数据库日志中
auto_explain.log_analyze=on--sql执行计划输出是否时analyze模式，相当于explain开启analyze模式，默认off
auto_explain.log_buffers=off--sql执行计划输出是否包含数据块信息。相当于explain开启buffer选项。默认off

auto_explain是数据据库性能分析的一个重要工具。

## 典型的用法可能是

In ordinary usage, these parameters are set in postgresql.conf, although superusers can alter them on-the-fly within their own sessions. Typical usage might be:

管理员使用。此方法可用来单次记录sql执行计划到错误日志

```sql
# postgresql.conf
session_preload_libraries = 'auto_explain'

auto_explain.log_min_duration = '3s'

postgres=# LOAD 'auto_explain';
postgres=# SET auto_explain.log_min_duration = 0;
postgres=# SET auto_explain.log_analyze = true;
postgres=# SELECT count(*)
           FROM pg_class, pg_index
           WHERE oid = indrelid AND indisunique;
```

