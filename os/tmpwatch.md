# tmpwatch

**作者**

Chrisx

**日期**

2021-05-12

**内容**

tmpwatch是目录自动清理程序。用于自动清理临时文件垃圾。如果你使用的是基于 Debian 的系统，请使用 tmpreaper 而不是 tmpwatch。

tmpreaper - removes files which haven't been accessed for a period of time
通常，用于清理存放临时文件的目录。如“/tmp”

ref [tmpreaper](https://manpages.ubuntu.com/manpages/jammy/man8/tmpreaper.8.html)

----

[toc]

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

## 安装使用tmpreaper

```sh
sudo apt install tmpreaper  #安装
tmpreaper  --ctime 10 /tmp  #删除/tmp目录10天以前创建的文件
tmpreaper  --test --verbose --ctime 10 /tmp    #模拟删除

```

:warning: 安装完成后，会生成自动计划任务/etc/cron.daily/tmpreaper,读取配置文件/etc/tmpreaper.conf

```sh
# Verify that these variables are set, and if not, set them to default values
# This will work even if the required lines are not specified in the included
# file above, but the file itself does exist.
TMPREAPER_TIME=${TMPREAPER_TIME:-7d}
TMPREAPER_PROTECT_EXTRA=${TMPREAPER_PROTECT_EXTRA:-''}
TMPREAPER_DIRS=${TMPREAPER_DIRS:-'/tmp/.'}

nice -n10 tmpreaper --delay=$TMPREAPER_DELAY --mtime-dir --symlinks $TMPREAPER_TIME  \
  $TMPREAPER_ADDITIONALOPTIONS \
  --ctime \
  --protect '/tmp/.X*-{lock,unix,unix/*}' \
  --protect '/tmp/.ICE-{unix,unix/*}' \
  --protect '/tmp/.iroha_{unix,unix/*}' \
  --protect '/tmp/.ki2-{unix,unix/*}' \
  --protect '/tmp/lost+found' \
  --protect '/tmp/journal.dat' \
  --protect '/tmp/quota.{user,group}' \
  --protect '/tmp/systemd-private*/*' \
  `for i in $TMPREAPER_PROTECT_EXTRA; do echo --protect "$i"; done` \
  $TMPREAPER_DIRS
```

删除/tmp中7天以前创建的文件。排除那些--protect的文件
