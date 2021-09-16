benchmarksql

下载地址：http://sourceforge.net/projects/benchmarksql/?source=navbar
 
解压缩
[highgo@rsbdb benchmarksql-5.0]$ ls -atl
总用量 28
drwxrwxr-x 7 highgo highgo 4096 12月  9 15:22 ru
n
drwxr-xr-x 3 highgo highgo   30 12月  9 15:17 ..
drwxrwxr-x 6 highgo highgo  124 5月  26 2016 .
-rwxr-xr-x 1 highgo highgo 1130 5月  26 2016 build.xml
drwxrwxr-x 3 highgo highgo   17 5月  26 2016 doc
-rw-rw-r-- 1 highgo highgo   11 5月  26 2016 .gitignore
-rwxr-xr-x 1 highgo highgo 6376 5月  26 2016 HOW-TO-RUN.txt
drwxrwxr-x 5 highgo highgo  129 5月  26 2016 lib
-rwxr-xr-x 1 highgo highgo 5318 5月  26 2016 README.md
drwxrwxr-x 6 highgo highgo   67 5月  26 2016 src
[highgo@rsbdb benchmarksql-5.0]$
 
$ cat HOW-TO-RUN.txt
 
Instructions for running BenchmarkSQL on PostgreSQL
---------------------------------------------------
 
0. Requirements
 
    Use of JDK7 is required.
 
eg：
tar -xzvf jdk-8u231-linux-x64.tar.gz
 
cat .bash_profile
# java config
export JAVA_HOME=/opt/jdk1.8.0_231
export PATH=$JAVA_HOME/bin:$PATH:$PGHOME/bin
 
注意：$JAVA_HOME/bin要在$PATH，否则，总是使用系统自带的java
 
