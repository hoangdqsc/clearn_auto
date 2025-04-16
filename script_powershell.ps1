# Kiểm tra quyền Admin
if (-NOT [System.Security.Principal.WindowsIdentity]::GetCurrent().IsSystem) {
    Write-Host "Cần quyền Administrator. Vui lòng chạy lại với quyền Admin."
    exit
}

# Yêu cầu người dùng nhập URL của script muốn tải về
$scriptUrl = Read-Host "Nhập URL của script .bat (ví dụ: https://raw.githubusercontent.com/username/cleanup-scripts/main/full_cleanup.bat)"

# Kiểm tra nếu URL hợp lệ
if ($scriptUrl -match "^https://.*\.bat$") {
    # Đường dẫn lưu trữ trên máy tính
    $savePath = "C:\Scripts"
    $fileName = [System.IO.Path]::GetFileName($scriptUrl)

    # Tạo thư mục nếu chưa tồn tại
    if (-not (Test-Path -Path $savePath)) {
        New-Item -ItemType Directory -Path $savePath
    }

    # Tải file từ URL
    Write-Host "Đang tải file từ URL..."
    Invoke-WebRequest -Uri $scriptUrl -OutFile "$savePath\$fileName"

    Write-Host "File đã được tải về: $savePath\$fileName"

    # Chạy script tải về với quyền Admin
    Write-Host "Đang chạy script..."
    Start-Process -FilePath "$savePath\$fileName" -Verb RunAs

    Write-Host "Cài đặt hoàn tất! Đã chạy script thành công."
} else {
    Write-Host "URL không hợp lệ. Vui lòng kiểm tra lại."
}
