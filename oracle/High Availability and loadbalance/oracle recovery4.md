Parallel Recovery

Parallel recovery can speed up both instance recovery and media recovery. In parallel recovery, multiple parallel slave processes are used to perform recovery operations. The SMON background process reads the redo log files, and the parallel slave processes apply the changes to the datafiles. Parallel recovery is most beneficial when several datafiles on different disks are being recovered.
In a serial recovery scenario, the SMON background process both reads the redo log files and applies the changes to the datafiles. This may take a considerably long time when multiple datafiles need to be recovered. However, when parallel recovery is being used, the SMON process is responsible only for reading the redo log files. The changes are applied to the datafiles by multiple parallel slave processes, thereby reducing the recovery time.
Recovery requires that the changes be applied to the datafiles in exactly the same order in which they occurred. This is achieved by single-threading the read phase of the recovery process by the SMON process. SMON reads the redo log files and serializes the changes before dispatching them to the parallel slave processes. The parallel slave processes then apply those changes to the datafiles in the proper order. Therefore, the reading of the redo log files is performed serially even during a parallel recovery operation.
The RECOVERY_PARALLELISM initialization parameter controls the degree of parallelism to use for a recovery. You can override that setting for a specific situation by using the RECOVER command’s PARALLEL clause. Both options are described in the following sections.
Specifying the RECOVERY_PARALLELISM Parameter
The initialization parameter RECOVERY_PARALLELISM specifies the number of parallel slave processes to participate in a recovery process. It applies to both instance recovery and media recovery. A value of or 1 indicates serial recovery—no parallelism will be used. The RECOVERY_PARALLELISM parameter setting cannot exceed the PARALLEL_MAX_SERVERS setting.
Specifying the PARALLEL Clause
The PARALLEL clause can be used with the RECOVER command to parallelize media recovery. You use it to specify the degree or the number of parallel slave processes that will be used. The syntax for the PARALLEL clause is discussed in Section 4.3 of this chapter. You can use the PARALLEL clause with the RECOVER DATABASE, RECOVER TABLESPACE, and RECOVER DATAFILE commands. Here are some examples:
RECOVER DATABASE PARALLEL (DEGREE d INSTANCES DEFAULT);
RECOVER TABLESPACE tablespace_name PARALLEL (DEGREE d INSTANCES i);
RECOVER DATAFILE 'datafile_name' PARALLEL (DEGREE d);
RECOVER DATABASE PARALLEL (DEGREE DEFAULT);
When you specify DEFAULT for DEGREE, it takes a value equal to twice the number of datafiles being recovered. When you specify DEFAULT for INSTANCES, it takes the instance-level default value specified by the initialization parameter PARALLEL_DEFAULT_MAX_INSTANCES.
The specification in the PARALLEL clause used with the RECOVER command overrides any RECOVER_PARALLELISM parameter setting. If you’ve enabled parallel recovery by setting RECOVER_PARALLELISM, you can disable it for a specific recovery operation by using the RECOVER command’s NOPARALLEL clause. For example:
RECOVER DATABASE NOPARALLEL;
In this case, since you used the NOPARALLEL keyword, the recovery would be done serially.