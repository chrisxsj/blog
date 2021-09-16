netsh wlan show profiles



netsh 显示wlan密码
 
C:\Users\xians>netsh wlan show profiles
接口 WLAN 上的配置文件:
组策略配置文件(只读)
---------------------------------
    <无>
用户配置文件
-------------
    所有用户配置文件 : HG-office
    所有用户配置文件 : TP-LINK_3418
    所有用户配置文件 : QLNET
    所有用户配置文件 : Smartisan personal hotspot
    所有用户配置文件 : Xiaomi_D3F8
    所有用户配置文件 : 360免费WiFi-85
    所有用户配置文件 : highgo-work
    所有用户配置文件 : xxzx201
    所有用户配置文件 : RM-984 8661
    所有用户配置文件 : highgo5G
    所有用户配置文件 : 360WiFi-6A3B07
    所有用户配置文件 : ChinaUnicom
    所有用户配置文件 : worknet
    所有用户配置文件 : UNIMAS
    所有用户配置文件 : TP-LINK_18191C
    所有用户配置文件 : TP-LINK_BC3A7C
    所有用户配置文件 : gongqingtuan
    所有用户配置文件 : zzfyxxk
    所有用户配置文件 : HappyHouse
    所有用户配置文件 : fuwuzhongxin-AP5
    所有用户配置文件 : sanlouhuiyishi
    所有用户配置文件 : oracle
C:\Users\xians>netsh wlan show profile name="360WiFi-8C661E" key=clear
接口 WLAN 上的配置文件 HG-office:
=======================================================================
已应用: 所有用户配置文件
配置文件信息
-------------------
    版本                   : 1h
    类型                   : 无线局域网
    名称                   : HG-office
    控制选项               :
        连接模式           : 自动连接
        网络广播           : 只在网络广播时连接
        AutoSwitch         : 请勿切换到其他网络
        MAC 随机化: 禁用
连接设置
---------------------
    SSID 数目              : 1
    SSID 名称              :“HG-office”
    网络类型               : 结构
    无线电类型             : [ 任何无线电类型 ]
    供应商扩展名           : 不存在
安全设置
-----------------
    身份验证         : WPA2 - 个人
    密码                 : CCMP
    身份验证         : WPA2 - 个人
    密码                 : GCMP
    安全密钥               : 存在
    关键内容            : highgo@4007088006
费用设置
-------------
    费用                : 无限制
    阻塞                : 否
    接近数据限制        : 否
    过量数据限制        : 否
    漫游                : 否
    费用来源            : 默认