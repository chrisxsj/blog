sysinternal

https://technet.microsoft.com/en-us/sysinternals/bb842062
 
2. 以管理员身份运行以上的procexp.exe
3. 在左边的"Process"面板选择进程TNSLSNR.EXE，再选中menu菜单的View->Lower Pane View ->handles
之后在menu菜单的File->Saveas to 来保存到listener_snap1.txt , 这样就可以把TNSLSNR.EXE的process的handle信息保存了。
4. 过一段时间，如果您发现TNSLSNR.EXE又增长了，按照相同的办法，保存成另外一个listener_snap2.txt，便于对比是什么handle增长了。
=====================================
步骤: 双击运行->第一屏选择进程tnslsnr.exe - > 接下来的界面中选择file->save as 将其存为tnslsnr.mmp，上传这个文件