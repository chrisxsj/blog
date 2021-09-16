grant
 
CREATE DATABASE name;
where name follows the usual rules for SQL identifiers. The current role automatically becomes the owner of the new database. It is the privilege of the owner of a database to remove it later (which also removes all the objects in it, even if they have a different owner).
 
From <https://www.postgresql.org/docs/10/manage-ag-createdb.html>
 
 
Database owner：可以删除数据库（数据库可以被看作一个对象）及修改数据库属性
 

GRANT { { SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }
    [, ...] | ALL [ PRIVILEGES ] }
    ON
 
ALL 代表之前的{ SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER }所有的权限
 