# selinux

**作者**

chrisx

**日期**

2021-05-12

**内容**

关闭selinux

----

[toc]

## 关闭

```bash
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
setenforce 0
getenforce
```
