一、如果没有iptables禁止ping
echo 1 >/proc/sys/net/ipv4/icmp_echo_igore_all #禁止
echo 0 > /proc/sys/net/ipv4/icmp_echo_igore_all #允许
立即生效
此种方法别人不能ping自己，自己可以ping别人
二、利用iptables规则禁ping
iptables -A INPUT -p icmp --icmp-type8 -s 0/0 -j DROP
三、利用iptables规则，禁止服务器向外发包，防止DDOS向外攻击
iptables -I OUTPUT -p udp --dport 53 -d 8.8.8.8 -j ACCEPT #允许UDP服务IP
iptables -A OUTPUT -p udp -j DROP #禁止udp服务
上述53端口和8888是DNS服务必须有的，如果不清楚本机的DNS设置，可执行以下命令得到IP：
cat/etc/resolv.conf
 
来自 <http://www.2cto.com/os/201304/205387.html>