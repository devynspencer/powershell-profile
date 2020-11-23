#

function Export-History {
    param (
        $Path = "C:\temp\history"
    )

    mkdir $Path -Force -EA 0 | Out-Null
    (Get-History).CommandLine | Out-File -FilePath "$Path\$((New-Guid).Guid).history.txt"
}
