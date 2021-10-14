CREATE OR REPLACE FUNCTION public.testinsert()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$  
declare  
    total integer;  
BEGIN  
   insert into test values (1);   
END;  
$function$
;