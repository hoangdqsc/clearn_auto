@echo off
setlocal enabledelayedexpansion

:: =========================================================
:: UJU VINA IT - SYSTEM OPTIMIZER (FINAL VERSION)
:: =========================================================

:: 1. CẤU HÌNH ĐƯỜNG DẪN
set CONFIG=C:\Scripts\config.json
set LOG=C:\Scripts\clearn.log
:: Thay đổi địa chỉ dưới đây thành thư mục chia sẻ trên Server của bạn
set SERVER_LOG_PATH=\\30.10.20.102\LogClearn\

:: 2. KHỞI TẠO CẤU HÌNH
if not exist C:\Scripts mkdir C:\Scripts
if not exist %CONFIG% (echo {"mode": "SAFE", "hidden": true} > %CONFIG%)

:: 3. CHẾ ĐỘ ẨN (HIDDEN MODE) - DÙNG POWERSHELL HIỆN ĐẠI
for /f "tokens=1,2 delims=:," %%a in ('powershell -Command "(Get-Content '%CONFIG%') | Select-String 'hidden'"') do set IS_HIDDEN=%%~b
set IS_HIDDEN=%IS_HIDDEN: =%

if "%IS_HIDDEN%"=="true" if "%~1" neq "hidden" (
    powershell -WindowStyle Hidden -Command "Start-Process cmd.exe -ArgumentList '/c \"%~f0\" hidden' -WindowStyle Hidden"
    exit
)

:: 4. QUYỀN ADMIN
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -ArgumentList 'hidden' -Verb RunAs"
    exit
)

:: 5. LOAD MODE (SAFE/FULL)
for /f "tokens=1,2 delims=:," %%a in ('powershell -Command "(Get-Content '%CONFIG%') | Select-String 'mode'"') do set MODE=%%~b
set MODE=%MODE: =%
set MODE=%MODE:"=%

echo ===== START CLEAN %date% %time% MODE=%MODE% ===== > %LOG%

:: =========================================================
:: 6. MAIN PROGRESS
:: =========================================================
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
if %errorlevel% neq 0 call :log_error "User Temp"
for /d %%i in ("%LOCALAPPDATA%\Temp\*") do rd /s /q "%%i" >nul 2>&1

del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
if %errorlevel% neq 0 call :log_error "Windows Temp"
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1

powershell -command "Clear-RecycleBin -Force" >nul 2>&1

taskkill /f /im chrome.exe /t >nul 2>&1
taskkill /f /im msedge.exe /t >nul 2>&1
for /d %%d in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do if exist "%%d\Cache" del /f /s /q "%%d\Cache\*" >nul 2>&1
for /d %%d in ("%LOCALAPPDATA%\Microsoft\Edge\User Data\*") do if exist "%%d\Cache" del /f /s /q "%%d\Cache\*" >nul 2>&1

if /I "%MODE%"=="FULL" (
    net stop wuauserv >nul 2>&1
    del /f /s /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
    net start wuauserv >nul 2>&1
    del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
)

:: =========================================================
:: 7. FINALIZE & SYNC TO SERVER
:: =========================================================
echo ===== DONE %date% %time% ===== >> %LOG%

:: Lấy ngày tháng định dạng YYYY-MM-DD
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set TODAY=%%c-%%b-%%a

:: Đẩy log về Server với định dạng [TenMay]_[NgayThang].log
if exist "%SERVER_LOG_PATH%" (
    copy /y "%LOG%" "%SERVER_LOG_PATH%%COMPUTERNAME%_%TODAY%.log" >nul 2>&1
)

:: Dọn dẹp log cũ trên Server quá 30 ngày để tiết kiệm dung lượng
if exist "%SERVER_LOG_PATH%" (
    forfiles /p "%SERVER_LOG_PATH%" /m *.log /d -30 /c "cmd /c del @path" >nul 2>&1
)

exit

:: =========================================================
:: SUBROUTINE: LOG ERROR
:: =========================================================
:log_error
echo [%date% %time%] ERROR: %1 failed >> %LOG%
goto :eof
