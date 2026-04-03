# ============================================
# 🚀 Clearn Auto - Setup (FINAL CLEAN VERSION)0304 15h
# ============================================

# ===== CHECK ADMIN =====
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️ Hãy chạy PowerShell bằng quyền Administrator!" -ForegroundColor Red
    pause
    exit
}

# ===== CONFIG =====
$repoRaw   = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"
$taskName  = "ClearnAutoTask"

# ===== FILE LIST =====
$files = @(
    "clearn_auto.bat",
    "config.json",
    "update.ps1"
)

# ===== CREATE FOLDER =====
if (!(Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath -Force | Out-Null
}

# ===== DOWNLOAD & OVERWRITE =====
foreach ($file in $files) {
    $url = "$repoRaw/$file"
    $out = "$localPath\$file"

    try {
        Invoke-WebRequest -Uri $url -OutFile $out -TimeoutSec 5
        Write-Host "✅ Updated: $file"
    } catch {
        Write-Host "❌ Failed: $file" -ForegroundColor Red
        exit
    }
}

# ===== LOAD LOCAL CONFIG =====
$configPath = "$localPath\config.json"

if (!(Test-Path $configPath)) {
    Write-Host "❌ Missing config.json" -ForegroundColor Red
    exit
}

$config = Get-Content $configPath | ConvertFrom-Json

$cleanTime  = $config.clean_time
$updateTime = $config.update_time

# ===== VALIDATE =====
if (-not $cleanTime -or -not $updateTime) {
    Write-Host "❌ config.json thiếu clean_time/update_time" -ForegroundColor Red
    exit
}

# ===== CREATE / UPDATE TASK CLEAN =====
$mainScript = "$localPath\clearn_auto.bat"

$action1 = New-ScheduledTaskAction `
    -Execute "cmd.exe" `
    -Argument "/c `"$mainScript`" >> C:\Scripts\clearn.log 2>&1"

$trigger1 = New-ScheduledTaskTrigger -Daily -At $cleanTime

Register-ScheduledTask `
    -TaskName "$taskName-Main" `
    -Action $action1 `
    -Trigger $trigger1 `
    -RunLevel Highest `
    -Force

# ===== CREATE / UPDATE TASK UPDATE =====
$updateScript = "$localPath\update.ps1"

$action2 = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$updateScript`""

$trigger2 = New-ScheduledTaskTrigger -Daily -At $updateTime

Register-ScheduledTask `
    -TaskName "$taskName-Updater" `
    -Action $action2 `
    -Trigger $trigger2 `
    -RunLevel Highest `
    -Force

# ===== DONE =====
Write-Host ""
Write-Host "🎉 SETUP HOÀN TẤT" -ForegroundColor Green
Write-Host "📌 Clean: $cleanTime"
Write-Host "🔄 Update: $updateTime"
Write-Host "📂 Path: $localPath"
