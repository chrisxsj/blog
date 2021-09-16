create or replace trigger ddl_watcher
--after ddl on database
  before create or alter or drop /*or truncate*/ /*or comment or insert or update or delete*/
on database
  
when (user not in ('sys', 'system'))
declare
  v_osuser  varchar2(1024);
  v_machine varchar2(1024);
  v_ip_addr varchar2(1024);
  v_program varchar2(1024);
  event     varchar2(1024);
  obj_name  varchar2(1024);
  obj_type  varchar2(1024);
  obj_owner varchar2(1024);
  sql_text  ora_name_list_t;
  stmt      varchar2(4000);
  n         number;

  l_errmsg varchar2(100) := 'you have no permission to this operation. Go back home And tell your mother!';
begin

  select sys_context('userenv', 'ip_address'),
         sys_context('userenv', 'host')
    into v_ip_addr,
         v_machine
    from dual;

  event     := ora_sysevent;
  obj_name  := ora_dict_obj_name;
  obj_type  := ora_dict_obj_type;
  obj_owner := ora_dict_obj_owner;

  n := ora_sql_txt(sql_text);
  if n > 256 then
    n := 256;
  end if;

  for i in 1 .. n
  loop
    exit when lengthb(stmt) + lengthb(sql_text(i)) > 4000;
    stmt := stmt || sql_text(i);
  end loop;

  insert into ddl_event
    (timestamp, user_name, os_user, machine, ip_addr, program, event,
     object_name, object_type, object_owner, statement)
  values
    (sysdate, user, v_osuser, v_machine, v_ip_addr, v_program, event,
     obj_name, obj_type, obj_owner, stmt);

  if (v_machine not in ('WORKGROUP\THINKPAD',
                        --¿ÓΩ®∑Ω
                        'WORKGROUP\XINGXING',
                        --∫¬∫È–«
                        'WORKGROUP\LONGSHINE-PCPC', 
                        --÷£¡÷À…
                        'WORKGROUP\CHUPENGFEI-PC',
                        --¥¢≈Ù∑…
                        'WORKGROUP\YZL-PC',
                        --“∂’‹¡’  
                        'WORKGROUP\SHY-PC'                        
                        --Œ∫¿⁄               
                                                       
                        )) then
    if (obj_type not in
       ('PACKAGE BODY', 'PROCEDURE', 'PACKAGE', 'FUNCTION')) then
      raise_application_error(-20001,
                              ora_dict_obj_owner || '.' ||
                               ora_dict_obj_name || ' ' || ora_sysevent || ' ' ||
                               l_errmsg);
    end if;
  end if;

end;
