# =========================================
# 🔄 Clearn Auto Updater (Refactored)
# =========================================

# ===== CONFIG =====
$repoRaw   = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"
$logFile   = "$localPath\update.log"
$maxLogSize = 1MB

# ===== ENSURE FOLDER =====
if (!(Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath | Out-Null
}

# ===== LOG FUNCTION =====
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
    Log "❌ Script not running as Administrator"
    exit
}

# ===== LOG ROTATION =====
function Rotate-Log {
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
}

Rotate-Log

# ===== LOAD CONFIG =====
function Get-LocalConfig {
    try {
        if (Test-Path "$localPath\config.json") {
            return Get-Content "$localPath\config.json" | ConvertFrom-Json
        }
    } catch {
        Log "❌ Failed to read local config"
    }
    return $null
}

function Get-RemoteConfig {
    try {
        $res = Invoke-WebRequest "$repoRaw/config.json" -UseBasicParsing
        return $res.Content | ConvertFrom-Json
    } catch {
        Log "❌ Cannot load remote config"
        return $null
    }
}

# ===== DOWNLOAD FILE =====
function Download-File($url, $output) {
    try {
        Invoke-WebRequest $url -OutFile $output -UseBasicParsing
        Log "✅ Downloaded: $output"
        return $true
    } catch {
        Log "❌ Failed to download: $url"
        return $false
    }
}

# ===== LOAD CONFIG =====
$remote = Get-RemoteConfig
$local  = Get-LocalConfig

if (-not $remote) {
    Log "❌ Remote config unavailable. Exit."
    exit
}

# ===== UPDATE FILES =====
if (-not $local -or $remote.version -ne $local.version) {

    Log "🔄 Updating version: $($local.version) -> $($remote.version)"

    $ok1 = Download-File "$repoRaw/clearn_auto.bat" "$localPath\clearn_auto.bat"
    $ok2 = Download-File "$repoRaw/config.json" "$localPath\config.json"

    if ($ok1 -and $ok2) {
        Log "✅ Update completed successfully"
    } else {
        Log "⚠️ Update may be incomplete"
    }
}

# ===== GET TASK TIME =====
function Get-TaskTime($taskName) {
    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task -and $task.Triggers) {
            return ($task.Triggers[0].StartBoundary).Substring(11,5)
        }
    } catch {}
    return $null
}

# ===== CREATE TASK =====
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

        Log "✅ Task updated: $name at $time"
    } catch {
        Log "❌ Failed to update task: $name"
    }
}

# ===== SYNC TASKS =====
$currentCleanTime  = Get-TaskTime "ClearnAutoTask-Main"
$currentUpdateTime = Get-TaskTime "ClearnAutoTask-Updater"

$cleanTime  = $remote.clean_time
$updateTime = $remote.update_time

# CLEAN TASK
if ($cleanTime -ne $currentCleanTime) {
    Log "🔄 Sync CLEAN task: $currentCleanTime -> $cleanTime"

    Create-Task `
        "ClearnAutoTask-Main" `
        "cmd.exe" `
        "/c `"$localPath\clearn_auto.bat`"" `
        $cleanTime
}

# UPDATE TASK
if ($updateTime -ne $currentUpdateTime) {
    Log "🔄 Sync UPDATER task: $currentUpdateTime -> $updateTime"

    Create-Task `
        "ClearnAutoTask-Updater" `
        "powershell.exe" `
        "-ExecutionPolicy Bypass -File `"$localPath\update.ps1`"" `
        $updateTime
}

Log "🏁 Script finished"
