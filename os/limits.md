# limits

**作者**

Chrisx

**日期**

2021-05-12

**内容**

系统资源限制

----

[toc]

## 配置文件

编辑文件/etc/security/limits.conf

```bash
highgo               soft    nofile          1024000
highgo               hard    nofile          1024000
highgo               soft    nproc           unlimited
highgo               hard    nproc           unlimited
highgo               soft    core            unlimited
highgo               hard    core            unlimited
highgo               soft    memlock         unlimited
highgo               hard    memlock         unlimited
```

:warning: nproc可以在两个文件文件/etc/security/limits.d/20-nproc.conf和/etc/security/limits.conf中都配置，但文件/etc/security/limits.d/20-nproc.conf会覆盖/etc/security/limits.conf，注意修改文件/etc/security/limits.d/20-nproc.conf的配置

```bash
*       soft    nproc   1024000
root    soft    nproc   unlimited
# nproc
highgo    soft    nproc   2047
highgo    hard    nproc   16384
```

:warning: `nofile超过1048576的话，要先将sysctl的fs.nr_open设置为更大的值，并生效后才能继续设置nofile`

## 配置检查

```sh
ulimit -a

```
