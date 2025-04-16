# Kiểm tra quyền Admin đúng cách
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $adminCheck) {
    Write-Host "⚠️ Vui lòng chạy PowerShell với quyền Administrator." -ForegroundColor Red
    exit
}

# URL cố định – không cần người dùng nhập
$scriptUrl = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main/full_cleanup.bat"
$savePath = "C:\Scripts"
$fileName = "full_cleanup.bat"

# Tạo thư mục nếu chưa tồn tại
if (-not (Test-Path $savePath)) {
    New-Item -ItemType Directory -Path $savePath -Force
}

# Tải và chạy file
Invoke-WebRequest -Uri $scriptUrl -OutFile "$savePath\$fileName"
Start-Process -FilePath "$savePath\$fileName" -Verb RunAs
