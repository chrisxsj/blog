# git-repo-clean

**作者**

chrisx

**日期**

2022-01-25

**内容**

仓库体积过大，如何减小?

如用户在使用过程中不小心将较大的二进制文件加入仓库，那么仓库大小很快就会超过规定的配额，用户可以通过去除仓库中的大文件进行瘦身

ref [仓库体积过大，如何减小？](https://gitee.com/help/articles/4232#article-header0)

----

[toc]

## git-repo-clean

```sh
tar -xvf git-repo-clean-1.3.1-Linux-64.tar
sudo cp git-repo-clean /usr/bin/
git repo-clean --version
git repo-clean -i

```

有没有办法把这个文件从历次提交中彻底地移除呢？而不是移除文件。

## 清空git提交记录

１.清空所有历史记录

```sh
git checkout --orphan new_branch    #进入 仓库，创建一个孤立的分支，从而启动一个新的历史记录。此时checkout在新分支上
git add -A  #新分支添加所有的文件
git commit -m 'cx'  #将添加的所有的文件提交到缓冲区
git branch -D master  #删除 master 分支
git branch -m master  #更改当前分支为 master 分支
git push -f origin master #强制更新远程存储库
```

2. 删除本地仓库，重新克隆仓库

```sh
git clone git@gitee.com:chrisxian/work.git
```

<!--
https://www.cnblogs.com/zooqkl/p/10417186.html

chris@hg-cx:/mnt/c/data/gitee/repository$ git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -10
48d252241d4437f69fbb30212453039819f477a5 blob   22181941 22054053 193595368
d5a4d5989b42bd0b035b90c9e419d0c83f92adbc blob   22792888 21515161 668467907
a9937c12ac9b35339ba9c7114422b84d07224a64 blob   23206626 13976032 873734053
77cdee931cf454d6d960059fb0495011e82dbcbc blob   23729145 16562949 839577661
78e2ec881a6fe9507dd26a8feebc21033459c4a5 blob   25280245 20155119 744470450
acf624f3da3710e6171760c3fa1403f2fe8c3764 blob   25634831 8560062 99051542
52576c051eca713fd23aa914d5ffec63e4e37a5f blob   28895921 11301853 138620389
d5df9ea5dc253556ceadd3fde46d0c689dfdeeb1 blob   31390316 31390942 637076965
d982bc9447e662dd58b724fb7ec24a1b2e2f29ff blob   34493751 34504004 786677035
6e2cd525fcad3eff3db431e8adcd0848f7d348e2 blob   47044231 46894314 215756284

chris@hg-cx:/mnt/c/data/gitee/repository$ git rev-list --objects --all | grep 48d252241d4437f69fbb30212453039819f477a5
48d252241d4437f69fbb30212453039819f477a5 hgdb_guidance_doc/瀚高数据库企业版V5流复制-安装手册(Windows平台)V1.1.docx

chris@hg-cx:/mnt/c/data/gitee/repository$ git log --pretty=oneline --branches -- 'hgdb_guidance_doc/瀚高数据库企业版V5流复制-安装手册(Windows平台)V1.1.docx'
d8934c1c8cbfded4fc1e82df5a22ad671bfe8a83 (HEAD -> master, origin/master) cx
eb637e3cf690c27c9acb2ea2da45b625af937182 cx
chris@hg-cx:/mnt/c/data/gitee/repository$

git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch "hgdb_guidance_doc/瀚高数据库企业版V5流复制-安装手册(Windows平台)V1.1.docx"' --prune-empty --tag-name-filter cat -- --all
-->
