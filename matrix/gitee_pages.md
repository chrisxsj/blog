# gitee_pages

Gitee Pages 是一个免费的静态网页托管服务，您可以使用 Gitee Pages 托管博客、项目官网等静态网页。

## 开通gitee pages

ref[Gitee Pages](https://gitee.com/help/articles/4136#article-header3)

index.html

```html
<html>
    <head>
        <title>chrisx的炉边</title>
    </head>
    <body>
        <h1>test pages</h1>
    </body>
</html>

```

## 安装hugo

Jekyll、Hugo、Hexo 究竟是什么？

Jekyll、Hugo、Hexo 是简单的博客形态的静态站点生产机器。它有一个模版目录，其中包含原始文本格式的文档，通过 Markdown 以及 Liquid 转化成一个完整的可发布的静态网站，你可以发布在任何你喜爱的服务器上。Jekyll、Hugo、Hexo 也可以运行在 Gitee Pages 上，也就是说，你可以使用 Gitee 的服务来搭建你的仓库页面、博客或者网站，而且是完全免费的。

Hugo
Hugo是最简单的，强烈推荐。生成又快，现在Github star数量是静态博客里排名第一的

1. 安装 Git 和 Go

使用Hugo前需要安装[Git](https://git-scm.com/) 和 [Go](https://golang.org/dl/) 语言开发环境，点击对应网址下载安装包即可。

2. 安装Hugo

参考[install](https://gohugo.io/getting-started/installing)

下载[Hugo Releases](https://github.com/gohugoio/hugo/releases)

选择合适的安装包，如
hugo_0.81.0_Windows-64bit.zip

1. 解压获取hugo.exe
2. 将Hugo添加到Windows的环境变量 PATH中

```powershell
PS C:\Users\xians> hugo.exe version
hugo v0.81.0-59D15C97 windows/amd64 BuildDate=2021-02-19T17:07:12Z VendorInfo=gohugoio

```

3. 生成博客站点

hugo new site "你的文件名字"，便可以生成一个用于存放博客的文件夹。

```powershell
PS C:\Users\xians> hugo new site c:\data\hugowebsite
Congratulations! Your new Hugo site is created in c:\data\hugowebsite.

Just a few more steps and you're ready to go:

1. Download a theme into the same-named folder.
   Choose a theme from https://themes.gohugo.io/ or
   create your own with the "hugo new theme <THEMENAME>" command.
2. Perhaps you want to add some content. You can add single files
   with "hugo new <SECTIONNAME>\<FILENAME>.<FORMAT>".
3. Start the built-in live server via "hugo server".

Visit https://gohugo.io/ for quickstart guide and full documentation.
PS C:\Users\xians>

```

其中，config.toml是网站的配置文件，content 目录放 markdown 文章，data 目录放数据，layouts 目录放网站模板文件，static 目录放图片等静态资源，themes 命令放下载的主题。

按照提示，

1. 下载主题

[主题](https://themes.gohugo.io/)

cd themes
git clone https://github.com/panr/hugo-theme-hello-friend.git

或

下载放到themes目录，修改主题名字hello-friend

修改配置文件config.toml，指定主题为angels-ladder，修改完成后的配置文件如下：

baseURL = "http://example.org/"
languageCode = "en-us"
title = "My New Hugo Site"
theme = "ghostwriter-master"

2. 添加文章

```powershell
PS C:\data\hugowebsite> hugo new test.md
C:\data\hugowebsite\content\test.md created

```

此命令会在content目录下新建test.md，这个位置与发布时的url有关，如放在如上所说路径下的.md文件生成网页的访问地址是http://xxx.gitee.io/post/first.md。如果你已有用markdown编写的文章，直接将.md·文件复制到content目录内即可，但是要注意，使用该命令创建的.md文件默认包含以下内容文章标题、文章创建时间、是否为草稿，启动，如果draft: true表示该文章为草稿，在编译的时候会自动略过，发布的站点内也不会有这篇文章。你原有的.md文件也要加上以下内容以便hugo识别。

```hugo
title: "First"
date: 2020-03-01T18:06:24+08:00
draft: true

```

3. 启动服务

在项目根目录下，通过 hugo server 命令可以使用 hugo 内置服务器调试预览博客。--theme 选项可以指定主题，--watch 选项可以在修改文件后自动刷新浏览器，--buildDrafts 包括标记为草稿（draft）的内容。

hugo server --theme ghostwriter --watch

```powershell
c:\data\hugowebsite>hugo server --theme ghostwriter --watch
Start building sites …

                   | EN
-------------------+-----
  Pages            |  9
  Paginator pages  |  0
  Non-page files   |  0
  Static files     |  8
  Processed images |  0
  Aliases          |  3
  Sitemaps         |  1
  Cleaned          |  0

Built in 203 ms
Watching for changes in c:\data\hugowebsite\{archetypes,content,data,layouts,static,themes}
Watching for config changes in c:\data\hugowebsite\config.toml
Environment: "development"
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop

```

## 编译站点

在编译站点之前，要先将config.toml内的baseURL = "http://example.org/"中的url改成自己gitee pages的地址，这是因为gitee pages提供的是托管静态网页的服务，而静态页面要定位到资源要先确定基准地址。笔者修改完成后的config.toml内容如下，具体内容根据你的情况修改：

baseURL = "https://chrisxian.gitee.io/"
languageCode = "en-us"
title = "chrisx"
theme = "hello-friend"

修改完配置文件后，就可以使用hugo -D即可完成站点的编译，或者使用hugo完成编译不带草稿文档的站点。

```powershell
PS C:\data\hugowebsite> hugo -D
Start building sites …

                   | EN
-------------------+-----
  Pages            |  8
  Paginator pages  |  0
  Non-page files   |  0
  Static files     | 16
  Processed images |  0
  Aliases          |  1
  Sitemaps         |  1
  Cleaned          |  0

Total in 200 ms
```

## 部署到gitee

先将你的gitee pages对应的仓库clone到本地
完成后，进入该目录，并将编译完成的站点内的所有文件复制到该目录下
提交推送到gitee服务器

完成后，访问gitee pages地址（如：https://chrisxian.gitee.io/）会发现gitee pages并没有更新，这是因为gitee pages提交后要手动重新部署。使用以下步骤进行重新部署：服务 -> Gitee Pages -> 更新。
