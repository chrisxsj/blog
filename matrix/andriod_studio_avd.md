# andriod_studio_avd

**作者**

Chrisx

**日期**

2021-07-21

**内容**

安卓模拟器

使用andriod studio创建安卓模拟器

ref [设置 Android 模拟器以运行 Android 11](https://developer.android.google.cn/about/versions/11/get)

---

## 安装andriod studio

下载[andriod studio](https://developer.android.google.cn/studio)

## 配置安卓sdk

tools > SDK manager > andriod SDK
勾选需要的安卓版本

## 创建安卓虚拟设备

tools > AVD manager
根据向导创建一个安卓虚拟机

## 安装本地apk

### adb配置环境变量

1. 开始菜单输入env，点击编辑系统环境变量

2. 新建环境变量

变量名：ANDROID_HOME
变量值：sdk目录

:warning: sdk目录可以从SDK manager中查看（Android sdk location）

3. 添加path

新建%ANDROID_HOME%、%ANDROID_HOME%\tools、%ANDROID_HOME%\platform-tools

4. 验证是否配置成功 

adb --version

### 安装apk

1. 打开AVD模拟器
2. 安装
adb install xxx.apk
