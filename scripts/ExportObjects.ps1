Param (
    [Parameter(Mandatory = $false)]
    $envFile = '',
    [Parameter(Mandatory = $false)]
    [string]$companyName
)

Set-Location $PSScriptRoot

$ScriptPath = Split-Path $PSScriptRoot -Parent
$ScriptPath = Join-Path $ScriptPath "scripts\ap-nav-docker\navcontainerhelper\BCContainerHelper.ps1"
if (Test-Path $ScriptPath) {
    & $ScriptPath
    Write-Host "Loaded navcontainerhelper at path: $scriptPath"
}

$envFile = 'set.env.local.ps1'

$ScriptPath = ''
$ScriptPath = Split-Path $PSScriptRoot -Parent
if ($envFile -ne '' ) {
    $envFilePath = Join-Path $ScriptPath "scripts"
    $envFile = Join-Path "$envFilePath" "$envFile"
    if (Test-Path $envFile) {
        Write-Host "Set Local Variables"
        & "$envFile"
    }
}

& "ap-nav-docker\ExportTextObjectsToSource.ps1"