--带-的uuid值

CREATE OR REPLACE FUNCTION public.newid1()
RETURNS character varying
LANGUAGE plpgsql
AS $function$   
DECLARE v_seed_value varchar(40);   
BEGIN   
select   
md5(     
timeofday() || random()
)   
into v_seed_value;   
  
return (substr(v_seed_value,1,8) || '-' ||   
        substr(v_seed_value,9,4) || '-' ||   
        substr(v_seed_value,13,4) || '-' ||   
        substr(v_seed_value,17,4) || '-' ||   
        substr(v_seed_value,21,12));   
END;   
$function$
;

--TimeOfDay 属性返回一个 TimeSpan 值不含日期，仅含时间