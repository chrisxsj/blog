# security

**作者**

Chrisx

**日期**

2021-08-08

**内容**

pg数据库安全建议

---

[TOC]

统计security（参考pgcp课件）

## 数据库防勒索病毒建议

1. 升级数据库到最新小版本，最新小版本通常修复了经常遇到的bug、安全问题等。
2. 加强数据库用户密码安全，设置密码更换周期；设置强密码，例如密码长度，包含数字，字母，大小写，特殊字符等
3. 密码防止暴力破解，使用auth_delay.so模块会导致服务器在报告身份验证失败之前短暂停留。
4. 管控客户端网络访问控制，使用最小权限原则，只允许固定的IP地址连接；不使用无密码登陆方式。
5. 用户权限管控，普通用户不能授予管理员权限
6. 软件安全，使用官方介质，包括数据库软件，客户端工具。不使用非正版、破解、绿色软件。
7. 数据安全，建议配置物理备份和逻辑备份
8. 清理不必要的定时任务，运行脚本

## 升级建议

1. 使用pg_upgrade原地升级方式，pg_upgrade支持复制模式和链接模式，其差异参考以下图表
2. 建议升级至pg12最新版本（当前最新版本pg12.8）
3. 需要进行应用兼容测试，保证升级完成后，应用可用。
4. 需要进行数据库升级测试，验证升级步骤，提高升级效率。
5. 升级的影响
   1. 数据库扩展插件需要重新安装
   2. 采用链接模式升级时流复制备库需要重做
   3. 逻辑复制备库数据库需要完全重新同步一遍

| 属性     | 复制模式                           | 链接模式                                       |
| -------- | ---------------------------------- | ---------------------------------------------- |
| 描述     | 将源文件复制到目标集群。           | 使用硬链接就地修改源集群数据。                 |
| 升级时间 | 慢，因为它在升级前复制了数据。     | 很快，因为数据就地修改了。                     |
| 磁盘空间 | 需要约 60% 的可用磁盘空间。        | 需要约 20% 的可用磁盘空间。                    |
| 恢复速度 | 较快，因为源集群保持不变。         | 较慢，因为源文件已被修改，主文件和镜像需要重建 |
| 风险     | 由于源集群未受影响，因此风险较小。 | 由于修改了源集群，因此风险更大。               |