1. Create the benchmarksql user and a database
 
    As Unix user postgres use the psql shell to connect to the postgres
    database and issue the CREATE USER and CREATE DATABASE commands.
 
    [postgres#localhost ~] $ psql postgres
    psql (9.5.2)
    Type "help" for help.
 
    postgres=# CREATE USER benchmarksql WITH ENCRYPTED PASSWORD 'changeme';
    postgres=# CREATE DATABASE benchmarksql OWNER benchmarksql;
    postgres=# \q
    [postgres#localhost ~] $
 
 
eg：
create user bms password 'bms';
create database bms owner bms encoding='UTF-8';
create schema bms authorization bms;
\c bms bms
bms=> show search_path;
   search_path  
-----------------
 "$user", public
(1 row)
 
2. Compile the BenchmarkSQL source code
 
    As your own UNIX user change into the toplevel directory of the
    benchmarksql git repository checkout or the directory that was
    created by unpacking the release tarball/zipfile. Use the ant
    command to compile the code.
 
    [wieck@localhost ~] $ cd benchmarksql
    [wieck@localhost benchmarksql] $ ant
    Buildfile: /nas1/home/wieck/benchmarksql.git/build.xml
 
    init:
        [mkdir] Created dir: /home/wieck/benchmarksql/build
 
    compile:
[javac] Compiling 11 source files to /home/wieck/benchmarksql/build
 
    dist:
[mkdir] Created dir: /home/wieck/benchmarksql/dist
  [jar] Building jar: /home/wieck/benchmarksql/dist/BenchmarkSQL-5.0.jar
    BUILD SUCCESSFUL
    Total time: 1 second
    [wieck@localhost benchmarksql] $
 
Eg:
yum install ant
 
本地yum源即可
 
[highgo@rsbdb benchmarksql-5.0]$ pwd
/opt/benchmarksql/benchmarksql-5.0
 
[highgo@rsbdb benchmarksql-5.0]$ ant
Buildfile: /opt/benchmarksql/benchmarksql-5.0/build.xml
 
init:
    [mkdir] Created dir: /opt/benchmarksql/benchmarksql-5.0/build
 
compile:
    [javac] Compiling 11 source files to /opt/benchmarksql/benchmarksql-5.0/build
 
dist:
    [mkdir] Created dir: /opt/benchmarksql/benchmarksql-5.0/dist
      [jar] Building jar: /opt/benchmarksql/benchmarksql-5.0/dist/BenchmarkSQL-5.0.jar
 
BUILD SUCCESSFUL
Total time: 5 seconds
[highgo@rsbdb benchmarksql-5.0]$
 
[highgo@rsbdb benchmarksql-5.0]$ ls -atl
总用量 32
drwxrwxr-x 2 highgo highgo   34 12月  9 17:00 dist
drwxrwxr-x 8 highgo highgo  149 12月  9 17:00 .
drwxrwxr-x 2 highgo highgo 4096 12月  9 17:00 build
drwxrwxr-x 7 highgo highgo 4096 12月  9 15:22 run
drwxr-xr-x 3 highgo highgo   30 12月  9 15:17 ..
-rwxr-xr-x 1 highgo highgo 1130 5月  26 2016 build.xml
drwxrwxr-x 3 highgo highgo   17 5月  26 2016 doc
-rw-rw-r-- 1 highgo highgo   11 5月  26 2016 .gitignore
-rwxr-xr-x 1 highgo highgo 6376 5月  26 2016 HOW-TO-RUN.txt
drwxrwxr-x 5 highgo highgo  129 5月  26 2016 lib
-rwxr-xr-x 1 highgo highgo 5318 5月  26 2016 README.md
drwxrwxr-x 6 highgo highgo   67 5月  26 2016 src
[highgo@rsbdb benchmarksql-5.0]$
 
 
3. Create the benchmark configuration file
 
    Change the the run directory, copy the props.pg file and edit
    the copy to match your system setup and desired scaling.
 
    [wieck@localhost benchmarksql] $ cd run
    [wieck@localhost run] $ cp props.pg my_postgres.properties
    [wieck@localhost run] $ vi my_postgres.properties
    [wieck@localhost run] $
 
    Note that the provided example configuration is meant to test
    the functionality of your setupr. That benchmarksql can connect
    to the database and execute transactions. That configuration
    is NOT a benchmark run. To make it into one you need to have a
    configuration that matches your database server size and
    workload. Leave the sizing for now and perform a first functional
    test.
 
    The BenchmarkSQL database has an initial size of approximately
    100-100MB per configured warehouse. A typical setup would be
    a database of 2-5 times the physical RAM of the server.
 
    Likewise the number of concurrent database connections (config
    parameter terminals) should be something about 2-6 times the
    number of CPU threads.
 
    Last but not least benchmark runs are normally done for hours,
    if not days. This is because on the database sizes above it
    will take that long to reach a steady state and make sure that
    all performance relevant functionality of the database, like
    checkpointing and vacuuming, is included in the measurement.
 
    So you can see that with a modern server, that has 32-256 CPU
    threads and 64-512GBi, of RAM we are talking about thousands of
    warehouses and hundreds of concurrent database connections.
 
eg:
cd run
cp props.pg props_my.pg
vi props_my.pg
 
db=postgres
driver=org.postgresql.Driver
conn=jdbc:postgresql://localhost:5866/bms
user=bms
password=bms
 
warehouses=50
loadWorkers=4
 
terminals=6
//To run specified transactions per terminal- runMins must equal zero
runTxnsPerTerminal=0
//To run for specified minutes- runTxnsPerTerminal must equal zero
runMins=10
//Number of total transactions per minute
limitTxnsPerMin=0
 
配置文件重要参数如下：
        1）warehouse：
            BenchmarkSQL数据库每个warehouse大小大概是100MB，如果该参数设置为10，那整个数据库的大小大概在1000MB。建议将数据库的大小设置为服务器物理内存的2-5倍，如果服务器内存为16GB，那么warehouse设置建议在328～819之间。
        2）terminals：
            terminals指的是并发连接数，建议设置为服务器CPU总线程数的2-6倍。如果服务器为双核16线程（单核8线程），那么建议配置在32～96之间。
 
4.配置文件详解：
    db=postgres    //数据库类型，postgres代表我们对PG数据库进行测试，不需要更改
    driver=org.postgresql.Driver    //驱动，不需要更改
    conn=jdbc:postgresql://localhost:5432/postgres     //PG数据库连接字符串，正常情况下，需要更改localhost为对应PG服务IP、5432位对应PG服务端口、postgres为对应测试数据库名
    user=benchmarksql    //数据库用户名，通常建议用默认，这就需要我们提前在数据库中建立benchmarksql用户
    password=PWbmsql    //如上用户密码
    warehouses=1    //仓库数量，数量根据实际服务器内存配置，配置方法见第3步
    loadWorkers=4    //用于在数据库中初始化数据的加载进程数量，默认为4，实际使用过程中可以根据实际情况调整，加载速度会随worker数量的增加而有所提升
    terminals=1    //终端数，即并发客户端数量，通常设置为CPU线程总数的2～6倍
       runTxnsPerTerminal=10 //每个终端（terminal）运行的固定事务数量，例如：如果该值设置为10，意味着每个terminal运行10个事务，如果有32个终端，那整体运行320个事务后，测试结束。该参数配置为非0值时，下面的runMins参数必须设置为0
        runMins=0//要测试的整体时间，单位为分钟，如果runMins设置为60，那么测试持续1小时候结束。该值设置为非0值时，runTxnsPerTerminal参数必须设置为0。这两个参数不能同时设置为正整数，如果设置其中一个，另一个必须为0，主要区别是runMins定义时间长度来控制测试时间；runTxnsPerTerminal定义事务总数来控制时间。
    limitTxnsPerMin=0//每分钟事务总数限制，该参数主要控制每分钟处理的事务数，事务数受terminals参数的影响，如果terminals数量大于limitTxnsPerMin值，意味着并发数大于每分钟事务总数，该参数会失效，想想也是如此，如果有1000个并发同时发起，那每分钟事务数设置为300就没意义了，上来就是1000个并发，所以要让该参数有效，可以设置数量大于并发数，或者让其失效，测试过程中目前采用的是默认300。
    //测试过程中的整体逻辑通过一个例子来说明：假如limitTxnsPerMin参数使用默认300，termnals终端数量设置为150并发，实际会计算一个值A=limitTxnsPerMin/terminals=2（此处需要注意，A为int类型，如果terminals的值大于limitTxnsPerMin，得到的A值必然为0，为0时该参数失效），此处记住A=2；接下来，在整个测试运行过程中，软件会记录一个事务的开始时间和结束时间，假设为B=2000毫秒；然后用60000（毫秒，代表1分钟）除以A得到一个值C=60000/2=30000，假如事务运行时间B<C，那么该事务执行完后，sleep C-B秒再开启下一个事务；假如B>C，意味着事务超过了预期时间，那么马上进行下一个事务。在本例子中，每分钟300个事务，设置了150个并发，每分钟执行2个并发，每个并发执行2秒钟完成，每个并发sleep 28秒，这样可以保证一分钟有两个并发，反推回来整体并发数为300/分钟。
 
    terminalWarehouseFixed=true//终端和仓库的绑定模式，设置为true时可以运行4.x兼容模式，意思为每个终端都有一个固定的仓库。设置为false时可以均匀的使用数据库整体配置。TPCC规定每个终端都必须有一个绑定的仓库，所以一般使用默认值true。
  
  //下面五个值的总和必须等于100，默认值为：45, 43, 4, 4 & 4 ，与TPC-C测试定义的比例一致，实际操作过程中，可以调整比重来适应各种场景。
    newOrderWeight=45
    paymentWeight=43
    orderStatusWeight=4
    deliveryWeight=4
    stockLevelWeight=4
    //测试数据生成目录，默认无需修改，默认生成在run目录下面，名字形如my_result_xxxx的文件夹。
    resultDirectory=my_result_%tY-%tm-%td_%tH%tM%tS
    //操作系统性能收集脚本，默认无需修改，需要操作系统具备有python环境
    osCollectorScript=./misc/os_collector_linux.py
    //操作系统收集操作间隔，默认为1秒
    osCollectorInterval=1
    //操作系统收集所对应的主机，如果对本机数据库进行测试，该参数保持注销即可，如果要对远程服务器进行测试，请填写用户名和主机名。
    //osCollectorSSHAddr=user@dbhost
    //操作系统中被收集服务器的网卡名称和磁盘名称，例如：使用ifconfig查看操作系统网卡名称，找到测试所走的网卡，名称为enp1s0f0，那么下面网卡名设置为net_enp1s0f0（net_前缀固定）；使用df -h查看数据库数据目录，名称为（/dev/sdb                33T   18T   16T   54% /hgdata），那么下面磁盘名设置为blk_sdb（blk_前缀固定）
    osCollectorDevices=net_eth0 blk_sda
 
 
 
4. Build the schema and initial database load
 
    Execute the runDatabaseBuild.sh script with your configuration file.
 
    [wieck@localhost run]$ ./runDatabaseBuild.sh my_postgres.properties
    # ------------------------------------------------------------
    # Loading SQL file ./sql.common/tableCreates.sql
    # ------------------------------------------------------------
    create table bmsql_config (
    cfg_name    varchar(30) primary key,
    cfg_value   varchar(50)
    );
    create table bmsql_warehouse (
    w_id        integer   not null,
    w_ytd       decimal(12,2),
    [...]
    Starting BenchmarkSQL LoadData
 
    driver=org.postgresql.Driver
    conn=jdbc:postgresql://localhost:5432/benchmarksql
    user=benchmarksql
    password=***********
    warehouses=30
    loadWorkers=10
    fileLocation (not defined)
    csvNullValue (not defined - using default 'NULL')
 
    Worker 000: Loading ITEM
    Worker 001: Loading Warehouse      1
    Worker 002: Loading Warehouse      2
    Worker 003: Loading Warehouse      3
    [...]
    Worker 000: Loading Warehouse     30 done
    Worker 008: Loading Warehouse     29 done
    # ------------------------------------------------------------
    # Loading SQL file ./sql.common/indexCreates.sql
    # ------------------------------------------------------------
    alter table bmsql_warehouse add constraint bmsql_warehouse_pkey
    primary key (w_id);
    alter table bmsql_district add constraint bmsql_district_pkey
    primary key (d_w_id, d_id);
    [...]
    vacuum analyze;
    [wieck@localhost run]$
 
eg:
[highgo@rsbdb run]$ ./runDatabaseBuild.sh props_my.pg
# ------------------------------------------------------------
# Loading SQL file ./sql.common/tableCreates.sql
# ------------------------------------------------------------
create table bmsql_config (
cfg_name    varchar(30) primary key,
cfg_value   varchar(50)
);
create table bmsql_warehouse (
w_id        integer   not null,
w_ytd       decimal(12,2),
w_tax       decimal(4,4),
w_name      varchar(10),
w_street_1  varchar(20),
w_street_2  varchar(20),
w_city      varchar(20),
w_state     char(2),
w_zip       char(9)
);
create table bmsql_district (
d_w_id       integer       not null,
d_id         integer       not null,
d_ytd        decimal(12,2),
d_tax        decimal(4,4),
d_next_o_id  integer,
d_name       varchar(10),
d_street_1   varchar(20),
d_street_2   varchar(20),
d_city       varchar(20),
d_state      char(2),
d_zip        char(9)
);
create table bmsql_customer (
c_w_id         integer        not null,
c_d_id         integer        not null,
c_id           integer        not null,
c_discount     decimal(4,4),
c_credit       char(2),
c_last         varchar(16),
c_first        varchar(16),
c_credit_lim   decimal(12,2),
c_balance      decimal(12,2),
c_ytd_payment  decimal(12,2),
c_payment_cnt  integer,
c_delivery_cnt integer,
c_street_1     varchar(20),
c_street_2     varchar(20),
c_city         varchar(20),
c_state        char(2),
c_zip          char(9),
c_phone        char(16),
c_since        timestamp,
c_middle       char(2),
c_data         varchar(500)
);
create sequence bmsql_hist_id_seq;
create table bmsql_history (
hist_id  integer,
h_c_id   integer,
h_c_d_id integer,
h_c_w_id integer,
h_d_id   integer,
h_w_id   integer,
h_date   timestamp,
h_amount decimal(6,2),
h_data   varchar(24)
);
create table bmsql_new_order (
no_w_id  integer   not null,
no_d_id  integer   not null,
no_o_id  integer   not null
);
create table bmsql_oorder (
o_w_id       integer      not null,
o_d_id       integer      not null,
o_id         integer      not null,
o_c_id       integer,
o_carrier_id integer,
o_ol_cnt     integer,
o_all_local  integer,
o_entry_d    timestamp
);
create table bmsql_order_line (
ol_w_id         integer   not null,
ol_d_id         integer   not null,
ol_o_id         integer   not null,
ol_number       integer   not null,
ol_i_id         integer   not null,
ol_delivery_d   timestamp,
ol_amount       decimal(6,2),
ol_supply_w_id  integer,
ol_quantity     integer,
ol_dist_info    char(24)
);
create table bmsql_item (
i_id     integer      not null,
i_name   varchar(24),
i_price  decimal(5,2),
i_data   varchar(50),
i_im_id  integer
);
create table bmsql_stock (
s_w_id       integer       not null,
s_i_id       integer       not null,
s_quantity   integer,
s_ytd        integer,
s_order_cnt  integer,
s_remote_cnt integer,
s_data       varchar(50),
s_dist_01    char(24),
s_dist_02    char(24),
s_dist_03    char(24),
s_dist_04    char(24),
s_dist_05    char(24),
s_dist_06    char(24),
s_dist_07    char(24),
s_dist_08    char(24),
s_dist_09    char(24),
s_dist_10    char(24)
);
Starting BenchmarkSQL LoadData
 
driver=org.postgresql.Driver
conn=jdbc:postgresql://localhost:5866/bms
user=bms
password=***********
warehouses=50
loadWorkers=4
fileLocation (not defined)
csvNullValue (not defined - using default 'NULL')
 
Worker 000: Loading ITEM
Worker 001: Loading Warehouse      1
Worker 002: Loading Warehouse      2
Worker 003: Loading Warehouse      3
Worker 000: Loading ITEM done
Worker 000: Loading Warehouse      4
Worker 003: Loading Warehouse      3 done
Worker 003: Loading Warehouse      5
Worker 001: Loading Warehouse      1 done
Worker 001: Loading Warehouse      6
Worker 002: Loading Warehouse      2 done
Worker 002: Loading Warehouse      7
Worker 000: Loading Warehouse      4 done
Worker 000: Loading Warehouse      8
Worker 001: Loading Warehouse      6 done
Worker 001: Loading Warehouse      9
Worker 003: Loading Warehouse      5 done
Worker 003: Loading Warehouse     10
Worker 002: Loading Warehouse      7 done
Worker 002: Loading Warehouse     11
Worker 000: Loading Warehouse      8 done
Worker 000: Loading Warehouse     12
Worker 001: Loading Warehouse      9 done
Worker 001: Loading Warehouse     13
Worker 003: Loading Warehouse     10 done
Worker 003: Loading Warehouse     14
Worker 002: Loading Warehouse     11 done
Worker 002: Loading Warehouse     15
Worker 000: Loading Warehouse     12 done
Worker 000: Loading Warehouse     16
Worker 001: Loading Warehouse     13 done
Worker 001: Loading Warehouse     17
Worker 003: Loading Warehouse     14 done
Worker 003: Loading Warehouse     18
Worker 002: Loading Warehouse     15 done
Worker 002: Loading Warehouse     19
Worker 000: Loading Warehouse     16 done
Worker 000: Loading Warehouse     20
Worker 003: Loading Warehouse     18 done
Worker 003: Loading Warehouse     21
Worker 001: Loading Warehouse     17 done
Worker 001: Loading Warehouse     22
Worker 002: Loading Warehouse     19 done
Worker 002: Loading Warehouse     23
Worker 000: Loading Warehouse     20 done
Worker 000: Loading Warehouse     24
Worker 003: Loading Warehouse     21 done
Worker 003: Loading Warehouse     25
Worker 002: Loading Warehouse     23 done
Worker 002: Loading Warehouse     26
Worker 001: Loading Warehouse     22 done
Worker 001: Loading Warehouse     27
Worker 000: Loading Warehouse     24 done
Worker 000: Loading Warehouse     28
Worker 003: Loading Warehouse     25 done
Worker 003: Loading Warehouse     29
Worker 002: Loading Warehouse     26 done
Worker 002: Loading Warehouse     30
Worker 001: Loading Warehouse     27 done
Worker 001: Loading Warehouse     31
Worker 000: Loading Warehouse     28 done
Worker 000: Loading Warehouse     32
Worker 003: Loading Warehouse     29 done
Worker 003: Loading Warehouse     33
Worker 002: Loading Warehouse     30 done
Worker 002: Loading Warehouse     34
Worker 001: Loading Warehouse     31 done
Worker 001: Loading Warehouse     35
Worker 000: Loading Warehouse     32 done
Worker 000: Loading Warehouse     36
Worker 002: Loading Warehouse     34 done
Worker 002: Loading Warehouse     37
Worker 003: Loading Warehouse     33 done
Worker 003: Loading Warehouse     38
Worker 001: Loading Warehouse     35 done
Worker 001: Loading Warehouse     39
Worker 000: Loading Warehouse     36 done
Worker 000: Loading Warehouse     40
Worker 002: Loading Warehouse     37 done
Worker 002: Loading Warehouse     41
Worker 003: Loading Warehouse     38 done
Worker 003: Loading Warehouse     42
Worker 001: Loading Warehouse     39 done
Worker 001: Loading Warehouse     43
Worker 000: Loading Warehouse     40 done
Worker 000: Loading Warehouse     44
Worker 002: Loading Warehouse     41 done
Worker 002: Loading Warehouse     45
Worker 003: Loading Warehouse     42 done
Worker 003: Loading Warehouse     46
Worker 001: Loading Warehouse     43 done
Worker 001: Loading Warehouse     47
Worker 000: Loading Warehouse     44 done
Worker 000: Loading Warehouse     48
Worker 002: Loading Warehouse     45 done
Worker 002: Loading Warehouse     49
Worker 003: Loading Warehouse     46 done
Worker 003: Loading Warehouse     50
Worker 001: Loading Warehouse     47 done
Worker 000: Loading Warehouse     48 done
Worker 002: Loading Warehouse     49 done
Worker 003: Loading Warehouse     50 done
# ------------------------------------------------------------
# Loading SQL file ./sql.common/indexCreates.sql
# ------------------------------------------------------------
alter table bmsql_warehouse add constraint bmsql_warehouse_pkey
primary key (w_id);
alter table bmsql_district add constraint bmsql_district_pkey
primary key (d_w_id, d_id);
alter table bmsql_customer add constraint bmsql_customer_pkey
primary key (c_w_id, c_d_id, c_id);
create index bmsql_customer_idx1
on  bmsql_customer (c_w_id, c_d_id, c_last, c_first);
alter table bmsql_oorder add constraint bmsql_oorder_pkey
primary key (o_w_id, o_d_id, o_id);
create unique index bmsql_oorder_idx1
on  bmsql_oorder (o_w_id, o_d_id, o_carrier_id, o_id);
alter table bmsql_new_order add constraint bmsql_new_order_pkey
primary key (no_w_id, no_d_id, no_o_id);
alter table bmsql_order_line add constraint bmsql_order_line_pkey
primary key (ol_w_id, ol_d_id, ol_o_id, ol_number);
alter table bmsql_stock add constraint bmsql_stock_pkey
primary key (s_w_id, s_i_id);
alter table bmsql_item add constraint bmsql_item_pkey
primary key (i_id);
# ------------------------------------------------------------
# Loading SQL file ./sql.common/foreignKeys.sql
# ------------------------------------------------------------
alter table bmsql_district add constraint d_warehouse_fkey
foreign key (d_w_id)
references bmsql_warehouse (w_id);
alter table bmsql_customer add constraint c_district_fkey
foreign key (c_w_id, c_d_id)
references bmsql_district (d_w_id, d_id);
alter table bmsql_history add constraint h_customer_fkey
foreign key (h_c_w_id, h_c_d_id, h_c_id)
references bmsql_customer (c_w_id, c_d_id, c_id);
alter table bmsql_history add constraint h_district_fkey
foreign key (h_w_id, h_d_id)
references bmsql_district (d_w_id, d_id);
alter table bmsql_new_order add constraint no_order_fkey
foreign key (no_w_id, no_d_id, no_o_id)
references bmsql_oorder (o_w_id, o_d_id, o_id);
alter table bmsql_oorder add constraint o_customer_fkey
foreign key (o_w_id, o_d_id, o_c_id)
references bmsql_customer (c_w_id, c_d_id, c_id);
alter table bmsql_order_line add constraint ol_order_fkey
foreign key (ol_w_id, ol_d_id, ol_o_id)
references bmsql_oorder (o_w_id, o_d_id, o_id);
alter table bmsql_order_line add constraint ol_stock_fkey
foreign key (ol_supply_w_id, ol_i_id)
references bmsql_stock (s_w_id, s_i_id);
alter table bmsql_stock add constraint s_warehouse_fkey
foreign key (s_w_id)
references bmsql_warehouse (w_id);
alter table bmsql_stock add constraint s_item_fkey
foreign key (s_i_id)
references bmsql_item (i_id);
# ------------------------------------------------------------
# Loading SQL file ./sql.postgres/extraHistID.sql
# ------------------------------------------------------------
-- ----
-- Extra Schema objects/definitions for history.hist_id in PostgreSQL
-- ----
-- ----
--      This is an extra column not present in the TPC-C
--      specs. It is useful for replication systems like
--      Bucardo and Slony-I, which like to have a primary
--      key on a table. It is an auto-increment or serial
--      column type. The definition below is compatible
--      with Oracle 11g, using a sequence and a trigger.
-- ----
-- Adjust the sequence above the current max(hist_id)
select setval('bmsql_hist_id_seq', (select max(hist_id) from bmsql_history));
-- Make nextval(seq) the default value of the hist_id column.
alter table bmsql_history
alter column hist_id set default nextval('bmsql_hist_id_seq');
-- Add a primary key history(hist_id)
alter table bmsql_history add primary key (hist_id);
# ------------------------------------------------------------
# Loading SQL file ./sql.postgres/buildFinish.sql
# ------------------------------------------------------------
-- ----
-- Extra commands to run after the tables are created, loaded,
-- indexes built and extra's created.
-- PostgreSQL version.
-- ----
vacuum analyze;
[highgo@rsbdb run]$
 
 
or

创建表结构

$ cd ~/benchmarksql-5.0/run   
$ ./runSQL.sh ./props_my.pg ./sql.common/tableCreates.sql  

生成测试数据

$ mkdir /data/benchmarksql-csv    
$ pwd
/opt/benchmarksql/benchmarksql-5.0/run
$ ./runLoader.sh props_my.pg fileLocation /data/benchmarksql-csv/
$ ls -l /data/benchmarksql-csv 


导入数据
$ cd ~/benchmarksql-5.0/run
$ ln -s /data/benchmarksql-csv /tmp/csv
$ ./runSQL.sh ./props_my.pg ./sql.postgres/tableCopies.sql  
$ ./runSQL.sh ./props_my.pg ./sql.common/indexCreates.sql  
$ ./runSQL.sh ./props_my.pg ./sql.common/foreignKeys.sql

tableCopies.sql 是从/tmp/csv 导入数据的，所以要 ln -s
提示：可以运行 ./runDatabaseBuild.sh ./props.pg 一步完成 创建表、生成测试数据、导入数据。

5. Run the configured benchmark
 
    [wieck@localhost run]$ ./runBenchmark.sh my_postgres.properties
 
    The benchmark should run for the number of configured concurrent
    connections (terminals) and the duration or number of transactions.
 
    The end result of the benchmark will be reported like this:
 
    01:58:09,081 [Thread-1] INFO   jTPCC : Term-00,
    01:58:09,082 [Thread-1] INFO   jTPCC : Term-00, Measured tpmC (NewOrders) = 179.55
    01:58:09,082 [Thread-1] INFO   jTPCC : Term-00, Measured tpmTOTAL = 329.17
    01:58:09,082 [Thread-1] INFO   jTPCC : Term-00, Session Start     = 2016-05-25 01:58:07
    01:58:09,082 [Thread-1] INFO   jTPCC : Term-00, Session End       = 2016-05-25 01:58:09
    01:58:09,082 [Thread-1] INFO   jTPCC : Term-00, Transaction Count = 10
 
    At this point you have a working setup.
 
eg:
[highgo@rsbdb run]$ ./runBenchmark.sh props_my.pg
13:33:26,411 [main] INFO   jTPCC : Term-00,
13:33:26,418 [main] INFO   jTPCC : Term-00, +-------------------------------------------------------------+
13:33:26,418 [main] INFO   jTPCC : Term-00,      BenchmarkSQL v5.0
13:33:26,418 [main] INFO   jTPCC : Term-00, +-------------------------------------------------------------+
13:33:26,418 [main] INFO   jTPCC : Term-00,  (c) 2003, Raul Barbosa
13:33:26,419 [main] INFO   jTPCC : Term-00,  (c) 2004-2016, Denis Lussier
13:33:26,430 [main] INFO   jTPCC : Term-00,  (c) 2016, Jan Wieck
13:33:26,430 [main] INFO   jTPCC : Term-00, +-------------------------------------------------------------+
13:33:26,431 [main] INFO   jTPCC : Term-00,
13:33:26,431 [main] INFO   jTPCC : Term-00, db=postgres
13:33:26,431 [main] INFO   jTPCC : Term-00, driver=org.postgresql.Driver
13:33:26,431 [main] INFO   jTPCC : Term-00, conn=jdbc:postgresql://localhost:5866/bms
13:33:26,431 [main] INFO   jTPCC : Term-00, user=bms
13:33:26,431 [main] INFO   jTPCC : Term-00,
13:33:26,432 [main] INFO   jTPCC : Term-00, warehouses=50
13:33:26,432 [main] INFO   jTPCC : Term-00, terminals=6
13:33:26,434 [main] INFO   jTPCC : Term-00, runMins=10
13:33:26,434 [main] INFO   jTPCC : Term-00, limitTxnsPerMin=300
13:33:26,435 [main] INFO   jTPCC : Term-00, terminalWarehouseFixed=true
13:33:26,435 [main] INFO   jTPCC : Term-00,
13:33:26,435 [main] INFO   jTPCC : Term-00, newOrderWeight=45
13:33:26,435 [main] INFO   jTPCC : Term-00, paymentWeight=43
13:33:26,435 [main] INFO   jTPCC : Term-00, orderStatusWeight=4
13:33:26,435 [main] INFO   jTPCC : Term-00, deliveryWeight=4
13:33:26,435 [main] INFO   jTPCC : Term-00, stockLevelWeight=4
13:33:26,436 [main] INFO   jTPCC : Term-00,
13:33:26,436 [main] INFO   jTPCC : Term-00, resultDirectory=my_result_%tY-%tm-%td_%tH%tM%tS
13:33:26,436 [main] INFO   jTPCC : Term-00, osCollectorScript=./misc/os_collector_linux.py
13:33:26,436 [main] INFO   jTPCC : Term-00,
13:33:26,531 [main] INFO   jTPCC : Term-00, copied props_my.pg to my_result_2019-12-10_133326/run.properties
13:33:26,532 [main] INFO   jTPCC : Term-00, created my_result_2019-12-10_133326/data/runInfo.csv for runID 1
13:33:26,533 [main] INFO   jTPCC : Term-00, writing per transaction results to my_result_2019-12-10_133326/data/result.csv
13:33:26,535 [main] INFO   jTPCC : Term-00, osCollectorScript=./misc/os_collector_linux.py
13:33:26,535 [main] INFO   jTPCC : Term-00, osCollectorInterval=1
13:33:26,536 [main] INFO   jTPCC : Term-00, osCollectorSSHAddr=null
13:33:26,536 [main] INFO   jTPCC : Term-00, osCollectorDevices=net_eth0 blk_sda
13:33:27,175 [main] INFO   jTPCC : Term-00,
13:33:27,770 [main] INFO   jTPCC : Term-00, C value for C_LAST during load: 212
13:33:27,771 [main] INFO   jTPCC : Term-00, C value for C_LAST this run:    131
13:33:27,771 [main] INFO   jTPCC : Term-00,                                                                                                                               Traceback (most recent call last):: 0.00    Current tpmTOTAL: 0    Memory Usage: 5MB / 15MB         
  File "<stdin>", line 299, in <module>
  File "<stdin>", line 90, in main                                                  Term-00, Running Average tpmTOTAL: 300.02    Current tpmTOTAL: 19860    Memory Usage: 613:43:29,907 [Thread-2] INFO   jTPCC : Term-00,                                                                                                                            13:43:29,908 [Thread-2] INFO   jTPCC : Term-00,                                                                                                                            13:43:29,908 [Thread-2] INFO   jTPCC : Term-00, Measured tpmC (NewOrders) = 135.06                                                                                         13:43:29,908 [Thread-2] INFO   jTPCC : Term-00, Measured tpmTOTAL = 299.72                            
13:43:29,909 [Thread-2] INFO   jTPCC : Term-00, Session Start     = 2019-12-10 13:33:27
13:43:29,909 [Thread-2] INFO   jTPCC : Term-00, Session End       = 2019-12-10 13:43:29
13:43:29,909 [Thread-2] INFO   jTPCC : Term-00, Transaction Count = 3006
[highgo@rsbdb run]$

测试结果简单查看
TPC-C使用三种性能和价格度量，其中性能由TPC-C吞吐率衡量，单位是tpmC。tpm是transactions per minute的简称；C指TPC中的C基准程序。它的定义是每分钟内系统处理的新订单个数。要注意的是，在处理新订单的同时，系统还要按表1的要求处理其它4类事务 请求。从表1可以看出，新订单请求不可能超出全部事务请求的45％，因此，当一个 系统的性能为1000tpmC时，它每分钟实际处理的请求数是2000多个。价格是指系 统的总价格，单位是美元，而价格性能比则定义为总价格÷性能，单位是＄/tpmC。

From <https://blog.csdn.net/jiao_fuyou/article/details/15497511>

TPC-C的测试结果主要有两个指标：

①流量指标(Throughput，简称tpmC)
按照TPC的定义，流量指标描述了系统在执行Payment、Order-status、Delivery、Stock-Level这四种交易的同时，每分钟可以处理多少个New-Order交易。所有交易的响应时间必须满足TPC-C测试规范的要求。
 
流量指标值越大越好！
 
②性价比(Price/Performance，简称Price/tpmC)
即测试系统价格（指在美国的报价）与流量指标的比值。
 
性价比越大越好！
 
 
 
6. Scale the benchmark configuration.
 
    Change the my_postgres.properties file to the correct scaling
    (number of warehouses and concurrent connections/terminals). Switch
    from using a transaction count to time based:
 
        runTxnsPerTerminal=0
runMins=180
 
    Rebuild the database (if needed) by running
 
    [wieck@localhost run]$ ./runDatabaseDestroy.sh my_postgres.properties
    [wieck@localhost run]$ ./runDatabaseBuild.sh my_postgres.properties
 
    Then run the benchmark again.
 
    Rinse and repeat.
 
eg:
重建运行数据库的方法（如果你修改了配置文件中的warehouse或者load的值都需要重建数据库）
 
[highgo@rsbdb run]$ ./runDatabaseDestroy.sh props_my.pg
# ------------------------------------------------------------
# Loading SQL file ./sql.common/tableDrops.sql
# ------------------------------------------------------------
drop table bmsql_config;
drop table bmsql_new_order;
drop table bmsql_order_line;
drop table bmsql_oorder;
drop table bmsql_history;
drop table bmsql_customer;
drop table bmsql_stock;
drop table bmsql_item;
drop table bmsql_district;
drop table bmsql_warehouse;
drop sequence bmsql_hist_id_seq;
[highgo@rsbdb run]$
 
[highgo@rsbdb run]$ ./runDatabaseBuild.sh props_my.pg
# ------------------------------------------------------------
# Loading SQL file ./sql.common/tableCreates.sql
# ------------------------------------------------------------
create table bmsql_config (
cfg_name    varchar(30) primary key,
cfg_value   varchar(50)
);
……
 
7. Result report
 
    BenchmarkSQL collects detailed performance statistics and (if
    configured) OS performance data. The example configuration file
    defaults to a directory starting with my_result_.
 
    Use the generateReport.sh DIRECTORY script to create an HTML file
    with graphs. This requires R to be installed, which is beyond the
    scope of this HOW-TO.
 
[pg@pg benchmarksql-5.0]$
 
运行结果会生成在当前目录，以my_result_开头的目录，可以通过generateReport.sh 生成图形化的HTML界面，但需要安装R环境。R环境的安装这里不做介绍。
 
eg:
[highgo@rsbdb run]$ ./generateReport.sh my_result_2019-12-10_133326/
Generating my_result_2019-12-10_133326//tpm_nopm.png ... ./generateGraphs.sh:行25: R: 未找到命令
ERROR
 
Generating my_result_2019-12-10_133326//report.html ... ./generateReport.sh:行161: data/tx_summary.csv: 没有那个文件或目录
grep: data/tx_summary.csv: 没有那个文件或目录
grep: data/tx_summary.csv: 没有那个文件或目录
grep: data/tx_summary.csv: 没有那个文件或目录
OK
[highgo@rsbdb run]$
 
 
如果运行过程中产生日志和错误，都会存储在run目录下，可以打开看是否有报错退出。
 
===========================================
 
--安装R语言（用于生成图形结果）
  1.通过tar.gz包安装（依赖太多，最后安装失败）
  tar -zxvf R-3.3.0.tar.gz
  cd R-3.3.0
  ./configure --prefix=/opt/R-3.3.0
 
 
--enable-R-shlib LDFLAGS="-L/opt/bzip2-1.0.6/lib -L/opt/xz-5.2.3/lib -L/opt/pcre-8.39/lib -L/opt/curl-7.53.1/lib" CPPFLAGS="-I/opt/bzip2-1.0.6/include -I/opt/xz-5.2.3/include -I/opt/pcre-8.39/include -I/opt/curl-7.53.1/include"
  2.yum安装
    安装R依赖的rpm包，本次缺少2个
    ftp://fr2.rpmfind.net/linux/centos/6.8/os/x86_64/Packages/texinfo-tex-4.13a-8.el6.x86_64.rpm
    http://mirror.ox.ac.uk/sites/mirror.centos.org/6/os/x86_64/Packages/libjpeg-turbo-1.2.1-3.el6_5.x86_64.rpm
    yum install texinfo-tex-4.13a-8.el6.x86_64.rpm
    yum install libjpeg-turbo-1.2.1-3.el6_5.x86_64.rpm
    yum install R
--生成图形结果
  # ./generateGraph.sh 结果路径（runBenchmark.sh测试结果的路径）
--生成html汇总结果
  # ./generateReport.sh 结果路径（runBenchmark.sh测试结果的路径）
 
 
====================================
错误
14:23:17,962 [Thread-0] ERROR  OSCollector$CollectData : OSCollector, unexpected EOF while reading from external helper process
 
解决方法
根据测试机器中 /proc/stat文件第一行的列数（假设为N），修改benchmarksql-5.0/run/misc/os_collector_linux.py脚本。
[root@pg Packages]# head /proc/stat -n 2
cpu  13629 33 2155 1926602 993 0 243 0 0 0
cpu0 13629 33 2155 1926602 993 0 243 0 0 0
 
// 共11列，所以N为11
 
[pg@pg run]$ pwd
/tmp/benchmarksql-5.0/run
[pg@pg run]$ vi misc/os_collector_linux.py
......
    if len(lastStatData) != 10:   //此处的11修改为N-1的值，即10
        raise Exception("cpu line in /proc/stat too short");

    procVMStatFD = open("/proc/vmstat", "r", buffering = 0)
    lastVMStatData = {}
    for line in procVMStatFD:
        line = line.split()
        if line[0] in ['nr_dirty', ]:
            lastVMStatData['vm_' + line[0]] = int(line[1])
    if len(lastVMStatData.keys()) != 1:
        raise Exception("not all elements found in /proc/vmstat")
 
    return [
            'cpu_user', 'cpu_nice', 'cpu_system',
            'cpu_idle', 'cpu_iowait', 'cpu_irq',
            'cpu_softirq', 'cpu_steal',
            'cpu_guest', 'cpu_guest_nice',
            'vm_nr_dirty'
]
     //这里多返回2列，根据/proc/stat第一行各列的含义，此处多了'vm_nr_dirty'，删除即可。

> cat /proc/stat
  cpu  2255 34 2290 22625563 6290 127 456 0 0 0
  cpu0 1132 34 1441 11311718 3675 127 438 0 0 0
  cpu1 1123 0 849 11313845 2614 0 18 0 0 0
  intr 114930548 113199788 3 0 5 263 0 4 [... lots more numbers ...]
  ctxt 1990473
  btime 1062191376
  processes 2915
  procs_running 1
  procs_blocked 0
  softirq 183433 0 21755 12 39 1137 231 21459 2263

以cpu开头的第一行统计数字为之后行cpu统计值的总和。这些数字值标识cpu处理器不同类型的事务耗费的时间总和。单位为USER_HZ（典型值为100）。以下按照从左到右的顺序说明每一列数字的含义。
- user: 用户态正常进程执行时间
- nice: 用户态nice值为负的进程执行时间
- system: 进程在内核态的执行时间
- idle: 空闲时间
- iowait: 简单来说，iowait代表着等待I/O操作完成的时间。但是还有几个问题：
  1. 处理器不会一直等待I/O操作完成，iowait是任务等待I/O完成的时间。当有任务的I/O操作未完成时处理器进入空闲状态，其它的任务将调度到此处理器执行。
  2. 在多核处理器上，等待I/O操作完成的任务不在任何CPU上运行，所以每个CPU的iowait时间很难统计。
  3. PROC文件stat中的iowait值在一定情况下还会减少。
  所以，文件stat中的iowait值并不准确。
- irq: 硬件中断的执行时间
- softirq: 软中断的执行时间
- steal: 非自主等待时间
- guest: 运行正常客户机的时间
- guest_nice: 运行niced客户机的时间
 
 