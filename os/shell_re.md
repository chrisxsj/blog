# shell_re

**作者**

Chrisx

**日期**

2022-02-15

**内容**

shell RE 正则表达式使用

----

[toc]

## 介绍

regular expression
我们常常需要查询符合某些复杂规则的字符串，这些规则由正则表达式进行描述。

常用场景

```sh
^[0-9]+$   #匹配数字，以0-9开头和结尾的
[a-z0-9_]+@[a-z0-9]+\.[a-z] #匹配mail
[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}  #匹配ip

```

## 正则表达式元字符

| 字符  | 含义                                              |
| ----- | ------------------------------------------------- |
| .     | 匹配任意单个字符                                  |
| ^     | 匹配行首                                          |
| $     | 匹配行尾                                          |
| +     | 匹配前面正则表达式的一个或多个实例                |
| ?     | 匹配前面正则表达式的0个或1个实例                  |
| []    | 方括号表达式，匹配方括号内任一字符。配合-表示范围 |
| -     | 连字符，方括号内使用，表示范围                    |
| {n,m} | 区间表达式，表示匹配前面字符n-m次                 |
| {n}   | 匹配值千字符n次                                   |
| \     | 转义字符                                          |
| ()    | 匹配正则表达式群                                  |
| ( )   | 保留空间                                          |
| \n    | 与保留空间配合使用                                |
| \|    | 匹配位于\| 符号前或后的正则表达式                 |

## 示例

* .* 所有字符
* ^[^] 非字符组内的字符开头的行
* [a-z] 小写字母
* [A-Z] 大写字母
* [a-Z] 小写和大写字母
* [0-9] 数字
* < 单词头
* \> 单词尾

```sh
grep r..t t #匹配中间两个字符的行
grep [Nn]et #匹配N或n开头的


```
