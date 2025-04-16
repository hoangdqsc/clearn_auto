# Kiểm tra quyền Administrator
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $adminCheck) {
    Write-Host "⚠️ Vui lòng chạy PowerShell với quyền Administrator." -ForegroundColor Red
    exit
}

# Thông tin repo GitHub
$baseUrl = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"

# Tạo thư mục nếu chưa có
if (-not (Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath -Force
}

# Danh sách các file cần tải
$files = @("clearn_auto.bat", "scheduler_clearn.bat")

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $outFile = "$localPath\$file"
    Invoke-WebRequest -Uri $url -OutFile $outFile
}

# Thực thi file scheduler (tạo tác vụ khởi động)
Start-Process -FilePath "$localPath\scheduler_clearn.bat" -Verb RunAs

Write-Host "✅ Đã tải và thiết lập xong. Máy sẽ tự động dọn rác khi khởi động." -ForegroundColor Green
