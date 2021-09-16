Failover slots for PostgreSQL

https://www.2ndquadrant.com/en/blog/failover-slots-postgresql/


craig.ringer
Failover slots for PostgreSQL
June 8, 2020/in Craig's PlanetPostgreSQL /by craig.ringer
Logical decoding and logical replication is getting more attention in the PostgreSQL world. This means we need it working well alongside production HA systems – and it turns out there’s a problem there. Replication slots are not themselves synced to physical replicas so you can’t continue to use a slot after a master failure results in promotion of a standby.

The failover slots patch changes that, syncing slot creation and updates to physical replica servers such as those maintained with WAL archives or streaming replication. That lets logical decoding clients seamlessly follow a failover promotion and continue replay without losing consistency.


Logical decoding and slots
Introduced in 9.4, logical decoding lets a client stream changes row-by-row in consistent transaction commit order to some receiver – which can be another PostgreSQL instance or your choice of applications like message queues and search engines.

To stream the row data the client connects to a replication slot on the server. The slot makes sure that the server retains the WAL needed for decoding and (for logical slots) also prevents the removal of old versions of system catalog rows that might be needed to understand that WAL.

The failover problem
Most production PostgreSQL deployments rely on streaming replication and/or WAL archive based replication ("physical replication") as part of their high availability and failover capabilities. Unlike most server state, replication slots are not replicated from a master server to its replicas. When the master fails and a replica is promoted any replication slots from the master are missing. Logical replication clients cannot continue because they have no slot to connect to.

Easy, right? Just create a slot with the same name on the replica.

It’s not that simple. A logical replication slot can only be created with a view of the database history somewhere in the future relative to when it’s created. So if the client wasn’t totally up to date replaying from the slot on the old master, or if it doesn’t create a replacement slot on the new master as the very first thing done on the master, the client will miss out on changes. That’s what slots are meant to prevent and can be a critical problem for some applications.

The two key reasons a slot can’t be created "back in time" are WAL retention and – for logical slots – vacuuming of the system catalogs. We also can’t get a snapshot of the past to export, but that’s only a problem for new client setup. WAL retention is the simplest: the standby might throw away WAL segments corresponding to database changes that a logical decoding client on the master hasn’t yet replayed. If there’s a failover then there’s no way to ever replay those changes to that client. The other issue is catalogs – logical decoding needs the historical definition of tables, types, etc to interpret data in WAL, and to do that it does a sort of MVCC-based time travel using deleted rows. If VACUUM on the master removes those deleted rows and marks the space free for re-use then the standby will replay that change and we can’t make sense of what’s in WAL anymore.

Failover slots
Failover slots address these issues by synchronizing slot creation, deletion and position updates to replica servers. This is done through the WAL stream like everything else. If a slot is created as a failover slot using the new failover boolean option to pg_create_logical_replication_slot then its creation is logged in WAL. So are subsequent position updates when the client tells the server it can free no-longer-needed resources.

If the master fails and a standby is promoted, logical decoding clients can just reconnect to the standby and carry on as if nothing had happened. If a DNS update or IP swap is done along with the promotion the logical decoding client might not even notice it’s anything more than a master restart.

What about physical slots?
PostgreSQL’s block-level ("physical") replication also has replication slots. They can be used to pin WAL retention, providing a finer-grained mechanism than wal_keep_segments at the cost of also being unbounded.

A physical failover slot can be created, just like a logical failover slot.

Does this mean pglogical can be used to fail over to a logical replica?
Failover slots do not aid logical replication solutions in supporting failover to a logical replica. They exist to allow logical replication to follow a physical failover.

Supporting failover to a logical replica is a completely unrelated matter. There are a number of limitations in PostgreSQL core that are relevant to it, like the currently missing support for logical decoding of sequence position advances. Failover slots will neither help nor hinder there. What they do is provide a way to integrate logical replication into HA solutions now, into existing mature and established infrastructure patterns.