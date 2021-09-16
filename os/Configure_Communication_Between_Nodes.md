# Configure Communication Between Nodes

**作者**

chrisx

**日期**

2021-04-02

**内容**

Configure Host Name Resolution
Configure SSH
ssh_authorized_keys

---

## Configure Host Name Resolution

确认两个节点互通

```shell
ping -c 3 192.168.6.141
ping -c 3 192.168.6.142

```

修改主机名映射

```shell
cat /etc/hosts

# Host Name Resolution
192.168.6.141   db1
192.168.6.142   db2

```

确认主机名互通

```shell
ping -c 3 db1
ping -c 3 db2

```

## Configure SSH

1.在两台机器上生成各自的key文件

```shell
ssh-keygen -t rsa       #下面一直按回车就好,可单独使用rsa
ssh-keygen -t dsa 
```

2.用ssh-copy-id 把公钥复制到远程主机上

它通过将密钥附加到远程用户的~/.ssh/authorized_keys（如果需要，创建文件和目录）来添加密钥。

```shell
ssh-copy-id -i  .ssh/id_rsa.pub root@192.168.6.142

```

:warning: 注：如果不是默认的端口,可以使用参数 -P指定

免密登陆

```shell
ssh root@192.168.3.21

```

3. 节点2上重复以上操作

4. 不行就重新做

```shell
cd ~/.ssh/
rm *

```

说明：

* 上面是以root用户配置互信，如果想要其它用户，可以切到相应的用户下执行命令即可
* 如果单纯的只需要单向信任，在一台机器上执行命令就可以了，比如说node1连接node2，不用密码的话，在node1上执行命令就可以了
* 也可以把ip地址和主机名对应关系加到 /etc/hosts里 这样直接ssh 主机名就可以了
* 其中known_hosts是本机知道的别的机器信息
* .ssh 权限为700 ，否则等效性失败
* 之后修改密码不影响ssh认证

## SSH无密码验证的原理

Master作为客户端，要实现无密码公钥认证，连接到服务器Salve上时，需要在Master上生成一个密钥对，包括一个公钥和一个私钥，而后将公钥复制到所有的Salve上。当Master通过SSH链接到Salve上时，Salve会生成一个随机数并用Master的公钥对随机数进行加密，并发送给Master。Master收到加密数之后再用私钥解密，并将解密数回传给Salve，Salve确认解密数无误之后就允许Master进行连接了。这就是一个公钥认证过程，期间不需要手工输入密码，重要的过程是将Master上产生的公钥复制到Salve上。
