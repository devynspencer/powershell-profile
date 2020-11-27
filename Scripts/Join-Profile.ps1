$Files = ls -Path "$PSScriptRoot\Functions" -Recurse -Filter *.ps1
$DateSlug = (Get-Date).ToString('yyyyMd')
$ExportFileName = "$DateSlug-$(New-Guid).Profile.ps1"

# Combine individual functions from files and export into new file
$Files | Get-Content | Out-File -FilePath $ExportFileName
