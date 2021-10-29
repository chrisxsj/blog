# Git

**作者**

chrisx

**时间**

2021-03-02

**内容**

git的学习和使用
Git是目前世界上最先进的分布式版本控制系统

ref [git](https://git-scm.com/doc)

git学习

[Git 命令学习](https://oschina.gitee.io/learn-git-branching)
[git教程](https://www.liaoxuefeng.com/wiki/896043488029600)

---

[toc]

## 下载安装

下载地址[GIT](https://git-scm.com/download/)

## git使用

1. 创建密钥

```sh
ssh-keygen
cat ~/.ssh/id_rsa.pub

```

2. 添加密钥

去你的代码托管服务器，你的账号设置中，添加它。

打开主页-setting-ssh keys-add key。填写Title、key

[sshkeys](https://gitee.com/profile/sshkeys)

> 注意，需要认证gitee用户密码

3. 填写用户认证

```sh
git config --global user.email "xianshijie0@163.com"
git config --global user.name "Chrisx"

```

> 注意，替换email和name

4. 使用

clone仓库

```sh
git clone git@gitee.com:chrisxian/blog.git 
# clone的自动关联远程仓库
# 只是为了clone小的话，用--depth=1只获取最新的commit即可
```

创建本地仓库，命令示例

```sh
mkdir imagehost # 创建目录
git init    #git初始化
#本地初始化的需要关联远程仓库
git add .
git commit -m 'init'
git remote add gitee git@gitee.com:chrisxian/imagehost.git    #设置remote地址
git branch --set-upstream-to=gitee/master #关联本地 master 到远程 master
git pull gitee --allow-unrelated-histories #pull远程仓库的内容，更新本地仓库，使用–allow-unrelated-histories忽略本地仓库和远程仓库的无关性，强行合并（关键）：
git push --set-upstream gitee main
```

## git两个仓库

### 将本地仓库与 Gitee 和 GitHub 两个远程库关联

如果原本只有 GitHub 一个远程库，则要注意，git 给远程库起的默认名称是 origin，需要用不同的名称来标识不同的远程库（GitHub & Gitee），则先删除

```sh
git remote rm origin    #删除已关联的名为 origin 的远程库
git remote add github 远程库地址    #先关联GitHub的远程库.注意，远程库的名称叫 github，不叫 origin 了。
git remote add gitee 远程库地址 #再关联 Gitee 的远程库

```

查看远程库信息，可以看到两个远程库

```sh
git remote -v
chrisx@hg-cx:/opt/git/blog$ git remote -v
gitee   git@gitee.com:chrisxian/blog.git (fetch)
gitee   git@gitee.com:chrisxian/blog.git (push)
github  git@github.com:chrisxsj/blog.git (fetch)
github  git@github.com:chrisxsj/blog.git (push)

```

### 同步更新

```sh
git add . #将工作区的“新建/修改”添加到暂存区
git commit -m "提交日志" #将暂存区的内容提交到本地库
git push -u github master  #推送到 GitHub
git push -u gitee master   #推送到 Gitee

```

:warning: 如果permission denied（publickey），则需要在github或gitee中提供本地git的ssh key；GitHub添加SSH key

## vscode管理

安装完git后，可以使用vscode直接管理gitee仓库

将gitee仓库添加到vscode，打开文件夹或工作区

1. 本地创文件变化后，vs里我们就可以看到这些变化，新增的文件时绿色的，后面有个U字母，修改的文件是个M，左侧图标上会有数字显示
2. 点击左侧图标，然后点击更改旁边的+号，暂存所有的更改
3. 在上面输入文字，这里的文字要好好写，后面你会发现是很有必要的，写好后点击“对号√”，就提交了，注意只是提交到你的本地仓库
4. 点击推送到，把这些更改push到码云仓库里

## error: RPC failed

Delta compression using up to 4 threads.
Compressing objects: 100% (2364/2364), done.
Writing objects: 100% (4329/4329), 1.15 MiB | 11.20 MiB/s, done.
Total 4329 (delta 2657), reused 3050 (delta 1497)
error: RPC failed; HTTP 413 curl 22 The requested URL returned error: 413 Request Entity Too Large
fatal: The remote end hung up unexpectedly
fatal: The remote end hung up unexpectedly
Everything up-to-date

问题在于用http提交有上传大小限制，修改上传大小限制使用 git config --global http.postBuffer 52428800 后依然报错；

改为了ssh提交就好了 (git remote -v查询git的提交地址)

git remote set-url origin ssh://xxx@github.org/hello/etl.git