Set-Location $PSScriptRoot
az artifacts universal download --organization https://dev.azure.com/archerpoint --feed "Scripts" --name "ap-nav-docker" --version "1.0.*" --path ./ap-nav-docker