# Date or Time Functions and Operators

reference[Date/Time Functions and Operators](https://www.postgresql.org/docs/12/functions-datetime.html)


## 时间函数介绍

有时，你会发现，程序中select now() 获取的时间为什么一直不变？

pg中获取时间的方式有多种
如果放在事务中，now()获取的就是事务开始的时间，事务不结束，时间不变；而clock_timestamp()显示的时间会实时变化。获取时间行数参考如下：
`now()`
timestamp with time zone
Current date and time (start of current transaction); see Section 9.9.4
`current_timestamp`
timestamp with time zone
Current date and time (start of current transaction); see Section 9.9.4
`current_time`
time with time zone
Current time of day; see Section 9.9.4
`clock_timestamp()`
timestamp with time zone
Current date and time (changes during statement execution); see Section 9.9.4
## 函数使用
```
postgres=# begin;
BEGIN
postgres=# select now();
now
-------------------------------
2019-04-15 16:05:23.491101+08
(1 row)
postgres=# select now();
now
-------------------------------
2019-04-15 16:05:23.491101+08
(1 row)
postgres=# end;
COMMIT
postgres=#
 
postgres=# begin;
BEGIN
postgres=# select clock_timestamp();
clock_timestamp
-------------------------------
2019-04-15 16:04:20.491936+08
(1 row)
postgres=# select clock_timestamp();
clock_timestamp
-------------------------------
2019-04-15 16:05:01.330757+08
(1 row)
postgres=# end;
COMMIT
```

## Delaying Execution


The following functions are available to delay execution of the server process:
pg_sleep(seconds)
pg_sleep_for(interval)
pg_sleep_until(timestamp with time zone)

pg_sleep makes the current session's process sleep until seconds seconds have elapsed. seconds is a value of type double precision, so fractional-second delays can be specified. pg_sleep_for is a convenience function for larger sleep times specified as an interval. pg_sleep_until is a convenience function for when a specific wake-up time is desired. For example:

SELECT pg_sleep(1.5);
SELECT pg_sleep_for('5 minutes');
SELECT pg_sleep_until('tomorrow 03:00');
