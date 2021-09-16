# pg_data_security

**作者**

Chrisx

**日期**

2021-07-06

**内容**

数据安全(未完成)

---

[TOC]

## 1. 数据传输加密

如果你的网络是不可靠的，请使用加密传输，例如OPENSSL
参考示例：设置数据传输安全ssl
端口安全性 ：
修改默认端口，防火墙策略 ，ssh隧道技术
参考文档：
《PostgreSQL performance test use ssh tunnel》

## 2. 字段存储加密

将敏感数据加密后存储在数据库中，即使加密数据泄露，只要加解密方法没有泄露，也是相对安全的
加解密方法建议放在应用端实现，（或者加密在数据库端实现，解密在应用程序端实现）。
pgcrypto模块为PostgreSQL提供了密码函数；详细参见中文手册-》F.25. pgcrypto

create extension pgcrypto;
#计算hash值的函数.
digest(data text, type text) returns bytea
digest(data bytea, type text) returns bytea
#type为算法.支持 md5, sha1, sha224, sha256, sha384, sha512。
#如果编译postgresql时有了with-openssl选项, 则可以支持更多的算法.

## 3. 函数代码加密
对于先编译后执行的函数，例如C函数，是不需要加密的
对于解释性语言函数如plpgsql，建议加密函数的内容
如果不能加密，至少需要控制普通用户不能查看函数内容->函数内容存在pg_proc.prosrc字段中
参考文档《How to control who can see PostgreSQL function》
