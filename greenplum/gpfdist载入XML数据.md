# gpfdist载入XML数据

## 一、准备工作

运行gpfdist之前环境中可能会缺少一些库文件而导致程序无法执行。

检查缺少的库文件：
ldd /usr/local/hgdw/bin/gpfdist

下载缺少的库
yum install apr
yum install libyaml
yum install libevent
下载完成后会自动建立软连接，如果是自己下载的tar包则还需要手动编译并建立软连接

建立软链接示例
ln -s /usr/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5

结束后再次检查库文件是否都包含
ldd /usr/local/hgdw/bin/gpfdist

下载joost工具包，并解压安装

使用root用户，解压安装包，然后复制到/home/hgadmin目录下。为hgadmin用户赋予使用该文件的权限
unzip -p joost-0.9.1-bin.zip joost-0.9.1/joost.jar &gt; joost.jar
cp joost.jar /home/hgadmin/
chown -R hgadmin:hgadmin /home/hgadmin/joost.jar

## 二、使用gpfdist

首先需要一个要装载的XML文件，这里用一个简单的prices.xml作为示例

```bash
cat prices.xml

<?xml version="1.0" encoding="ISO-8859-1" ?>
<prices>
  <pricerecord>
    <itemnumber>708421</itemnumber>
    <price>19.99</price>
  </pricerecord>
  <pricerecord>
    <itemnumber>708466</itemnumber>
    <price>59.25</price>
  </pricerecord>
  <pricerecord>
    <itemnumber>711121</itemnumber>
    <price>24.99</price>
  </pricerecord>
</prices>

```
从数据中可以看出，我们需要导入的数据应该是itemnumber和price两列。但是在导入诗句之前需要将XML数据转化为数据库认识的TEXT格式，因此需要进行以下两步。

生成input_transform.stx文件来进行数据转化，prices.xml文件的STX转化文件如下

```bash
cat input_transform.stx

<?xml version="1.0"?>
<stx:transform version="1.0"
   xmlns:stx="http://stx.sourceforge.net/2002/ns"
   pass-through="none">
  <!-- declare variables -->
  <stx:variable name="itemnumber"/>
  <stx:variable name="price"/>
  <!-- match and output prices as columns delimited by | -->
  <stx:template match="/prices/pricerecord">
    <stx:process-children/>
    <stx:value-of select="$itemnumber"/>    
<stx:text>|</stx:text>
    <stx:value-of select="$price"/>      <stx:text>
</stx:text>
  </stx:template>
  <stx:template match="itemnumber">
    <stx:assign name="itemnumber" select="."/>
  </stx:template>
  <stx:template match="price">
    <stx:assign name="price" select="."/>
  </stx:template>
</stx:transform>

```

编写gpfdist配置文件


vi config.yaml
```bash
---

VERSION: 1.0.0.1
TRANSFORMATIONS:
  prices_input:
    TYPE:     input
           COMMAND:  /bin/bash input_transform.sh %filename%

```
yaml文件的格式是非常严格的，多一个空格都是会失败的

创建脚本来调用STX文件并返回其输出逻辑

```bash
vi input_transform.sh
!/bin/bash
# input_transform.sh - sample input transformation,
# demonstrating use of Java and Joost STX to convert XML into
# text to load into Greenplum Database.
# java arguments:
#   -jar joost.jar         joost STX engine
#   -nodecl                  don't generate a <?xml?> declaration
#   $1                        filename to process
#   input_transform.stx    the STX transformation
#
# the AWK step eliminates a blank line joost emits at the end
java \
    -jar joost.jar \
    -nodecl \
    $1 \
    input_transform.stx | \
awk 'NF>0'

```


另开一个窗口运行gpfdist
gpfdist -c config.yaml


在数据库中建表

```sql
CREATE TABLE prices (
  itemnumber integer,       
  price       decimal        
) 
DISTRIBUTED BY (itemnumber);
```


建立对应外部表，注意这里的hostname应该设置为你的主机名称

```sql
CREATE READABLE EXTERNAL TABLE prices_readable (LIKE prices)
   LOCATION ('gpfdist://hostname:8080/prices.xml#transform=prices_input')
   FORMAT 'TEXT' (DELIMITER '|')
   LOG ERRORS SEGMENT REJECT LIMIT 10;


```


装载数据

```sql
INSERT INTO prices SELECT * FROM prices_readable;
```


检查是否插入成功
```sql
select * from prices;
```
