@echo off
setlocal

:: ===== Kiểm tra quyền admin, nếu không thì tự yêu cầu bật lại =====
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Script chưa chạy với quyền Administrator. Đang yêu cầu bật lại...
    set "vbsfile=%temp%\getadmin.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~s0", "", "", "runas", 1 > "%vbsfile%"
    cscript //nologo "%vbsfile%"
    del "%vbsfile%"
    exit /b
)

echo [+] Đang chạy với quyền Administrator. Bắt đầu dọn dẹp...

:: ========== 1. XÓA FILE + FOLDER TRONG TEMP NGƯỜI DÙNG ==========
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
for /d %%i in ("%LOCALAPPDATA%\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: ========== 2. XÓA FILE + FOLDER TRONG WINDOWS TEMP ==========
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: ========== 3. XÓA PREFETCH ==========
del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1

:: ========== 4. XÓA THÙNG RÁC ==========
powershell.exe -command "Clear-RecycleBin -Force" >nul 2>&1

:: ========== 5. XÓA FILE UPDATE WINDOWS CŨ ==========
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%i" >nul 2>&1

:: ========== 6. XÓA WINDOWS.OLD (NẾU CÓ) ==========
if exist "C:\Windows.old" rd /s /q "C:\Windows.old"

:: ========== 7. XÓA ĐIỂM KHÔI PHỤC CŨ ==========
vssadmin delete shadows /for=c: /oldest >nul 2>&1

:: ========== 8. DỌN CACHE TRÌNH DUYỆT ==========
:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
)

:: Edge
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
)

echo [+] Dọn dẹp hoàn tất!
timeout /t 3 >nul
exit /b
