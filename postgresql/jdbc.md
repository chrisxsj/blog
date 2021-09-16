# jdbc

**作者**

chrisx

**日期**

2021-05-20

**内容**

hg repmgr配置和使用

reference [JDBC DRIVER]([./](https://jdbc.postgresql.org/documentation/head/connect.html))

----

[toc]

## 针对ssl连接

配置参考如下（url里有ssl字符），请确认中间件连接配置是否正确
jdbc.type=postgre
jdbc.driver=com.highgo.jdbc.Driver
jdbc.url=jdbc:highgo://localhost:5866/highgo?ssl=true&&sslfactory=com.highgo.jdbc.ssl.NonValidatingFactory
jdbc.username=highgo
jdbc.password=admin123
jdbc.testSql=SELECT 'x' FROM DUAL
jdbc.dual = from dual

## URL

JDBC

JDBC的多主机URL功能全面，支持failover，读写分离和负载均衡。可以通过参数配置不同的连接策略。

jdbc:postgresql://192.168.234.201:5432,192.168.234.202:5432,192.168.234.203:5432/postgres?targetServerType=primary
连接主节点(实际是可写的节点)。当出现"双主"甚至"多主"时驱动连接第一个它发现的可用的主节点

jdbc:postgresql://192.168.234.201:5432,192.168.234.202:5432,192.168.234.203:5432/postgres?targetServerType=preferSecondary&loadBalanceHosts=true
优先连接备节点，无可用备节点时连接主节点，有多个可用备节点时随机连接其中一个。

jdbc:postgresql://192.168.234.201:5432,192.168.234.202:5432,192.168.234.203:5432/postgres?targetServerType=any&loadBalanceHosts=true
随机连接任意一个可用的节点

举两个例子：
1、前几天某个项目用户要求集群高可用，没有提读写分离。这种情况下，能做高可用切换就OK，通过JDBC的targetServerType=primary配置，就可以保证始终连到主库，不需要VIP、也不需要proxy
2、不动产项目，开发商可以做读写分离的应用改造，这时候也不需要proxy，更不需要VIP，应用改造做写入的配置targetServerType=primary，做查询的可以配置彩波给出的任意一个

另外：
1、高可用，负责主备切换，vip是高可用的一个附加功能，如果JDBC没有提供上述功能的话，VIP是不可或缺的。当高可用完全可以避免脑裂发生的时候，JDBC的targetServerType=primary就能够替代VIP了。
2、proxy，负责读写分离，可独立部署，也可跟数据库部署在一块。如果独立部署，vip也是不需要的，如果和数据库一块部署，JDBC可以用彩波提供的第三种模式。
