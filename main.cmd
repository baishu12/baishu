@echo off
REM 本配置文件为加载外置组件包，可根据实际需要修改
REM 删除本目录不影响WinPE的正常系统维护

REM %CurDir% 表示当前目录
REM %Desktop% 表示系统桌面
REM %Programs% 表示开始菜单路径
REM %QuickLaunch\User Pinned\StartMenu 表示快速启动目录
REM %SystemRoot% 表示 Windows 目录

REM 如不为 WinPE 则直接退出
if not exist X: goto :eof

REM 注册热键
call :hotk "截图工具.exe CTRL+ALT+A"

REM 创建快捷方式
call :link "EasyRCV2.exe %Desktop%\EasyRC 一键重装" "EasyRCV2.exe %Programs%\备份还原\EasyRC 一键重装"
call :link "PartAssist.exe %Desktop%\分区助手" "PartAssist.exe %Programs%\磁盘工具\分区助手"

call :link "WinNTSetup.exe %Programs%\备份还原\WinNTSetup"

call :link "Defraggler.exe %Programs%\磁盘工具\磁盘碎片整理"

call :link "EasyRecovery.exe %Programs%\文件工具\EasyRecovery"

call :link "Aida64.exe %Programs%\硬件检测\Aida64"

REM 网络版PE
if exist "%SystemRoot%\SYSTEM32\netsetupsvc.dll" (
    call :link "TheWorld.exe, %Desktop%\世界之窗 浏览器" "TheWorld.exe %Programs%\网络工具\世界之窗 浏览器"
    call :link "Thunder.exe %Desktop%\迅雷" "Thunder.exe %Programs%\网络工具\迅雷"
    call :link "ToDesk.exe %Desktop%\Todesk 远程控制" "ToDesk.exe %Programs%\网络工具\Todesk 远程控制"
    call :link "Mstsc.exe %Programs%\网络工具\远程桌面连接"
    call :link "iStorage.exe %Programs%\网络工具\iStorage 服务器"
)

REM 刷新桌面
PECMD ENVI @@DeskTopFresh=1

REM 运行各种初始化
for %%a in ("%~dp0*.reg" "%~dp0*.wcs" "%~dp0*.cmd" "%~dp0*.bat") do (if not "%%~fa"=="%~0" call :exec "%%~a")
call :exec install.reg install.bat install.cmd

REM 加载驱动
setlocal enabledelayedexpansion
for %%i in (%~dp0驱动程序\*.zip %~dp0驱动程序\*.7z %~dp0驱动程序\*.rar) do (
	set indexFile=%~dp0驱动程序\%%~ni.index
	call :Log WinPE初始化 正在加载驱动: %%~ni
	if exist !indexFile! (
		DriverIndexer --debug load-driver "%%i" "!indexFile!"
	) else (
		DriverIndexer --debug load-driver "%%i"
	)
)
setlocal disabledelayedexpansion

goto :eof


:link
REM 快捷方式
REM 程序位置可以是具体值，否则将搜索执行（默认搜索System32，否则搜索配置文件所有目录下）
REM call :link "程序位置 快捷方式位置,图标,参数"
REM call :link "程序位置 快捷方式位置,图标,参数" "程序位置 快捷方式位置,图标,参数"

:pint
rem 固定到任务栏
REM call :pint "程序位置"

:hotk
REM 快捷键
REM call :hotk "程序位置 热键"

:exec
REM 运行程序
REM call :exec "程序位置 [参数]"

for %%a in (%*) do (
    if exist "%%~a" (
        call %0start "%%~a"
    ) else for /f "tokens=1*" %%b in ("%%~a") do (
        if exist "%%~b" (
            call %0start "%%~b" "%%~c"
        ) else for /r "%~dp0" %%i in (%%b) do (
            if exist "%%~i" call %0start "%%~i" "%%~c"
        )
    )
)
goto :eof

:linkstart
REM %1: 程序路径
REM %~2: 快捷方式路径
REM %~f0: 当前文件路径
set icon=%1
REM 设置同文件名图标
if exist %~dpn1.ico set icon=%~dpn1.ico

if exist "%ProgramFiles%\Launcher.cmd" (
    start PECMD.exe LINK %~2,PECMD.exe,EXEC! "%ProgramFiles%\Launcher.cmd" autoBuiltIn "%~2" %1,%icon%
) else (
    start PECMD.exe LINK %~2,%1
)
goto :eof

:pintstart
start PECMD.exe PINT %1,TaskBand
goto :eof

:hotkstart
start PECMD.exe HOTK %~2,%1
goto :eof

:execstart
if /i "%~x1"==".reg" (
    start regedit.exe /s %1
) else if /i "%~x1"==".inf" (
    start PECMD.exe DEVI %1
) else if /i "%~x1"==".ini" (
    start PECMD.exe LOAD %1
) else (
    start PECMD.exe EXEC !%1 %~2
)
goto :eof

:Log
rem 日志，使用方法：call :Log 日志类别 日志内容。注意：如参数有空格则需要使用引号
echo %time% %~1-%~2 >>X:\Users\Log.txt
goto :eof