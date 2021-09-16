# pg_versioning_policy

**作者**

Chrisx

**日期**

2021-06-18

**内容**

postgresql 版本策略，生命周期

ref [Versioning Policy](https://www.postgresql.org/support/versioning/)

----

[toc]

## 版本介绍

PostgreSQL全球开发组每年发布一次包含新特性，新功能的主要新版本。
每个主要版本都会收到错误修复，如果需要的话，还会收到安全修复，这些修复至少每三个月发布一次，称之为“次要版本”

有关次要发行计划的更多信息，可以查看次要发行路线图[minor release roadmap](https://www.postgresql.org/developer/roadmap/)（预定发行计划是二月、五月、八月和十一月的第二个星期四。）

下一个主版本是14，预计2021年的第三季度发行。

PostgreSQL全球开发组在一个主要版本发布后的5年内支持该版本。在五周年之后，会发布最后一个包含任何修复的次要版本，将此主版本视为生命结束end-of-life (EOL)，并不再受支持。

## 版本号

从PostgreSQL 10开始，主要版本通过增加版本的第一部分来表示，例如10到11。在PostgreSQL 10之前，主要版本通过增加版本号的第一部分或第二部分来表示，例如9.5到9.6。
次要版本通过增加版本号的最后一部分进行编号。从PostgreSQL 10开始，这是版本号的第二部分，例如10.0到10.1；对于旧版本，这是版本号的第三部分，例如9.5.3到9.5.4。

## 升级

**我们始终建议所有用户为正在使用的任何主要版本运行最新可用的次要版本。**

主版本通常会更改系统表数据文件内部格式，升级一般采用 pg_upgrade或转储方式，可以从一个主板本升级到另一个主板本，无需通过中间版本
次要版本通常不需要转储和恢复；您可以停止数据库服务器，安装更新的二进制文件，然后重新启动服务器。

虽然升级总是会包含一定程度的风险，但PostgreSQL次要版本只修复了经常遇到的bug、安全问题和数据损坏问题，以降低与升级相关的风险。对于小版本，社区认为不升级比升级风险更大。

以下是版本支持情况

```sh
Version	Current minor	Supported	First Release	Final Release
13	13.3	Yes	September 24, 2020	November 13, 2025
12	12.7	Yes	October 3, 2019	November 14, 2024
11	11.12	Yes	October 18, 2018	November 9, 2023
10	10.17	Yes	October 5, 2017	November 10, 2022
```

PG10，最新版本为10.17，目前属于支持范围。2022-11-10左右会发布最后一个支持版本，之后不再受支持。主板本不受支持情况下建议升级主板本。

具体版本支持情况请参考官方[release](https://www.postgresql.org/support/versioning/)

**主板本不再受支持情况下建议升级主板本**
**始终建议您使用可用的最新次要版本** ref [pg_security_infomation](./pg_security_Information.md)