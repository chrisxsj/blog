# windows_terminal

**作者**

chrisx

**时间**

2021-03-03

**内容**

windows terminal使用

ref [Windows 终端](https://docs.microsoft.com/zh-cn/windows/terminal/)

ref [官方文档-配色方案](https://docs.microsoft.com/zh-cn/windows/terminal/customize-settings/color-schemes)

ref [主题](https://windowsterminalthemes.dev)

---

[toc]

## 安装

ref [install](https://aka.ms/terminal)

## 自定义配置

设置-配置文件-外观

## 快捷键，标签页切换

自定义快捷键，通过alt+数字键快速切换不同的标签页

将快捷键定义到actions

```json
    // Add custom actions and keybindings to this array.
    // To unbind a key combination from your defaults.json, set the command to "unbound".
    // To learn more about actions and keybindings, visit https://aka.ms/terminal-keybindings
    "actions":
    [

    ]

```

在此区域添加如下的设置

```json
// Add custom actions and keybindings to this array.
"actions":
[

// switchToTab
{ "command": { "action": "switchToTab", "index": 0 }, "keys": "alt+1" },
{ "command": { "action": "switchToTab", "index": 1 }, "keys": "alt+2" },
{ "command": { "action": "switchToTab", "index": 2 }, "keys": "alt+3" },
{ "command": { "action": "switchToTab", "index": 3 }, "keys": "alt+4" },
{ "command": { "action": "switchToTab", "index": 4 }, "keys": "alt+5" },
{ "command": { "action": "switchToTab", "index": 5 }, "keys": "alt+6" },
{ "command": { "action": "switchToTab", "index": 6 }, "keys": "alt+7" },
{ "command": { "action": "switchToTab", "index": 7 }, "keys": "alt+8" },
{ "command": { "action": "switchToTab", "index": 8 }, "keys": "alt+9" },

]

```

参考[官方文档](https://docs.microsoft.com/en-gb/windows/terminal/customize-settings/key-bindings)

## 自定义主题

可以在 settings.json 文件的 schemes 数组中定义配色方案。

```json
// Add custom color schemes to this array.
// To learn more about color schemes, visit https://aka.ms/terminal-color-schemes
"schemes": [
]

```

在此区域添加如下的配置，配色方案

```json
"schemes": [
    {
      "name": "Ubuntu",
      "black": "#2e3436",
      "red": "#cc0000",
      "green": "#4e9a06",
      "yellow": "#c4a000",
      "blue": "#3465a4",
      "purple": "#75507b",
      "cyan": "#06989a",
      "white": "#d3d7cf",
      "brightBlack": "#555753",
      "brightRed": "#ef2929",
      "brightGreen": "#8ae234",
      "brightYellow": "#fce94f",
      "brightBlue": "#729fcf",
      "brightPurple": "#ad7fa8",
      "brightCyan": "#34e2e2",
      "brightWhite": "#eeeeec",
      "background": "#300a24",
      "foreground": "#eeeeec",
      "selectionBackground": "#b5d5ff",
      "cursorColor": "#bbbbbb"
    }
],

```

指定terminal使用配色方案。找到 profiles 项目，里面是不同的终端的详细配置。 下面以 PowerShell 修改为例，

```json
"profiles":
{
    "defaults":
    {
        // Put settings here that you want to apply to all profiles.
    },
    "list":
    [
        {
            // Make changes here to the powershell.exe profile.
            "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
            "name": "Windows PowerShell",
            "commandline": "powershell.exe",
            // colorScheme
            "colorScheme": "Sonoran Sunrise",
            "hidden": false

```

我们需要在配置里面添加一行、或修改

```json
"colorScheme": "Sonoran Sunrise",

```

> 注意，Sonoran Sunrise是配色方案中的"name"
