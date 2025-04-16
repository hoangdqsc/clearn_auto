@echo off

:: Kiểm tra quyền admin, nếu không thì thoát
net session >nul 2>&1
if %errorlevel% neq 0 exit /b

:: ========== 1. XÓA FILE + FOLDER TRONG TEMP NGƯỜI DÙNG ==========
:: Xóa file trong Temp user
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1

:: Xóa folder con trong Temp user
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

exit /b
