#

function Prompt {
    $Cwd = "$(Split-Path -Path (Get-Location).Path -Leaf)"
    $Width = ($Host.UI.RawUI.WindowSize.Width - 2 - $Cwd.Length)
    $Divider = New-Object System.String @("-", $Width)
    Write-Host $Cwd $Divider -ForegroundColor Green
    $Identity = "$env:USERDOMAIN\$env:USERNAME".ToLower()
    Write-Host "[" -NoNewline
    Write-Host $Identity -ForegroundColor Cyan -NoNewline
    Write-Host "." -NoNewline
    Write-Host $env:COMPUTERNAME.ToLower() -ForegroundColor Cyan -NoNewline
    Write-Host "] " -NoNewline
    Write-Host (Get-PSSession).Count -ForegroundColor Red -NoNewline
    " > "
}


function Export-History {
    param (
        $Path = "C:\temp\history"
    )

    mkdir $Path -Force -EA 0 | Out-Null
    (Get-History).CommandLine | Out-File -FilePath "$Path\$((New-Guid).Guid).history.txt"
}


function Get-HomeDirectoryShare {
    <#
    .DESCRIPTION
        List shared directories containing user home directories.
    #>

    param (
        $Users = (Get-ADUser -Filter * -Properties HomeDirectory | ? HomeDirectory | select HomeDirectory)
    )

    # Creating array ahead of time instead of outputting to pipeline so we can sort and unique the results
    $HomeDirectoryShares = @()

    foreach ($User in $Users) {
        # Parsing home directory name from HomeDirectory attribute string in case
        # the home directory name != $User.SamAccountName
        # Not using Get-Item because it's slower and touches the filesystem
        $HomeDirectoryName = ($User.HomeDirectory -split "\\")[-1]

        # Return the home directory (without leading backslash)
        $HomeDirectoryShares += $User.HomeDirectory -replace "\\$HomeDirectoryName"
    }

    $HomeDirectoryShares | sort -Unique | Get-Item
}


function Find-HomeDirectoryOrphan {
    <#
    .DESCRIPTION
        Find home directories without a corresponding user in Active Directory.
    #>

    param (
        $Users = (Get-ADUser -Filter * -Properties HomeDirectory | ? HomeDirectory | select SamAccountName, HomeDirectory)
    )

    $HomeDirectoryServers = Get-HomeDirectoryShare -Users $Users

    foreach ($Server in $HomeDirectoryServers) {
        $HomeDirectories = ls $Server -Directory
        $HomeDirectories | ? { $_.Name -notin $Users.SamAccountName }
    }
}


function Copy-Signature {
    $signature = "Devyn Spencer
Sr. Technical Systems Administrator
Oregon Youth Authority  - Information Services"
    $signature | Set-Clipboard
}
