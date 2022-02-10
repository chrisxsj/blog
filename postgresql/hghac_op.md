# hghac

**作者**

chrisx

**日期**

2021-12-14

**内容**

hahac管理

----

[toc]

## 节点添加删除

hghac集群可以在其他机器上通过配置hghac.yaml文件，添加新节点加入集群。
主要过程为：

1. 安装相关软件
2. 配置hghac.yaml
3. 启动hghac
4. 查看状态

注意，需要注意的是，namespace和scope两个参数应与要加入集群中各节点参数值相同。可以将原集群节点中hghac.yaml复制到新节点中，修改restapi和postgresql中的connect_address值及name值。

hghac集群节点如果超出设置的ttl时间(默认30s)没有与dsc进行通信，则dcs会将其信息删除，根据这一特性我们可以删除集群中某一节点。
具体过程如下：

1. 关闭某一节点hghac
2. 等待ttl时间后，查看集群状态
3. 卸载相关软件

注意，通过验证在ttl（30s）时间内，dcs中仍保留hgdw1节点信息，超出30s后，查看集群状态，hgdw1相关信息被删除。

## 重做备节点

确定数据正常情况下，进行重做。

1. 停止备节点hghac服务

```sh
systemctl stop hghac
ps -ef |grep hghac #无hghac服务
```

2. 清空备节点data目录

```sh
mv $PGDATA $PGDATA.bak

```

注意，是否有软连接

3. 启动hghac服务

```sh
systemctl start hghac
hghactl list
systemctl status hghac
```

4. 查看状态

```sh
hghactl list
systemctl status hghac

```

## 切换和重启

hghactl -c $HGHAC_CONF switchover   #手动切换
hghactl -c $HGHAC_CONF restart hg hg1   #重启节点，不会触发时间线增加情况
