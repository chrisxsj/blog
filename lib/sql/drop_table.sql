-----------------------------------------
-- author，Chrisx
-- date，2021-07-08
-- Copyright (C): 2021 All rights reserved"
------------------------------------------

SELECT 'drop table ' ||  tablename || ';'
FROM pg_tables
WHERE schemaname = 'public'
    and tablename NOT LIKE 'pg%'
    AND tablename NOT LIKE 'sql_%'
ORDER BY tablename;