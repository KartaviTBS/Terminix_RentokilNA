$ServerInstance = 'nav110-test'
#$ServerInstance = 'nav110-prod'
$appName = "Surface Materials Customizations"


Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -WarningAction SilentlyContinue | out-null
Import-Module "$env:ProgramFiles\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1" -WarningAction SilentlyContinue | Out-Null
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1" -WarningAction SilentlyContinue | Out-Null

$appURL = 'https://approductdevelopment.blob.core.windows.net/customer/surf/surface-materials.zip'
$downloadFile = Join-Path $PSScriptRoot "download.zip"
$tempPath = Join-Path $PSScriptRoot "temp"

if (Test-Path $tempPath)
{
    Remove-Item -Path $tempPath -recurse -force
}

(New-Object System.Net.WebClient).DownloadFile($appURL, $downloadFile)

Expand-Archive -Path "$downloadFile" -DestinationPath $tempPath

UnInstall-NAVApp -ServerInstance $ServerInstance -Name $appName –Tenant default -verbose
UnPublish-NAVApp -ServerInstance $ServerInstance -Name $appName

Get-ChildItem -Path $tempPath -File -Filter "*.app" | ForEach-Object {     
    
    $appFile = $_.FullName    
    Publish-NAVApp -ServerInstance $ServerInstance -Path $appFile -verbose    
    Sync-NAVApp -ServerInstance $ServerInstance -Name $appName -Tenant default -verbose -force #-Mode Clean
    Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Name $appName
    Install-NAVApp -ServerInstance $ServerInstance -Name $appName –Tenant default -verbose
}

#if (Test-Path $tempPath)
#{
#    Remove-Item -Path $tempPath -recurse -force
#}