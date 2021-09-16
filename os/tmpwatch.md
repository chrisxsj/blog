# tmpwatch
## 关于linux tmp下文件自动删除的问题

最近发现放在/tmp下的目录ora_tmp总是莫名奇妙的被删除掉，通过crontab发现并没有定期执行的任务。。。

/var/log/  除了有message系统日志，还有cron 计划任务的日志
查看cron会有以下的类似内容
```bash
May 29 03:24:02 *** run-parts(/etc/cron.daily)[105072]: starting rhsmd
May 29 03:24:02 *** run-parts(/etc/cron.daily)[105288]: finished rhsmd
May 29 03:24:02 *** run-parts(/etc/cron.daily)[105072]: starting tmpwatch
May 29 03:24:02 *** run-parts(/etc/cron.daily)[105326]: finished tmpwatch
```
这里发现有运行tempwatch
 
## 什么是tmpwatch
**tmpwatch  -  removes  files  which haven’t been accessed for a period of time**
 
当你安装了tmpwatch package后就有这个命令，并且在/etc/cron.daily/目录下生成一个tmpwatch文件
tmpwatch package
rpm -qa |grep tempwatch
tmpwatch-2.9.16-4.el6.x86_64

```bash
tmpwatch command
-u, --atime 基于访问时间来删除文件，默认的。
-m, --mtime 基于修改时间来删除文件。
-c, --ctime 基于创建时间来删除文件，对于目录，基于mtime。
-M, --dirmtime 删除目录基于目录的修改时间而不是访问时间。
-a, --all 删除所有的文件类型，不只是普通文件，符号链接和目录。
-d, --nodirs 不尝试删除目录，即使是空目录。
-d, --nosymlinks 不尝试删除符号链接。
-f, --force 强制删除。
-q, --quiet 只报告错误信息。
-s, --fuser 如果文件已经是打开状态在删除前，尝试使用“定影”命令。默认不启用。
-t, --test 仅作测试，并不真的删除文件或目录。
-U, --exclude-user=user 不删除属于谁的文件。
-v, --verbose 打印详细信息。
-x, --exclude=path 排除路径，如果路径是一个目录，它包含的所有文件被排除了。如果路径不存在，它必须是一个绝对路径不包含符号链接。
-X, --exclude-pattern=pattern 排除某规则下的路径。
 
cat /etc/cron.daily/tmpwatch
#! /bin/sh
flags=-umc
/usr/sbin/tmpwatch "$flags" -x /tmp/.X11-unix -x /tmp/.XIM-unix \
        -x /tmp/.font-unix -x /tmp/.ICE-unix -x /tmp/.Test-unix \
        -X '/tmp/hsperfdata_*' 10d /tmp
/usr/sbin/tmpwatch "$flags" 30d /var/tmp
for d in /var/{cache/man,catman}/{cat?,X11R6/cat?,local/cat?}; do
    if [ -d "$d" ]; then
        /usr/sbin/tmpwatch "$flags" -f 30d "$d"
    fi
done


```

发现
```bash
/usr/sbin/tmpwatch "$flags" -f 30d "$d"
```
这一行，就是说清理30天没有被访问过的文件或文件夹
 