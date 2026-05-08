function Get-NetCompartment {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetCompartment is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetCompartment @PSBoundParameters
    }
}
