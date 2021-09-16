# greenplum install PostGis

```bash

展开
1、下载Greenplum的postgis插件
下载地址：

https://network.pivotal.io/products/pivotal-gpdb/#/releases/449820/file_groups/2053

注意选择相应的版本，如果版本对应不上安装将失败。

2、安装
gppkg -i postgis-2.1.5+pivotal.2-2-gp6-rhel7-x86_64.gppkg

即可完成安装

3、测试
在相应的数据库执行：

 ./psql -h [ip] -p [port] -d [db_name] -f /usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/install/postgis.sql
 
 ./psql -h [ip] -p [port] -d [db_name] -f /usr/local/greenplum-db/share/postgresql/contrib/postgis-2.1/install/spatial_ref_sys.sql
安装完成之后，可以在相应的数据库中看到如下表spatial_ref_sys和另外2张视图， spatial_ref_sys 存储着合法的空间坐标系统：

# SELECT srid,auth_name,proj4text FROM spatial_ref_sys LIMIT 10;
 srid | auth_name |                             proj4text                             
------+-----------+-------------------------------------------------------------------
 3889 | EPSG      | +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs 
 4001 | EPSG      | +proj=longlat +ellps=airy +no_defs 
 4009 | EPSG      | +proj=longlat +a=6378450.047548896 +b=6356826.621488444 +no_defs 
 4025 | EPSG      | +proj=longlat +ellps=WGS66 +no_defs 
 4033 | EPSG      | +proj=longlat +a=6378136.3 +b=6356751.616592146 +no_defs 
 4041 | EPSG      | +proj=longlat +a=6378135 +b=6356750.304921594 +no_defs 
 4081 | EPSG      | +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs 
 4120 | EPSG      | +proj=longlat +ellps=bessel +no_defs 
 4128 | EPSG      | +proj=longlat +ellps=clrk66 +no_defs 
 4136 | EPSG      | +proj=longlat +ellps=clrk66 +no_defs 
(10 rows)
添加表测试：

# CREATE TABLE cities ( id int4, name varchar(50) );
NOTICE:  Table doesn't have 'DISTRIBUTED BY' clause -- Using column named 'id' as the Greenplum Database data distribution key for this table.
HINT:  The 'DISTRIBUTED BY' clause determines the distribution of data. Make sure column(s) chosen are the optimal data distribution key to minimize skew.
CREATE TABLE
 
 
# SELECT AddGeometryColumn ('cities', 'the_geom', 4326, 'POINT', 2);
                  addgeometrycolumn                  
-----------------------------------------------------
 public.cities.the_geom SRID:4326 TYPE:POINT DIMS:2 
(1 row)
 
 
 
# SELECT * from cities;
 id | name | the_geom 
----+------+----------
(0 rows)
插入数据并查看

INSERT INTO cities (id, the_geom, name) VALUES (1,ST_GeomFromText('POINT(-0.1257 51.508)',4326),'London, England');
INSERT INTO cities (id, the_geom, name) VALUES (2,ST_GeomFromText('POINT(-81.233 42.983)',4326),'London, Ontario');
INSERT INTO cities (id, the_geom, name) VALUES (3,ST_GeomFromText('POINT(27.91162491 -33.01529)',4326),'East London,SA');
 
#   SELECT * FROM cities;
 id |      name       |                      the_geom                      
----+-----------------+----------------------------------------------------
  3 | East London,SA  | 0101000020E610000040AB064060E93B4059FAD005F58140C0
  1 | London, England | 0101000020E6100000BBB88D06F016C0BF1B2FDD2406C14940
  2 | London, Ontario | 0101000020E6100000F4FDD478E94E54C0E7FBA9F1D27D4540
(3 rows)
空间计算：

# SELECT p1.name,p2.name,ST_Distance_Sphere(p1.the_geom,p2.the_geom) FROM cities AS p1, cities AS p2 WHERE p1.id > p2.id;
      name       |      name       | st_distance_sphere 
-----------------+-----------------+--------------------
 East London,SA  | London, England |   9789680.59961472
 East London,SA  | London, Ontario |   13892208.6782928
 London, Ontario | London, England |   5875787.03777356
(3 rows)

```