# pg_各系统表的RelationId的认识

reference [Database Object Location Functions](https://www.postgresql.org/docs/12/functions-admin.html)

Name
Return Type
Description
pg_relation_filenode(relation regclass)
oid
Filenode number of the specified relation
pg_relation_filepath(relation regclass)
text
File path name of the specified relation
pg_filenode_relation(tablespace oid, filenode oid)
regclass
Find the relation associated with a given tablespace and filenode

```sql
postgres=# select pg_relation_filenode('pg_class');
pg_relation_filenode
----------------------
                 1259
(1 row)
postgres=# select pg_relation_filepath(1259);
pg_relation_filepath
----------------------
base/13212/1259
(1 row)
postgres=# select pg_filenode_relation(1259);
ERROR:  function pg_filenode_relation(integer) does not exist
LINE 1: select pg_filenode_relation(1259);
               ^
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
```
 
对PostgreSQL中 pg_各表的RelationId的认识
读取普通的table或者系统表，都会调用heap_open函数：
/* ----------------
*        heap_open - open a heap relation by relation OID
*
*        This is essentially relation_open plus check that the relation
*        is not an index nor a composite type.  (The caller should also
*        check that it's not a view or foreign table before assuming it has
*        storage.)
* ----------------
*/
Relation
heap_open(Oid relationId, LOCKMODE lockmode)
{
    //fprintf(stderr,"++++++++++++++++++++ In heap_open start by process %d....relationId is:%d\n",
getpid(),relationId);
    Relation    r;
    r = relation_open(relationId, lockmode);
    if (r->rd_rel->relkind == RELKIND_INDEX)
        ereport(ERROR,
                (errcode(ERRCODE_WRONG_OBJECT_TYPE),
                 errmsg("\"%s\" is an index",
                        RelationGetRelationName(r))));
    else if (r->rd_rel->relkind == RELKIND_COMPOSITE_TYPE)
        ereport(ERROR,
                (errcode(ERRCODE_WRONG_OBJECT_TYPE),
                 errmsg("\"%s\" is a composite type",
                        RelationGetRelationName(r))));
    //fprintf(stderr,"++++++++++++++++++++ In heap_open end by process %d\n\n",getpid());
    return r;
}

对于普通表而言，RelationId就是在base目录下的某个子目录里面的文件名。
但是对于系统表而言，则不同。
比如 pg_tablespace 的RelationId为 1213（这已经写死在PostgreSQL源代码中），
但是其对应的文件的名称为 12587（对应global/12587文件）。
经过一番测试，发现其对应关系如下：


 pg_default_acl
826
pg_pltemplate
1136
pg_tablespace
1213
pg_shdepend
1214
pg_type
1247
pg_attribute
1249
pg_proc
1255
pg_class
1259
pg_authid
1260
pg_auth_members
1261
pg_database 
1262
pg_foreign_server
1417
pg_user_mapping
1418
pg_foreign_data_wrapper
2328
pg_shdescription
2396
pg_aggregate
2600
pg_am
2601
pg_amop
2602
pg_ampro
2603
pg_attrdef
2604
pg_cast
2605
pg_constraint
2606
pg_conversion
2607
pg_depend
2608
pg_description
2609
pg_index
2610
pg_inherits
2611
pg_language
2612
pg_largeobject
2613
pg_namespace
2615
pg_opclass
2616
pg_operator
2617
pg_rewrite
2618
pg_stastic
2619
pg_trigger
2620
pg_opfamily
2753
pg_db_role_setting
2964
pg_largeobject_metadata
2995
pg_extension
3079
pg_foreign_table
3118
pg_collation
3456
pg_enum
3501
pg_seclabel
3596
pg_ts_dict
3600
pg_ts_parser
3601
pg_ts_config
3602
pg_ts_config_map
3603
pg_ts_template
3764

然后，我还可以进一步，观察 ，把上述表格补充完整：
/* ----------------
*        relation_open - open any relation by relation OID
*
*        If lockmode is not "NoLock", the specified kind of lock is
*        obtained on the relation.  (Generally, NoLock should only be
*        used if the caller knows it has some appropriate lock on the
*        relation already.)
*
*        An error is raised if the relation does not exist.
*
*        NB: a "relation" is anything with a pg_class entry.  The caller is
*        expected to check whether the relkind is something it can handle.
* ----------------
*/
Relation
relation_open(Oid relationId, LOCKMODE lockmode)
{
    fprintf(stderr,"___________________ In relation_open start by process %d\n",getpid());
    Relation    r;
    Assert(lockmode >= NoLock && lockmode < MAX_LOCKMODES);
    /* Get the lock before trying to open the relcache entry */
    if (lockmode != NoLock)
        LockRelationOid(relationId, lockmode);
    /* The relcache does all the real work... */
    r = RelationIdGetRelation(relationId);
    fprintf(stderr,"In relation_open ,the relNode is:%d....\n\n",r->rd_node.relNode);
    if (!RelationIsValid(r))
        elog(ERROR, "could not open relation with OID %u", relationId);
    /* Make note that we've accessed a temporary relation */
    if (RelationUsesLocalBuffers(r))
        MyXactAccessedTempRel = true;
    pgstat_initstats(r);
    fprintf(stderr,"___________________ In relation_open end by process %d\n",getpid());
    return r;
}
加入了调试代码后，我可以看到，pg_tablespace 的 RelationId是 1213，而它的对应文件名是 12587。
下面，补充完整：


system table name
RelationId
FileName
pg_default_acl
826
12642
pg_pltemplate
1136
12591
pg_tablespace
1213
12587
pg_shdepend
1214
12598
pg_type
1247
12442
pg_attribute
1249
12446
pg_proc
1255
12458
pg_class
1259
12465
pg_authid
1260
12450
pg_auth_members
1261
12594
pg_database 
1262
12692
pg_foreign_server
1417
12635
pg_user_mapping
1418
12454
pg_foreign_data_wrapper
2328
12631
pg_shdescription
2396
12602
pg_aggregate
2600
12525
pg_am
2601
12505
pg_amop
2602
12509
pg_ampro
2603
12514
pg_attrdef
2604
12469
pg_cast
2605
12549
pg_constraint
2606
12476
pg_conversion
2607
12562
pg_depend
2608
12567
pg_description
2609
12543
pg_index
2610
12489
pg_inherits
2611
12485
pg_language
2612
12518
pg_largeobject
2613
12571
pg_namespace
2615
12558
pg_opclass
2616
12501
pg_operator
2617
12493
pg_rewrite
2618
12528
pg_stastic
2619
12436
pg_trigger
2620
12535
pg_opfamily
2753
12497
pg_db_role_setting
2964
12581
pg_largeobject_metadata
2995
12522
pg_extension
3079
12627
pg_foreign_table
3118
12639
pg_collation
3456
12652
pg_enum
3501
12553
pg_seclabel
3596
12646
pg_ts_dict
3600
12615
pg_ts_parser
3601
12619
pg_ts_config
3602
12608
pg_ts_config_map
3603
12612
pg_ts_template
3764
12623

如果进一步查看，还可以发现：
只有如下几个系统表的对应文件位于 global目录，其余的系统表的对应文件则是base目录下的每个子目录中都有（一个子目录对应一个数据库）：


system table name
RelationId
FileName
pg_pltemplate
1136
12591
pg_tablespace
1213
12587
pg_shdepend
1214
12598
pg_authid
1260
12450
pg_auth_members
1261
12594
pg_database 
1262
12692
pg_shdescription
2396
12602
pg_db_role_setting
2964
12581

来自 <http://www.cnblogs.com/gaojian/p/3169560.html>