【11、PL/pgSQL编程-提高篇】

章节1：【控制结构】
实验1：【从函数中返回】
		 (1) create or replace function fn_raise_return_1(a int) 
			returns void as 
			$$
				begin
						if a > 0 then
						  RAISE NOTICE 'there is %',a;
						else
						  return; 
						end if;
					return; 
				end
			$$
		language plpgsql;	


实验2：【从函数中返回】
		 (1) create or replace function fn_raise_return_2
			(in_col1 IN int,in_col2 IN TEXT,out_col1 OUT int, out_col2 OUT TEXT) as 
				$$
					begin
						out_col1 := in_col1 + 1;
						out_col2 := in_col2 || '_result';
						return;
					end
				$$ 
			language plpgsql;
			
实验3：【从函数中返回】
		 (1) create or replace function fn_raise_return_com_1() returns numeric as 
			$$
			  declare
			  begin
				return (3+4*2)-(2*2-1);
			   end 
			$$
			language plpgsql;	
			
实验4：【从函数中返回】
		 (1) create or replace function fn_raise_return_com_2(a int) returns test_tb as 
			$$
				declare
					result test_tb%rowtype;
				begin
					select * from test_tb where id = a into result;
					return result;
				end
			$$
			language plpgsql;
实验5：【从函数中返回】
		 (1) create or replace function fn_raise_return_com_3() returns record as 
			$$
			  declare
			  begin
				return (1,2,'three'::text);
				raise notice '%','=======================';
			  end 
			$$
			language plpgsql;	

实验5：【从函数中返回】
		 (1) create or replace function fn_raise_return_next() returns setof test_tb as
			$$
				
					declare 
						every_row test_tb%rowtype;
				begin		
					for every_row in select * from test_tb where id < 20 loop
						every_row.name:=every_row.name || '_result';
						return next every_row;
						return next every_row;
					end loop;
					return;
				end
			$$
		language plpgsql;

         (2) select * from fn_raise_return_next();		
		 
实验5：【从函数中返回】
		 (1) create or replace function fn_raise_return_next() returns setof test_tb as
			$$
				
					declare 
						every_row test_tb%rowtype;
				begin		
					for every_row in select * from test_tb where id < 20 loop
						every_row.name:=every_row.name || '_result';
						return next every_row;
						return next every_row;
					end loop;
					return;
				end
			$$
		language plpgsql;

         (2) select * from fn_raise_return_next();

实验6：【从函数中返回】
		 (1) create or replace function fn_raise_return_next_query_1() returns setof test_tb as 
			$$
			
				declare 
					every_row test_tb%rowtype;
			begin		
				return query select * from test_tb where id < 20;
				return query select * from test_tb where id > 20;
				return;
			end
			$$
		language plpgsql;	

实验7：【从函数中返回】
		 (1) create or replace function fn_raise_return_next_query_2(a int) returns setof test_tb as 
			$$
			
				declare 
					every_row test_tb%rowtype;
			begin		
				return query EXECUTE 'select * from test_tb where id < $1' using a;
				return;
			end
			$$
		language plpgsql; 

实验8：【条件控制IF】
		 (1) create or replace function fn_raise_if(col int) returns text as 
			$$
			declare 
				result text;
			begin		
				IF col = 0 THEN
					result := '为0';
				ELSIF col > 0 THEN
					result := '正数';
				ELSIF col < 0 THEN
					result := '负数';
				ELSIF col is null THEN
					result := 'NULL';
				ELSE
					null;
				END IF;
			return result;
			end
			$$
		language plpgsql;

实验9：【条件控制CASE WHEN】
		 (1) create or replace function fn_raise_case_1(col int) returns text as 
			$$
			declare 
				result text;
			begin		
				CASE col
				 WHEN 1, 2 THEN
					result := 'one or two';
				 WHEN 3, 4 THEN
					result := 'three or four';		 	
				 ELSE
					result := 'other value';
				END CASE;
				return result;
			end
			$$
		language plpgsql;

		(2) select fn_raise_case_1(3);	

实验10：【条件控制CASE WHEN】
		 (1) create or replace function fn_raise_case_2(col int) returns text as 
			$$
			declare 
				result text;
			begin		
				CASE
				 WHEN col BETWEEN 1 AND 2 THEN
					result := 'value is between zero and ten';
				 WHEN col BETWEEN 3 AND 4 THEN
					result := 'value is between three and four';
				 ELSE
					result := 'other value';
				END CASE;
				return result;
			end
			$$
		language plpgsql;

		(2) select fn_raise_case_2(4);	

