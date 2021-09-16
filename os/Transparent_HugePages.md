# Transparent_HugePages

**作者**

chrisx

**日期**

2021-05-13

**内容**

关闭透明大页

ref [How to disable transparent hugepages (THP) on Red Hat Enterprise Linux 7](./os/../How%20to%20disable%20transparent%20hugepages.md)

----

[toc]

## 透明大页

此处指的是Transparent HugePages，不是标准的HugePages。

根据数据库工程经验，开启透明大页（Transparent HugePages ） 会导致一些异常的性能问题，因此，一般的建议是关闭透明大页（Transparent HugePages ）

## 关闭透明大页

1. Add the "transparent_hugepage=never" kernel parameter option to the grub2 configuration file.
○ Append or change the "transparent_hugepage=never" kernel parameter on the GRUB_CMDLINE_LINUX option in /etc/default/grub file. Only include the parameter once.
Raw
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap ... transparent_hugepage=never"
2. Rebuild the /boot/grub2/grub.cfg file by running the grub2-mkconfig -o command as follows:
○ Please ensure to take a backup of the existing /boot/grub2/grub.cfg before rebuilding.
§ On BIOS-based machines: ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
3. Reboot the system and verify option has been added
○ Reboot the system

```sh
# shutdown -r now
```

Verify the parameter is set correctly

```sh
# cat /proc/cmdline

```

查看透明大叶开启情况

```sh
# cat /sys/kernel/mm/transparent_hugepage/enabled 
always madvise [never]


```