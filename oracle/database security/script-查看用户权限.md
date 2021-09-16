查看用户权限
set serveroutput on size 1000000
set verify off
undefine user_name

declare
v_name varchar2(30) := upper('&user_name');
no_grant exception;
pragma exception_init( no_grant, -31608 );
begin
dbms_metadata.set_transform_param(dbms_metadata.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
dbms_output.enable(1000000);
dbms_output.put_line(dbms_metadata.get_ddl('USER',v_name));
begin
dbms_output.put_line(dbms_metadata.get_granted_ddl('SYSTEM_GRANT',v_name));
exception
when no_grant then dbms_output.put_line('每 No system privs granted');
end;
begin
dbms_output.put_line(dbms_metadata.get_granted_ddl('ROLE_GRANT',v_name));
exception
when no_grant then dbms_output.put_line('每 No role privs granted');
end;
begin
dbms_output.put_line(dbms_metadata.get_granted_ddl('OBJECT_GRANT',v_name));
exception
when no_grant then dbms_output.put_line('每 No object privs granted');
end;
begin
dbms_output.put_line(dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA',v_name));
exception
when no_grant then dbms_output.put_line('每 No tablespace quota specified');
end;
dbms_output.put_line(dbms_metadata.get_granted_ddl('DEFAULT_ROLE', v_name ));
exception
when others then
if SQLCODE = -31603 then dbms_output.put_line('每 User does not exists');
else raise;
end if;
end;
/

输入 user_name 的值:  sdzw
