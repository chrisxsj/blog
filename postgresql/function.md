# pg function

```plpgsql
Create or replace function 过程名(参数名 参数类型,…..) returns 返回值类型 as
   $body$
        //声明变量
        Declare
        变量名变量类型；
        如：
        flag Boolean;
        变量赋值方式（变量名类型 ：=值；）
        如：
        str  text :=值; / str  text;  str :=值；
        Begin
                 函数体；
         return 变量名； //存储过程中的返回语句
        End;
   $body$
Language plpgsql;

```

随机日期函数

```plpgsql
create or replace function random_timestamp ()
returns setof timestamp
as
$$
begin
return query
select timestamp '2020-01-10 20:00:00' +
       random() * (timestamp '2020-12-20 20:00:00' -
                   timestamp '2020-01-10 10:00:00');
end;
$$
language plpgsql;
```

随机字符函数

```plpgsql
create or replace function random_string ()
returns setof  text
as
$$
begin
return query
select md5(timeofday() || random());
end;
$$
language plpgsql;


```
