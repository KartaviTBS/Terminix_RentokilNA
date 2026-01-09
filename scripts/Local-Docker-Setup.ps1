<#
 .Synopsis
    Used to create a docker container based on preconfigured values (set in set.env.local.ps1) for the repository.
 .Description
 .Parameter
 .Example
#>

Param (
    [Parameter(Mandatory = $false)]
    $envFile = '',
    [Parameter(Mandatory = $false)]
    [string]$companyName
)

try {
    if ($psISE -ne $null) {
        $scriptRoot = Split-Path $psISE.CurrentFile.FullPath -Parent
    }
    else {
        $scriptRoot = $PSScriptRoot
    }
}
catch {
    $scriptRoot = $PSScriptRoot
}

Set-Location $scriptRoot
$ScriptPath = Split-Path $scriptRoot -Parent

# try {
#     Invoke-Expression "az --version" -ErrorVariable installed
# } catch {
#     if ($installed[0].ToString().Contains("is not recognized as the name of a cmdlet")) {
#         Write-Host "Installing Azure CLI. This may take a minute."
#         & "$scriptPath\scripts\Install-AzureCLI.ps1"
#     }
# }

# try {
#     Invoke-Expression "az extension show --name azure-devops --debug" -ErrorVariable installed
# } catch {
#     if ($installed[0].ToString().Contains("is not installed"))
#     {
#         Invoke-Expression "az extension add --name azure-devops"
#     }
# }

# & az login --allow-no-subscriptions
# Invoke-Expression "az artifacts universal download --organization `"https://dev.azure.com/archerpoint/`" --feed `"Scripts`" --name `"ap-nav-docker`" --version `"1.0.17458`" --path `"$scriptPath\scripts\ap-nav-docker`""


$ScriptPath = Join-Path $ScriptPath "scripts\ap-nav-docker\navcontainerhelper\BCContainerHelper.ps1"
if (Test-Path $ScriptPath) {
    & $ScriptPath
    Write-Host "Loaded navcontainerhelper at path: $scriptPath"
}

$envFile = 'set.env.local.ps1'

$ScriptPath = ''
$ScriptPath = Split-Path $scriptRoot -Parent
#$ScriptPath = Split-Path $PSScriptRoot
if ($envFile -ne '' ) {
    $envFilePath = Join-Path $ScriptPath "scripts"
    $envFile = Join-Path "$envFilePath" "$envFile"
    if (Test-Path $envFile) {
        Write-Host "Set Local Variables"
        & "$envFile"
    }
}

### Create a new NAV Container
if (!(Test-NavContainer -containerName $env:HostName)) {
    & "ap-nav-docker\docker-build.ps1"

    # & "ap-nav-docker\Import-TestToolkitToNavContainer.ps1" -includetestlibrariesonly -doNotUseRuntimePackages

    if (Test-Path $ScriptPath\RapidStart -PathType Container) {
        Copy-Item -Path "$ScriptPath\RapidStart\*" -Destination ${env:importDataDirectory} -Recurse -Force
        & "ap-nav-docker\Import-ConfigPackageInNavContainer.ps1"
    }

    ### Create a new empty Company
    & "ap-nav-docker\New-NavContainerCompany.ps1" -companyName 'rentokil'

    ### Add Fonts to Container
    & "ap-nav-docker\Add-FontsToNavContainer.ps1" -Path 'C:\Windows\Fonts\arial*.*'
    & "ap-nav-docker\Add-FontsToNavContainer.ps1" -Path 'C:\Windows\Fonts\segoe*.*'
} else {
    Write-Error "A container named $($env:HostName) already exists."
}

 if (Test-Path $ScriptPath\RapidStart -PathType Container) {
        Copy-Item -Path "$ScriptPath\RapidStart\*" -Destination ${env:importDataDirectory} -Recurse -Force
        & "ap-nav-docker\Import-ConfigPackageInNavContainer.ps1"
}