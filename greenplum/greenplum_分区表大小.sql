-- Function: calc_partition_table(character varying, character varying)

-- DROP FUNCTION calc_partition_table(character varying, character varying);

CREATE OR REPLACE FUNCTION calc_partition_table(v_schemaname character varying, v_tablename character varying)
  RETURNS bigint AS
$BODY$
DECLARE
    v_calc BIGINT := 0;
    v_total BIGINT := 0;
    v_tbname VARCHAR(200);
    cur_tbname cursor for select schemaname||'.'||partitiontablename as tb from pg_partitions
   where schemaname=v_schemaname and tablename=v_tablename;
BEGIN
    OPEN cur_tbname;
    loop
        FETCH cur_tbname into v_tbname;
        if not found THEN
            exit;
        end if;
        EXECUTE 'select pg_relation_size('''||v_tbname||''')' into v_calc;
        v_total:=v_total+v_calc;        
    end loop;
    CLOSE cur_tbname;
    RETURN v_total;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION calc_partition_table(character varying, character varying) OWNER TO gpadmin;