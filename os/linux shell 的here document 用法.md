linux shell 的here document 用法 (cat << EOF)
收藏
GreatFish
	* 
发表于 3年前
	* 
阅读 7931
	* 
收藏 6
	* 
点赞 0
	* 
评论 3


什么是Here Document
Here Document 是在Linux Shell 中的一种特殊的重定向方式，它的基本的形式如下
cmd << delimiter
Here Document Content
delimiter
它的作用就是将两个 delimiter 之间的内容(Here Document Content 部分) 传递给cmd 作为输入参数。
比如在终端中输入cat << EOF ，系统会提示继续进行输入，输入多行信息再输入EOF，中间输入的信息将会显示在屏幕上。如下：
fish@mangos:~$ cat << EOF
> First Line
> Second Line
> Third Line EOF
> EOF
First Line
Second Line
Third Line EOF
注： >这个符号是终端产生的提示输入信息的标识符
这里要注意几点
	1. 
EOF 只是一个标识而已，可以替换成任意的合法字符
	2. 
作为结尾的delimiter一定要顶格写，前面不能有任何字符
	3. 
作为结尾的delimiter后面也不能有任何的字符（包括空格）
	4. 
作为起始的delimiter前后的空格会被省略掉


Here Document 不仅可以在终端上使用，在shell 文件中也可以使用，例如下面的here.sh 文件
cat << EOF > output.sh
echo "hello"echo "world"
EOF
使用 sh here.sh 运行这个脚本文件，会得到output.sh 这个新文件，里面的内容如下
echo "hello"echo "world"
Here Document的变形
delimiter 与变量
在Here Document 的内容中，不仅可以包括普通的字符，还可以在里面使用变量，例如将上面的here.sh 改为
cat << EOF > output.sh
echo "This is output"echo $1
EOF
使用sh here.sh HereDocument 运行脚本得到output.sh的内容
echo "This is output"echo HereDocument
在这里 $1 被展开成为了脚本的参数 HereDocument
但是有时候不想展开这个变量怎么办呢，可以通过在起始的 delimiter的前后添加 " 来实现，例如将上面的here.sh 改为
cat << "EOF" > output.sh #注意引号echo "hello"echo "world"
EOF
得到的output.sh 的内容为
echo "This is output"echo $1
<< 变为 <<-
Here Document 还有一个用法就是将 '<<' 变为 '<<-'。 使用 <<- 的唯一变化就是Here Document 的内容部分每行前面的 tab (制表符)将会被删除掉，这种用法是为了编写Here Document的时候可以将内容部分进行缩进，方便阅读代码。
参考链接
Wiki: Here Document<br /> Learn Linux, 101: Streams, pipes, and redirects
 
来自 <https://my.oschina.net/u/1032146/blog/146941>