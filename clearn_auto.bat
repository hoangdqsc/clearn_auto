@echo off
:: =========================================
:: =========================================
::    UPDATE NGAY 27-03-2026

:: =========================================
:: UPDATE SCRIPT (update.ps1)
:: =========================================
echo Updating updater script...

powershell -Command ^
"Invoke-WebRequest 'https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main/update.ps1' ^
-OutFile 'C:\Scripts\update.ps1'" >nul 2>&1

:: =========================================
:: 🚀 AUTO RUN AS ADMIN
:: =========================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo =====================================
    echo   Dang khoi dong voi quyen Admin...
    echo =====================================
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: =========================================
:: CONFIG
:: =========================================
set LOG=C:\Scripts\clearn.log
set MODE=SAFE   :: SAFE hoặc FULL

if not exist C:\Scripts mkdir C:\Scripts

echo. >> %LOG%
echo ===== START CLEAN %date% %time% ===== >> %LOG%

:: =========================================
:: 1. CLEAN TEMP USER
:: =========================================
echo Cleaning USER TEMP...
echo Cleaning USER TEMP >> %LOG%
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
for /d %%i in ("%LOCALAPPDATA%\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: =========================================
:: 2. CLEAN WINDOWS TEMP
:: =========================================
echo Cleaning WINDOWS TEMP...
echo Cleaning WINDOWS TEMP >> %LOG%
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: =========================================
:: 3. EMPTY RECYCLE BIN
:: =========================================
echo Cleaning Recycle Bin...
echo Cleaning Recycle Bin >> %LOG%
powershell -command "Clear-RecycleBin -Force" >nul 2>&1

:: =========================================
:: 4. CLEAN BROWSER CACHE
:: =========================================
echo Cleaning Browser Cache...
echo Cleaning Browser Cache >> %LOG%

:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
)

:: Edge
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
)

:: =========================================
:: 5. FULL MODE (DỌN SÂU)
:: =========================================
if /I "%MODE%"=="FULL" (

    echo Running FULL CLEAN...
    echo Running FULL CLEAN >> %LOG%

    :: Stop Windows Update
    net stop wuauserv >nul 2>&1

    :: Clean update cache
    del /f /s /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%i" >nul 2>&1

    :: Start lại service
    net start wuauserv >nul 2>&1

    :: Prefetch (không nên chạy hàng ngày)
    echo Cleaning Prefetch >> %LOG%
    del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
)

:: =========================================
:: DONE
:: =========================================
echo ===== DONE %date% %time% ===== >> %LOG%
echo.
echo =====================================
echo   CLEAN HOAN TAT! MODE: %MODE%
echo =====================================
timeout /t 2 /nobreak >nul
exit /b
