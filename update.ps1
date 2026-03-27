# =========================================
# 🔄 Clearn Auto Updater
# =========================================

$repoRaw = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"

function Get-RemoteVersion {
    try {
        return (Invoke-WebRequest "$repoRaw/version.txt" -UseBasicParsing).Content.Trim()
    } catch {
        return ""
    }
}

function Get-LocalVersion {
    if (Test-Path "$localPath\version.txt") {
        return (Get-Content "$localPath\version.txt").Trim()
    }
    return ""
}

$remote = Get-RemoteVersion
$local = Get-LocalVersion

if ($remote -eq "") {
    Write-Output "❌ Cannot check version"
    exit
}

if ($remote -ne $local) {
    Write-Output "🔄 Updating to version $remote..."

    try {
        Invoke-WebRequest "$repoRaw/clearn_auto.bat" -OutFile "$localPath\clearn_auto.bat"
        Invoke-WebRequest "$repoRaw/version.txt" -OutFile "$localPath\version.txt"

        Write-Output "✅ Update completed!"
    } catch {
        Write-Output "❌ Update failed"
    }
} else {
    Write-Output "✔ Already latest version"
}
