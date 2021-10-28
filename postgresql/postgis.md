# postgis

**作者**

Chrisx

**日期**

2021-10-25

**内容**

postgis安装使用

reference [postgis](http://postgis.net/documentation/)

reference [postgis download](https://postgis.net/source/)

----

[toc]

## linux安装

安装包有源码编译安装包（Compiling from Source）和二进制程序安装包(Binary Installers)。不同的安装包有不同的方式。
下面以源码安装为例，源码安装太难了！


<!--
1. 获取源码包
reference [postgis download](https://postgis.net/source/)

2. 安装需求

Required

* pg9.6或更高版本的数据库
* GNU C compiler (gcc)
* GNU Make (gmake or make)
* Proj4 reprojection library. Proj4 4.9 or above is required.  [http://trac.osgeo.org/proj/](http://trac.osgeo.org/proj/)
* GEOS geometry library, version 3.6 or greater,[http://trac.osgeo.org/geos/](http://trac.osgeo.org/geos/)
* LibXML2, version 2.5.x or higher. http://xmlsoft.org/downloads.html
* JSON-C, version 0.9 or higher. [https://github.com/json-c/json-c/releases/](https://github.com/json-c/json-c/releases/)
* GDAL, version 2+ is required 3+ is preferred.[http://trac.osgeo.org/gdal/wiki/DownloadSource](http://trac.osgeo.org/gdal/wiki/DownloadSource)
* If compiling with PostgreSQL+JIT, LLVM version >=6 is required [https://trac.osgeo.org/postgis/ticket/4125](https://trac.osgeo.org/postgis/ticket/4125)

Optional

参考文档[install](https://postgis.net/docs/postgis_installation.html#install_short_version)

满足以上需求进行安装前的配置

```sh
安装数据库

安装依赖

yum install -y gcc make libxml2  libxml2-devel gcc-c++ sqlite sqlite-devel cmake swig ruby python

安装 proj-5.2.0.tar.gz （建议安装proj-5.x，更高版本需要安装高版本sqlite等依赖包）
cd proj-5.2.0
./configure
make
sudo make install

安装 geos-3.6.5.tar.bz2 （建议安装geos-3.6.x，更高版本需要安装高版本cmake等依赖包）
cd geos-3.6.5/
./configure
make
sudo make install


安装 gdal-2.4.4.tar.gz  （建议安装geos-2.x，更高版本需要安装高版本proj等依赖包）
cd gdal-2.4.4
./configure
make
sudo make install

=================

可选

安装 boost_1_67_0.tar.gz
cd boost_1_67_0
./bootstrap.sh
sudo ./b2 install

安装 gmp-6.1.2.tar.lz
cd gmp-6.1.2/
./configure
make
sudo make install

安装 mpfr-4.0.1.tar.gz
cd mpfr-4.0.1/
./configure
make
sudo make install

安装 CGAL-4.7.tar.gz
cd CGAL-4.7
cmake .
make
sudo make install

安装 SFCGAL-1.2.2.zip
cd SFCGAL-1.2.2/
cmake .
make
sudo make install


```

2.编译安装插件

假设数据库目录为：/home/highgo/highgo/database/4.3.2/ 

postgis-2.4.4.tar.gz

export PATH=$PATH:/home/highgo/highgo/database/4.3.2/bin
sudo cp -rf -d /usr/local/lib64/libSFCGAL.so* /usr/local/lib/
cd postgis-2.4.4
./configure
make
sudo make install

ogr_fdw 插件： https://github.com/pramsey/pgsql-ogr-fdw

export PATH=$PATH:/home/highgo/highgo/database/4.3.2/bin
cd pgsql-ogr-fdw-1.0.6
make
make install

pgrouting-2.6.0
export PATH=$PATH:/home/highgo/highgo/database/4.3.2/bin
cd pgrouting-2.6.0/
mkdir build
cd build/
cmake ..
make make install

pointcloud
export PATH=$PATH:/home/highgo/highgo/database/4.3.2/bin 
./autogen.sh
./configure
make
make install

3.拷贝库文件

#!/bin/bash
LIBPATH="/home/highgo/highgo/database/4.3.2/lib"
cp -d /usr/local/lib/libgeos* $LIBPATH
cp -d /usr/local/lib/libgeos_c* $LIBPATH
cp -d /usr/local/lib/libproj* $LIBPATH
cp -d /usr/local/lib/libSFCGAL* $LIBPATH
cp -d /usr/local/lib/libCGAL* $LIBPATH
cp -d /usr/local/lib/libmpfr* $LIBPATH
cp -d /usr/local/lib/libgdal* $LIBPATH
cp -d /usr/local/lib/libboost_date_time* $LIBPATH
cp -d /usr/local/lib/libboost_thread* $LIBPATH
cp -d /usr/local/lib/libboost_system* $LIBPATH
cp -d /usr/local/lib/libboost_serialization* $LIBPATH

4.测试
create extension postgis;
create extension postgis_topology;
create extension postgis_sfcgal;
create extension address_standardizer;
create extension fuzzystrmatch;
create extension postgis_tiger_geocoder;
create extension pgrouting;
create extension pointcloud;
create extension pointcloud_postgis;
create extension ogr_fdw;
-->

## win安装

下载地址[postgis for win](http://download.osgeo.org/postgis/windows/)

> 注意，版本一定要对应好，否则安装失败（HGDBV4对应PG9.5， HGDBV5对应PG10）
> 注意，V5中LIB和PATH都要配置在PATH中

下载的gis安装包分为.zip和.exe两种格式
.exe：直接安装，指定到数据库的安装目录，例如：D:\highgo\database\5.6.4
.zip：直接解压到指定目录，例如D:\highgo\database\5.6

解压到D:\highgo\database\5.6.4
修改配置文件：makepostgisdb_using_extensions.bat

```bash
REM this is an example of how to create a new db and spatially enable it using CREATE EXTENSION
set PGPORT=5866
set PGHOST=localhost
set PGUSER=highgo
set PGPASSWORD=highgo123
set THEDB=postgis
set PGINSTALL=D:\highgo\database\5.6.4

set PGADMIN=%PGINSTALL%\hgdbadmin
set PGBIN=%PGINSTALL%\bin
set PGLIB=%PGINSTALL%\lib
set POSTGISVER=3.0
xcopy bin\*.* "%PGBIN%"
xcopy /I /S bin\postgisgui\* "%PGBIN%\postgisgui"
xcopy /I plugins.d\* "%PGADMIN%\plugins.d"
xcopy lib\*.* "%PGLIB%"
xcopy share\extension\*.* "%PGINSTALL%\share\extension"
xcopy /I /S share\contrib\*.* "%PGINSTALL%\share\contrib"
xcopy /I gdal-data "%PGINSTALL%\gdal-data"
"%PGBIN%\psql" -U "%PGUSER%" -c "CREATE DATABASE %THEDB%"
"%PGBIN%\psql" -U "%PGUSER%" -d "%THEDB%" -c "CREATE EXTENSION postgis;"
"%PGBIN%\psql" -U "%PGUSER%" -d "%THEDB%" -c "CREATE EXTENSION postgis_sfcgal;"
"%PGBIN%\psql" -U "%PGUSER%" -d "%THEDB%" -c "CREATE EXTENSION postgis_topology;"
"%PGBIN%\psql" -U "%PGUSER%" -d "%THEDB%" -c "CREATE EXTENSION address_standardizer;"
"%PGBIN%\psql" -U "%PGUSER%" -d "%THEDB%" -c "CREATE EXTENSION address_standardizer_data_us;"
"%PGBIN%\psql" -U "%PGUSER%" -d "%THEDB%" -c "CREATE EXTENSION fuzzystrmatch;"
"%PGBIN%\psql" -U "%PGUSER%" -d "%THEDB%" -c "CREATE EXTENSION postgis_tiger_geocoder;"


REM Uncomment the below line if this is a template database
REM "%PGBIN%\psql" -d "%THEDB%" -c "UPDATE pg_database SET datistemplate = true WHERE datname = '%THEDB%';GRANT ALL ON geometry_columns TO PUBLIC; GRANT ALL ON spatial_ref_sys TO PUBLIC"


pause

```

修改如下的配置

```bash
set PGPORT=5866
set PGHOST=localhost
set PGUSER=highgo
set PGPASSWORD=highgo123
set THEDB=postgis
set PGINSTALL=D:\highgo\database\5.6.4

set PGADMIN=%PGINSTALL%\hgdbadmin
set POSTGISVER=3.0

```

双击makepostgisdb_using_extensions.bat运行  
中间可能需要输入五次密码，运行完毕后退出.单机无需输入密码

创建扩展

```sql
create extension postgis;

```

