# linux下^M替换

## 现象

CREATE TABLE dj_fz (ID VARCHAR, DJSLSQ_ID VARCHAR, YWH VARCHAR, YSDM VARCHAR, FZRY VARCHAR, FZSJ VARCHAR, FZMC VARCHAR, FZSL VARCHAR, HFZSH VARCHAR, LZRXM VARCHAR, LZRZJLB VARCHAR, LZRZJH VARCHAR, LZRDH VARCHAR, LZRDZ VARCHAR, LZRYB VARCHAR, BZ VARCHAR, SCRKSJ VARCHAR, GXSJ VARCHAR, QXDM VARCHAR, RECORDS VARCHAR, QLDJLX^M VARCHAR) distributed by (ID);

有的列类似，`QLDJLX^M`，带有`^M`符号。

不知道为啥产生

## 解决

打开一个terminal命令行终端
然后输入如下命令

sed -i 's/^M//g' FileName

把这里的filename替换成你自己要处理的文件名就可以了

> 注意，^M在Linux中命令行的输入方法是同时按下ctrl+v然后按下M，一定要在linux下打出这个字符。
