# java_env

**作者**

Chrisx

**日期**

2021-11-29

**内容**

java开发环境配置，运行java程序，需要使用jdk编译

* JDK : Java SE Development Kit Java （开发工具）
* JRE : Java Runtime Environment Java （运行环境）

----

[toc]

## 下载

下载[Java SE Development Kit](https://www.oracle.com/java/technologies/downloads/)

## 安装

上传压缩包，解压

```sh
tar -zxvf jdk-17_linux-x64_bin.tar.gz
mv jdk-17.0.1/ /opt

```

设置环境变量

```sh
# java conf
export JAVA_HOME=/opt/jdk-17.0.1
export CLASSPATH=.:$JAVA_HOME/lib
export PATH=$JAVA_HOME/bin:$PATH
```

查看版本

```sh
$ java --version
java version "17.0.1" 2021-10-19 LTS
Java(TM) SE Runtime Environment (build 17.0.1+12-LTS-39)
Java HotSpot(TM) 64-Bit Server VM (build 17.0.1+12-LTS-39, mixed mode, sharing)
```

## 调用命令

```sh
编译
javac Test.java
运行
java -cp . Test或java Test
```