实验11：【LOOP循环】
		 (1) create or replace function fn_raise_loop() returns void as 
			$$
			begin
				<<loop_1>>
				loop
					some_statement;
					<<loop_2>>
					loop
						some_statement;
						exit;
						exit loop_1 when when_condition;
						continue;
						continue loop_1 when when_condition;
					end loop loop_2;
				end loop loop_1;
				return;
			end; 
			$$
		language plpgsql;

实验12：【WHILE LOOP 循环】
		 (1) create or replace function fn_raise_while_loop() returns void as 
			$$
			  declare 
				v_value int := 0;
			  begin
				while v_value < 6 loop
				   v_value = v_value + 1;
				end loop;
			  end 
			$$
		language plpgsql;		
		
实验13：【FOR LOOP 循环】
		 (1) create or replace function fn_raise_for_loop() returns void as 
			$$
				begin
					FOR i IN 1..10 LOOP
					 -- 我在循环中将取值 1,2,3,4,5,6,7,8,9,10 
					END LOOP;
					FOR i IN 1..10 BY 2 LOOP
					 -- 我在循环中将取值 1,3,5,7,9 
					END LOOP;			
					FOR j IN REVERSE 10..1 LOOP
					 -- 我在循环中将取值 10,9,8,7,6,5,4,3,2,1 
					END LOOP;
					FOR k IN REVERSE 10..1 BY 2 LOOP
					 -- 我在循环中将取值 10,8,6,4,2 
					END LOOP;
				end
			$$
		language plpgsql;	


章节2：【游标】
实验1：【使用游标FETCH】
		 (1) create or replace function fn_raise_cur_fetch_1() returns refcursor as
			$$
				declare
					cur_test_tb cursor for select * from test_tb;
				begin
					open cur_test_tb;
					return cur_test_tb;
				end 
			$$
			language plpgsql;

		 (2) create or replace function fn_raise_cur_fetch_2(cur_col refcursor) returns test_tb as
			$$
				declare
					result_fun test_tb%rowtype;
				begin
					fetch from cur_col into result_fun;
					return result_fun;
				end 
			$$
			language plpgsql;
		 (3) select somefunc();	
		 
实验2：【使用游标实现建议分页】
		 (1) create or replace function fn_raise_cur_move(page_no int) returns setof test_tb as
			$$
				declare
					cur_test_tb cursor for select * from test_tb;
				begin
					open cur_test_tb;
					move (page_no)*10 from cur_test_tb; 
					return query execute format('fetch FORWARD 10 from cur_test_tb');
					close cur_test_tb;
					return;
				end 
			$$
			language plpgsql;

		 (2) select fn_raise_cur_move(3);		 
		
		
章节4：【触发器】
实验1：【了解触发器函数】	
		(1)	create or replace FUNCTION fn_tri_test_tb() RETURNS trigger AS 
			$$
				 BEGIN
					 IF NEW.empname IS NULL THEN
						RAISE EXCEPTION 'empname cannot be null';
					 END IF;
					 IF NEW.salary IS NULL THEN
						 RAISE EXCEPTION '% cannot have null salary', NEW.empname;
					 END IF;
					 IF NEW.salary < 0 THEN
						 RAISE EXCEPTION '% cannot have a negative salary', NEW.empname;
					 END IF;
					 NEW.last_date := current_timestamp;
					 NEW.last_user := current_user;
					 RETURN NEW;
				 END;
			$$ 
			LANGUAGE plpgsql;
			
		(2)	CREATE TRIGGER fn_tri_test_tb BEFORE INSERT OR UPDATE ON test_emp_tri
			FOR EACH ROW EXECUTE function fn_tri_test_tb();




##

操作符 ~~ 等效于 LIKE， 而 ~~* 对应 ILIKE。 还有 !~~ 和 !~~* 操作符 分别代表 NOT LIKE 和 NOT ILIKE。
另外：
~  匹配正则表达式，大小写相关 'thomas' ~ '.*thomas.*' 
~*  匹配正则表达式，大小写无关 'thomas' ~* '.*Thomas.*' 
!~  不匹配正则表达式，大小写相关 'thomas' !~ '.*Thomas.*' 
!~*  不匹配正则表达式，大小写无关 'thomas' !~* '.*vadim.*'
