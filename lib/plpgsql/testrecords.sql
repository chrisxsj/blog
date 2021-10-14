CREATE OR REPLACE FUNCTION public.testrecords()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$  
declare  
    total integer;  
BEGIN  
   SELECT count(*) into total FROM test;  
   RETURN total;  
END;  
$function$
;