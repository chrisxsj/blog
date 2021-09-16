# Entering emergency mode

## 问题描述

CentOS虚拟机断电或强制关机，再开机出现问题

```bash
Entering emergency mode. Exit the shell to continue.
```

## 问题分析

这里的 `journalctl` 是查看系统的日志信息；直接输入此命令查看，日志内容可能很多，快速翻页或者直接定位到最新的日志信息，发现有标红的，说明此处出现错误。

错误原因

```bash
failed to mount /sysroot.
Dependency failed for Initrd root File System.
Dependency failed for Reload configuration from the Real Root.
```

解决问题,输入命令

```bash
xfs_repair -v -L /dev/dm-0
```

-L 选项指定强制日志清零，强制xfs_repair将日志归零，即使它包含脏数据（元数据更改）
