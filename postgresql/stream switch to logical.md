# stream switch to logical

1. standby

pg_ctl promote

2. primary

create publication t_slot for all tables;

grant usage on schema public to logicalrep;
grant select on all tables in schema public to logicalrep;

3. standby

192.168.198.194:5532:*:logicalrep:logicalrep

create subscription t_slot_sub connection 'host=192.168.198.194 port=5532 dbname=postgres user=logicalrep' publication t_slot;

4. primary

alter publication t_slot for all tables;