@echo off
setlocal enabledelayedexpansion
title HE THONG TOI UU MAY TINH TU DONG - UJU VINA IT

:: =========================================
:: 📋 1. LOG ROTATION31
:: =========================================
set LOG=C:\Scripts\clearn.log
if exist %LOG% (
    for %%A in (%LOG%) do (
        if %%~zA gtr 1048576 (
            echo Log too big, resetting...
            del %LOG%
        )
    )
)

:: =========================================
:: 🚀 2. AUTO RUN AS ADMIN (GIAO DIÊN CẢI TIẾN)
:: =========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    color 0E
    echo.
    echo  =====================================================
    echo     DANG KHOI DONG VOI QUYEN ADMIN...
    echo  =====================================================
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: =========================================
:: 🔄 3. UPDATE SCRIPT (GIỮ NGUYÊN LOGIC GITHUB)
:: =========================================
cls
color 0B
echo.
echo  =====================================================
echo     DANG KIEM TRA BAN CAP NHAT...
echo  =====================================================
echo Checking update for updater...

powershell -NoProfile -Command ^
"try { ^
    $ProgressPreference='SilentlyContinue'; ^
    $url='https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main/update.ps1'; ^
    $out='C:\Scripts\update.ps1'; ^
    Invoke-WebRequest $url -OutFile $out -TimeoutSec 2 ^
} catch { }"

:: =========================================
:: ⚙️ 4. CONFIG & INITIALIZE Đọc Mode từ config
:: =========================================
set MODE=SAFE
if exist C:\Scripts\config.json (
    for /f %%i in ('powershell -NoProfile -Command "(Get-Content 'C:\Scripts\config.json' | ConvertFrom-Json).mode"') do set MODE=%%i
)
if not exist C:\Scripts mkdir C:\Scripts

echo. >> %LOG%
echo ===== START CLEAN %date% %time% MODE=%MODE% ===== >> %LOG%

:: =========================================
:: 🧹 5. MAIN CLEANING PROGRESS (GIAO DIỆN TRỰC QUAN)
:: =========================================

:: Bước 1: User Temp
cls
echo.
echo  =====================================================
echo     CONG CU TOI UU HE THONG - UJU VINA
echo  =====================================================
echo  [Step 1/4] Dang don dep tep tam (User Temp)...
echo  [###-------] 25%%
echo Cleaning USER TEMP >> %LOG%
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
for /d %%i in ("%LOCALAPPDATA%\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: Bước 2: Windows Temp
cls
echo.
echo  =====================================================
echo     CONG CU TOI UU HE THONG - UJU VINA
echo  =====================================================
echo  [Step 2/4] Dang xoa bo nho dem Windows...
echo  [#####-----] 50%%
echo Cleaning WINDOWS TEMP >> %LOG%
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: Bước 3: Recycle Bin
cls
echo.
echo  =====================================================
echo     CONG CU TOI UU HE THONG - UJU VINA
echo  =====================================================
echo  [Step 3/4] Dang lam trong Thung rac...
echo  [#######---] 75%%
echo Cleaning Recycle Bin >> %LOG%
powershell -command "Clear-RecycleBin -Force" >nul 2>&1

:: Bước 4: Browser Cache
cls
echo.
echo  =====================================================
echo     CONG CU TOI UU HE THONG - UJU VINA
echo  =====================================================
echo  [Step 4/4] Dang xoa Cache trinh duyet...
echo  [#########-] 95%%
echo Cleaning Browser Cache >> %LOG%
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
)

:: =========================================
:: 🚀 6. FULL MODE (DỌN SÂU - GIỮ NGUYÊN LOGIC SERVICE)
:: =========================================
if /I "%MODE%"=="FULL" (
    cls
    echo.
    echo  =====================================================
    echo     DANG CHAY CHE DO DON DEP SAU (FULL MODE)
    echo  =====================================================
    echo  [*] Dang tam dung Windows Update Service...
    echo Running FULL CLEAN >> %LOG%

    net stop wuauserv >nul 2>&1
    del /f /s /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%i" >nul 2>&1
    net start wuauserv >nul 2>&1

    echo Cleaning Prefetch >> %LOG%
    del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
)

:: =========================================
:: ✅ 7. DONE
:: =========================================
echo ===== DONE %date% %time% ===== >> %LOG%
cls
color 0A
echo.
echo  ==========================================
echo  HOAN TAT! MAY TINH CUA BAN DA DUOC DON DEP
echo  ==========================================
echo
echo    [+] Trang thai: Thanh cong
echo    [+] Che do: %MODE%
echo    [+] May tinh da duoc toi uu hoa.
echo    
echo  =====================================
echo.
echo Dang tu dong dong sau 4 giay...
timeout /t 3 /nobreak >nul
exit /b
