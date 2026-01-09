<#
.SYNOPSIS
Sets Local Environment Process Variables for local Docker
.DESCRIPTION

.EXAMPLE

#>

### Loads navcontainerhelper without having to install it as a module

$ScriptPath = Split-Path $PSScriptRoot -Parent
$ScriptPath = Join-Path $ScriptPath "navcontainerhelper\NavContainerHelper.ps1"
if (Test-Path $ScriptPath) {
    & $ScriptPath
    Write-Host "Loaded navcontainerhelper at path: $scriptPath"
}

$userHome = Join-Path $home .ap-nav-docker | Join-Path -ChildPath 'ap-nav-docker-globals.ps1'
if (Test-Path $userHome ) {
    & "$userHome"
}

[Environment]::SetEnvironmentVariable("imageName", "", "Process")

[Environment]::SetEnvironmentVariable("ArtifactType", "onprem", "Process")
[Environment]::SetEnvironmentVariable("ArtifactCountry", "na", "Process")
[Environment]::SetEnvironmentVariable("ArtifactVersion", "11.0.27667.0", "Process")
[Environment]::SetEnvironmentVariable("ArtifactSelect", "Closest", "Process")


### Name of the docker container.  This will also be used as the "machine" name
### 15 Character limit, no underscores or spaces
[Environment]::SetEnvironmentVariable("HostName", "RENTNA", "Process")
### Name of the SQL database instance and basis for files if moved outside of the NAV Container to the local file system
$dbname = $env:HostName
[Environment]::SetEnvironmentVariable("DatabaseName", "$dbname", "Process")

[Environment]::SetEnvironmentVariable("licenseFile", "https://approductdevelopment.blob.core.windows.net/license/APDEV.flf", "Process")

$dockerPath = Split-Path $PSScriptRoot -Parent
$dockerPath = Join-Path $dockerPath ".docker"
if (Test-Path $dockerPath) {
    [Environment]::SetEnvironmentVariable("workingfolder", "$dockerPath", "Process")
}

$calObjectPath = Split-Path $PSScriptRoot -Parent
$calObjectPath = Join-Path $calObjectPath "database\objects"
if (Test-Path $calObjectPath) {
    [Environment]::SetEnvironmentVariable("sourceControlFilesDirectory", "$calObjectPath", "Process")
}


$baseDirectory = Join-Path $env:workingfolder $env:HostName
$myfolder = Join-Path $baseDirectory "myfolder"
$databaseFilesDirectory = Join-Path $baseDirectory "dbfiles"
$pickupDirectory = Join-Path $baseDirectory "pickup"
$artifactsDirectory = Join-Path $baseDirectory "artifacts"
$importDataDirectory = Join-Path $baseDirectory  "data\rapidstart"
$dependObjectDirectory = Join-Path $baseDirectory  "dependencies\objects"
$navdbfiles = Join-Path $baseDirectory "navdbfiles"
$appProjectFolder = Join-Path $baseDirectory "appProjectFolder"
$navAppInstallDirectory = Join-Path $baseDirectory "navAppInstallDirectory"
# $sqlBakFileDirectory = Join-Path $baseDirectory "sqlBakFileDirectory"

[Environment]::SetEnvironmentVariable("myfolder", "$myfolder", "Process")
[Environment]::SetEnvironmentVariable("databaseFilesDirectory", $databaseFilesDirectory, "Process")
[Environment]::SetEnvironmentVariable("pickupDirectory", $pickupDirectory, "Process")
[Environment]::SetEnvironmentVariable("artifactsDirectory", $artifactsDirectory , "Process")
[Environment]::SetEnvironmentVariable("importDataDirectory", $importDataDirectory, "Process")
[Environment]::SetEnvironmentVariable("dependObjectDirectory", $dependObjectDirectory, "Process")
[Environment]::SetEnvironmentVariable("navdbfiles", $navdbfiles, "Process")
[Environment]::SetEnvironmentVariable("appProjectFolder", $appProjectFolder, "Process")
[Environment]::SetEnvironmentVariable("navAppInstallDirectory", $navAppInstallDirectory, "Process")
###
### Less Commonly used Settings
###

### Specify a docker network if you would like to use another network other than the default nat network
#[Environment]::SetEnvironmentVariable("network", "tlan", "Process")

### Pick NavUserPassword or Windows for the Authentication method.
### NavUserPassword will require NavUserName and NavUserPassword variables to be set
# [Environment]::SetEnvironmentVariable("auth", "NavUserPassword", "Process")
### Windows will require UserName and UserPassword
[Environment]::SetEnvironmentVariable("auth", "NavUserPassword", "Process")

### For use with NavUserPassword Authentication
[Environment]::SetEnvironmentVariable("NavUserName", "admin", "Process")
[Environment]::SetEnvironmentVariable("NavUserPassword", "admin", "Process")

### For use with Windows Authentication
[Environment]::SetEnvironmentVariable("UserName", "$env:USERNAME", "Process")
[Environment]::SetEnvironmentVariable("UserPassword", "", "Process")


### Will delete the container if it already exists
[Environment]::SetEnvironmentVariable("removeContainer", $True, "Process")
### Used for VSTS builds, signals that the container is to be removed on exit
[Environment]::SetEnvironmentVariable("isCIBuild", $false, "Process")
### Install ClickOnce Shortcuts
[Environment]::SetEnvironmentVariable("installClickOnce", "N", "Process")
### Use SQL Express within NAV Container
[Environment]::SetEnvironmentVariable("useSQLExpress", $True, "Process")
### Move SQL Database to volume shared with the host, yet also use SQL Exrpress within NAV Container
[Environment]::SetEnvironmentVariable("useHostForSQLExpress", $false, "Process")


[Environment]::SetEnvironmentVariable("includeCSide", $true, "Process")
[Environment]::SetEnvironmentVariable("doNotExportObjectsToText", $true, "Process")
[Environment]::SetEnvironmentVariable("enableSymbolLoading", $true, "Process")

### Used by the ExportObjects.ps1 command, refer to the link below for more advanced filtering
### https://docs.microsoft.com/en-us/dynamics-nav/exportobjects
[Environment]::SetEnvironmentVariable("objectExportFilter", "Modified=1", "Process")