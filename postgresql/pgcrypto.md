# pgcrypto

**作者**

Chrisx

**日期**

2021-09-01

**内容**

pgcrypto模块为PostgreSQL提供了密码函数。可对字段加密

----

[toc]

## 介绍

pgcrypto扩展是pg内核中支持的扩展插件，全部编译后，会扩展目录中找到。（GP/HGDW也可以安装pgcrypto扩展模块）
pgcrypto提供了一组加密函数。可以实现服务器端的数据加密。我们可以在SQL语句中调用这些函数来完成数据的加密
pgcrypto可以加密存储数据，但是读取时无法透明解密数据。通常只用于加密存储已知的密码，不建议用于加密列数据

## 安装

```sql
select * from pg_available_extensions where name like '%cryp%'; --查看是否村咋可用插件，没有的话需要源码编译需要的插件
create extension pgcrypto;  --安装扩展

```

:warning: 老版本需要执行脚本安装

```sh
psql -d testdb -f $HOME/share/postgresql/contrib/pgcrypto.sql）

```

## 加密函数使用

1. 普通哈希函数，digest()函数可以根据不同的算法生成数据的二进制哈希值。

加密函数digest

```sql
postgres=# select digest('jason', 'md5');
               digest              
------------------------------------
 \x2b877b4b825b48a9a0950dd5bd1f264d
(1 row)
```

2. 口令哈希函数，函数crypt()和gen_salt()是特别设计用来做口令哈希的。

3. PGP 加密函数，这里的函数实现了OpenPGP (RFC 4880) 标准的加密部分。对称密钥和公钥加密都被支持。

加密函数

pgp_sym_encrypt(data text, psw text [, options text ]) returns bytea
pgp_sym_encrypt_bytea(data bytea, psw text [, options text ]) returns bytea

```sql
highgo=# select pgp_sym_encrypt('jinan', 'pwd');
                                                                 pgp_sym_encrypt
--------------------------------------------------------------------------------------------------------------------------------------------------
 \xc30d040703025abb390292ee38bb7ad236013209f47b0767bbfb8e9a7f511c906e5ed81575825480bb572d88f434d4ca0558c6766ca238c257d7e02e3c3cb3a9a7ae8ebf44201f
(1 row)

```

解密函数

pgp_sym_decrypt(msg bytea, psw text [, options text ]) 返回 text
pgp_sym_decrypt_bytea(msg bytea, psw text [, options text ]) returns bytea

```sql
highgo=# select pgp_sym_decrypt('\xc30d040703025abb390292ee38bb7ad236013209f47b0767bbfb8e9a7f511c906e5ed81575825480bb572d88f434d4ca0558c6766ca238c257d7e02e3c3cb3a9a7ae8ebf44201f', 'pwd');
 pgp_sym_decrypt
-----------------
 jinan
(1 row)

```

:warning: msg bytea需要使用查询出的加密后的字串；不允许使用pgp_sym_decrypt解密bytea数据。

## 应用示例

```sql
create table test_pgcrypt(id int,name text);
insert into test_pgcrypt(id,name) values (1,pgp_sym_encrypt('world','ppp'));
insert into test_pgcrypt(id,name) values (2,pgp_sym_encrypt('chris','psw'));
update test_pgcrypt set name=pgp_sym_encrypt('chrisx','psw') where id=2;

highgo=# select * from test_pgcrypt ;
 id |                                                                        name
----+----------------------------------------------------------------------------------------------------------------------------------------------------
  1 | \xc30d04070302f26f9b1a0034fcda7fd236017f853534bfebb4b2a5a1002f0ec479e49ebd3f3b2364994af290867da7338dcfc536acaf48c76f38092820b16ce3e8fb63060046ea
  2 | \xc30d04070302caa951d34ebe02a86ad23701d8166fc92c35ab34d753af306111acc42edef5c7eca0e60ec38dfa4adabbf23a8119f61ed4d1cc878c9e4319b41abcc61f73b25163a0
(2 rows)


highgo=# select id,pgp_sym_decrypt('\xc30d04070302caa951d34ebe02a86ad23701d8166fc92c35ab34d753af306111acc42edef5c7eca0e60ec38dfa4adabbf23a8119f61ed4d1cc878c9e4319b41abcc61f73b25163a0','psw') as name from test_pgcrypt where id=2;
 id | name
----+-------
  2 | chrisx
(1 row)


```
