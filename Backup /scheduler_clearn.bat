@echo off
setlocal

:: Kiểm tra quyền admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Vui lòng chạy script này với quyền Administrator.
    pause
    exit /b
)

:: Đường dẫn tới script cần chạy
set CLEANUP_SCRIPT=C:\Scripts\clearn_auto.bat
set TASK_NAME=AutoCleanupOnStartup

:: Tạo tác vụ
schtasks /create ^
 /tn "%TASK_NAME%" ^
 /tr "%CLEANUP_SCRIPT%" ^
 /sc onstart ^
 /ru SYSTEM ^
 /rl HIGHEST ^
 /f

:: Kiểm tra lỗi
if %errorlevel% neq 0 (
    echo Lỗi khi tạo tác vụ.
    pause
    exit /b
)

echo Đã tạo tác vụ "%TASK_NAME%" chạy khi khởi động máy.
pause
exit /b
