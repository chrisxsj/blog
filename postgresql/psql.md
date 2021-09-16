# psql常用命令

ref [psql](https://www.postgresql.org/docs/10/app-psql.html)

## .psqlrc

Files

psqlrc and ~/.psqlrc

    Unless it is passed an -X option, psql attempts to read and execute commands from the system-wide startup file (psqlrc) and then the user's personal startup file (~/.psqlrc), after connecting to the database but before accepting normal commands. These files can be used to set up the client and/or the server to taste, typically with \set and SET commands.

    The system-wide startup file is named psqlrc and is sought in the installation's “system configuration” directory, which is most reliably identified by running pg_config --sysconfdir. By default this directory will be ../etc/ relative to the directory containing the PostgreSQL executables. The name of this directory can be set explicitly via the PGSYSCONFDIR environment variable.

    The user's personal startup file is named .psqlrc and is sought in the invoking user's home directory. On Windows, which lacks such a concept, the personal startup file is named %APPDATA%\postgresql\psqlrc.conf. The location of the user's startup file can be set explicitly via the PSQLRC environment variable.

    Both the system-wide startup file and the user's personal startup file can be made psql-version-specific by appending a dash and the PostgreSQL major or minor release number to the file name, for example ~/.psqlrc-9.2 or ~/.psqlrc-9.2.5. The most specific version-matching file will be read in preference to a non-version-specific file.
.psql_history

    The command-line history is stored in the file ~/.psql_history, or %APPDATA%\postgresql\psql_history on Windows.

    The location of the history file can be set explicitly via the HISTFILE psql variable or the PSQL_HISTORY environment variable.

## \o 将命令输出到文件

postgres=# \o /tmp/psql.out
postgres=# \t
Tuples only is on.
postgres=# select * from test.test_copy;
postgres=# \o
[pg@pg tmp]$ cat psql.out
7499 | ALLEN | SALESMAN | 7698 | 1991-02-20 00:00:00 | 1600 | 300 | 30
7566 | JONES | MANAGER | 7839 | 1991-04-02 00:00:00 | 2975 | | 20
7654 | MARTIN | SALESMAN | 7698 | 1991-09-28 00:00:00 | 1250 | 1400 | 30
7498 | JASON | ENGINEER | 7724 | 1990-02-20 00:00:00 | 1600 | 300 | 10

## \pset pager

无翻页，一次性显示内容。

## \pset footer off

footer
If value is specified it must be either on or off which will enable or disable display of the table footer (the (n rows) count). If value is omitted the command toggles footer display on or off.
不显示页脚行统计

## 只显示数据

-A, --no-align
Switches to unaligned output mode. (The default output mode is otherwise aligned.) This is equivalent to \pset format unaligned.
非对齐模式
-t, --tuples-only
Turn off printing of column names and result row count footers, etc. This is equivalent to \t or \pset tuples_only.
关闭列名和结果行计数页脚等的打印
-q, --quiet
Specifies that psql should do its work quietly. By default, it prints welcome messages and various informational output. If this option is used, none of this happens. This is useful with the -c option. This is equivalent to setting the variable QUIET to on.
静默模式，不显示版本和欢迎信息

只显示数据，无统计数据、无列标题

psql -qtA -c "select * from test_t1";

  1 | aaa
  2 | bbb

## autocommit

\set AUTOCOMMIT off
\echo :AUTOCOMMIT