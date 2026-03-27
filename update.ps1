# =========================================
# 🔄 Clearn Auto Updater PRO
# =========================================

$repoRaw = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"
$logFile = "$localPath\update.log"

# ===== LOG =====
function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append $logFile
}

# ===== READ CONFIG =====
function Get-Config($path) {
    $config = @{}
    if (Test-Path $path) {
        $lines = Get-Content $path
        foreach ($line in $lines) {
            if ($line -match "=") {
                $k,$v = $line -split "="
                $config[$k.Trim()] = $v.Trim()
            }
        }
    }
    return $config
}

function Get-RemoteConfig {
    $config = @{}
    try {
        $lines = (Invoke-WebRequest "$repoRaw/version.txt").Content -split "`n"
        foreach ($line in $lines) {
            if ($line -match "=") {
                $k,$v = $line -split "="
                $config[$k.Trim()] = $v.Trim()
            }
        }
    } catch {}
    return $config
}

$remote = Get-RemoteConfig
$local  = Get-Config "$localPath\version.txt"

# ===== UPDATE FILE =====
if ($remote.version -ne $local.version) {

    Log "Updating version $($local.version) -> $($remote.version)"

    Invoke-WebRequest "$repoRaw/clearn_auto.bat" -OutFile "$localPath\clearn_auto.bat"
    Invoke-WebRequest "$repoRaw/version.txt" -OutFile "$localPath\version.txt"
}

# ===== UPDATE TASK (KHÔNG XÓA) =====
$cleanTime  = $remote.clean_time
$updateTime = $remote.update_time

$taskMain   = Get-ScheduledTask -TaskName "ClearnAutoTask-Main" -ErrorAction SilentlyContinue
$taskUpdate = Get-ScheduledTask -TaskName "ClearnAutoTask-Updater" -ErrorAction SilentlyContinue

$currentCleanTime  = $null
$currentUpdateTime = $null

if ($taskMain) {
    $currentCleanTime = ($taskMain.Triggers[0].StartBoundary).Substring(11,5)
}
if ($taskUpdate) {
    $currentUpdateTime = ($taskUpdate.Triggers[0].StartBoundary).Substring(11,5)
}

# ===== UPDATE CLEAN TASK =====
if ($cleanTime -ne $currentCleanTime) {

    Log "Update CLEAN: $currentCleanTime -> $cleanTime"

    $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$localPath\clearn_auto.bat`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $cleanTime

    Register-ScheduledTask `
        -TaskName "ClearnAutoTask-Main" `
        -Action $action `
        -Trigger $trigger `
        -RunLevel Highest `
        -Force
}

# ===== UPDATE UPDATE TASK =====
if ($updateTime -ne $currentUpdateTime) {

    Log "Update UPDATER: $currentUpdateTime -> $updateTime"

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$localPath\update.ps1`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $updateTime

    Register-ScheduledTask `
        -TaskName "ClearnAutoTask-Updater" `
        -Action $action `
        -Trigger $trigger `
        -RunLevel Highest `
        -Force
}
