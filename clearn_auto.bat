# ============================================
# 🚀 Clearn Auto PRO - Safe & Optimized apdate 27/03/2026
# ============================================

# ===== AUTO RUN AS ADMIN =====
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "🔄 Restarting with Administrator rights..."
    
    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    
    exit
}
# ===== CONFIG =====
$localPath = "C:\Scripts"
$logFile = "$localPath\clearn.log"
$mode = "SAFE"   # SAFE or FULL

# ===== CREATE FOLDER =====
if (!(Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath -Force | Out-Null
}

# ===== LOG FUNCTION =====
function Write-Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append $logFile
}

Write-Log "===== START CLEAN ====="

# ===== 1. CLEAN USER TEMP =====
Write-Log "Cleaning USER TEMP"
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# ===== 2. CLEAN WINDOWS TEMP =====
Write-Log "Cleaning WINDOWS TEMP"
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# ===== 3. EMPTY RECYCLE BIN =====
Write-Log "Cleaning Recycle Bin"
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# ===== 4. CLEAN BROWSER CACHE =====
Write-Log "Cleaning Browser Cache"
Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# ===== 5. FULL MODE EXTRA =====
if ($mode -eq "FULL") {
    Write-Log "Running FULL cleanup"

    # Stop Windows Update
    net stop wuauserv | Out-Null

    # Clean update cache
    Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Start again
    net start wuauserv | Out-Null

    # Optional Prefetch (weekly only recommended)
    Write-Log "Cleaning Prefetch"
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Log "===== DONE CLEAN ====="
Write-Host "✅ Cleanup completed! Mode: $mode" -ForegroundColor Green
