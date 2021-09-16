# windows_terminal

**作者**

chrisx

**时间**

2021-03-03

**内容**

windows terminal自定义配置

---

## 自定义配置

Windows Terminal 的配置文件是一个 JSON 格式的文件，我们会在其中定义全部 Windows Terminal 的属性。简单来讲，这个配置文件包含了如下的几个部分：

* 全局属性：位于 JSON 最外侧，包含有设置亮暗主题、默认 Profile 等项目的配置。

* 环境入口 profiles：一个列表，其中包含有 Windows Terminal 下拉菜单中唤起的各种环境（比如打开 PowerShell 环境、WSL 环境或 SSH 至远程服务器的环境……）与各种环境里 Windows Terminal 的显示方案（比如字体、背景、色彩方案等）。

* 配色主题 schemes：一个配色方案列表，其中包含有 Windows Terminal 在上一项「环境入口」中可以调用的「色彩主题」。

* 快捷键绑定 keybindings：自定义快捷键。

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
        "name": "Sonoran Sunrise",
        "black": "#F9FAE3",
        "red": "#EB6f6f",
        "green": "#669C50",
        "yellow": "#F2C55C",
        "blue": "#227B4D",
        "purple": "#7189D9",
        "cyan": "#E07941",
        "white": "#665E4B",
        "brightBlack": "#F9FAE3",
        "brightRed": "#EB6f6f",
        "brightGreen": "#669C50",
        "brightYellow": "#F2C55C",
        "brightBlue": "#227B4D",
        "brightPurple": "#7189D9",
        "brightCyan": "#E07941",
        "brightWhite": "#665E4B",
        "background": "#F9FAE3",
        "foreground": "#61543E",
        "cursorColor": "#61543E"
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

我们需要在配置里面添加一行

```json
"colorScheme": "Sonoran Sunrise",

```

> 注意，Sonoran Sunrise是配色方案中的"name"

参考[官方文档-配色方案](https://docs.microsoft.com/zh-cn/windows/terminal/customize-settings/color-schemes)
参考[主题](https://windowsterminalthemes.dev)