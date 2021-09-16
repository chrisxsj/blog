# Oracle Multitenant Architecture common command

# 1 连接到 CDB 或 PDB
远程连接
select name,con_id from v$services;
select name,con_id from v$active_services;
sqlplus sys/oracle@localhost:1521/cdb1 as sysdba or connect / as sysdba    -- 简便连接方式或本地认证
本地更换 container
conn / as sysdba
select * from v$version;
show con_name
show con_id
select pdb_name, status from cdb_pdbs;
select name, open_mode from v$pdbs;
alter session set container=cdb$root;  -- 更换 pdb 数据库
# 3 管理 CDB 和 PDB
conn / as sysdba
show con_name
shutdown immediate     -- This operation first closes all PDBs, then dismounts the control files, and finally shuts down the instance.
startup    -- This operation first starts the instance, then mounts the control files, and finally opens only the root container. 
select sys_context ( 'USERENV' , 'CON_NAME' ) from dual; -- 查看 cdb
select name, open_mode from v$pdbs;
alter pluggable database pdb2 open;
select name, open_mode from v$pdbs;
alter pluggable database all open;
select name, open_mode from v$pdbs;
alter pluggable database pdb1 close immediate;
select name, open_mode from v$pdbs;
alter pluggable database all close immediate;
select name, open_mode from v$pdbs;
创建触发器，使 PDB 随着 CDB 实例启动而自动启动
a. Create a trigger to open all PDBs after CDB startup. 
b. Shut down and start the CDB to verify that the trigger automatically opens all PDBs.
create or replace trigger Sys.After_Startup after startup on database 
begin 
   execute immediate 'alter pluggable database all open'; 
end After_Startup;
/
shutdown immediate
startup
select name, open_mode from v$pdbs;
重命名一个 pdb
alter pluggable database pdb3 close immediate;
alter pluggable database pdb3 open restricted;
select name, restricted from v$pdbs;
alter pluggable database pdb3 rename global_name to pdb3_bis;
Note: You should receive an error message when you execute this statement because you are not connected to the pluggable database that is being renamed.
connect sys/oracle@localhost:1521/pdb3 as sysdba
alter pluggable database pdb3 rename global_name to pdb3_bis;
alter pluggable database close immediate;
alter pluggable database open;
select name, open_mode from v$pdbs;
# 4 管理存储（ CDB 和 PDB ）
pdb 是可插拔数据库，在 cdb 中叫 container 
每个 cdb 都有一个 root container
每个 pdb 存储数据在自己的数据文件，临时数据在临时文件中
connect / as sysdba
select tablespace_name, con_id from cdb_tablespaces where con_id=1;
select file_name, con_id from cdb_data_files where con_id=1;
select file_name, con_id from cdb_temp_files where con_id=1;
在 root 里创建永久表空间
create tablespace cdata datafile '/u01/app/oracle/oradata/cdb1/cdata01.dbf' SIZE 10M;
select tablespace_name, con_id from cdb_tablespaces order by con_id;
select file_name, con_id from cdb_data_files order by con_id;
在 root 里创建临时表空间
create temporary tablespace temp_root tempfile '/u01/app/oracle/oradata/cdb1/temproot01.dbf' SIZE 10M;
select tablespace_name, con_id from cdb_tablespaces where contents='TEMPORARY' and con_id=1;
select file_name, con_id from cdb_temp_files where con_id=1;
在 pdb 里创建永久表空间
connect system/oracle@localhost:1521/pdb3_bis
create tablespace ldata datafile '/u01/app/oracle/oradata/cdb1/pdb3/ldata01.dbf' SIZE 10M;
select tablespace_name, con_id from cdb_tablespaces order by con_id;
select file_name, con_id from cdb_data_files order by con_id;
select file_name from dba_data_files;
在 pdb 里创建临时表空间
create temporary tablespace temp_pdb3 tempfile '/u01/app/oracle/oradata/cdb1/pdb3/temppdb301.dbf' SIZE 10M;
select tablespace_name, con_id from cdb_tablespaces where contents='TEMPORARY';
select file_name from dba_temp_files;
# 5 管理 pdb 的安全性
cdb 里的每一个 container 都有通用（ common ）和本地（ local ）用户
common 用户从 root 里创建自动复制到每个 pdb 里（出来 pdb 模版），可以链接到任何 pdb ，这类用户名必须以 ‘c##’ 开头
local 用户从 pdb 里创建，这类用户不能访问其他 pdb
创建 common 用户
connect / as sysdba
create user c##1 identified by oracle container=all;
select username, common, con_id from cdb_users where username like 'C##%';
用 common 用户链接其他 pdb
connect c##1/oracle@localhost:1521/pdb2
connect c##1/oracle@localhost:1521/pdb3_bis
以 dba 角色登陆到 pdb 创建 local 用户
connect system/oracle@localhost:1521/pdb3_bis
create user hr identified by oracle;
select username, common, con_id  from cdb_users where username ='HR';
用 local 用户链接其他 pdb
connect hr/oracle@localhost:1521/pdb2
connect hr/oracle@localhost:1521/pdb3_bis
管理通用和本地角色。。。
cdb 里的每一个 container 都有通用（ common ）和本地（ local ）角色
common 角色从 root 里创建自动复制到每个 pdb 里（出来 pdb 模版），这类角色名必须以 ‘c##’ 开头
local 角色从 pdb 里创建，这类就角色被授予
管理通用和本地权限。。。
# 6 删除 pdb
删除 pdb 可保留数据文件或删除数据文件，当拔下一个 pdb 插入到另一个 cdb 中时可重用这些保留的数据文件
关闭 pdb
connect / as sysdba
alter pluggable database all close immediate;
select name, open_mode from v$pdbs;
删除 pdb 包括他们的数据文件
drop pluggable database pdb3_bis including datafiles;
select name from v$pdbs;