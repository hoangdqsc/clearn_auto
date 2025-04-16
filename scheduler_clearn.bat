@echo off
setlocal

:: Đường dẫn đến script dọn dẹp (sửa nếu bạn đặt chỗ khác)
set CLEANUP_SCRIPT=C:\Scripts\scheduler_clearn.bat

:: Tên tác vụ muốn tạo
set TASK_NAME_SHUTDOWN=AutoCleanupOnShutdown
set TASK_NAME_RESTART=AutoCleanupOnRestart

:: ===================== TẠO TÁC VỤ KHI SHUTDOWN =======================
:: Tạo tác vụ chạy lúc shutdown
schtasks /create ^
    /tn "%TASK_NAME_SHUTDOWN%" ^
    /tr "%CLEANUP_SCRIPT%" ^
    /sc onevent ^
    /ec System ^
    /ev Microsoft-Windows-ShutdownEvent ^
    /ru "SYSTEM" ^
    /rl HIGHEST ^
    /f >nul 2>&1

:: ===================== TẠO TÁC VỤ KHI RESTART =======================
:: Tạo tác vụ chạy lúc restart (khởi động lại máy)
schtasks /create ^
    /tn "%TASK_NAME_RESTART%" ^
    /tr "%CLEANUP_SCRIPT%" ^
    /sc onstart ^
    /ru "SYSTEM" ^
    /rl HIGHEST ^
    /f >nul 2>&1

:: Xác nhận đã tạo xong
echo Tác vụ "%TASK_NAME_SHUTDOWN%" đã được tạo để chạy khi shutdown.
echo Tác vụ "%TASK_NAME_RESTART%" đã được tạo để chạy khi restart.
pause
exit /b
