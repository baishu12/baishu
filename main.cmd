@echo off
REM �������ļ�Ϊ����������������ɸ���ʵ����Ҫ�޸�
REM ɾ����Ŀ¼��Ӱ��WinPE������ϵͳά��

REM %CurDir% ��ʾ��ǰĿ¼
REM %Desktop% ��ʾϵͳ����
REM %Programs% ��ʾ��ʼ�˵�·��
REM %QuickLaunch\User Pinned\StartMenu ��ʾ��������Ŀ¼
REM %SystemRoot% ��ʾ Windows Ŀ¼

REM �粻Ϊ WinPE ��ֱ���˳�
if not exist X: goto :eof

REM ע���ȼ�
call :hotk "��ͼ����.exe CTRL+ALT+A"

REM ������ݷ�ʽ
call :link "EasyRCV2.exe %Desktop%\EasyRC һ����װ" "EasyRCV2.exe %Programs%\���ݻ�ԭ\EasyRC һ����װ"
call :link "PartAssist.exe %Desktop%\��������" "PartAssist.exe %Programs%\���̹���\��������"

call :link "WinNTSetup.exe %Programs%\���ݻ�ԭ\WinNTSetup"

call :link "Defraggler.exe %Programs%\���̹���\������Ƭ����"

call :link "EasyRecovery.exe %Programs%\�ļ�����\EasyRecovery"

call :link "Aida64.exe %Programs%\Ӳ�����\Aida64"

REM �����PE
if exist "%SystemRoot%\SYSTEM32\netsetupsvc.dll" (
    call :link "TheWorld.exe, %Desktop%\����֮�� �����" "TheWorld.exe %Programs%\���繤��\����֮�� �����"
    call :link "Thunder.exe %Desktop%\Ѹ��" "Thunder.exe %Programs%\���繤��\Ѹ��"
    call :link "ToDesk.exe %Desktop%\Todesk Զ�̿���" "ToDesk.exe %Programs%\���繤��\Todesk Զ�̿���"
    call :link "Mstsc.exe %Programs%\���繤��\Զ����������"
    call :link "iStorage.exe %Programs%\���繤��\iStorage ������"
)

REM ˢ������
PECMD ENVI @@DeskTopFresh=1

REM ���и��ֳ�ʼ��
for %%a in ("%~dp0*.reg" "%~dp0*.wcs" "%~dp0*.cmd" "%~dp0*.bat") do (if not "%%~fa"=="%~0" call :exec "%%~a")
call :exec install.reg install.bat install.cmd

REM ��������
setlocal enabledelayedexpansion
for %%i in (%~dp0��������\*.zip %~dp0��������\*.7z %~dp0��������\*.rar) do (
	set indexFile=%~dp0��������\%%~ni.index
	call :Log WinPE��ʼ�� ���ڼ�������: %%~ni
	if exist !indexFile! (
		DriverIndexer --debug load-driver "%%i" "!indexFile!"
	) else (
		DriverIndexer --debug load-driver "%%i"
	)
)
setlocal disabledelayedexpansion

goto :eof


:link
REM ��ݷ�ʽ
REM ����λ�ÿ����Ǿ���ֵ����������ִ�У�Ĭ������System32���������������ļ�����Ŀ¼�£�
REM call :link "����λ�� ��ݷ�ʽλ��,ͼ��,����"
REM call :link "����λ�� ��ݷ�ʽλ��,ͼ��,����" "����λ�� ��ݷ�ʽλ��,ͼ��,����"

:pint
rem �̶���������
REM call :pint "����λ��"

:hotk
REM ��ݼ�
REM call :hotk "����λ�� �ȼ�"

:exec
REM ���г���
REM call :exec "����λ�� [����]"

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
REM %1: ����·��
REM %~2: ��ݷ�ʽ·��
REM %~f0: ��ǰ�ļ�·��
set icon=%1
REM ����ͬ�ļ���ͼ��
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
rem ��־��ʹ�÷�����call :Log ��־��� ��־���ݡ�ע�⣺������пո�����Ҫʹ������
echo %time% %~1-%~2 >>X:\Users\Log.txt
goto :eof