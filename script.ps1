# Kiểm tra quyền Administrator
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $adminCheck) {
    Write-Host "⚠️ Vui lòng chạy PowerShell với quyền Administrator." -ForegroundColor Red
    exit
}

# Thông tin repo GitHub
$baseUrl = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
//$localPath = [System.IO.Path]::Combine($env:USERPROFILE, "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup")
$localPath = "C:\Scripts"
# Tạo thư mục nếu chưa có
if (-not (Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath -Force
}

# Đường dẫn tệp cần tải
$file = "clearn_auto.bat"
$url = "$baseUrl/$file"
$outFile = "$localPath\$file"

# Tải tệp
Invoke-WebRequest -Uri $url -OutFile $outFile

Write-Host "✅ Đã tải tệp clearn_auto.bat và lưu vào thư mục Startup." -ForegroundColor Green
