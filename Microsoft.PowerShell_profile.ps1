#

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

    $HomeDirectoryShares | sort -Unique
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
