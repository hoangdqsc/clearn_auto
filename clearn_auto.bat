@echo off
setlocal enabledelayedexpansion

:: =========================================
:: 📺 1. CĂN GIỮA MÀN HÌNH & THIẾT LẬP KÍCH THƯỚC
:: =========================================
:: Thiết lập kích thước trước: 70 cột x 15 dòng
mode con: cols=70 lines=15

:: Gọi PowerShell để đưa cửa sổ ra chính giữa màn hình
powershell -Command "$w=Get-Host; $r=$w.UI.RawUI; $s=(Get-WmiObject Win32_VideoController).CurrentHorizontalResolution, (Get-WmiObject Win32_VideoController).CurrentVerticalResolution; $app=$Visual:Window; $size=$r.WindowSize; $pos=$r.WindowPosition; $pos.X=[math]::Max(0, [int](($s[0]-70*8)/2)); $pos.Y=[math]::Max(0, [int](($s[1]-25*16)/2)); $r.WindowPosition=$pos" >nul 2>&1

title CONG CU TOI UU HE THONG - UJU VINA IT

:: =========================================
:: 📋 2. LOG ROTATION (GIỮ NGUYÊN)
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
:: 🚀 3. AUTO RUN AS ADMIN (GIAO DIỆN CẢI TIẾN)
:: =========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    color 0E
    echo.
    echo    =========================================================
    echo       DANG KHOI DONG VOI QUYEN ADMIN...
    echo    =========================================================
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: =========================================
:: 🔄 4. UPDATE SCRIPT (GIỮ NGUYÊN LOGIC GITHUB)
:: =========================================
cls
color 0B
echo.
echo    =========================================================
echo       DANG KIEM TRA BAN CAP NHAT...
echo    =========================================================
echo.
echo    [*] Dang kiem tra phien ban moi tu Server...

powershell -NoProfile -Command ^
"try { ^
    $ProgressPreference='SilentlyContinue'; ^
    $url='https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main/update.ps1'; ^
    $out='C:\Scripts\update.ps1'; ^
    Invoke-WebRequest $url -OutFile $out -TimeoutSec 2 ^
} catch { }"

:: =========================================
:: ⚙️ 5. CONFIG & INITIALIZE
:: =========================================
set MODE=SAFE
if exist C:\Scripts\config.json (
    for /f %%i in ('powershell -NoProfile -Command "(Get-Content 'C:\Scripts\config.json' | ConvertFrom-Json).mode"') do set MODE=%%i
)
if not exist C:\Scripts mkdir C:\Scripts

echo. >> %LOG%
echo ===== START CLEAN %date% %time% MODE=%MODE% ===== >> %LOG%

:: =========================================
:: 🧹 6. MAIN PROGRESS (CĂN LỀ TRÁI 3 KHOẢNG TRẮNG)
:: =========================================

:: Bước 1: User Temp
cls
echo.
echo    =========================================================
echo       CONG CU TOI UU HE THONG - UJU VINA IT
echo    =========================================================
echo.
echo    [Buoc 1/4] Dang don dep tep tam (User Temp)...
echo    [###-------] 25%%
echo Cleaning USER TEMP >> %LOG%
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
for /d %%i in ("%LOCALAPPDATA%\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: Bước 2: Windows Temp
cls
echo.
echo    =========================================================
echo       CONG CU TOI UU HE THONG - UJU VINA IT
echo    =========================================================
echo.
echo    [Buoc 2/4] Dang xoa bo nho dem Windows...
echo    [#####-----] 50%%
echo Cleaning WINDOWS TEMP >> %LOG%
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1

:: Bước 3: Recycle Bin
cls
echo.
echo    =========================================================
echo       CONG CU TOI UU HE THONG - UJU VINA IT
echo    =========================================================
echo.
echo    [Buoc 3/4] Dang lam trong Thung rac...
echo    [#######---] 75%%
echo Cleaning Recycle Bin >> %LOG%
powershell -command "Clear-RecycleBin -Force" >nul 2>&1

:: Bước 4: Browser Cache
cls
echo.
echo    =========================================================
echo       CONG CU TOI UU HE THONG - UJU VINA IT
echo    =========================================================
echo.
echo    [Buoc 4/4] Dang xoa Cache trinh duuyet...
echo    [#########-] 95%%
echo Cleaning Browser Cache >> %LOG%
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
)

:: =========================================
:: 🚀 7. FULL MODE (DỌN SÂU - GIỮ NGUYÊN LOGIC)
:: =========================================
if /I "%MODE%"=="FULL" (
    cls
    echo.
    echo    =========================================================
    echo       DANG CHAY CHE DO DON DEP SAU (FULL MODE)
    echo    =========================================================
    echo.
    echo    [*] Dang tam dung Windows Update Service...
    echo Running FULL CLEAN >> %LOG%

    net stop wuauserv >nul 2>&1
    del /f /s /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%i" >nul 2>&1
    net start wuauserv >nul 2>&1

    echo    [*] Dang don dep Windows Prefetch...
    echo Cleaning Prefetch >> %LOG%
    del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
)

:: =========================================
:: ✅ 8. DONE
:: =========================================
echo ===== DONE %date% %time% ===== >> %LOG%
cls
color 0A
echo.
echo    =========================================================
echo       DON DEP HOAN TAT! CHUC BAN LAM VIEC TOT
echo    =========================================================
echo.
echo       [+] Trang thai: Thanh cong
echo       [+] Che do: %MODE%
echo       [+] Cap nhat: 27-03-2026 (UJU VINA IT)
echo.
echo    =========================================================
echo    Cua so tu dong dong sau 5 giay...
timeout /t 5 /nobreak >nul
exit /b
