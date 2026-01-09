<#
 .Synopsis
   Installs and Configures Azure CLI and azure-devops extension
 .Description
  https://github.com/Azure/azure-devops-cli-extension

 .Exampe Usage
  az artifacts universal download --organization https://dev.azure.com/archerpoint --feed alpackages --name sen-common-al --version 1.0.6666 --path ./alpackages
#>

###
###  Install Azure CLI
###
try 
{    
    if ($psISE -ne $null)
    {
        $scriptRoot = Split-Path $psISE.CurrentFile.FullPath -Parent
    }
    else
    {
        $scriptRoot = $PSScriptRoot
    }
}
catch 
{
    $scriptRoot = $PSScriptRoot
}

$appURL = 'https://aka.ms/installazurecliwindows'
$fileName = 'azure-cli.msi'
$downloadFile = Join-Path $scriptRoot $fileName
$organization = 'https://dev.azure.com/archerpoint'
$project = 'master'

# if (Test-Path $downloadFile) {
#     Remove-Item -Path $downloadFile -recurse -force
# }

#(New-Object System.Net.WebClient).DownloadFile($appURL, $downloadFile)

#& cmd /c "msiexec.exe /i $downloadFile"

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

#Remove-Item -Path $downloadFile


###
### Add azure-devops extension to Azure CLI
###

az extension add --name azure-devops
# az extension update --name azure-devops

# Configure your account to log into azure devops
# Will pop up a log in dialog in the web browser
#az login

#az devops configure --defaults organization=$organization project=$project

#
#  Only need this last step if you have subscription errors
#
# https://dev.azure.com/archerpoint/Master/_workitems/edit/3230/
#az cloud set -n AzureCloud
#Login-AzAccount
