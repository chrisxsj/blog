# shell_concurrency

**作者**

Chrisx

**日期**

2022-02-15

**内容**

shell命令并发及并发控制

----

[toc]

## 并发

默认，shell命令是串行执行，如果一批命令需要执行，而又相互影响情况下，使用并发能提高速度和效率

## 通过文件描述符和命名管道实现并发

### 文件描述符

fd 是文件描述符。每个打开的文件都有一个文件描述符编号

```sh
ll /proc/$$/fd  #查看当前进程的文件描述符
```

### 自定义文件描述符

自定义文件描述符时，使用的文件编号不能被占用

```sh
exec 8<> /tmp/file  #自定义用当前进程打开一个文件
echo "111" >> /tmp/file #给文件写入、追加内容
exec 8<&-       #自定义用当前进程关闭一个文件

```

### 文件描述符恢复文件

原文件备删除后，如果进程没有停止，可使用进程打开的文件描述符恢复文件。

```sh
exec 8<> /tmp/file  #自定义用当前进程打开一个文件
echo "111" >> /tmp/file #给文件写入、追加内容
rm /tmp/file    #删除源文件
ll /proc/$$/fd  #查看当前进程的文件描述符，状态为删除
cp /proc/$$/fd/8 /tmp/file  #拷贝文件描述符恢复文件
exec 8<&-       #关闭文件
exec 8<> /tmp/file  #重新读取文件
```

### 命名管道

默认管道|是匿名管道，不能跨终端。使用命名管道

```sh
mkfifo /tmp/fifo1   #创建命名管道文件（管道内的文件只能读取一次，不能永久保存）
cat /tmp/fifo1  #查看管道命名文件
```

### 实现多进程并发控制

通过文件描述符和命名管道实现多进程并发控制

```sh multi.sh
#! /bin/bash
# multi thread
thread=5
tmp_fifo_file=/tmp/$$.fifo  #当前进程pid创建命名管道文件，避免冲突

mkfifo $tmp_fifo_file
exec 8<> $tmp_fifo_file #当前进程打开创建的命名管道文件
rm $tmp_fifo_file   #删除命名管道文件 ？

for i in $(seq $thread)
do
    echo "11" >&8    #给命名管道文件（&8）输入$thread条记录。（写入任何内容都可以，添加$thread条记录，管道文件内容不会被覆盖）
done

for i in {1..254}
do
    read -u 8   #读取一次文件描述符的内容。（读取$thread次）
    {
        echo "current time is $(date) " >> /tmp/multi.log 2>&1
        echo "11" >&8   #给管道文件（描述符8）写入一条记录，还回一条记录。
    } &

done
wait    #等待循环结束
exec 8<&-
echo "all finish $(date)" >>/tmp/multi.log 2>&1

```

初始时给管道写入$thread个字符，然后每从管道读出一个字符串就生成一个子进程。当管道内没有字符串可读时就阻塞在那里。每个并发进程执行完毕时又向管道内写入一个字符串。表示子进程执行完毕，可以创建新的子进程。

