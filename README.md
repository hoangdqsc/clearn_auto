# Clearn Auto – 1 Click Cleanup & Auto Update Tool

Clearn Auto là công cụ tự động dọn dẹp máy tính (cleanup) và tự cập nhật script từ GitHub.  
Hỗ trợ **1 click cài đặt**, chạy tự động, không cần PowerShell thủ công.

---

## 🚀 Tính năng

- Tải và lưu `clearn_auto.bat` vào `C:\Scripts`  
- Tạo **Task Scheduler**:
  - **Cleanup**: chạy mỗi ngày 9:00 AM
  - **Auto Update**: chạy mỗi ngày 10:00 AM
- Tự động cập nhật script nếu GitHub có version mới (`version.txt`)  
- Ghi log hoạt động vào `C:\Scripts\clearn.log`  
- Hỗ trợ chạy 1 click bằng file `.exe` (convert từ PowerShell bằng PS2EXE)

---

## 📦 Cài đặt & sử dụng

### 1️⃣ Tải file setup

Clone repo hoặc tải trực tiếp `setup.ps1`:

powershell
git clone https://github.com/<username>/clearn_auto.git
