@echo off
setlocal

:: Path to the cleanup script (adjust if placed elsewhere)
set CLEANUP_SCRIPT=C:\Scripts\clearn_auto.bat

:: Task names to be created
set TASK_NAME_SHUTDOWN=AutoCleanupOnShutdown
set TASK_NAME_RESTART=AutoCleanupOnRestart

:: ===================== CREATE TASK FOR SHUTDOWN =======================
:: Create task to run at shutdown
schtasks /create /tn "%TASK_NAME_SHUTDOWN%" ^
    /tr "%CLEANUP_SCRIPT%" ^
    /sc onstart ^
    /ru "SYSTEM" ^
    /rl HIGHEST ^
    /f

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Unable to create task "%TASK_NAME_SHUTDOWN%"
    pause
    exit /b
)

:: ===================== CREATE TASK FOR RESTART =======================
:: Create task to run at restart (on system restart)
schtasks /create /tn "%TASK_NAME_RESTART%" ^
    /tr "%CLEANUP_SCRIPT%" ^
    /sc onstart ^
    /ru "SYSTEM" ^
    /rl HIGHEST ^
    /f

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Unable to create task "%TASK_NAME_RESTART%"
    pause
    exit /b
)

:: Confirmation that the tasks were created successfully
echo Task "%TASK_NAME_SHUTDOWN%" has been created to run at shutdown.
echo Task "%TASK_NAME_RESTART%" has been created to run at restart.
pause
exit /b
