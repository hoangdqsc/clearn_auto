# ===== CONFIG =====0304 15h
$repoRaw  = "https://raw.githubusercontent.com/hoangdqsc/clearn_auto/main"
$localPath = "C:\Scripts"
$logFile  = "$localPath\update.log"

# ===== LOG =====
function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append $logFile
}

# ===== LOAD CONFIG =====
function Get-LocalConfig {
    if (Test-Path "$localPath\config.json") {
        return Get-Content "$localPath\config.json" | ConvertFrom-Json
    }
    return $null
}

function Get-RemoteConfig {
    try {
        $json = (Invoke-WebRequest "$repoRaw/config.json").Content
        return $json | ConvertFrom-Json
    } catch {
        Log "Cannot load remote config"
        return $null
    }
}

$remote = Get-RemoteConfig
$local  = Get-LocalConfig

if (-not $remote) { exit }

# ===== UPDATE FILE =====
if (-not $local -or $remote.version -ne $local.version) {

    Log "Updating version $($local.version) -> $($remote.version)"

    Invoke-WebRequest "$repoRaw/clearn_auto.bat" -OutFile "$localPath\clearn_auto.bat"
    Invoke-WebRequest "$repoRaw/config.json" -OutFile "$localPath\config.json"
}

# ===== UPDATE TASK TIME =====
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

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$localPath\update.ps1`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $updateTime

    Register-ScheduledTask `
        -TaskName "ClearnAutoTask-Updater" `
        -Action $action `
        -Trigger $trigger `
        -RunLevel Highest `
        -Force
}
