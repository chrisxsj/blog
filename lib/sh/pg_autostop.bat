@echo off 　　
if "%1" == "h" goto begin 
    mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit 
:begin 
::
pg_ctl stop

goto comment bat里有隐藏窗口的命令，很简单，只需要在代码头部加一段代码就可以了。
goto comment @echo off 　　
goto comment if "%1" == "h" goto begin 
goto comment mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit 
goto comment :begin 
goto comment ::下面是你自己的代码。


