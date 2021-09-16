Linux recyelebinrm替换为别名

 
[小技巧] 将 rm 命令删除的文件放在回收站
原创HaveFunInLinux 最后发布于2014-08-28 23:31:46 阅读数 2887  收藏
展开
linux 的 rm命令使用时得非常小心，一不注意就误删了。所以最好的方式是将rm替换成其他的命令。
 
有几种方式实现：
 
1. rm.sh 脚本，参考：https://github.com/artmees/rm
 
2. trash-cli 脚本，参考：https://github.com/andreafrancia/trash-cli
 
这里有比较多的工具，包括查看删除的文件，以及恢复删除的文件等等。
 
3.最简单的方式，将rm alias为mv。如：
 
alias rm="mv -t ~/.Trash"
 
4. 将rm实现成一个bash function.
function rm () {
local path
for path in "$@"; do
# ignore any arguments
if [[ "$path" = -* ]]; then :
else
local dst=${path##*/}
# append the time if necessary
if [[ -z "$dst" ]]; then
dst=$(echo $path | sed -e 's/\/$//')
dst=${dst##*/}
fi
while [ -e ~/.Trash/"$dst" ]; do
dst="$dst"-$(date +%Y-%m-%d-%H-%M-%S)
done
sudo mv "$path" ~/.Trash/"$dst"
fi
done
}
 
 
eg：
 
 
[root@postgres tmp]# cat /bin/trash
#!/bin/sh
# script to send removed files to trash directory
# trash(){ D=/tmp/$(date +%Y%m%d%H%M%S); mkdir -p $D; mv "$@" $D && echo "moved to trash"; }
D=/tmp/$(date +%Y%m%d%H%M%S)  #在文件夹/tmp 下创建 一个 时间为名称的 目录
mkdir -p $D;mv "$@" $D && echo "moved to trash"         #有$1~$9个数量, $@代表all
 
chmod +x /bin/trash
 
 
cat ~/.bash_profile
alias rm=/bin/trash
 
 
[root@postgres ~]# ls -atl /tmp/20200122172212/
total 8
drwxrwxrwt. 17 root root 4096 Jan 22 17:22 ..
drwxr-xr-x   2 root root   18 Jan 22 17:22 .
-rw-r--r--   1 root root    3 Jan 22 17:22 test
 