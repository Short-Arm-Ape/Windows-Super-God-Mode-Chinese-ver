@echo off
chcp 65001
:: 以两个冒号开头的行::是注释

:: ----------------------------- 如果找不到实际脚本，则显示错误 ---------------------------------
if not exist "Super_God_Mode.ps1" (
    echo --- 错误: 此脚本 "Super_God_Mode.ps1" 在当前目录下未找到 ---
    echo 请确保PowerShell脚本与此批处理文件位于同一文件夹中。此批处理文件只是启动脚本。
	echo.
	echo 按任意键退出...
	pause > nul
)
:: --------------------------------------------------------------------------------------------

:: 设置当前进程的执行策略以允许脚本运行，然后运行它。
powershell -NoProfile -ExecutionPolicy Bypass -File "Super_God_Mode.ps1"

:: 或者，您可以在运行脚本之前在PowerShell窗口中自己运行此命令：
:: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
:: 这也将只会允许当前PowerShell会话的脚本，然后您可以使用以下命令运行脚本：
:: .\Super_God_Mode.ps1
:: 注意执行命令时别把命令前::（双冒号）和 （空格）复制了
