# =========================================
# 🔄 Clearn Auto Updater (FINAL SILENT)
# =========================================

# ===== AUTO RE-RUN HIDDEN =====
if (-not $env:RUN_HIDDEN) {
    $env:RUN_HIDDEN = "1"

    Start-Process powershell.exe `
        -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -WindowStyle Hidden

    exit
}

# ===== CONFIG =====
$repoRaw   = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"
$logFile   = "$localPath\update.log"
$maxLogSize = 1MB

# ===== STATE =====
$updated = $false

# ===== ENSURE FOLDER =====
if (!(Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath | Out-Null
}

# ===== LOG =====
function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append $logFile
}

# ===== CHECK ADMIN =====
function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Log "❌ Not running as Administrator"
    exit
}

Log "🚀 Starting updater..."

# ===== LOG ROTATION =====
if (Test-Path $logFile) {
    $size = (Get-Item $logFile).Length
    if ($size -gt $maxLogSize) {
        $backup = "$localPath\update_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log"
        Rename-Item $logFile $backup

        $logs = Get-ChildItem "$localPath\update_*.log" | Sort-Object LastWriteTime -Descending
        if ($logs.Count -gt 5) {
            $logs | Select-Object -Skip 5 | Remove-Item
        }
    }
}

# ===== LOAD CONFIG =====
function Get-LocalConfig {
    try {
        if (Test-Path "$localPath\config.json") {
            return Get-Content "$localPath\config.json" | ConvertFrom-Json
        }
    } catch {
        Log "❌ Read local config failed"
    }
    return $null
}

function Get-RemoteConfig {
    try {
        $res = Invoke-WebRequest "$repoRaw/config.json" -UseBasicParsing
        return $res.Content | ConvertFrom-Json
    } catch {
        Log "❌ Load remote config failed"
        return $null
    }
}

# ===== DOWNLOAD =====
function Download-File($url, $output) {
    try {
        Invoke-WebRequest $url -OutFile $output -UseBasicParsing
        Log "Downloaded: $output"
        return $true
    } catch {
        Log "❌ Download failed: $url"
        return $false
    }
}

# ===== LOAD CONFIG =====
$remote = Get-RemoteConfig
$local  = Get-LocalConfig

if (-not $remote) {
    Log "❌ No remote config"
    exit
}

# ===== UPDATE FILE =====
if (-not $local -or $remote.version -ne $local.version) {

    $updated = $true
    Log "Updating version: $($local.version) -> $($remote.version)"

    $ok1 = Download-File "$repoRaw/clearn_auto.bat" "$localPath\clearn_auto.bat"
    $ok2 = Download-File "$repoRaw/config.json" "$localPath\config.json"

    if ($ok1 -and $ok2) {
        Log "Update success"
    } else {
        Log "⚠️ Update incomplete"
    }

} else {
    Log "Already latest version"
}

# ===== TASK =====
function Get-TaskTime($taskName) {
    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task -and $task.Triggers) {
            return ($task.Triggers[0].StartBoundary).Substring(11,5)
        }
    } catch {}
    return $null
}

function Create-Task($name, $exe, $args, $time) {
    try {
        $action  = New-ScheduledTaskAction -Execute $exe -Argument $args
        $trigger = New-ScheduledTaskTrigger -Daily -At $time

        Register-ScheduledTask `
            -TaskName $name `
            -Action $action `
            -Trigger $trigger `
            -RunLevel Highest `
            -Force

        Log "Task updated: $name"
    } catch {
        Log "❌ Task update failed: $name"
    }
}

$currentCleanTime  = Get-TaskTime "ClearnAutoTask-Main"
$currentUpdateTime = Get-TaskTime "ClearnAutoTask-Updater"

if ($remote.clean_time -ne $currentCleanTime) {
    $updated = $true
    Create-Task "ClearnAutoTask-Main" "cmd.exe" "/c `"$localPath\clearn_auto.bat`"" $remote.clean_time
}

if ($remote.update_time -ne $currentUpdateTime) {
    $updated = $true
    Create-Task "ClearnAutoTask-Updater" "powershell.exe" "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$localPath\update.ps1`"" $remote.update_time
}

Log "🏁 Finished"
