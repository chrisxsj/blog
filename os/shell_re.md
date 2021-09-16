# shell re

regular expression
我们常常需要查询符合某些复杂规则的字符串，这些规则由正则表达式进行描述。

## 删除空行

/^$/d
/ - start of regex
^ - start of line
$ - end of line
/ - end of regex
d - delete lines which match
所以基本上找到任何空的行(起点和终点是相同的，例如没有字符)，并删除它们。