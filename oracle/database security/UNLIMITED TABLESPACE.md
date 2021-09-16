限额是指定标空间中允许的空间容量，默认的情况下，用户在任何表空间中都是没有限额的，可以使用一下三个选项来为用户提供表空间限额：
A、无限制的：允许用户最大限度的使用表空间中的可用空间
B、值：用户可以使用的表空间，以千字节或者兆字节为单位。这并不能保证会为用户保留该空间。因此此值可能大于或小于表看三毛中的当前可用表空间
C、UNLIMITED TABLESPACE系统权限：此系统权限会覆盖所有的单个表空间限额，并向用户提供所有表空间（包括SYSTEM和SYSAUX）的无限制限额（注：授予resource角色的时候也会授予此权限）
一定不要为用户提供system或sysaux表空间的限额。通常，只有sys和system用户才能在system或sysaux表空间中创建对象。
对于分配的临时表空间或临时还原表空间则不需要限额。



与表空间限额先关的数据字典：
dba_ts_quotas：DBA_TS_QUOTAS describes tabelspace quotas for all users
user_ts_quotas：USER_TS_QUOTAS describes tablespace quotas for the current user. This view does not display the USERNAME column;
在两个数据字典中，max_bytes字段就是表示表空间限额的值了，单位是B，其中-1代表没有限制，其他的值多少就是多少的限额了。

-----------------昏割线------------------------
在最后我们需要关于一个比较重要的权限做一个说明，这个系统权限就是UNLIMITED TABLESPACE
unlimited tablespace的特点：
1、系统权限unlimited tablespace不能被授予role，只能被授予用户。也就是说，unlimited tablespace系统权限不能包含在一个角色role中
2、unlimited tablespace没有被包括在resource role和dba role中，但是unlimited tablespace随着resource或者dba的授予而授予用户的。也就是说，如果将role角色授予了某个用户，那么这个用户将会拥有unlimited tablespace系统权限
3、unlimited tablespace不能伴随这resource被授予role而授予用户。也就是说加入resource角色被授予了role_test角色，然后把role_test授予了test用户，但是此时unlimited tablespace没有被授予test用户
