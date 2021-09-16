# pg_security_Information

**作者**

Chrisx

**日期**

2021-06-18

**内容**

postgresql 安全问题、安全漏洞介绍

ref [Versioning Policy](https://www.postgresql.org/support/security/13/)

---

[toc]

## 介绍

PostgreSQL安全更新主要作为次要版本升级提供。**我们始终建议您使用可用的最新次要版本**，因为它可能还包含其他与安全无关的修复程序。所有已知的安全问题都会在下一个主要版本发布时得到修复。

## 版本漏洞

漏洞列出了它们出现在哪个主要版本中，以及每个漏洞都固定在哪个版本中。如果该漏洞在没有有效登录的情况下可被利用，则也会说明这一点。它们还列出了一个漏洞类，但我们敦促所有用户阅读该描述，以确定该漏洞是否会影响特定的安装。

在支持的版本中已知的安全问题参考[Known security issues in all supported versions](https://www.postgresql.org/support/security/13/)

You can filter the view of patches to show just patches for version:
13 - 12 - 11 - 10 - 9.6 - all   <<<---此处选择主版本号

| Reference                   | Affected   | Fixed             | Component & CVSS v3 Base Score                      | Description                                                |
| --------------------------- | ---------- | ----------------- | --------------------------------------------------- | ---------------------------------------------------------- |
| CVE-2021-32029 Announcement | 13, 12, 11 | 13.3, 12.7, 11.12 | core server 6.5 AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N | Memory disclosure in artitioned-table UPDATE ... RETURNING |

## 安全漏洞处理

主要参考 Reference列中的Announcement

辅助参考[安全客](https://www.anquanke.com/vul/id/2238291)和[vigilance](https://vigilance.fr/vulnerability/PostgreSQL-three-vulnerabilities-33897)

**主板本不再受支持情况下建议升级主板本** ref [pg_vrsioning_policy](./pg_Versioning_Policy.md)
**始终建议您使用可用的最新次要版本。**
