北京-酱油(632027885)  12:27:43
猫大，我想用fga审计一个schema下的所有表，得上百个…
请问这个咋整？
上海-老猫(1623798908)  12:35:48
begin
  dbms_fga.add_policy
  (
    object_schema=>'SCOTT',
    object_name=>'EMP',
    policy_name=>'AUDIT_DEMO',
    statement_types=>'INSERT, UPDATE, DELETE, SELECT'
  );
end;
/



begin
for v in select owner,table_name from dba_tables where owner = '&OWNER'
loop
dbms_fga.add_policy
(
object_schema=>v.owner,
object_name=>v.table_name,
policy_name=>'AUDIT_DEMO'
);
end loop;
end;
/
