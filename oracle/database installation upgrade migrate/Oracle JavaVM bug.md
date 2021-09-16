各位好：
 
OJVM PSU主要是针对oracle java VM。从2014年10月开始Oracle JavaVM组件作为一个单独的部分来进行安装。之前是包含在oracle rdbms psu中。
只要oracle db中安装jvm组件，就需要安装对应版本的oracle JavaVM PSU。如果只是打了rdbms的PSU，安全漏洞检查就会检查出jvm的安全漏洞。
如果该组件存在漏洞，将可能威胁数据库安全，建议对此组件安装最新PSU。详细说明如下：
 
1、Oracle建议在安装了Oracle JavaVM的数据库环境中安装最新的OJVM PSU/DBBP/Update patch，无论是否使用OJVM组件（原因参考2和3）。
 
2、尽管OJVM组件没有被安装在当前的数据库环境中，Oracle也建议在当前数据库中安装OJVM PSU/Update，以便为后期使用当前ORACLE_HOME创建的新数据库提供保护。
 
3、如果当前数据库创建时没有安装JavaVM组件，而且后期确认不会使用当前的ORACLE_HOME创建新的数据库，则无需安装OJVM PSU。（注意：如果当前未安装OJVM PSU，那么后期使用此
ORACLE_HOME创建了带有OJVM组件的数据库将不会得到保护，依旧会存在OJVM相关的漏洞）。
 
4、OJVM PSU仅在数据库home下安装即可，无需在 Grid home下安装。
 
5、Oracle建议在与安装的数据库修补程序相同的季度应用OJVM修补程序。 在这种匹配至关重要的情况下，OJVM补丁要求数据库补丁打到某个版本的PSU后才能安装OJVM补丁（require the
database home to be patched to at least October 2014 DB PSU (or equivalent)）。
 
6、使用如下命令查询当前数据库中是否已经安装了Oracle JavaVM ：
SELECT version, status FROM dba_registry WHERE comp_id='JAVAVM';
如果"STATUS"显示"VALID" 则建议安装最新的 OJVM PSU/Update 。
如果什么都没显示或者"STATUS" 显示"REMOVED" ，则表明当前数据库中没有Oracle JavaVM组件。
如果"STATUS"显示其他的值，则表明当前数据库中的JavaVM组件可能出现问题，建议优先处理问题后再安装最新的OJVM PSU/Update。
 
7、数据库客户端需要安装OJVM PSU吗 ?
OJVM PSU补丁不适用于客户端安装。
JDBC修补程序适用于客户端安装。
 
8、可以在使用DBUA升级数据库前应用OJVM PSU patch吗？
可以。 DBUA will perform the Post Install steps for the OJVM PSU after the upgrade completes
 
9、主要学习文章
Oracle Recommended Patches -- "Oracle JavaVM Component Database PSU and Update" (OJVM PSU and OJVM Update) Patches (文档 ID 1929745.1)
 
10、其他参考文章
Will OJVM PSU post install script update registry$history ? (文档 ID 1936371.1)
RAC Rolling Install Process for the "Oracle JavaVM Component Database PSU/RU" (OJVM PSU/RU) Patches (文档 ID 2217053.1)
How to Deinstall "Oracle JavaVM Component Database PSU" OJVM PSU (文档 ID 1941680.1)
How to Install, Remove, Reload, Validate and Repair the JVM Component in an Oracle Database (文档 ID 2149019.1)
 
11、对于新实施的数据库，全部要求安装当前最新的DB PSU + OJVM PSU。
    对于客户方漏洞扫描软件发现的关于OJVM漏洞，我方需积极配合完成OJVM PSU的升级实施。
    OJVM PSU独立于DB PSU之外，需要单独下载，具体安装方法类似DB PSU，具体参考各版本补丁包中的readme.html。
    【重要】在生产环境中升级此类PSU前，务必进行完整的测试，因为Oracle官方并不能保证每个版本的升级和回退过程完全准确，参考如下:
            OJVM PSU 12.1.0.2.160419 for HP-UX Itanium Contains Wrong Rollback Script(文档 ID 2258280.1)
