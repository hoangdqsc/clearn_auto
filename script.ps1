# ============================================
# 🚀 Clearn Auto - One Click Setup (Full)
# ============================================

# Muốn chạy file này hãy mở powerShell quyển quản trị viên và dán code sau: powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\script.ps1"


# ===== Kiểm tra Admin =====
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️ Hãy chạy PowerShell bằng quyền Administrator!" -ForegroundColor Red
    pause
    exit
}

# ===== CONFIG =====
$repoRaw = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"
$mainFile = "clearn_auto.bat"
$versionFile = "version.txt"
$taskName = "ClearnAutoTask"

# ===== Tạo thư mục =====
if (!(Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath -Force | Out-Null
}

# ===== Hàm tải file =====
function Download-File($fileName) {
    $url = "$repoRaw/$fileName"
    $out = "$localPath\$fileName"

    try {
        Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
        if ((Test-Path $out) -and ((Get-Item $out).Length -gt 0)) {
            Write-Host "✅ $fileName OK"
        } else {
            throw "File lỗi"
        }
    } catch {
        Write-Host "❌ Lỗi tải $fileName" -ForegroundColor Red
        exit
    }
}

# ===== Tải file chính và version =====
Download-File $mainFile
Download-File $versionFile

# ===== Tạo script updater =====
$updaterPath = "$localPath\update.ps1"

@"
`$repoRaw = "$repoRaw"
`$localPath = "$localPath"

function Get-RemoteVersion {
    try {
        return (Invoke-WebRequest "`$repoRaw/version.txt" -UseBasicParsing).Content.Trim()
    } catch { return "" }
}

function Get-LocalVersion {
    if (Test-Path "`$localPath\version.txt") {
        return (Get-Content "`$localPath\version.txt").Trim()
    }
    return ""
}

`$remote = Get-RemoteVersion
`$local = Get-LocalVersion

if (`$remote -ne "" -and `$remote -ne `$local) {
    Write-Output "Updating..."
    Invoke-WebRequest "`$repoRaw/clearn_auto.bat" -OutFile "`$localPath\clearn_auto.bat"
    Invoke-WebRequest "`$repoRaw/version.txt" -OutFile "`$localPath\version.txt"
}
"@ | Out-File -Encoding UTF8 $updaterPath

# ===== Tạo Task Cleanup =====
$mainScript = "$localPath\clearn_auto.bat"

$action1 = New-ScheduledTaskAction `
    -Execute "cmd.exe" `
    -Argument "/c `"$mainScript`" >> C:\Scripts\clearn.log 2>&1"

$trigger1 = New-ScheduledTaskTrigger -Daily -At 9:00AM

# ===== Tạo Task Auto Update =====
$action2 = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$updaterPath`""

$trigger2 = New-ScheduledTaskTrigger -Daily -At 10:00AM

# ===== Xóa Task cũ nếu tồn tại =====
Get-ScheduledTask -TaskName "$taskName*" -ErrorAction SilentlyContinue | 
    Unregister-ScheduledTask -Confirm:$false

# ===== Register Task =====
Register-ScheduledTask `
    -TaskName "$taskName-Main" `
    -Action $action1 `
    -Trigger $trigger1 `
    -RunLevel Highest `
    -User $env:USERNAME

Register-ScheduledTask `
    -TaskName "$taskName-Updater" `
    -Action $action2 `
    -Trigger $trigger2 `
    -RunLevel Highest `
    -User $env:USERNAME

# ===== DONE =====
Write-Host ""
Write-Host "🎉 CÀI ĐẶT HOÀN TẤT!" -ForegroundColor Green
Write-Host "📌 Cleanup chạy: 9:00 AM mỗi ngày"
Write-Host "🔄 Auto update: 10:00 AM mỗi ngày"
Write-Host "📂 Thư mục: $localPath"
