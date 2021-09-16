#! /bin/bash
#######################################
# author，Chrisx
# date，2021-06-15
# Copyright (C): 2021 All rights reserved"
######################################
# introduction,循环执行一个sql
#######################################
function loop_sql() {
    for i in {1..600};do
     psql -U taudit -d highgo -c "insert into test_audit values(1);
     insert into test_audit values(2);
     insert into test_audit values(3);
     insert into test_audit values(4);
     insert into test_audit values(5);
     insert into test_audit values(6);
     insert into test_audit values(7);
     insert into test_audit values(8);
     insert into test_audit values(9);
     insert into test_audit values(10);"
    done
}