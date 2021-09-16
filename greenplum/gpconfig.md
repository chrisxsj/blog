
# gpconfig

ref [gpconfig](http://47.92.231.67:8080/6-0/utility_guide/admin_utilities/gpconfig.html#topic1)
ref [gpconfig](http://docs.greenplum.org/6-8/utility_guide/ref/gpconfig.html#topic1)

在Greenplum数据库系统中所有的Segment上设置服务器配置参数。

## 概要

gpconfig -c param_name -v value [-m master_value | --masteronly]
               | -r param_name [--masteronly | -l
               [--skipvalidation] [--verbose] [--debug]
        
        gpconfig -s param_name [--file | --file-compare] [--verbose] [--debug]
        
        gpconfig --help

## 描述

gpconfig工具允许用户在Greenplum数据库系统中所有实例 （Master、Segment和镜像）的postgresql.conf文件中设置、 复原或查看配置参数。设置参数时，如果需要，还可以为Master指定一个不同的值。 例如，诸如max_connections之类的参数要求Master的设置 不同于Segment的设置。如果要设置或复原全局参数或仅可对Master设置的参数， 请使用--masteronly选项。

gpconfig只能用来管理某些参数。例如，用户不能使用它来设置 port等参数，这些参数对每个Segment实例都不同。使用-l （list）选项查看gpconfig支持的配置参数的完整列表。

当gpconfig在Segment的postgresql.conf 文件中设置配置参数时，新的参数设置将总是显示在该文件的底部。当用户使用 gpconfig移除配置参数时，gpconfig会在所有 Segment的postgresql.conf文件中把该参数注释掉，从而恢复系统 默认设置。例如，如果使用gpconfig 删除（注释掉）一个参数，并且 稍后把它添加回来（设置新值），则该参数会有两个实例，一个被注释掉，另一个被启用并 添加到postgresql.conf文件的底部。

设置参数之后，用户必须重新启动其Greenplum数据库系统，或者重新加载postgresql.conf 文件以使得更改生效。是否需要重新启动或者加载取决于被设置的参数。

有关服务器配置参数的更多信息，请参阅Greenplum数据库参考指南。

要显示系统中当前参数的设置值，请使用-s选项。

## 选项

-c | --change param_name
通过在postgresql.conf文件的底部添加新的设置来改变配置参数的设置。
-v | --value value
用于由-c选项指定的配置参数的值。默认情况下，此值将应用于所有 Segment及其镜像、Master和后备Master。
非单个字符或数字的参数值必须用单引号包裹（'）。例如，包括空格或特殊字符的字符串 必须用单引号包裹。如果要在字符串参数重嵌入单引号，需要用2个单引号或反斜杠进行转移（\'）。
工具会在将值写入postgresql.conf时带着单引号。
-m | --mastervalue master_value
用于由-c选项指定的配置参数的Master值。如果指定，则该值仅适用于Master 和后备Master。该选项只能与-v一起使用。
--masteronly
当被指定时，gpconfig将仅编辑Master的postgresql.conf文件。
-s | --show param_name
显示在Greenplum数据库系统中所有实例（Master和Segment）上使用的配置参数的值。 如果实例中参数值存在差异，则工具将显示错误消息。使用-s选项运行 gpconfig将直接从数据库中读取参数值，而不是从postgresql.conf 文件中读取。如果用户使用gpconfig在所有Segment中设置配置参数， 然后运行gpconfig -s来验证更改，用户仍可能会看到以前的（旧）值。 用户必须重新加载配置文件（gpstop -u）或重新启动系统（gpstop -r） 以使更改生效。
-l | --list
列出所有被gpconfig工具支持的配置参数。

## 示例

查看
gpconfig -s max_connections

[dgadmin@hgdb-master-26 hgseg-1]$ gpconfig -s max_connections
Values on all segments are consistent
GUC          : max_connections
Master  value: 250
Segment value: 750
[dgadmin@hgdb-master-26 hgseg-1]$

修改(-m只应用与mast和standby mast)
gpconfig -c max_connections -v 1000 -m 500

修改（所有segment，包括mast和standby mast） 
gpconfig -c max_prepared_transactions -v 500

删除配置
gpconfig -r <parameter name> 

重启数据库生效
