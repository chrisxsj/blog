# vscode

## 插件 extension

* HBuilderX Soft Green Light Theme--绿柔主题的特点是柔和、低对比度、强光可见、绿色感加强
* Markdown Preview Enhanced是一个很好用的完善预览功能的插件
* Maridown pdf插件可以简单的将编写的.md文件转换成其他格式的文件
* Chinese (Simplified) Language Pack for Visual Studio Code
* Remote - WSL
* markdownlint, markdown语法检查和修复
* markdownlint is a Visual Studio Code extension that includes a library of rules to encourage standards and consistency for Markdown files. It is powered by markdownlint for Node.js which is based on markdownlint for Ruby.
* docs-markdown
* Markdown Shortcuts, 提供markdown快捷命令，右击或右上角
* markdown-formatter，格式化markdown文本。右击
* vscode-pdf (Multi-language support),在vscode中显示查看pdf文件

## 小技巧

* 打开markdown文件，然后按cmd+k 再按V键 就可以边写边预览了
* ctrl+b 打开和关闭侧边栏

## 高效编写shell脚本

需求及对应的解决插件

* 智能提示AutoComplate Shell
* 格式化代码shell-format 【快捷键：shift+alt+f】
* 引用查找Bash IDE

## settings.json

{
    "workbench.colorTheme": "HBuilderX Soft Green Light",
    "markdownShortcuts.icons.link": true,
    "markdownShortcuts.icons.image": true,
    "markdownShortcuts.icons.citations": true,
    "window.zoomLevel": 0,
    "git.autofetch": true,
    "[markdown]": {
        "editor.defaultFormatter": "yzhang.markdown-all-in-one"
    },
    "editor.renderControlCharacters": true,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 10000,
    "workbench.editorAssociations": [
    
    ],
    "workbench.editor.enablePreviewFromQuickOpen": false
}

