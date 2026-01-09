$HostName = Read-Host -Prompt 'Enter a name for your container'

Set-Location $PSScriptRoot

$ScriptPath = Split-Path $PSScriptRoot -Parent
Write-Host "$ScriptPath"
$ScriptPath = Join-Path $ScriptPath "scripts\ap-nav-docker\navcontainerhelper\BCContainerHelper.ps1"
if (Test-Path $ScriptPath) {
    & $ScriptPath
    Write-Host "Loaded navcontainerhelper at path: $scriptPath"
}

function Get-InstallApp {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$containerName,
        [Parameter(Mandatory = $true)]
        [string]$packageFeed,
        [Parameter(Mandatory = $true)]
        [string]$package,
        [Parameter(Mandatory = $true)]
        [string]$version
    )

    $tempPath = Join-Path $PSScriptRoot "temp"
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -recurse -force
    }

    az artifacts universal download --organization https://dev.azure.com/archerpoint --feed $packageFeed --name $package --version $version --path $tempPath  --file-filter !*Test*.app "&" !*onprem*.app

    Get-ChildItem $tempPath -Filter *.app | ForEach-Object {

        $appFile = $_.FullName
        $folderFilter = '.alpackages'
        $appFolder = Split-Path $PSScriptRoot -Parent
        $alpackages = (Get-ChildItem -Path $appFolder -filter $folderFilter -Recurse).FullName
        if (Test-Path $alpackages) {
            Copy-Item $appFile -Destination $alpackages
        }

        if (![string]::IsNullOrEmpty($HostName)) {
            try {
                $appName = $appFile.Split('_')
                $params = @{ "containerName" = $HostName }
                $params += @{ "appName" = $appName[1] }
                $params += @{ "uninstall" = [switch]$true }
                Write-Host "Unpublishing $appName[1] on $HostName."
                UnPublish-NavContainerApp @params
            }
            catch {
                Write-Host 'Unable to Unpublish-NavContainerApp.'
            }

            $params = @{ "containerName" = $HostName }
            $params += @{ 'appfile' = $appFile }
            $params += @{ 'SkipVerification' = [switch]$true }
            $params += @{ 'sync' = [switch]$true }
            # $params += @{ 'syncMode' = 'Development' }
            $params += @{ 'install' = [switch]$true }
            $params += @{ 'packageType' = 'Extension' }
            Write-Host "Installing extension $appfile into $HostName."
            Publish-NavContainerApp @params

            try {
                $params = @{ "containerName" = $HostName }
                $params += @{ "appName" = $appName[1] }
                Start-NavContainerAppDataUpgrade @params
            }
            catch {
                Write-Host 'Unable to Start-NavContainerAppDataUpgrade.'
            }

            if (Test-Path $tempPath) {
                Remove-Item -Path $tempPath -recurse -force
            }
        }
    }
}

# Get-InstallApp -containerName $HostName -packageFeed 'alpackages' -package 'sen-common-al' -version '1.0.*'
Get-InstallApp -containerName $HostName -packageFeed 'alpackages' -package 'rpm-al' -version '1.0.10529'
# Get-InstallApp -containerName $HostName -packageFeed 'alpackages' -package 'rpm-job' -version '1.15.*'