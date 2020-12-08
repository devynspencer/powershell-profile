function Get-OrphanProfile {
    param (
        [Parameter(Mandatory)]
        $ComputerName
    )

    $AccountNames = (Get-ADUser -Filter *).SamAccountName

    foreach ($Computer in $ComputerName) {
        $ProfileDirectories = Get-ChildItem -Path "\\$Computer\c$\Users" -Exclude "Public"

        foreach ($Profile in $ProfileDirectories) {
            if ($Profile.Name -notin $AccountNames) {
                $Profile
            }
        }
    }
}
